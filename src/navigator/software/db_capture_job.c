#include "db_capture_job.h"
#include "db_config.h"
#include "db_copy.h"
#include "db_log.h"
#include "xaxivdma_hw.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "xparameters.h"
#include <string.h>
static int tag(DbCaptureJob *j,unsigned c,uint32_t *sequence,uint32_t *stamp)
{
    uint32_t a=XGpio_DiscreteRead(&j->tag[c],1);
    *stamp=XGpio_DiscreteRead(&j->tag[c],2);*sequence=XGpio_DiscreteRead(&j->tag[c],1);
    return a==*sequence && a!=0;
}
/* PG020: SOF/EOL size errors are sticky even when S2MM keeps running.
 * Bit 4 is recoverable ONLY together with a frame-size error and RS=1.
 * Never reset a channel or reclaim an in-flight PS DMA destination here. */
#define CAPTURE_SIZE_ERRORS (0x00008000U | XAXIVDMA_SR_ERR_FSZ_LESS_MASK | \
    XAXIVDMA_SR_ERR_LSZ_LESS_MASK | XAXIVDMA_SR_ERR_FSZ_MORE_MASK)
static int channel_health(DbCaptureJob *j)
{
    uint32_t status[2],errors[2],sequence[2],stamp[2];unsigned c,any=0;
    for(c=0;c<2;++c) {
        status[c]=Xil_In32(j->camera[c].BaseAddr+XAXIVDMA_RX_OFFSET+XAXIVDMA_SR_OFFSET);
        errors[c]=status[c]&(XAXIVDMA_SR_ERR_ALL_MASK|0x00008000U);
        if(errors[c] || (status[c]&XAXIVDMA_SR_HALTED_MASK)) {
            uint32_t cr=Xil_In32(j->camera[c].BaseAddr+XAXIVDMA_RX_OFFSET+XAXIVDMA_CR_OFFSET);
            unsigned recoverable=(errors[c]&CAPTURE_SIZE_ERRORS) &&
                !(errors[c]&~(CAPTURE_SIZE_ERRORS|XAXIVDMA_SR_ERR_INTERNAL_MASK)) &&
                !(status[c]&XAXIVDMA_SR_HALTED_MASK) && (cr&XAXIVDMA_CR_RUNSTOP_MASK) &&
                (!(errors[c]&XAXIVDMA_SR_ERR_INTERNAL_MASK) ||
                 (errors[c]&(XAXIVDMA_SR_ERR_FSZ_LESS_MASK|XAXIVDMA_SR_ERR_FSZ_MORE_MASK)));
            if(!recoverable) {
                db_log("CAPTURE hard fault camera=%u status=%08lx control=%08lx\r\n",
                    c,(unsigned long)status[c],(unsigned long)cr);return -2;
            }
            any=1;
        }
    }
    if(any) {
        /* Snapshot both counters before acknowledging either error. No frame
         * is published until a full three-store rotation of fresh tags. */
        for(c=0;c<2;++c)if(!tag(j,c,&sequence[c],&stamp[c]))return -1;
        for(c=0;c<2;++c) {
            j->resync_sequence[c]=sequence[c];
            if(errors[c]) {
                Xil_Out32(j->camera[c].BaseAddr+XAXIVDMA_RX_OFFSET+XAXIVDMA_SR_OFFSET,
                    errors[c]|XAXIVDMA_IXR_ERROR_MASK);
                db_log("CAPTURE resync camera=%u status=%08lx discard_through=%lu\r\n",
                    c,(unsigned long)status[c],(unsigned long)(sequence[c]+3U));
            }
        }
        j->resyncing=1;++j->recoveries;return -1;
    }
    if(j->resyncing) {
        for(c=0;c<2;++c)if(!tag(j,c,&sequence[c],&stamp[c]) ||
            (uint32_t)(sequence[c]-j->resync_sequence[c])<3U)return -1;
        j->resyncing=0;
        db_log("CAPTURE resumed fresh_pair=%lu,%lu recoveries=%lu\r\n",
            (unsigned long)sequence[0],(unsigned long)sequence[1],(unsigned long)j->recoveries);
    }
    return 1;
}
static int source_owned(DbCaptureJob *j)
{
    unsigned c;int health=channel_health(j);
    if(health<0)return health;
    for(c=0;c<2;++c) {
        uint32_t sequence,stamp;
        unsigned store=(Xil_In32(j->camera[c].BaseAddr+XAXIVDMA_PARKPTR_OFFSET)&XAXIVDMA_PARKPTR_WRTSTR_MASK)>>24;
        if(!tag(j,c,&sequence,&stamp) || (uint32_t)(sequence-j->sequence[c])>=2U || store==j->store[c])return -1;
    }
    return 1;
}
static int start(XAxiVdma *v,unsigned id,uint32_t base)
{
    XAxiVdma_Config *config=XAxiVdma_LookupConfig(id);XAxiVdma_DmaSetup setup;unsigned i;
    if(!config || XAxiVdma_CfgInitialize(v,config,config->BaseAddress)!=XST_SUCCESS)return 0;
    memset(&setup,0,sizeof(setup));setup.VertSizeInput=DB_HEIGHT;
    setup.HoriSizeInput=setup.Stride=DB_WIDTH;setup.EnableCircularBuf=1;
    for(i=0;i<3;++i)setup.FrameStoreStartAddr[i]=base+i*DB_IMAGE_BYTES;
    return XAxiVdma_DmaConfig(v,XAXIVDMA_WRITE,&setup)==XST_SUCCESS &&
       XAxiVdma_DmaSetBufferAddr(v,XAXIVDMA_WRITE,setup.FrameStoreStartAddr)==XST_SUCCESS &&
       XAxiVdma_DmaStart(v,XAXIVDMA_WRITE)==XST_SUCCESS;
}
int db_capture_init(DbCaptureJob *j)
{
    unsigned c;memset(j,0,sizeof(*j));j->dma=db_copy_init();
    /* A JTAG reload can leave dirty lines in the reused capture buffers.
     * Publish them before enabling the camera writers, including CPU fallback. */
    Xil_DCacheFlushRange(DB_CAPTURE_BASE,3U*DB_IMAGE_BYTES);
    Xil_DCacheFlushRange(DB_CAPTURE_RIGHT_BASE,3U*DB_IMAGE_BYTES);
    if(!start(&j->camera[0],XPAR_AXIVDMA_0_DEVICE_ID,DB_CAPTURE_BASE) ||
       !start(&j->camera[1],XPAR_AXIVDMA_1_DEVICE_ID,DB_CAPTURE_RIGHT_BASE) ||
       XGpio_Initialize(&j->tag[0],XPAR_FRAME_TAG_LEFT_DEVICE_ID)!=XST_SUCCESS ||
       XGpio_Initialize(&j->tag[1],XPAR_FRAME_TAG_RIGHT_DEVICE_ID)!=XST_SUCCESS ||
       XGpio_Initialize(&j->clock_reader,XPAR_FRAME_CLOCK_DEVICE_ID)!=XST_SUCCESS)return 0;
    for(c=0;c<2;++c){XGpio_SetDataDirection(&j->tag[c],1,~0U);XGpio_SetDataDirection(&j->tag[c],2,~0U);}
    XGpio_SetDataDirection(&j->clock_reader,1,~0U);
    db_log("CAPTURE copy=%s\r\n",j->dma?"ps_dma":"cpu_bounded");return 1;
}
uint32_t db_capture_time_us(DbCaptureJob *j)
{return XGpio_DiscreteRead(&j->clock_reader,1);}
int db_capture_begin(DbCaptureJob *j,uint8_t *left,uint8_t *right)
{
    uint32_t sequence[2],stamp[2];int64_t skew;unsigned c;
    if(j->resyncing && !j->active) {
        int health=channel_health(j);
        if(health<0)return health==-2?-2:0;
    }
    if(j->active || !tag(j,0,&sequence[0],&stamp[0]) || !tag(j,1,&sequence[1],&stamp[1]) ||
       sequence[0]==j->previous[0] || sequence[1]==j->previous[1])return 0;
    skew=(int32_t)(stamp[0]-stamp[1]);if(skew<0)skew=-skew;
    if((uint64_t)skew>DB_MAX_SKEW_US)return 0;
    j->destination[0]=left;j->destination[1]=right;
    for(c=0;c<2;++c) {
        uint32_t confirm_sequence,confirm_stamp;
        unsigned current=(Xil_In32(j->camera[c].BaseAddr+XAXIVDMA_PARKPTR_OFFSET)&
            XAXIVDMA_PARKPTR_WRTSTR_MASK)>>24;
        /* Frame tags count from camera reset, while the VDMA frame-store
         * rotation restarts when the application configures it. The two
         * counters have no fixed modulo-three phase after a JTAG reload.
         * PARKPTR reports the store currently written by S2MM (PG020). */
        if(current>=3U || !tag(j,c,&confirm_sequence,&confirm_stamp) ||
           confirm_sequence!=sequence[c] || confirm_stamp!=stamp[c] ||
           current!=((Xil_In32(j->camera[c].BaseAddr+XAXIVDMA_PARKPTR_OFFSET)&
               XAXIVDMA_PARKPTR_WRTSTR_MASK)>>24))return 0;
        j->sequence[c]=sequence[c];j->stamp[c]=stamp[c];j->store[c]=(current+2U)%3U;
        j->source[c]=(const uint8_t *)(uintptr_t)((c?DB_CAPTURE_RIGHT_BASE:DB_CAPTURE_BASE)+j->store[c]*DB_IMAGE_BYTES);
    }
    j->active=1;j->phase=j->row=0;return 1;
}
int db_capture_poll(DbCaptureJob *j)
{
    unsigned c;int owned,done=0;
    if(!j->active)return 0;
    if(j->phase==0) {
        owned=source_owned(j);
        if(owned<0){if(owned!=-2)j->active=0;return owned;}
        if(j->dma) {
            if(!db_copy_begin(j->source[0],j->source[1],j->destination[0],j->destination[1]))return -2;
            j->phase=1;return 0;
        }
        for(c=0;c<2;++c) {
            unsigned rows=j->row+8U>DB_HEIGHT?DB_HEIGHT-j->row:8U;
            Xil_DCacheInvalidateRange((INTPTR)(j->source[c]+j->row*DB_WIDTH),rows*DB_WIDTH);
            memcpy(j->destination[c]+j->row*DB_WIDTH,j->source[c]+j->row*DB_WIDTH,rows*DB_WIDTH);
            Xil_DCacheFlushRange((INTPTR)(j->destination[c]+j->row*DB_WIDTH),rows*DB_WIDTH);
        }
        owned=source_owned(j);if(owned<0){if(owned!=-2)j->active=0;return owned;}
        j->row+=8U;done=j->row>=DB_HEIGHT;
    } else if(j->phase==1) {
        done=db_copy_poll();if(done<0)return -2;
        if(!done)return 0;
        owned=source_owned(j);if(owned<0){if(owned!=-2)j->active=0;return owned;}
        db_cache_begin(&j->cache,j->destination[0],j->destination[1],1);j->phase=2;return 0;
    } else {
        done=db_cache_poll(&j->cache);if(!done)return 0;
        if(!j->verified) {
            unsigned mismatch=0;
            owned=source_owned(j);if(owned<0){if(owned!=-2)j->active=0;return owned;}
            for(c=0;c<2;++c) {
                Xil_DCacheInvalidateRange((INTPTR)j->source[c],DB_IMAGE_BYTES);
                if(memcmp(j->source[c],j->destination[c],DB_IMAGE_BYTES))mismatch=1;
            }
            owned=source_owned(j);if(owned<0){if(owned!=-2)j->active=0;return owned;}
            if(mismatch)return -2;
            j->verified=1;db_log("RAW_DMA_VERIFY PASS bytes=%lu\r\n",(unsigned long)(2U*DB_IMAGE_BYTES));
        }
    }
    if(done) {
        for(c=0;c<2;++c)j->previous[c]=j->sequence[c];
        j->active=0;return 1;
    }
    return 0;
}

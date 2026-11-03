#include "db_copy.h"
#include "db_config.h"
#include "db_net.h"
#include "xdmaps.h"
#include "xil_cache.h"
#include <string.h>
static XDmaPs dma;
static XDmaPs_Cmd command[2];
static unsigned initialized,active,failed;
static uint32_t started;
int db_copy_init(void)
{
    XDmaPs_Config *cfg=XDmaPs_LookupConfig(XPAR_XDMAPS_1_DEVICE_ID);
    if(!cfg || XDmaPs_CfgInitialize(&dma,cfg,cfg->BaseAddress)!=XST_SUCCESS)return 0;
    /* No image DMA is running yet. Remove any dirty data left by a prior
     * development download. Thereafter CPU only reads these image ranges. */
    Xil_DCacheFlushRange(DB_CAPTURE_BASE,3U*DB_IMAGE_BYTES);
    Xil_DCacheFlushRange(DB_CAPTURE_RIGHT_BASE,3U*DB_IMAGE_BYTES);
    Xil_DCacheFlushRange(DB_RAW_TX_BASE,6U*DB_IMAGE_BYTES);
    initialized=1;return 1;
}
int db_copy_dma_owned(uint32_t source,uint32_t destination,unsigned bytes)
{
    unsigned c;
    if(!initialized || !active || bytes!=DB_IMAGE_BYTES)return 0;
    for(c=0;c<2;++c)if(command[c].BD.SrcAddr==source && command[c].BD.DstAddr==destination)return 1;
    return 0;
}
int db_copy_begin(const uint8_t *left,const uint8_t *right,uint8_t *out_left,uint8_t *out_right)
{
    const uint8_t *sources[2]={left,right};uint8_t *outputs[2]={out_left,out_right};unsigned c;
    if(!initialized || active || failed)return 0;
    for(c=0;c<2;++c) {
        uintptr_t src=(uintptr_t)sources[c],dst=(uintptr_t)outputs[c];
        uint32_t base=c?DB_CAPTURE_RIGHT_BASE:DB_CAPTURE_BASE;
        if(src<base || src-base>=3U*DB_IMAGE_BYTES || (src-base)%DB_IMAGE_BYTES ||
           dst<DB_RAW_TX_BASE || dst-DB_RAW_TX_BASE>=6U*DB_IMAGE_BYTES ||
           (dst-DB_RAW_TX_BASE)%DB_IMAGE_BYTES)return 0;
    }
    if(out_left==out_right)return 0;
    memset(command,0,sizeof(command));
    for(c=0;c<2;++c) {
        command[c].ChanCtrl.SrcBurstSize=command[c].ChanCtrl.DstBurstSize=4;
        command[c].ChanCtrl.SrcBurstLen=command[c].ChanCtrl.DstBurstLen=16;
        command[c].ChanCtrl.SrcInc=command[c].ChanCtrl.DstInc=1;
        command[c].BD.SrcAddr=(uint32_t)(uintptr_t)sources[c];
        command[c].BD.DstAddr=(uint32_t)(uintptr_t)outputs[c];
        command[c].BD.Length=DB_IMAGE_BYTES;
    }
    /* The generated program is cleaned by the SDK. Its image cache work
     * is bypassed only for this exact active pair. Outputs stay reserved. */
    active=1;started=db_time_us();
    for(c=0;c<2;++c)if(XDmaPs_Start(&dma,c,&command[c],0)!=XST_SUCCESS){failed=1;return 0;}
    return 1;
}
int db_copy_poll(void)
{
    uint32_t base=dma.Config.BaseAddress,status;unsigned c;
    if(failed)return -1;
    if(!active)return 1;
    if(XDmaPs_ReadReg(base,XDMAPS_FSM_OFFSET) || XDmaPs_ReadReg(base,XDMAPS_FSC_OFFSET) ||
       (uint32_t)(db_time_us()-started)>50000U){failed=1;return -1;}
    status=XDmaPs_ReadReg(base,XDMAPS_INTSTATUS_OFFSET);
    for(c=0;c<2;++c)if(XDmaPs_IsActive(&dma,c)) {
        /* SEV follows DMAWMB. Also wait for END before recycling a channel. */
        if(!(status&(1U<<c)) || (XDmaPs_ReadReg(base,XDmaPs_CSn_OFFSET(c))&15U))continue;
        if(c)XDmaPs_DoneISR_1(&dma);else XDmaPs_DoneISR_0(&dma);
    }
    if(XDmaPs_IsActive(&dma,0) || XDmaPs_IsActive(&dma,1))return 0;
    if(command[0].DmaStatus || command[1].DmaStatus){failed=1;return -1;}
    active=0;return 1;
}

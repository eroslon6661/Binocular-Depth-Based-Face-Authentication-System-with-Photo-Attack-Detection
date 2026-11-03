#include "db_screen.h"
#include "db_rgb_screen.h"
#include "db_mode.h"
#include "db_config.h"
#include "db_log.h"
#include "xparameters.h"
#include <string.h>
#if defined(XPAR_PHOTO_LEFT_DEVICE_ID) && defined(XPAR_PHOTO_RIGHT_DEVICE_ID)
#define DB_SCREEN_HW 1
#if XPAR_PHOTO_LEFT_S_AXIS_S2MM_TDATA_WIDTH != 24 || XPAR_PHOTO_RIGHT_S_AXIS_S2MM_TDATA_WIDTH != 24
#error "Photo DMA must store packed 24-bit originals, not padded 32-bit pixels"
#endif
#include "xaxivdma.h"
#include "xgpio.h"
#include "xil_cache.h"
#else
#define DB_SCREEN_HW 0
#endif
#define PHOTO_RGB_BYTES  (DB_IMAGE_BYTES*3U)
#if DB_PHOTO_RGB_BASE < (DB_LCD_BASE+DB_LCD_STEP+DB_LCD_BYTES) && \
    DB_LCD_BASE < (DB_PHOTO_RGB_BASE+DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES)
#error "Photo RGB buffers overlap LCD frame buffers"
#endif
#if (DB_PHOTO_RGB_BASE+DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES-1U) > XPAR_PS7_DDR_0_S_AXI_HIGHADDR
#error "Photo RGB buffers exceed DDR"
#endif
static DbPhoto photo;
static DbControl measurement;
static unsigned have_measurement,measurement_from_photo;
static DbScreenAdapter adapter;
static unsigned available,attached,event_pending,raw_ready,have_images,image_locked;
#if DB_SCREEN_HW
static XAxiVdma dma[2];
static XGpio arm[2],tag[2];
static unsigned arm_value[2],phase,row,failed,stop_requested[2];
static uint32_t started,capture_clock,preview_stamp[2][2];
/* Each camera owns an independent two-buffer queue. A slow right frame
 * must not prevent the left DMA from arming before its next SOF. */
static unsigned preview_active[2]={2,2},preview_lease[2]={2,2};
static uint32_t preview_clock[2],preview_started[2];
enum { PREVIEW_FREE,PREVIEW_CAPTURING,PREVIEW_READY,PREVIEW_LEASED };
static unsigned preview_state[2][2];
static uint32_t preview_attempts[2],preview_done[2],preview_completed,preview_rejected,preview_capture_us[2],preview_report;
static int32_t preview_last_skew;
#define PREVIEW_SECOND_BASE 0x13400000U
#define PREVIEW_RGB_BASE 0x12800000U
#if PREVIEW_SECOND_BASE+DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES-1U > XPAR_PS7_DDR_0_S_AXI_HIGHADDR
#error "Second preview pair exceeds DDR"
#endif
#if PREVIEW_RGB_BASE < DB_PHOTO_RGB_BASE+DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES || PREVIEW_RGB_BASE+DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES-1U > XPAR_PS7_DDR_0_S_AXI_HIGHADDR
#error "Preview DDR overlap or out of range"
#endif
static uint8_t *preview_rgb_slot(unsigned slot,unsigned c){return (uint8_t *)(uintptr_t)((slot?PREVIEW_SECOND_BASE:PREVIEW_RGB_BASE)+c*DB_PHOTO_RGB_STEP);}
static uint8_t *preview_rgb(unsigned c){return preview_rgb_slot(preview_active[c],c);}
static uint8_t *rgb(unsigned c){return (uint8_t *)(uintptr_t)(DB_PHOTO_RGB_BASE+c*DB_PHOTO_RGB_STEP);}
static uint8_t *green(unsigned c){return (uint8_t *)(uintptr_t)(DB_PHOTO_GREEN_BASE+c*DB_IMAGE_BYTES);}
static int init_channel(unsigned c,unsigned dma_id,unsigned arm_id,unsigned tag_id)
{
    XAxiVdma_Config *cfg=XAxiVdma_LookupConfig(dma_id);
    if(!cfg || XAxiVdma_CfgInitialize(&dma[c],cfg,cfg->BaseAddress)!=XST_SUCCESS ||
       XGpio_Initialize(&arm[c],arm_id)!=XST_SUCCESS || XGpio_Initialize(&tag[c],tag_id)!=XST_SUCCESS)return 0;
    XGpio_SetDataDirection(&arm[c],1,0);XGpio_DiscreteWrite(&arm[c],1,0);
    XGpio_SetDataDirection(&tag[c],1,~0U);XGpio_SetDataDirection(&tag[c],2,~0U);
    Xil_DCacheFlushRange((INTPTR)rgb(c),PHOTO_RGB_BYTES);return 1;
}
static int start_channel(unsigned c)
{
    XAxiVdma_DmaSetup cfg;XAxiVdma_FrameCounter count;unsigned i;
    memset(&cfg,0,sizeof(cfg));memset(&count,0,sizeof(count));
    cfg.VertSizeInput=DB_HEIGHT;cfg.HoriSizeInput=cfg.Stride=DB_WIDTH*3U;
    cfg.EnableFrameCounter=1;
    for(i=0;i<3;++i)cfg.FrameStoreStartAddr[i]=(UINTPTR)(preview_active[c]<2?preview_rgb(c):rgb(c));
    count.ReadFrameCount=count.WriteFrameCount=1;
    return XAxiVdma_SetFrameCounter(&dma[c],&count)==XST_SUCCESS &&
       XAxiVdma_DmaConfig(&dma[c],XAXIVDMA_WRITE,&cfg)==XST_SUCCESS &&
       XAxiVdma_DmaSetBufferAddr(&dma[c],XAXIVDMA_WRITE,cfg.FrameStoreStartAddr)==XST_SUCCESS &&
       XAxiVdma_DmaStart(&dma[c],XAXIVDMA_WRITE)==XST_SUCCESS;
}
/* Completion is checked separately. The caller may rearm the finished
 * camera while the other camera still drains its previous frame. */
static void preview_poll(uint32_t now)
{
 unsigned c;
 if(failed)return;
 for(c=0;c<2;++c)if(preview_active[c]<2){
  unsigned slot=preview_active[c],status=XGpio_DiscreteRead(&tag[c],1);
  uint32_t stamp=XGpio_DiscreteRead(&tag[c],2);
  if((status&2U) || XAxiVdma_GetDmaChannelErrors(&dma[c],XAXIVDMA_WRITE) ||
     (uint32_t)(now-preview_started[c])>500000U){
   failed=1;db_log("PREVIEW DMA fault camera=%u; owned buffers retained until reset\r\n",c);return;
  }
  if((status&1U) && (int32_t)(stamp-preview_clock[c])>=0 && !stop_requested[c]){
   XAxiVdma_DmaStop(&dma[c],XAXIVDMA_WRITE);stop_requested[c]=1;
  }
  if(stop_requested[c] && !XAxiVdma_IsBusy(&dma[c],XAXIVDMA_WRITE)){
   preview_stamp[c][slot]=stamp;preview_state[c][slot]=PREVIEW_READY;
   preview_active[c]=2;preview_capture_us[c]=now-preview_started[c];++preview_done[c];
  }
 }
}
#endif
static void notify(void){if(attached && adapter.notify)adapter.notify(adapter.context,&photo);}
int db_screen_init(void)
{
    memset(&photo,0,sizeof(photo));memset(&adapter,0,sizeof(adapter));
    available=attached=event_pending=raw_ready=have_images=image_locked=0;
    have_measurement=measurement_from_photo=0;memset(&measurement,0,sizeof(measurement));
#if DB_SCREEN_HW
    if(!init_channel(0,XPAR_PHOTO_LEFT_DEVICE_ID,XPAR_PHOTO_ARM_LEFT_DEVICE_ID,XPAR_PHOTO_TAG_LEFT_DEVICE_ID) ||
       !init_channel(1,XPAR_PHOTO_RIGHT_DEVICE_ID,XPAR_PHOTO_ARM_RIGHT_DEVICE_ID,XPAR_PHOTO_TAG_RIGHT_DEVICE_ID))return 0;
    Xil_DCacheFlushRange(PREVIEW_RGB_BASE,DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES);
    Xil_DCacheFlushRange(PREVIEW_SECOND_BASE,DB_PHOTO_RGB_STEP+PHOTO_RGB_BYTES);
    available=1;
    if(!db_rgb_screen_attach())
        db_log("SCREEN: RGB photo hardware ready; LCD unavailable\r\n");
#endif
    return (int)available;
}
int db_screen_attach(const DbScreenAdapter *a)
{
    if(!available || !a || !a->poll || !a->notify || attached)return 0;
#if DB_SCREEN_HW
    adapter=*a;attached=1;notify();return 1;
#else
    return 0;
#endif
}
void db_screen_poll(uint32_t now)
{
    if(!available)return;
    if(attached) {
        int event=adapter.poll(adapter.context);
        if(event==DB_SCREEN_EVENT_CAPTURE || event==DB_SCREEN_EVENT_MODE || event==DB_SCREEN_EVENT_HDMI)event_pending=(unsigned)event;
        else if(event<0){attached=0;event_pending=0;db_log("SCREEN: adapter failed; video/audio remain active\r\n");}
    }
#if DB_SCREEN_HW
    if(!phase)preview_poll(now);
    if(phase==1) {
        unsigned c,done=1;
        for(c=0;c<2;++c) {
            unsigned status=XGpio_DiscreteRead(&tag[c],1);
            uint32_t stamp=XGpio_DiscreteRead(&tag[c],2);
            if((status&2U) || XAxiVdma_GetDmaChannelErrors(&dma[c],XAXIVDMA_WRITE))failed=1;
            /* A one-shot stream has no following SOF. Request a graceful stop
             * after the tap has delivered every pixel, then wait for HALTED
             * before reading DDR. Tap done alone does not prove writes drained.
             * A previous shot's done bit must not stop a newly armed transfer. */
            if(!failed && (status&1U) && (int32_t)(stamp-capture_clock)>=0 &&
               !stop_requested[c]) {
                XAxiVdma_DmaStop(&dma[c],XAXIVDMA_WRITE);stop_requested[c]=1;
            }
            if(!stop_requested[c] || XAxiVdma_IsBusy(&dma[c],XAXIVDMA_WRITE))done=0;
        }
        if(failed || (uint32_t)(now-started)>500000U) {
            /* An incomplete AXI write must not be overwritten or rearmed. */
            unsigned c;
            for(c=0;c<2;++c)db_log("SCREEN capture fault camera=%u tag=%08lx dma_error=%08lx busy=%u\r\n",
                c,(unsigned long)XGpio_DiscreteRead(&tag[c],1),
                (unsigned long)XAxiVdma_GetDmaChannelErrors(&dma[c],XAXIVDMA_WRITE),
                XAxiVdma_IsBusy(&dma[c],XAXIVDMA_WRITE));
            failed=1;phase=0;db_screen_fail();db_log("SCREEN: capture fault; photo disabled until reset\r\n");
        } else if(done) {
            int64_t skew;uint32_t stamps[2];
            for(c=0;c<2;++c)stamps[c]=XGpio_DiscreteRead(&tag[c],2);
            for(c=0;c<2;++c)photo.stamp[c]=stamps[c];
            skew=(int32_t)(photo.stamp[0]-photo.stamp[1]);if(skew<0)skew=-skew;
            if((uint64_t)skew>DB_MAX_SKEW_US || (int32_t)(photo.stamp[0]-photo.trigger_us)<0 ||
               (int32_t)(photo.stamp[1]-photo.trigger_us)<0) {
                phase=0;db_screen_fail();
            } else {
                phase=2;row=0;
                db_log("SCREEN raw DMA complete left_us=%lu right_us=%lu\r\n",
                    (unsigned long)photo.stamp[0],(unsigned long)photo.stamp[1]);
            }
        }
    } else if(phase==2) {
        unsigned c,y,x,end=row+4U;if(end>DB_HEIGHT)end=DB_HEIGHT;
        for(c=0;c<2;++c) {
            Xil_DCacheInvalidateRange((INTPTR)(rgb(c)+row*DB_WIDTH*3U),(end-row)*DB_WIDTH*3U);
            for(y=row;y<end;++y)for(x=0;x<DB_WIDTH;++x)
                green(c)[y*DB_WIDTH+x]=rgb(c)[(y*DB_WIDTH+x)*3U+1U];
            Xil_DCacheFlushRange((INTPTR)(green(c)+row*DB_WIDTH),(end-row)*DB_WIDTH);
        }
        row=end;
        if(row==DB_HEIGHT){phase=0;raw_ready=1;have_images=1;}
    }
#else
    (void)now;
#endif
}
int db_screen_preview_start(uint32_t now,uint32_t clock)
{
#if DB_SCREEN_HW
 unsigned c,slot,armed=0;
 if((uint32_t)(now-preview_report)>=1000000U){preview_report=now;
  db_log("PREVIEW_CAPTURE armed=%lu,%lu done=%lu,%lu paired=%lu rejected=%lu capture_us=%lu,%lu skew_us=%ld\r\n",
   (unsigned long)preview_attempts[0],(unsigned long)preview_attempts[1],
   (unsigned long)preview_done[0],(unsigned long)preview_done[1],
   (unsigned long)preview_completed,(unsigned long)preview_rejected,
   (unsigned long)preview_capture_us[0],(unsigned long)preview_capture_us[1],(long)preview_last_skew);}
 if(!available || failed || phase || image_locked || db_screen_busy())return 0;
 for(c=0;c<2;++c){
  if(preview_active[c]<2)continue;
  for(slot=0;slot<2;++slot)if(preview_state[c][slot]==PREVIEW_FREE)break;
  if(slot==2)continue;
  preview_active[c]=slot;preview_state[c][slot]=PREVIEW_CAPTURING;
  preview_clock[c]=clock;preview_started[c]=now;stop_requested[c]=0;
  if(!start_channel(c)){failed=1;return 0;}
  arm_value[c]^=1U;XGpio_DiscreteWrite(&arm[c],1,arm_value[c]);
  ++preview_attempts[c];armed=1;
 }
 return (int)armed;
#else
 (void)now;(void)clock;return 0;
#endif
}
int db_screen_preview_busy(void)
{
#if DB_SCREEN_HW
 unsigned c,slot;
 for(c=0;c<2;++c)for(slot=0;slot<2;++slot)if(preview_state[c][slot]!=PREVIEW_FREE)return 1;
#endif
 return 0;
}
int db_screen_preview_acquire(const uint8_t *images[2],uint32_t stamps[2])
{
#if DB_SCREEN_HW
 unsigned c,slot,chosen[2],attempt;
 if(failed || preview_lease[0]<2 || preview_lease[1]<2)return 0;
 /* Queues can lose different frames under backpressure. Never pair by buffer
  * index or relax stereo skew: discard only the older unmatched frame. */
 for(attempt=0;attempt<4;++attempt){
  int32_t skew;
  for(c=0;c<2;++c){
   chosen[c]=2;
   for(slot=0;slot<2;++slot)if(preview_state[c][slot]==PREVIEW_READY &&
      (chosen[c]==2 || (int32_t)(preview_stamp[c][slot]-preview_stamp[c][chosen[c]])<0))chosen[c]=slot;
   if(chosen[c]==2)return 0;
  }
  skew=(int32_t)(preview_stamp[0][chosen[0]]-preview_stamp[1][chosen[1]]);
  preview_last_skew=skew;
  if((int64_t)skew>DB_MAX_SKEW_US || -(int64_t)skew>DB_MAX_SKEW_US){
   c=skew<0?0:1;preview_state[c][chosen[c]]=PREVIEW_FREE;++preview_rejected;continue;
  }
  for(c=0;c<2;++c){preview_lease[c]=chosen[c];preview_state[c][chosen[c]]=PREVIEW_LEASED;
   images[c]=preview_rgb_slot(chosen[c],c);stamps[c]=preview_stamp[c][chosen[c]];}
  ++preview_completed;return 1;
 }
#else
 (void)images;(void)stamps;
#endif
 return 0;
}
void db_screen_preview_release(void)
{
#if DB_SCREEN_HW
 unsigned c;for(c=0;c<2;++c)if(preview_lease[c]<2){preview_state[c][preview_lease[c]]=PREVIEW_FREE;preview_lease[c]=2;}
#endif
}
/* Cancelling never releases a DMA-owned buffer. Independent active channels
 * drain; the next cancellation discards their READY frames before a photo. */
void db_screen_preview_cancel(void)
{
#if DB_SCREEN_HW
 unsigned c,slot;db_screen_preview_release();
 for(c=0;c<2;++c)for(slot=0;slot<2;++slot)if(preview_state[c][slot]==PREVIEW_READY)preview_state[c][slot]=PREVIEW_FREE;
#endif
}
int db_screen_take_hdmi_switch(void)
{if(event_pending!=DB_SCREEN_EVENT_HDMI)return 0;event_pending=0;return 1;}
int db_screen_take_capture(void)
{if(event_pending!=DB_SCREEN_EVENT_CAPTURE)return 0;event_pending=0;return 1;}
int db_screen_take_mode_switch(void)
{if(event_pending!=DB_SCREEN_EVENT_MODE)return 0;event_pending=0;return 1;}
int db_screen_set_mode(unsigned mode)
{
 if(!attached || db_screen_busy() || image_locked || !db_rgb_screen_set_mode(mode))return 0;
 memset(&photo,0,sizeof(photo));memset(&measurement,0,sizeof(measurement));
 have_measurement=measurement_from_photo=have_images=raw_ready=event_pending=0;
 notify();return 1;
}
int db_screen_busy(void){return photo.state==DB_PHOTO_CAPTURING || photo.state==DB_PHOTO_READY || photo.state==DB_PHOTO_MEASURING;}
int db_screen_begin(unsigned x,unsigned y,uint32_t now,uint32_t clock)
{
    if(!available || !attached)return 0;
#if DB_SCREEN_HW
    unsigned c;
    if(failed || phase || db_screen_preview_busy() || image_locked || !db_photo_begin(&photo,x,y,clock))return 0;
    /* A new photo must not inherit the previous photo's distance. A separate
     * physical-key reading remains labelled as such on the LCD. */
    if(measurement_from_photo)have_measurement=0;
    have_images=raw_ready=0;
    for(c=0;c<2;++c)stop_requested[c]=0;
    for(c=0;c<2;++c)if(!start_channel(c)) {
        db_log("SCREEN: camera=%u photo DMA start failed\r\n",c);
        failed=1;db_screen_fail();return 0;
    }
    /* Arm only after both VDMAs are ready. No camera or realtime DMA reset. */
    for(c=0;c<2;++c){arm_value[c]^=1U;XGpio_DiscreteWrite(&arm[c],1,arm_value[c]);}
    capture_clock=clock;started=now;phase=1;notify();db_log("SCREEN capture armed x=%u y=%u\r\n",x,y);return 1;
#else
    (void)x;(void)y;(void)now;(void)clock;return 0;
#endif
}
int db_screen_raw_ready(uint8_t *images[2],uint32_t stamps[2])
{
#if DB_SCREEN_HW
    if(raw_ready){unsigned c;raw_ready=0;for(c=0;c<2;++c){images[c]=green(c);stamps[c]=photo.stamp[c];}return 1;}
#else
    (void)images;(void)stamps;
#endif
    return 0;
}
int db_screen_set_frame(uint32_t frame)
{
    if(!db_photo_ready(&photo,frame,photo.stamp[0],photo.stamp[1],DB_MAX_SKEW_US))return 0;
    notify();return 1;
}
int db_screen_bind(const DbControl *r){int ok=db_photo_bind(&photo,r);if(ok)notify();return ok;}
void db_screen_result(const DbControl *r){if(db_photo_result(&photo,r))notify();}
void db_screen_measurement(const DbControl *r,unsigned from_photo)
{
    if(!r || r->type!=DB_CTRL_RESULT || !r->id || r->x>=1280U || r->y>=720U ||
       r->status<DB_CTRL_OK || r->status>DB_CTRL_TIMEOUT ||
       (r->status==DB_CTRL_OK?(!r->frame || !r->distance_mm || r->distance_mm>3000U):r->distance_mm!=0U))return;
    measurement=*r;measurement_from_photo=from_photo!=0;have_measurement=1;notify();
}
const DbControl *db_screen_last_measurement(unsigned *from_photo)
{
    if(from_photo)*from_photo=measurement_from_photo;
    return have_measurement?&measurement:NULL;
}
void db_screen_fail(void){db_photo_fail(&photo);notify();}
const DbPhoto *db_screen_photo(void){return &photo;}
const uint8_t *db_screen_image(unsigned c,size_t *bytes)
{
    if(bytes)*bytes=0;
#if DB_SCREEN_HW
    if(have_images && c<2U){if(bytes)*bytes=PHOTO_RGB_BYTES;return rgb(c);}
#else
    (void)c;
#endif
    return NULL;
}
int db_screen_image_lock(uint32_t frame)
{
    if(!have_images || !frame || frame!=photo.frame || image_locked)return 0;
    image_locked=1;return 1;
}
void db_screen_image_release(void){image_locked=0;}
size_t db_screen_preview(uint32_t frame,unsigned c,unsigned w,unsigned h,
    size_t offset,size_t count,uint8_t *out,unsigned be)
{
    size_t bytes;const uint8_t *p;
    if(!image_locked || photo.frame!=frame)return 0;
    p=db_screen_image(c,&bytes);if(!p || bytes!=PHOTO_RGB_BYTES)return 0;
    if(count>128U)count=128U;
    return db_photo_rgb565(p,w,h,offset,count,out,be);
}

#include "db_rgb_screen.h"
#include "db_screen.h"
#include "db_rgb_ui.h"
#include "db_touch.h"
#include "db_log.h"
#include "db_net.h"
#include "db_config.h"
#include "xparameters.h"
#include <string.h>
#if defined(XPAR_LCD_DMA_DEVICE_ID) && defined(XPAR_TOUCH_GPIO_DEVICE_ID)
#if XPAR_LCD_DMA_M_AXIS_MM2S_TDATA_WIDTH != 24
#error "LCD DMA must read packed 24-bit framebuffer pixels"
#endif
#include "xaxivdma.h"
#include "xvtc.h"
#include "xgpio.h"
#include "xil_cache.h"
#if DB_LCD_BYTES != (DB_LCD_W*DB_LCD_H*3U)
#error "LCD framebuffer size disagrees with the central DDR memory map"
#endif
static XAxiVdma dma;
static XVtc vtc;
static XGpio touch_gpio,lcd_gpio;
static DbTouch touch;
static DbRgbUi ui;
static unsigned touch_drive,front,back,row,rendering,started,waiting,dirty,copying,copy_offset,failed;
static unsigned touch_armed=1,touch_was_online;
static uint32_t copy_frame,swap_start,revision,render_revision,last_errors,last_touch_report;
static uint32_t content_revision,render_content_revision,buffer_content_revision[2];
static unsigned buffer_valid[2],last_touch_down,last_touch_contacts;
static const uint8_t *raw[2];
static uint8_t *buffer(unsigned n){return (uint8_t *)(uintptr_t)(DB_LCD_BASE+n*DB_LCD_STEP);}
static void set_bus(void *ctx,unsigned low)
{(void)ctx;touch_drive=(touch_drive&12U)|(low&3U);XGpio_DiscreteWrite(&touch_gpio,1,touch_drive);}
static unsigned get_bus(void *ctx){(void)ctx;return XGpio_DiscreteRead(&touch_gpio,2);}
static void set_control(void *ctx,unsigned reset,unsigned irq)
{(void)ctx;touch_drive=(touch_drive&3U)|(reset?4U:0U)|(irq?8U:0U);XGpio_DiscreteWrite(&touch_gpio,1,touch_drive);}
static void notify(void *ctx,const DbPhoto *photo)
{
 const DbControl *m;(void)ctx;
 if(photo->state==DB_PHOTO_CAPTURING && ui.photo.state!=DB_PHOTO_CAPTURING) {
  db_rgb_ui_face_reset(&ui);ui.have_thumbs=0;
 }
 if(ui.photo.frame!=photo->frame || ui.photo.state!=photo->state)++content_revision;
 ui.photo=*photo;
 m=db_screen_last_measurement(&ui.measurement_is_photo);
 ui.have_measurement=m!=NULL;if(m)ui.measurement=*m;
 dirty=1;++revision;
}
static int start_video(void)
{
 XAxiVdma_DmaSetup cfg;XVtc_Timing timing;XVtc_SourceSelect source;
 memset(&timing,0,sizeof(timing));memset(&source,0,sizeof(source));memset(&cfg,0,sizeof(cfg));
 /* Provisional profile: ATK reference 7016, not a claimed panel datasheet. */
 timing.HActiveVideo=1024;timing.HFrontPorch=160;timing.HSyncWidth=20;timing.HBackPorch=140;
 timing.VActiveVideo=600;timing.V0FrontPorch=timing.V1FrontPorch=12;
 timing.V0SyncWidth=timing.V1SyncWidth=3;timing.V0BackPorch=timing.V1BackPorch=20;
 source.VBlankPolSrc=source.VSyncPolSrc=source.HBlankPolSrc=source.HSyncPolSrc=1;
 source.ActiveVideoPolSrc=source.ActiveChromaPolSrc=source.VChromaSrc=source.VActiveSrc=1;
 source.VBackPorchSrc=source.VSyncSrc=source.VFrontPorchSrc=source.VTotalSrc=1;
 source.HActiveSrc=source.HBackPorchSrc=source.HSyncSrc=source.HFrontPorchSrc=source.HTotalSrc=1;
 XVtc_RegUpdateEnable(&vtc);XVtc_SetGeneratorTiming(&vtc,&timing);XVtc_SetSource(&vtc,&source);
 cfg.VertSizeInput=DB_LCD_H;cfg.HoriSizeInput=cfg.Stride=DB_LCD_W*3U;
 cfg.FixedFrameStoreAddr=0;cfg.EnableCircularBuf=0;
 cfg.FrameStoreStartAddr[0]=(UINTPTR)buffer(0);cfg.FrameStoreStartAddr[1]=(UINTPTR)buffer(1);
 cfg.FrameStoreStartAddr[2]=(UINTPTR)buffer(0);
 if(XAxiVdma_DmaConfig(&dma,XAXIVDMA_READ,&cfg)!=XST_SUCCESS ||
    XAxiVdma_DmaSetBufferAddr(&dma,XAXIVDMA_READ,cfg.FrameStoreStartAddr)!=XST_SUCCESS ||
    XAxiVdma_DmaStart(&dma,XAXIVDMA_READ)!=XST_SUCCESS ||
    XAxiVdma_StartParking(&dma,0,XAXIVDMA_READ)!=XST_SUCCESS)return 0;
 /* GE alone does not set the core's software enable bit (SW). */
 XVtc_EnableGenerator(&vtc);XVtc_Enable(&vtc);
 XGpio_DiscreteWrite(&lcd_gpio,1,3);front=0;back=1;return 1;
}
void db_rgb_screen_detection(uint32_t frame,const DbFaceDetection *d)
{if(db_rgb_ui_detection(&ui,frame,d)){dirty=1;++revision;++content_revision;}}
void db_rgb_screen_identity(uint32_t frame,unsigned person,int32_t score,unsigned valid)
{if(db_rgb_ui_identity(&ui,frame,person,score,valid)){dirty=1;++revision;++content_revision;}}
void db_rgb_screen_liveness(uint32_t frame,unsigned status)
{if(db_rgb_ui_liveness(&ui,frame,status)){dirty=1;++revision;++content_revision;}}
void db_rgb_screen_controls_busy(unsigned busy)
{if(ui.controls_busy!=(busy!=0)){ui.controls_busy=busy!=0;dirty=1;++revision;++content_revision;}}
int db_rgb_screen_set_mode(unsigned mode)
{if(copying || !db_rgb_ui_set_mode(&ui,mode))return 0;dirty=1;++revision;++content_revision;return 1;}
static int poll(void *ctx)
{
 uint32_t now=db_time_us();unsigned n,end;int event=0;(void)ctx;
 if(failed)return 0;
 db_touch_poll(&touch,now);
 if(touch.online && !touch_was_online)
  db_log("LCD touch identified size=%ux%u firmware=%04x source=%s\r\n",touch.width,touch.height,touch.firmware,
   touch.using_profile?"panel_profile_requires_board_check":"controller");
 if(ui.touch_ready!=(touch.online && touch.reporting)) {
  ui.touch_ready=touch.online && touch.reporting;dirty=1;++revision;++content_revision;
 }
 if((uint32_t)(now-last_touch_report)>=5000000U) {
  last_touch_report=now;
  db_log("LCD_TOUCH reads=%u ready=%u status=%02x online=%u reporting=%u irq=%u down=%u contacts=%u x=%u y=%u bad=%u\r\n",
   touch.status_reads,touch.ready_reports,touch.last_status,touch.online,touch.reporting,
   (get_bus(NULL)>>2)&1U,touch.down,touch.contacts,touch.x,touch.y,touch.malformed_reports);
 }
 touch_was_online=touch.online;
 if(touch.errors!=last_errors){
  last_errors=touch.errors;touch_armed=0;
  db_log("LCD touch retry=%lu nack=%u byte=%u id=%02x%02x%02x size=%ux%u\r\n",
   (unsigned long)last_errors,touch.bus.error,touch.bus.pos,
   touch.bus.rx[0],touch.bus.rx[1],touch.bus.rx[2],touch.width,touch.height);
 }
 if(touch.updated) {
  touch.updated=0;
  if(touch.down!=last_touch_down || touch.contacts!=last_touch_contacts) {
   db_log("LCD_TOUCH edge down=%u contacts=%u raw_x=%u raw_y=%u size=%ux%u\r\n",
    touch.down,touch.contacts,touch.x,touch.y,touch.width,touch.height);
   last_touch_down=touch.down;last_touch_contacts=touch.contacts;
  }
  event=db_rgb_ui_touch(&ui,touch.down,touch.contacts,touch.x,touch.y,touch.width,touch.height);
  /* Redrawing/swapping a UI frame is not a reason to discard a button press. */
  if(!touch_armed || db_screen_busy() || copying || !started || !touch.online)event=0;
  /* An I2C failure is not evidence that the finger was physically released. */
  if(touch.online && !touch.down && !touch.contacts)touch_armed=1;
  if(event)db_log("LCD button event=%u raw_x=%u raw_y=%u\r\n",event,touch.x,touch.y);
 }
 if(started && XAxiVdma_GetDmaChannelErrors(&dma,XAXIVDMA_READ)) {
  failed=1;XGpio_DiscreteWrite(&lcd_gpio,1,1);db_screen_image_release();
  db_log("LCD DMA fault; only LCD disabled\r\n");return 0;
 }
 if(waiting) {
  if(XAxiVdma_CurrFrameStore(&dma,XAXIVDMA_READ)==back) {
   front=back;back=1U-front;waiting=0;
  } else if((uint32_t)(now-swap_start)>500000U) {
   failed=1;XGpio_DiscreteWrite(&lcd_gpio,1,1);db_screen_image_release();
   db_log("LCD frame switch timeout; buffers retained\r\n");return 0;
  }
  return event;
 }
 /* Raw photo lease covers both thumbnail copies, independent of measurement. */
 if(!copying && !rendering && ui.photo.frame && ui.photo.frame!=ui.thumb_frame &&
    ui.photo.state>=DB_PHOTO_READY && db_screen_image_lock(ui.photo.frame)) {
  size_t len0,len1;raw[0]=db_screen_image(0,&len0);raw[1]=db_screen_image(1,&len1);
  if(raw[0] && raw[1] && len0==DB_IMAGE_BYTES*3U && len1==len0) {
   copying=1;copy_offset=0;copy_frame=ui.photo.frame;
  } else db_screen_image_release();
 }
 if(copying) {
  n=256U;if(n>DB_THUMB_W*DB_THUMB_H-copy_offset)n=DB_THUMB_W*DB_THUMB_H-copy_offset;
  db_rgb_ui_copy(&ui,raw[0],raw[1],copy_offset,n);copy_offset+=n;
  if(copy_offset==DB_THUMB_W*DB_THUMB_H) {
   copying=0;ui.have_thumbs=1;ui.thumb_frame=copy_frame;dirty=1;++revision;++content_revision;db_screen_image_release();
  }
  return event;
 }
 if(!rendering && dirty) {
  rendering=1;render_revision=revision;render_content_revision=content_revision;dirty=0;
  /* Distance-only changes redraw the lower 168 rows when the back buffer
   * already contains the same header/photos. Never repaint the live front. */
  row=buffer_valid[back] && buffer_content_revision[back]==content_revision?432U:0U;
 }
 if(rendering) {
  end=row+2U;if(end>DB_LCD_H)end=DB_LCD_H;
  for(n=row;n<end;++n)db_rgb_ui_row(&ui,n,buffer(back)+n*DB_LCD_W*3U);
  Xil_DCacheFlushRange((INTPTR)(buffer(back)+row*DB_LCD_W*3U),(end-row)*DB_LCD_W*3U);row=end;
  if(row==DB_LCD_H) {
   rendering=0;
   /* A new status arrived mid-render: rerender before exposing any mixed UI. */
   if(render_revision!=revision){dirty=1;return event;}
   buffer_valid[back]=1;buffer_content_revision[back]=render_content_revision;
   if(!started) {
    /* First render used buffer 0; the other buffer is not read until rendered. */
    if(!start_video()){failed=1;db_log("LCD start failed\r\n");}else started=1;
   } else if(XAxiVdma_StartParking(&dma,(int)back,XAXIVDMA_READ)==XST_SUCCESS) {
    waiting=1;swap_start=now;
    db_log("LCD photo/status frame switch requested=%u\r\n",back);
   } else {failed=1;XGpio_DiscreteWrite(&lcd_gpio,1,1);db_log("LCD parking failed\r\n");}
  }
 }
 return event;
}
void db_rgb_screen_hdmi(unsigned mode,unsigned pending)
{if(ui.hdmi_mode!=mode || ui.hdmi_pending!=pending){ui.hdmi_mode=mode;ui.hdmi_pending=pending;dirty=1;++revision;++content_revision;}}
int db_rgb_screen_attach(void)
{
 XAxiVdma_Config *dc=XAxiVdma_LookupConfig(XPAR_LCD_DMA_DEVICE_ID);
 XVtc_Config *vc=XVtc_LookupConfig(XPAR_LCD_VTC_DEVICE_ID);
 DbI2cPins pins={set_bus,get_bus,0};DbScreenAdapter adapter={poll,notify,0};
 if(!dc || !vc || XAxiVdma_CfgInitialize(&dma,dc,dc->BaseAddress)!=XST_SUCCESS ||
    XVtc_CfgInitialize(&vtc,vc,vc->BaseAddress)!=XST_SUCCESS ||
    XGpio_Initialize(&touch_gpio,XPAR_TOUCH_GPIO_DEVICE_ID)!=XST_SUCCESS ||
    XGpio_Initialize(&lcd_gpio,XPAR_LCD_CONTROL_DEVICE_ID)!=XST_SUCCESS)return 0;
 XGpio_SetDataDirection(&touch_gpio,1,0);XGpio_SetDataDirection(&touch_gpio,2,15);
 XGpio_SetDataDirection(&lcd_gpio,1,0);XGpio_DiscreteWrite(&lcd_gpio,1,0);
 db_touch_init(&touch,&pins,set_control,0,db_time_us());
 /* Read-only fallback for this specified 1024x600 panel. Reported controller
  * dimensions take precedence; no GT911 flash/configuration is rewritten. */
 db_touch_set_profile(&touch,DB_LCD_W,DB_LCD_H);
 back=0;dirty=1;
 db_log("LCD RGB 1024x600 profile=ATK7016 provisional, camera=J4 direct\r\n");
 return db_screen_attach(&adapter);
}
#else
void db_rgb_screen_hdmi(unsigned m,unsigned p){(void)m;(void)p;}
int db_rgb_screen_attach(void){return 0;}
void db_rgb_screen_controls_busy(unsigned busy){(void)busy;}
int db_rgb_screen_set_mode(unsigned mode){(void)mode;return 0;}
void db_rgb_screen_detection(uint32_t f,const DbFaceDetection *d){(void)f;(void)d;}
void db_rgb_screen_identity(uint32_t f,unsigned p,int32_t s,unsigned v){(void)f;(void)p;(void)s;(void)v;}
void db_rgb_screen_liveness(uint32_t f,unsigned s){(void)f;(void)s;}
#endif

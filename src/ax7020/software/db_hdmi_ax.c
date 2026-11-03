#include "db_hdmi_ax.h"
#include "db_preview.h"
#include "db_config.h"
#include "db_log.h"
#include "xgpiops.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "lwip/pbuf.h"
#include <string.h>
#define FRAME_BYTES (1280U*720U*3U)
#define PREVIEW_BASE 0x10000000U
#define PREVIEW_STEP 0x00300000U
#define OFFSET ((16U*1280U+128U)*3U)
#if PREVIEW_BASE+3U*PREVIEW_STEP-1U > XPAR_PS7_DDR_0_S_AXI_HIGHADDR
#error "Preview frames exceed AX DDR"
#endif
static XAxiVdma *display;static XGpioPs keys;static unsigned keys_ok;
static struct udp_pcb *pcb;
static uint32_t session,revision=1,last_command,last_status,last_key,changed_at,stop_started,swap_started;
static unsigned mode,applied,front,back=1,receiving=1,complete_slot=1,ready,waiting,stopping,disabled;
static unsigned sample_key=1,stable_key=1;
static DbPreviewAssembly assembly;
static uint32_t complete_frames,discarded,shown_frames,stats_at,busy_rows,superseded;
static void choose_receiver(void);
static uint8_t packet[DB_PREVIEW_PACKET];
static uint8_t *buffer(unsigned i){return (uint8_t *)(uintptr_t)(PREVIEW_BASE+i*PREVIEW_STEP);}
static void receive(void *arg,struct udp_pcb *u,struct pbuf *p,const ip_addr_t *addr,u16_t port)
{
 DbPreviewRow r;int accepted;(void)arg;(void)u;(void)addr;(void)port;
 if(!p)return;
 if(disabled||!session||mode!=DB_HDMI_COLOR||stopping||p->tot_len!=sizeof(packet))goto done;
 if(receiving>=3){choose_receiver();if(receiving>=3){++busy_rows;goto done;}}
 if(pbuf_copy_partial(p,packet,sizeof(packet),0)!=sizeof(packet) || !db_preview_decode(&r,packet,sizeof(packet)) || r.session!=session){++discarded;goto done;}
 accepted=db_preview_accept(&assembly,&r,db_time_us());
 if(accepted){
  uint8_t *dst=buffer(receiving)+((16U+160U+r.row)*1280U+128U+r.camera*512U)*3U;
  db_preview_expand(dst,packet+DB_PREVIEW_HEADER);Xil_DCacheFlushRange((INTPTR)dst,512U*3U);
  if(accepted==2){
   if(ready)++superseded;
   complete_slot=receiving;receiving=3;ready=1;++complete_frames;
   /* UDP callbacks can continue before the next display poll. Reserve the
    * third buffer immediately so the next frame's first rows are not lost. */
   choose_receiver();
  }
 }
done:pbuf_free(p);
}
int db_hdmi_ax_init(DbNet *net,XAxiVdma *v)
{
 unsigned i;XGpioPs_Config *cfg=XGpioPs_LookupConfig(XPAR_XGPIOPS_0_DEVICE_ID);display=v;
 if(cfg && XGpioPs_CfgInitialize(&keys,cfg,cfg->BaseAddr)==XST_SUCCESS){
  /* AX7020 manual pp.30-31: PS KEY1=MIO50, active low. Never use reset. */
  XGpioPs_SetDirectionPin(&keys,50,0);keys_ok=1;sample_key=stable_key=XGpioPs_ReadPin(&keys,50);
 }
 for(i=0;i<3;++i){memset(buffer(i),0,FRAME_BYTES);Xil_DCacheFlushRange((INTPTR)buffer(i),FRAME_BYTES);}
 if(!net->udp)return 0;
 pcb=udp_new();if(!pcb)return 0;
 if(udp_bind(pcb,IP_ADDR_ANY,DB_PREVIEW_PORT)!=ERR_OK){udp_remove(pcb);pcb=0;return 0;}
 udp_recv(pcb,receive,0);db_log("HDMI modes ready: PS KEY1 MIO50, original color preview\r\n");return 1;
}
unsigned db_hdmi_ax_mode(void){return applied;}
static void choose_receiver(void)
{
 unsigned i;if(receiving<3)return;
 for(i=0;i<3;++i)if(i!=front && (!waiting||i!=back) && (!ready||i!=complete_slot)){receiving=i;break;}
}
static void select_mode(unsigned m)
{
 if(m==mode)return;
 mode=m;if(++revision==0)++revision;last_status=0;
 ready=0;receiving=3;choose_receiver();memset(&assembly,0,sizeof(assembly));
 db_log("HDMI requested=%s\r\n",mode?"original_color_L_R":"depth");
}
static int configure(unsigned color,unsigned selected)
{
 XAxiVdma_DmaSetup cfg;unsigned i;memset(&cfg,0,sizeof(cfg));
 cfg.VertSizeInput=640;cfg.HoriSizeInput=1024U*3U;cfg.Stride=1280U*3U;
 cfg.EnableCircularBuf=color?0:1;cfg.EnableSync=color?0:1;cfg.FrameDelay=color?0:2;
 cfg.FixedFrameStoreAddr=color?selected:0;
 for(i=0;i<3;++i)cfg.FrameStoreStartAddr[i]=(color?(UINTPTR)buffer(i):DB_RESULT_BASE+i*FRAME_BYTES)+OFFSET;
 return XAxiVdma_DmaConfig(display,XAXIVDMA_READ,&cfg)==XST_SUCCESS &&
  XAxiVdma_DmaSetBufferAddr(display,XAXIVDMA_READ,cfg.FrameStoreStartAddr)==XST_SUCCESS &&
  XAxiVdma_DmaStart(display,XAXIVDMA_READ)==XST_SUCCESS;
}
void db_hdmi_ax_poll(DbControlNet *ctrl,uint32_t sid,uint32_t now)
{
 DbControl m;
 if(session!=sid){session=sid;last_command=0;last_status=0;if(++revision==0)++revision;ready=0;receiving=3;choose_receiver();memset(&assembly,0,sizeof(assembly));}
 if(pcb && session && db_control_net_take(ctrl,DB_CTRL_DISPLAY_SET,&m) && m.session==session && m.calibration==DB_CALIBRATION_ID){
  if(!last_command||(int32_t)(m.id-last_command)>0){last_command=m.id;select_mode(m.data[0]);}
  last_status=0;
 }
 if(keys_ok && (uint32_t)(now-last_key)>=5000U){
  unsigned k=XGpioPs_ReadPin(&keys,50);last_key=now;
  if(k!=sample_key){sample_key=k;changed_at=now;}
  else if(k!=stable_key && (uint32_t)(now-changed_at)>=30000U){stable_key=k;if(!k && pcb)select_mode(mode^1U);}
 }
 if(!disabled){
  if(waiting){
   if(XAxiVdma_CurrFrameStore(display,XAXIVDMA_READ)==back){front=back;waiting=0;++shown_frames;choose_receiver();}
   else if((uint32_t)(now-swap_started)>500000U){disabled=1;db_log("HDMI parking timeout; preview buffers retained\r\n");}
  }
  if(!waiting && !stopping && mode!=applied && (!mode||ready)){
   XAxiVdma_DmaStop(display,XAXIVDMA_READ);stopping=1;stop_started=now;
  }
  if(stopping){
   if(!XAxiVdma_IsBusy(display,XAXIVDMA_READ)){
    if(mode)back=complete_slot;
    if(configure(mode,back)){
     applied=mode;stopping=0;last_status=0;
     if(mode){waiting=1;swap_started=now;ready=0;choose_receiver();}
     db_log("HDMI applied=%s complete_preview=%lu rejected=%lu\r\n",mode?"original_color_L_R":"depth",(unsigned long)complete_frames,(unsigned long)discarded);
    }else{disabled=1;db_log("HDMI reconfigure failed; measurement remains active\r\n");}
   }else if((uint32_t)(now-stop_started)>500000U){disabled=1;db_log("HDMI stop timeout; no reset of stereo engine\r\n");}
  }else if(!waiting && ready && applied==DB_HDMI_COLOR && mode==applied){
   back=complete_slot;
   if(XAxiVdma_StartParking(display,(int)back,XAXIVDMA_READ)==XST_SUCCESS){ready=0;waiting=1;swap_started=now;choose_receiver();}
   else{disabled=1;db_log("HDMI preview park failed\r\n");}
  }
 }
 if((uint32_t)(now-stats_at)>=1000000U){
  stats_at=now;db_log("PREVIEW received=%lu displayed=%lu rejected=%lu mode=%u\r\n",
   (unsigned long)complete_frames,(unsigned long)shown_frames,(unsigned long)discarded,applied);
  db_log("PREVIEW_QUEUE busy_rows=%lu superseded=%lu receiving=%u ready=%u waiting=%u\r\n",
   (unsigned long)busy_rows,(unsigned long)superseded,receiving,ready,waiting);
 }
 if(session && (uint32_t)(now-last_status)>=250000U){
  memset(&m,0,sizeof(m));m.type=DB_CTRL_DISPLAY_STATUS;m.session=session;m.calibration=DB_CALIBRATION_ID;
  m.id=last_command;m.frame=revision;m.data[0]=mode;m.data[1]=applied;m.data[2]=disabled;
  if(db_control_net_send(ctrl,&m))last_status=now;
 }
}

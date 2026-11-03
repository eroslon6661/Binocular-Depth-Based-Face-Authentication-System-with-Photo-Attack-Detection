#include "db_hdmi_nav.h"
#include "db_preview.h"
#include "db_screen.h"
#include "db_rgb_screen.h"
#include "db_calibration.h"
#include "db_log.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "lwip/pbuf.h"
#include <string.h>
static struct udp_pcb *pcb;
static struct pbuf *pool[4];static void *payload[4];
static uint32_t session,command,revision,last_status,last_command,command_started,last_packet,frame,tx_started;
static unsigned mode,applied,pending,txrow,txactive;
static unsigned encoding,encode_row,encode_slot,send_slot,packed_ready[2];
static uint32_t pack_started,encoded_count,sent_count,expired_count,last_metrics,pack_us,send_us;
#define PACKET_BASE 0x12E00000U
#define PACKET_STEP 0x00100000U
#if DB_PREVIEW_ROWS*DB_PREVIEW_PACKET > PACKET_STEP || PACKET_BASE+2U*PACKET_STEP-1U > XPAR_PS7_DDR_0_S_AXI_HIGHADDR
#error "Preview packet buffers exceed reserved DDR"
#endif
static uint8_t *packed(unsigned slot,unsigned row){return (uint8_t *)(uintptr_t)(PACKET_BASE+slot*PACKET_STEP+row*DB_PREVIEW_PACKET);}
static DbControl request;
static const uint8_t *images[2];static uint32_t stamps[2];
int db_hdmi_nav_init(DbNet *net,uint32_t sid)
{
 unsigned i;int vector_status;session=sid;if(!net->udp)return 0;
 vector_status=db_preview_pixels_init();
 if(db_preview_shading_init())db_log("PREVIEW color shading: separate camera maps, NEON selftest passed, HDMI only\r\n");
 else db_log("PREVIEW color shading: disabled, selftest failed\r\n");
 db_log("PREVIEW pixel kernel=%s selftest=%s\r\n",vector_status>0?"NEON":"scalar",vector_status<0?"fallback":"passed");
 pcb=udp_new();if(!pcb)return 0;
 if(udp_connect(pcb,&net->udp->remote_ip,DB_PREVIEW_PORT)!=ERR_OK)goto fail;
 for(i=0;i<4;++i){pool[i]=pbuf_alloc(PBUF_TRANSPORT,DB_PREVIEW_PACKET,PBUF_RAM);if(!pool[i])goto fail;payload[i]=pool[i]->payload;}
 return 1;
fail:
 for(i=0;i<4;++i)if(pool[i]){pbuf_free(pool[i]);pool[i]=0;}
 udp_remove(pcb);pcb=0;return 0;
}
void db_hdmi_nav_control(DbControlNet *c,uint32_t now,unsigned toggle)
{
 DbControl m;
 if(db_control_net_take(c,DB_CTRL_DISPLAY_STATUS,&m) && m.session==session && m.calibration==DB_CALIBRATION_ID &&
    (!revision||(int32_t)(m.frame-revision)>=0||(uint32_t)(now-last_status)>1500000U)) {
  revision=m.frame;last_status=now;mode=m.data[0];applied=m.data[1];
  if(pending && m.id==request.id)pending=0;
 }
 if(toggle && pcb && !pending && last_status && (uint32_t)(now-last_status)<1500000U){
  memset(&request,0,sizeof(request));request.type=DB_CTRL_DISPLAY_SET;request.session=session;
  request.calibration=DB_CALIBRATION_ID;if(++command==0)++command;request.id=command;request.data[0]=mode^1U;
  pending=1;last_command=0;command_started=now;
 }
 if(pending && (uint32_t)(now-command_started)>1500000U){pending=0;db_log("HDMI switch timeout; mode not assumed\r\n");}
 if(pending && (uint32_t)(now-last_command)>=DB_CONTROL_RETRY_US)
  if(db_control_net_send(c,&request))last_command=now;
 db_rgb_screen_hdmi(applied,pending || mode!=applied);
}
/* One DMA pair is converted into private wire-packet storage in small slices.
 * As soon as packing finishes, the photo DMA can capture the next pair while
 * GEM sends the previous one. Packet storage never aliases raw/photo buffers.
 * Datagram copies enter ref-counted pbufs, so GEM never owns a packing slot. */
/* Only an acknowledged, fresh COLOR status may pause background depth.
 * A missing peer/status automatically restores the depth scheduler. */
int db_hdmi_nav_color_active(uint32_t now)
{return pcb && mode==DB_HDMI_COLOR && last_status && (uint32_t)(now-last_status)<=1500000U;}
void db_hdmi_nav_poll(uint32_t now,uint32_t clock,unsigned idle)
{
 unsigned i,c,y,budget;DbPreviewRow r;
 if(!pcb)return;
 if(mode!=DB_HDMI_COLOR || !last_status || (uint32_t)(now-last_status)>1500000U || !idle){
  txactive=encoding=0;packed_ready[0]=packed_ready[1]=0;
  db_screen_preview_cancel();return;
 }
 if(!encoding){
  unsigned slot;
  for(slot=0;slot<2;++slot)if(!packed_ready[slot] && (!txactive||slot!=send_slot))break;
  if(slot<2 && db_screen_preview_acquire(images,stamps)){encoding=1;encode_slot=slot;encode_row=0;pack_started=db_time_us();if(++frame==0)++frame;}
 }
 /* Rearm a FREE raw pair before packing the LEASED pair. This catches the
  * next camera SOF even while CPU conversion still reads the preceding frame. */
 db_screen_preview_start(db_time_us(),clock);
 /* Limit each call to eight rows, leaving network/audio/input service time. */
 for(budget=0;encoding && budget<8;++budget){
  c=encode_row/DB_PREVIEW_H;y=encode_row%DB_PREVIEW_H;
  r.session=session;r.frame=frame;r.stamp[0]=stamps[0];r.stamp[1]=stamps[1];r.camera=c;r.row=y;
  {const uint8_t *line=images[c]+(y*720U/DB_PREVIEW_H)*1280U*3U;
   Xil_DCacheInvalidateRange((INTPTR)line,1280U*3U);
   db_preview_encode(packed(encode_slot,encode_row),&r,line);
  }
  if(++encode_row==DB_PREVIEW_ROWS){
   encoding=0;packed_ready[encode_slot]=1;++encoded_count;
   pack_us=db_time_us()-pack_started;db_screen_preview_release();
  }
 }
 if(!txactive){
  for(i=0;i<2;++i)if(packed_ready[i])break;
  if(i<2){send_slot=i;packed_ready[i]=0;txrow=0;txactive=1;tx_started=db_time_us();}
 }
 if(txactive){
  if((uint32_t)(db_time_us()-tx_started)>200000U){txactive=0;++expired_count;}
  /* No catch-up burst: actual clock pacing prevents receive-ring flooding. */
  for(budget=0;txactive && budget<4;++budget){
   uint32_t tick=db_time_us();if((uint32_t)(tick-last_packet)<20U)break;
   for(i=0;i<4;++i)if(pool[i]->ref==1)break;
   if(i==4)break;
   pool[i]->payload=payload[i];pool[i]->len=pool[i]->tot_len=DB_PREVIEW_PACKET;pool[i]->next=0;
   memcpy(pool[i]->payload,packed(send_slot,txrow),DB_PREVIEW_PACKET);
   if(udp_send(pcb,pool[i])!=ERR_OK)break;
   last_packet=db_time_us();
   if(++txrow==DB_PREVIEW_ROWS){txactive=0;++sent_count;send_us=db_time_us()-tx_started;}
  }
 }
 if((uint32_t)(now-last_metrics)>=1000000U){
  last_metrics=now;db_log("PREVIEW packed=%lu sent=%lu expired=%lu pack_us=%lu send_us=%lu\r\n",
   (unsigned long)encoded_count,(unsigned long)sent_count,(unsigned long)expired_count,
   (unsigned long)pack_us,(unsigned long)send_us);
 }
}

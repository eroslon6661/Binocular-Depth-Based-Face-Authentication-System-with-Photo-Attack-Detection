
#include "db_color_diag.h"
#include "db_preview.h"
#include "xil_cache.h"
#include "db_log.h"
#include <string.h>
extern unsigned char sccb_read_reg16(unsigned char camera,unsigned short address);
extern void sccb_write_reg16(unsigned char camera,unsigned short address,unsigned char value);
/* Temporary diagnostic mailbox. No image, calibration or audio processing changes.
 * Commands: 1 read/snapshot, 2 LENC off, 3 restore exact saved ISP_CONTROL00.
 * Submit command first, then a fresh sequence; poll only while UI/voice idle. */
typedef struct {
 uint32_t magic,sequence,command,ack,status,saved_valid;
 uint32_t saved[2],current[2],sensor_id[2],awb[2][7],lenc[2][62];
} ColorDiag;
volatile ColorDiag db_color_diag __attribute__((aligned(64)));
static uint32_t last_poll;
static unsigned saved[2],valid;
void db_color_diag_init(void){memset((void *)&db_color_diag,0,sizeof(db_color_diag));
 db_color_diag.magic=0x434f4c52U;
 Xil_DCacheFlushRange((INTPTR)&db_color_diag,sizeof(db_color_diag));}
void db_color_diag_poll(uint32_t now,unsigned busy){
 unsigned c,i,cmd;uint32_t seq;
 if(busy || (uint32_t)(now-last_poll)<100000U)return;
 last_poll=now;
 Xil_DCacheInvalidateRange((INTPTR)&db_color_diag,sizeof(db_color_diag));
 seq=db_color_diag.sequence;cmd=db_color_diag.command;
 if(!seq || seq==db_color_diag.ack)return;
 db_color_diag.status=0;
 for(c=0;c<2;++c){unsigned id=((unsigned)sccb_read_reg16(c,0x300a)<<8)|sccb_read_reg16(c,0x300b);
  db_color_diag.sensor_id[c]=id;if(id!=0x5640U)db_color_diag.status=1;}
 if(!db_color_diag.status){
  if(!valid){for(c=0;c<2;++c)saved[c]=sccb_read_reg16(c,0x5000);valid=1;}
  if(cmd==1){for(c=0;c<2;++c){
   for(i=0;i<7;++i)db_color_diag.awb[c][i]=sccb_read_reg16(c,0x3400+i);
   for(i=0;i<62;++i)db_color_diag.lenc[c][i]=sccb_read_reg16(c,0x5800+i);}}
  else if(cmd==2 || cmd==3){for(c=0;c<2;++c){
   unsigned value=cmd==2?(saved[c]&~0x80U):saved[c];
   sccb_write_reg16(c,0x5000,value);
   if(sccb_read_reg16(c,0x5000)!=value)db_color_diag.status=2;}}
  else if(cmd==4 || cmd==5)db_preview_shading_set(cmd==4);
  else db_color_diag.status=3;
 }
 for(c=0;c<2;++c){db_color_diag.saved[c]=saved[c];db_color_diag.current[c]=sccb_read_reg16(c,0x5000);}
 db_color_diag.saved_valid=valid;db_color_diag.ack=seq;
 db_log("COLOR_DIAG sequence=%lu cmd=%u status=%lu saved=%02lx,%02lx current=%02lx,%02lx\r\n",
  (unsigned long)seq,cmd,(unsigned long)db_color_diag.status,(unsigned long)db_color_diag.saved[0],
  (unsigned long)db_color_diag.saved[1],(unsigned long)db_color_diag.current[0],(unsigned long)db_color_diag.current[1]);
 Xil_DCacheFlushRange((INTPTR)&db_color_diag,sizeof(db_color_diag));
}

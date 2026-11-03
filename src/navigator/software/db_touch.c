#include "db_touch.h"
#include <string.h>
enum {IDLE,FREE_BUS,START_PULL,START_LOW,TX_LOW,TX_RISE,TX_HIGH,
 ACK_LOW,ACK_RISE,ACK_HIGH,RESTART_LOW,RESTART_RELEASE,RESTART_HIGH,
 RX_LOW,RX_RISE,RX_HIGH,NAK_LOW,NAK_RISE,NAK_HIGH,STOP_LOW,STOP_RISE,STOP_HIGH};
static void drive(DbI2c *b,unsigned v){b->pins.drive(b->pins.context,v);}
static unsigned sense(DbI2c *b){return b->pins.sense(b->pins.context);}
void db_i2c_init(DbI2c *b,const DbI2cPins *p){memset(b,0,sizeof(*b));b->pins=*p;drive(b,0);}
int db_i2c_begin(DbI2c *b,unsigned address,unsigned reg,const uint8_t *data,unsigned count,unsigned read,uint32_t now)
{
 if(b->state || !count || count>16 || address>127 || (!read && !data))return 0;
 b->tx[0]=(uint8_t)(address<<1);b->tx[1]=(uint8_t)(reg>>8);b->tx[2]=(uint8_t)reg;
 if(!read)memcpy(b->tx+3,data,count);
 b->len=read?3:count+3;b->count=count;b->read=read;b->reading=0;
 b->pos=0;b->bit=7;b->error=0;b->result=0;b->start=b->last=now;
 b->state=FREE_BUS;drive(b,0);return 1;
}
void db_i2c_poll(DbI2c *b,uint32_t now)
{
 unsigned lines,low;
 if(!b->state || (uint32_t)(now-b->last)<5U)return;
 if((uint32_t)(now-b->start)>200000U) {
  drive(b,0);b->state=IDLE;b->result=-1;return;
 }
 lines=sense(b);b->last=now;
 switch(b->state) {
 case FREE_BUS: if((lines&3U)==3U){drive(b,2);b->state=START_PULL;}break;
 case START_PULL: drive(b,3);b->state=START_LOW;break;
 case START_LOW: b->bit=7;b->state=TX_LOW;break;
 case TX_LOW: low=(b->tx[b->pos]&(1U<<b->bit))?0:2;drive(b,1|low);b->state=TX_RISE;break;
 case TX_RISE: low=(b->tx[b->pos]&(1U<<b->bit))?0:2;drive(b,low);b->state=TX_HIGH;break;
 case TX_HIGH:
  if(!(lines&1U))break;
  drive(b,1|((b->tx[b->pos]&(1U<<b->bit))?0:2));
  if(b->bit)--b->bit;else b->state=ACK_LOW;
  if(b->state!=ACK_LOW)b->state=TX_LOW;
  break;
 case ACK_LOW: drive(b,1);b->state=ACK_RISE;break;
 case ACK_RISE: drive(b,0);b->state=ACK_HIGH;break;
 case ACK_HIGH:
  if(!(lines&1U))break;
  drive(b,1);
  if(lines&2U){b->error=1;b->state=STOP_LOW;}
  else if(++b->pos<b->len){b->bit=7;b->state=TX_LOW;}
  else if(b->reading){b->pos=0;b->bit=7;b->value=0;b->state=RX_LOW;}
  else if(b->read)b->state=RESTART_LOW;
  else b->state=STOP_LOW;
  break;
 case RESTART_LOW: drive(b,1);b->state=RESTART_RELEASE;break;
 case RESTART_RELEASE: drive(b,0);b->state=RESTART_HIGH;break;
 case RESTART_HIGH:
  if(!(lines&1U))break;
  drive(b,2);b->tx[0]|=1;b->len=1;b->pos=0;b->reading=1;b->state=START_PULL;break;
 case RX_LOW: drive(b,1);b->state=RX_RISE;break;
 case RX_RISE: drive(b,0);b->state=RX_HIGH;break;
 case RX_HIGH:
  if(!(lines&1U))break;
  b->value=(b->value<<1)|((lines>>1)&1U);drive(b,1);
  if(b->bit){--b->bit;b->state=RX_LOW;}
  else {b->rx[b->pos++]=(uint8_t)b->value;b->state=NAK_LOW;}
  break;
 case NAK_LOW: drive(b,b->pos<b->count?3:1);b->state=NAK_RISE;break;
 case NAK_RISE: drive(b,b->pos<b->count?2:0);b->state=NAK_HIGH;break;
 case NAK_HIGH:
  if(!(lines&1U))break;
  drive(b,b->pos<b->count?3:1);
  if(b->pos<b->count){b->bit=7;b->value=0;b->state=RX_LOW;}else b->state=STOP_LOW;
  break;
 case STOP_LOW: drive(b,3);b->state=STOP_RISE;break;
 case STOP_RISE: drive(b,2);b->state=STOP_HIGH;break;
 case STOP_HIGH: if(lines&1U){drive(b,0);b->state=IDLE;b->result=b->error?-1:1;}break;
 default: drive(b,0);b->state=IDLE;b->result=-1;break;
 }
}
static int due(uint32_t now,uint32_t end){return (int32_t)(now-end)>=0;}
static int read_reg(DbTouch *t,unsigned reg,unsigned count,uint32_t now)
{return db_i2c_begin(&t->bus,0x5d,reg,0,count,1,now);}
static int clear(DbTouch *t,uint32_t now)
{const uint8_t zero=0;return db_i2c_begin(&t->bus,0x5d,0x814e,&zero,1,0,now);}
static int coordinates_mode(DbTouch *t,uint32_t now)
{
 /* Only the runtime command is changed. No panel scan matrix or saved
  * configuration is written (GT911 Command 0: coordinate status mode). */
 const uint8_t zero=0;
 return db_i2c_begin(&t->bus,0x5d,0x8040,&zero,1,0,now);
}
void db_touch_init(DbTouch *t,const DbI2cPins *pins,void (*ctrl)(void *,unsigned,unsigned),void *ctx,uint32_t now)
{
 memset(t,0,sizeof(*t));t->control=ctrl;t->context=ctx;db_i2c_init(&t->bus,pins);
 ctrl(ctx,0,1);t->deadline=now+20000U;
}
void db_touch_set_profile(DbTouch *t,unsigned width,unsigned height)
{
 if(!t)return;
 t->profile_width=(width && width<=4096U && height && height<=4096U)?width:0;
 t->profile_height=t->profile_width?height:0;
}
void db_touch_poll(DbTouch *t,uint32_t now)
{
 unsigned n;uint8_t *r=t->bus.rx;
 db_i2c_poll(&t->bus,now);
 if(t->bus.state)return;
 if(t->bus.result<0) {
  t->bus.result=0;t->online=t->using_profile=t->reporting=0;t->errors++;t->phase=0;
  t->down=t->contacts=0;t->updated=1;
  t->control(t->context,0,1);t->deadline=now+1000000U;return;
 }
 switch(t->phase) {
 case 0: if(due(now,t->deadline)){t->control(t->context,1,1);t->deadline=now+6000U;t->phase=1;}break;
 case 1: if(due(now,t->deadline)) {
  /* T5 synchronization: INT stays driven low for 50 ms AFTER reset release
   * and T4. Waiting 50 ms after releasing INT is not the same sequence. */
  t->control(t->context,1,1);t->deadline=now+50000U;t->phase=9;
 }break;
 case 9: if(due(now,t->deadline)) {
  t->control(t->context,1,0);t->deadline=now+50000U;t->phase=2;
 }break;
 case 2: if(due(now,t->deadline) && read_reg(t,0x8140,10,now))t->phase=3;break;
 case 3:
  t->using_profile=0;
  t->firmware=r[4]|((unsigned)r[5]<<8);
  t->bus.result=0;t->width=r[6]|((unsigned)r[7]<<8);t->height=r[8]|((unsigned)r[9]<<8);
  if(r[0]!='9' || r[1]!='1' || r[2]!='1' || t->width>4096 || t->height>4096) {
   t->errors++;t->control(t->context,0,1);t->phase=0;t->deadline=now+1000000U;break;
  }
  /* Some modules return zero in the runtime resolution mirror (0x8146).
   * Read the documented X/Y Output Max configuration, without rewriting it
   * or assuming that touch coordinates equal the LCD pixel dimensions. */
  if(!t->width && !t->height) {
   if(read_reg(t,0x8048,4,now))t->phase=8;
   break;
  }
  if(!t->width || !t->height) {
   t->errors++;t->control(t->context,0,1);t->phase=0;t->deadline=now+1000000U;break;
  }
  if(coordinates_mode(t,now))t->phase=10;
  break;
 case 8:
  t->bus.result=0;t->width=r[0]|((unsigned)r[1]<<8);t->height=r[2]|((unsigned)r[3]<<8);
  if(!t->width && !t->height && t->profile_width && t->profile_height) {
   t->width=t->profile_width;t->height=t->profile_height;t->using_profile=1;
  }
  if(!t->width || !t->height || t->width>4096 || t->height>4096) {
   t->errors++;t->control(t->context,0,1);t->phase=0;t->deadline=now+1000000U;break;
  }
  if(coordinates_mode(t,now))t->phase=10;
  break;
 case 10:
  t->bus.result=0;t->online=1;t->phase=4;t->deadline=now;break;
 case 4: if(due(now,t->deadline) && read_reg(t,0x814e,1,now))t->phase=5;break;
 case 5:
  t->bus.result=0;n=r[0]&15U;
  t->last_status=r[0];++t->status_reads;
  if(!(r[0]&0x80U)){t->phase=4;t->deadline=now+10000U;break;}
  ++t->ready_reports;
  t->contacts=n;t->down=n!=0;
  if(n==1 && read_reg(t,0x814f,8,now))t->phase=6;
  else {
   if(n<=5U)t->reporting=1;else {t->contacts=2;++t->malformed_reports;}
   t->updated=1;if(clear(t,now))t->phase=7;
  }
  break;
 case 6:
  t->bus.result=0;t->x=r[1]|((unsigned)r[2]<<8);t->y=r[3]|((unsigned)r[4]<<8);
  if(t->x>=t->width || t->y>=t->height){t->contacts=2;++t->malformed_reports;}
  else t->reporting=1;
  t->updated=1;if(clear(t,now))t->phase=7;break;
 case 7: t->bus.result=0;t->phase=4;t->deadline=now+10000U;break;
 default: break;
 }
}

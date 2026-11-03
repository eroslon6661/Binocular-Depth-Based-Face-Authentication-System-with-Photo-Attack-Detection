#include "db_control.h"
#include "db_wire.h"
#include <string.h>
static void put32(uint8_t *p,uint32_t v){p[0]=(uint8_t)(v>>24);p[1]=(uint8_t)(v>>16);p[2]=(uint8_t)(v>>8);p[3]=(uint8_t)v;}
static uint32_t get32(const uint8_t *p){return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3];}
static int valid(const DbControl *m)
{
    if(!m || !m->session || !m->calibration || m->type<DB_CTRL_HELLO || m->type>=DB_CTRL_TYPE_COUNT ||
       m->x>=DB_WIDTH || m->y>=DB_HEIGHT || m->status>DB_CTRL_SPOOF)return 0;
    if((m->type==DB_CTRL_REQUEST || m->type==DB_CTRL_PHOTO_REQUEST || m->type==DB_CTRL_RESULT ||
       m->type==DB_CTRL_RESULT_ACK || m->type==DB_CTRL_LIVE_REQUEST ||
       m->type==DB_CTRL_LIVE_RESULT || m->type==DB_CTRL_LIVE_ACK) && !m->id)return 0;
    if((m->type==DB_CTRL_PHOTO_REQUEST || m->type==DB_CTRL_PHOTO_ACK) &&
       (!m->frame || !m->id || m->status!=DB_CTRL_PENDING || m->distance_mm))return 0;
    if(m->type==DB_CTRL_RESULT && (m->status==DB_CTRL_PENDING ||
       (m->status==DB_CTRL_OK?(!m->distance_mm || m->distance_mm>3000U):m->distance_mm!=0U)))return 0;
    if(m->type==DB_CTRL_LIVE_REQUEST && (!m->frame || m->status!=DB_CTRL_PENDING || m->distance_mm))return 0;
    if(m->type==DB_CTRL_LIVE_RESULT && (m->status==DB_CTRL_PENDING || !m->frame ||
       (m->distance_mm && m->distance_mm>3000U)))return 0;
    if((m->type==DB_CTRL_DISPLAY_SET || m->type==DB_CTRL_DISPLAY_STATUS) &&
       (m->data[0]>1U || m->data[1]>1U || m->distance_mm || m->status))return 0;
    if(m->type==DB_CTRL_DISPLAY_SET && !m->id)return 0;
    return 1;
}
int db_control_encode(uint8_t p[DB_CONTROL_BYTES],const DbControl *m)
{
    if(!p || !valid(m))return 0;
    memset(p,0,DB_CONTROL_BYTES);put32(p,0x4442434fU);p[4]=2;p[5]=m->type;
    put32(p+8,m->session);put32(p+12,m->calibration);put32(p+16,m->id);
    put32(p+20,m->frame);put32(p+24,m->capture_us);
    p[28]=(uint8_t)(m->x>>8);p[29]=(uint8_t)m->x;p[30]=(uint8_t)(m->y>>8);p[31]=(uint8_t)m->y;
    put32(p+32,m->distance_mm);put32(p+36,m->status);
    {unsigned i;for(i=0;i<10U;++i){p[40U+i*2U]=(uint8_t)(m->data[i]>>8);p[41U+i*2U]=(uint8_t)m->data[i];}}
    put32(p+60,db_crc32(p,60));return 1;
}
int db_control_decode(DbControl *m,const uint8_t *p,size_t n)
{
    DbControl v;unsigned i;
    if(!m || !p || n!=DB_CONTROL_BYTES || get32(p)!=0x4442434fU || p[4]!=2 || p[6] || p[7] ||
       get32(p+60)!=db_crc32(p,60))return 0;
    memset(&v,0,sizeof(v));v.type=p[5];v.session=get32(p+8);v.calibration=get32(p+12);
    v.id=get32(p+16);v.frame=get32(p+20);v.capture_us=get32(p+24);
    v.x=(uint16_t)((unsigned)p[28]*256U+p[29]);v.y=(uint16_t)((unsigned)p[30]*256U+p[31]);
    v.distance_mm=get32(p+32);v.status=get32(p+36);
    for(i=0;i<10U;++i)v.data[i]=(uint16_t)((unsigned)p[40U+i*2U]*256U+p[41U+i*2U]);
    if(!valid(&v))return 0;
    *m=v;return 1;
}
void db_control_client_init(DbControlClient *c,uint32_t session,uint32_t calibration)
{memset(c,0,sizeof(*c));c->session=session;c->calibration=calibration;}
int db_control_request(DbControlClient *c,unsigned x,unsigned y,uint32_t now)
{return db_control_request_at(c,x,y,now,now);}
int db_control_request_at(DbControlClient *c,unsigned x,unsigned y,uint32_t now,uint32_t capture_clock)
{
    if(!c || c->active || x>=DB_WIDTH || y>=DB_HEIGHT)return 0;
    memset(&c->request,0,sizeof(c->request));c->request.type=DB_CTRL_REQUEST;
    c->request.session=c->session;c->request.calibration=c->calibration;
    if(++c->next_id==0)++c->next_id;
    c->request.id=c->next_id;c->request.x=(uint16_t)x;c->request.y=(uint16_t)y;
    c->request.capture_us=capture_clock;c->started_us=now;c->active=1;return 1;
}
int db_control_same_request(const DbControl *a,const DbControl *b)
{return a->session==b->session && a->calibration==b->calibration && a->id==b->id &&
        a->x==b->x && a->y==b->y && a->capture_us==b->capture_us &&
        ((a->type!=DB_CTRL_PHOTO_REQUEST && b->type!=DB_CTRL_PHOTO_REQUEST) ||
         (a->type==b->type && a->frame==b->frame));}
int db_control_request_frame(DbControlClient *c,unsigned x,unsigned y,uint32_t now,uint32_t frame,uint32_t stamp)
{
    if(!frame || !db_control_request_at(c,x,y,now,stamp))return 0;
    c->request.type=DB_CTRL_PHOTO_REQUEST;c->request.frame=frame;return 1;
}
int db_control_frame_eligible(const DbControl *r,uint32_t left,uint32_t right)
{return r && r->type==DB_CTRL_REQUEST && (int32_t)(left-r->capture_us)>=0 && (int32_t)(right-r->capture_us)>=0;}
int db_control_pair_eligible(const DbControl *r,uint32_t frame,uint32_t left,uint32_t right)
{
    if(!r)return 0;
    if(r->type==DB_CTRL_PHOTO_REQUEST)return r->frame==frame && r->frame &&
        (left==r->capture_us || right==r->capture_us) &&
        (int32_t)(left-r->capture_us)>=0 && (int32_t)(right-r->capture_us)>=0;
    return db_control_frame_eligible(r,left,right);
}
int db_control_photo_ack(const DbControl *r,const DbControl *ack)
{
    DbControl copy;
    if(!r || !ack || r->type!=DB_CTRL_PHOTO_REQUEST || ack->type!=DB_CTRL_PHOTO_ACK || !valid(ack))return 0;
    copy=*ack;copy.type=DB_CTRL_PHOTO_REQUEST;return db_control_same_request(r,&copy);
}
static int same_result(const DbControl *a,const DbControl *b)
{return db_control_same_request(a,b) && a->frame==b->frame &&
        a->distance_mm==b->distance_mm && a->status==b->status;}
int db_control_accept(DbControlClient *c,const DbControl *r,uint32_t now)
{
    if(!c || !valid(r) || r->type!=DB_CTRL_RESULT || r->session!=c->session || r->calibration!=c->calibration)return 0;
    if(c->have_accepted && same_result(&c->accepted,r))return 2;
    if(!c->active || r->id!=c->request.id || r->x!=c->request.x || r->y!=c->request.y)return 0;
    if(c->request.type==DB_CTRL_PHOTO_REQUEST && r->status!=DB_CTRL_TIMEOUT &&
       (r->frame!=c->request.frame || r->capture_us!=c->request.capture_us))return 0;
    if(r->status!=DB_CTRL_TIMEOUT && ((int32_t)(r->capture_us-c->request.capture_us)<0 ||
       (uint32_t)(now-r->capture_us)>DB_CONTROL_FRESH_US || !r->frame))return 0;
    c->accepted=*r;c->have_accepted=1;c->active=0;return 1;
}
int db_control_expire(DbControlClient *c,uint32_t now)
{
    if(!c || !c->active || (uint32_t)(now-c->started_us)<DB_CONTROL_REQUEST_TIMEOUT_US)return 0;
    c->active=0;return 1;
}

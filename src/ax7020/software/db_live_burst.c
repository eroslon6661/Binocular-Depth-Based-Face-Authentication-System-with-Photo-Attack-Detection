#include "db_live_burst.h"
#include <string.h>
int db_live_burst_init(DbLiveBurst *b,uint8_t *memory,unsigned step)
{
    unsigned i;if(!b||!memory||step<5U*DB_IMAGE_BYTES)return 0;
    memset(b,0,sizeof(*b));
    for(i=0;i<DB_LIVE_BURST_SLOTS;++i){
        b->slot[i].left=memory+i*step;b->slot[i].right=b->slot[i].left+DB_IMAGE_BYTES;
        b->slot[i].disparity=b->slot[i].right+DB_IMAGE_BYTES;
    }return 1;
}
void db_live_burst_clear(DbLiveBurst *b)
{
    unsigned i;b->active=b->count=b->next=0;
    b->session=b->id=b->photo_frame=b->photo_stamp=b->started_us=0;
    for(i=0;i<DB_LIVE_BURST_SLOTS;++i){
        b->slot[i].frame=b->slot[i].stamp[0]=b->slot[i].stamp[1]=0;
        b->slot[i].image_ready=b->slot[i].disparity_ready=0;
    }
}
int db_live_burst_start(DbLiveBurst *b,const DbControl *p,uint32_t now)
{
    if(!b||!p||p->type!=DB_CTRL_PHOTO_REQUEST||!p->session||!p->id||!p->frame)return 0;
    db_live_burst_clear(b);b->active=1;b->session=p->session;b->id=p->id;
    b->photo_frame=p->frame;b->photo_stamp=p->capture_us;b->started_us=now;return 1;
}
int db_live_burst_open(const DbLiveBurst *b,uint32_t now)
{return b->active&&b->count<DB_LIVE_BURST_SLOTS&&(uint32_t)(now-b->started_us)<=DB_LIVE_BURST_LOCAL_US;}
unsigned db_live_burst_capture(DbLiveBurst *b,uint32_t frame,uint32_t lt,uint32_t rt,
    const uint8_t *l,const uint8_t *r,uint32_t now)
{
    DbLiveBurstSlot *s;int32_t skew=(int32_t)(lt-rt);
    if(!l||!r||!db_live_burst_open(b,now)||!frame)return 0;
    if((int32_t)(lt-b->photo_stamp)<0||(int32_t)(rt-b->photo_stamp)<0||
       (uint32_t)(lt-b->photo_stamp)>DB_LIVE_BURST_CAPTURE_US||
       (uint32_t)(rt-b->photo_stamp)>DB_LIVE_BURST_CAPTURE_US||skew>15000||skew< -15000)return 0;
    if(!b->count){if(frame!=b->photo_frame||(lt!=b->photo_stamp&&rt!=b->photo_stamp))return 0;}
    else if((int32_t)(frame-b->slot[b->count-1U].frame)<=0 ||
            (int32_t)(lt-b->slot[b->count-1U].stamp[0])<=0 ||
            (int32_t)(rt-b->slot[b->count-1U].stamp[1])<=0)return 0;
    s=&b->slot[b->count];s->frame=frame;s->stamp[0]=lt;s->stamp[1]=rt;
    memcpy(s->left,l,DB_IMAGE_BYTES);memcpy(s->right,r,DB_IMAGE_BYTES);
    s->image_ready=1;s->disparity_ready=0;return ++b->count;
}
int db_live_burst_disparity(DbLiveBurst *b,unsigned tag,uint32_t frame,const uint8_t *rgb)
{
    DbLiveBurstSlot *s;
    if(!b->active||!rgb||!tag||tag>b->count)return 0;
    s=&b->slot[tag-1U];if(!s->image_ready||s->disparity_ready||s->frame!=frame)return 0;
    memcpy(s->disparity,rgb,3U*DB_IMAGE_BYTES);s->disparity_ready=1;return 1;
}
int db_live_burst_matches(const DbLiveBurst *b,const DbControl *r)
{return b->active&&r&&r->type==DB_CTRL_LIVE_REQUEST&&r->session==b->session&&r->id==b->id&&r->frame==b->photo_frame&&r->capture_us==b->photo_stamp;}
const DbLiveBurstSlot *db_live_burst_take(DbLiveBurst *b)
{
    const DbLiveBurstSlot *s;if(b->next>=b->count)return NULL;
    s=&b->slot[b->next];if(!s->image_ready||!s->disparity_ready)return NULL;
    ++b->next;return s;
}
int db_live_burst_pending(const DbLiveBurst *b,uint32_t now)
{return b->next<b->count||db_live_burst_open(b,now);}

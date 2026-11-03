#include "db_photo.h"
#include <string.h>
int db_photo_button(DbPhoto *p,unsigned down,unsigned inside,unsigned contacts)
{
    unsigned before;if(!p)return 0;before=p->pressed;p->pressed=down!=0;
    return down && !before && contacts==1 && inside;
}
int db_photo_begin(DbPhoto *p,unsigned x,unsigned y,uint32_t trigger)
{
    unsigned pressed;
    if(!p || x>=1280U || y>=720U || (p->state!=DB_PHOTO_IDLE &&
       p->state!=DB_PHOTO_DONE && p->state!=DB_PHOTO_FAILED))return 0;
    pressed=p->pressed;memset(p,0,sizeof(*p));p->pressed=pressed;
    p->state=DB_PHOTO_CAPTURING;p->x=x;p->y=y;p->trigger_us=trigger;return 1;
}
int db_photo_ready(DbPhoto *p,uint32_t frame,uint32_t left,uint32_t right,uint32_t max_skew)
{
    int64_t skew=(int32_t)(left-right);if(skew<0)skew=-skew;
    if(!p || p->state!=DB_PHOTO_CAPTURING || !frame ||
       (int32_t)(left-p->trigger_us)<0 || (int32_t)(right-p->trigger_us)<0 ||
       (uint64_t)skew>max_skew)return 0;
    p->frame=frame;p->stamp[0]=left;p->stamp[1]=right;p->state=DB_PHOTO_READY;return 1;
}
int db_photo_bind(DbPhoto *p,const DbControl *r)
{
    uint32_t stamp;if(!p || !r)return 0;
    stamp=(int32_t)(p->stamp[0]-p->stamp[1])<=0?p->stamp[0]:p->stamp[1];
    if(p->state!=DB_PHOTO_READY || r->type!=DB_CTRL_PHOTO_REQUEST || !r->id ||
       r->frame!=p->frame || r->capture_us!=stamp || r->x!=p->x || r->y!=p->y)return 0;
    p->request_id=r->id;p->state=DB_PHOTO_MEASURING;return 1;
}
int db_photo_result(DbPhoto *p,const DbControl *r)
{
    uint32_t stamp;if(!p || !r)return 0;
    stamp=(int32_t)(p->stamp[0]-p->stamp[1])<=0?p->stamp[0]:p->stamp[1];
    if(p->state!=DB_PHOTO_MEASURING || r->type!=DB_CTRL_RESULT ||
       r->id!=p->request_id || r->x!=p->x || r->y!=p->y ||
       r->status<DB_CTRL_OK || r->status>DB_CTRL_TIMEOUT ||
       (r->status==DB_CTRL_OK?(!r->distance_mm || r->distance_mm>3000U):r->distance_mm!=0U) ||
       (r->status!=DB_CTRL_TIMEOUT && (r->frame!=p->frame || r->capture_us!=stamp)))return 0;
    p->status=r->status;p->distance_mm=r->status==DB_CTRL_OK?r->distance_mm:0;
    p->state=r->status==DB_CTRL_OK?DB_PHOTO_DONE:DB_PHOTO_FAILED;return 1;
}
void db_photo_fail(DbPhoto *p){if(p){p->distance_mm=0;p->status=DB_CTRL_INVALID;p->state=DB_PHOTO_FAILED;}}
DbSlot *db_photo_acquire(DbReceiver *r,uint32_t frame,unsigned acquire)
{
    unsigned i;DbSlot *found=NULL;
    if(!r || !frame || (r->delivered && (int32_t)(frame-r->watermark)<=0))return NULL;
    for(i=0;i<DB_RX_SLOTS;++i) {
        DbSlot *s=&r->slots[i];
        if((s->state==DB_READY || s->state==DB_FILLING) && (int32_t)(s->frame-frame)<0)s->state=DB_FREE;
        if(s->state==DB_READY && s->frame==frame)found=s;
    }
    if(!acquire || !found)return NULL;
    found->state=DB_HELD;r->watermark=frame;r->delivered=1;return found;
}
size_t db_photo_rgb565(const uint8_t *raw,unsigned w,unsigned h,size_t offset,size_t count,uint8_t *out,unsigned be)
{
    size_t n,total;
    if(!raw || !out || !w || !h || w>1280U || h>720U)return 0;
    total=(size_t)w*h;if(offset>=total)return 0;
    if(count>total-offset)count=total-offset;
    for(n=0;n<count;++n) {
        size_t p=offset+n,x=(p%w)*1280U/w,y=(p/w)*720U/h;
        const uint8_t *bgr=raw+(y*1280U+x)*3U;
        uint16_t pixel=(uint16_t)(((unsigned)(bgr[2]&0xf8U)<<8)|((unsigned)(bgr[1]&0xfcU)<<3)|(bgr[0]>>3));
        out[n*2U+(be?0U:1U)]=(uint8_t)(pixel>>8);
        out[n*2U+(be?1U:0U)]=(uint8_t)pixel;
    }
    return count;
}

#include "db_preview.h"
#include "db_wire.h"
#include <string.h>
static void put(uint8_t *p,uint32_t x){p[0]=x>>24;p[1]=x>>16;p[2]=x>>8;p[3]=x;}
static uint32_t get(const uint8_t *p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
int db_preview_encode(uint8_t *p,const DbPreviewRow *r,const uint8_t *bgr)
{
 if(!p||!r||!bgr||!r->session||!r->frame||r->camera>1||r->row>=DB_PREVIEW_H)return 0;
 memset(p,0,DB_PREVIEW_HEADER);put(p,0x44425056U);put(p+4,r->session);put(p+8,r->frame);
 put(p+12,r->stamp[0]);put(p+16,r->stamp[1]);p[20]=r->camera;p[21]=1;
 p[22]=r->row>>8;p[23]=r->row;put(p+24,DB_PREVIEW_W);
 db_preview_shading_pixels(p+32,bgr,r->camera,r->row);
 /* CRC spans all fields and pixels, with the CRC field zeroed. */
 put(p+28,db_crc32(p,DB_PREVIEW_PACKET));return 1;
}
int db_preview_decode(DbPreviewRow *r,const uint8_t *p,size_t n)
{
 uint8_t copy[DB_PREVIEW_PACKET];uint32_t crc;int64_t skew;
 if(!r||!p||n!=DB_PREVIEW_PACKET||get(p)!=0x44425056U||p[21]!=1||get(p+24)!=DB_PREVIEW_W)return 0;
 memcpy(copy,p,n);crc=get(copy+28);memset(copy+28,0,4);if(crc!=db_crc32(copy,n))return 0;
 r->session=get(p+4);r->frame=get(p+8);r->stamp[0]=get(p+12);r->stamp[1]=get(p+16);
 r->camera=p[20];r->row=((unsigned)p[22]<<8)|p[23];skew=(int32_t)(r->stamp[0]-r->stamp[1]);if(skew<0)skew=-skew;
 return r->session&&r->frame&&r->camera<2&&r->row<DB_PREVIEW_H&&skew<=15000;
}
void db_preview_expand(uint8_t *p,const uint8_t *s)
{
 unsigned x;for(x=0;x<DB_PREVIEW_W;++x){unsigned q=((unsigned)s[x*2]<<8)|s[x*2+1];
  p[x*3]=(q&31U)*255U/31U;p[x*3+1]=((q>>5)&63U)*255U/63U;p[x*3+2]=(q>>11)*255U/31U;
 }
}
int db_preview_accept(DbPreviewAssembly *a,const DbPreviewRow *r,uint32_t now)
{
 unsigned i;if(!a||!r||!r->frame||r->camera>1||r->row>=DB_PREVIEW_H)return 0;
 if(a->frame!=r->frame){
  if(a->frame&&(int32_t)(r->frame-a->frame)<=0)return 0;
  memset(a,0,sizeof(*a));a->frame=r->frame;a->stamp[0]=r->stamp[0];a->stamp[1]=r->stamp[1];a->started=now;
 }
 if(a->stamp[0]!=r->stamp[0]||a->stamp[1]!=r->stamp[1]||(uint32_t)(now-a->started)>500000U)return 0;
 i=r->camera*DB_PREVIEW_H+r->row;if(a->seen[i/8]&(1U<<(i%8)))return 0;
 a->seen[i/8]|=1U<<(i%8);return ++a->count==DB_PREVIEW_ROWS?2:1;
}

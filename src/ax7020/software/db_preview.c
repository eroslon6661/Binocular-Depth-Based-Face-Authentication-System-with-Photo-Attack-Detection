#include "db_preview.h"
#include "db_wire.h"
#include <string.h>
static void put(uint8_t *p,uint32_t x){p[0]=x>>24;p[1]=x>>16;p[2]=x>>8;p[3]=x;}
static uint32_t get(const uint8_t *p){return (uint32_t)p[0]<<24|(uint32_t)p[1]<<16|(uint32_t)p[2]<<8|p[3];}
int db_preview_encode(uint8_t *p,const DbPreviewRow *r,const uint8_t *bgr)
{
 unsigned x;if(!p||!r||!bgr||!r->session||!r->frame||r->camera>1||r->row>=DB_PREVIEW_H)return 0;
 memset(p,0,DB_PREVIEW_HEADER);put(p,0x44425056U);put(p+4,r->session);put(p+8,r->frame);
 put(p+12,r->stamp[0]);put(p+16,r->stamp[1]);p[20]=r->camera;p[21]=1;
 p[22]=r->row>>8;p[23]=r->row;put(p+24,DB_PREVIEW_W);
 for(x=0;x<DB_PREVIEW_W;++x){unsigned sx=x*1280U/DB_PREVIEW_W;
  const uint8_t *s=bgr+sx*3U;unsigned q=((s[2]>>3)<<11)|((s[1]>>2)<<5)|(s[0]>>3);
  p[32+x*2]=q>>8;p[33+x*2]=q;
 }
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
 /* Exact 5/6-bit to 8-bit scaling, identical to the prior integer
  * division for every RGB565 value; tables avoid three multiplies/divides. */
 static const uint8_t c5[32]={0,8,16,24,32,41,49,57,65,74,82,90,98,106,115,123,131,139,148,156,164,172,180,189,197,205,213,222,230,238,246,255};
 static const uint8_t c6[64]={0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,85,89,93,97,101,105,109,113,117,121,125,129,133,137,141,145,149,153,157,161,165,170,174,178,182,186,190,194,198,202,206,210,214,218,222,226,230,234,238,242,246,250,255};
 unsigned x;for(x=0;x<DB_PREVIEW_W;++x){unsigned q=((unsigned)s[x*2]<<8)|s[x*2+1];
  p[x*3]=c5[q&31U];p[x*3+1]=c6[(q>>5)&63U];p[x*3+2]=c5[q>>11];
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

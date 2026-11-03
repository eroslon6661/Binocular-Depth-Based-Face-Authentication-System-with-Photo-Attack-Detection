#include "db_preview.h"
#include <string.h>
#if defined(__ARM_NEON)
#include <arm_neon.h>
#endif
extern const uint8_t db_preview_shading_gain[2][DB_PREVIEW_H][DB_PREVIEW_W/8U][2];
static unsigned ready,enabled;
static void scalar(uint8_t *out,const uint8_t *src,const uint8_t *gain)
{
 unsigned x;
 for(x=0;x<DB_PREVIEW_W;++x){const uint8_t *s=src+(x*1280U/DB_PREVIEW_W)*3U;
  unsigned b=((unsigned)s[0]*gain[2*(x/8U)]+64U)>>7,r=((unsigned)s[2]*gain[2*(x/8U)+1]+64U)>>7,q;
  if(b>255U)b=255U;
  if(r>255U)r=255U;
  q=((r>>3)<<11)|((s[1]>>2)<<5)|(b>>3);out[2*x]=q>>8;out[2*x+1]=q;
 }
}
static void vector(uint8_t *out,const uint8_t *src,const uint8_t *gain)
{
#if defined(__ARM_NEON)
 static const uint8_t indices[8]={0,2,5,7,10,12,15,17};
 uint8x8_t idx=vld1_u8(indices);unsigned x;
 for(x=0;x+8U<DB_PREVIEW_W;x+=8U){
  const uint8_t *p=src+(x/8U)*60U;
  uint8x8x3_t a=vld3_u8(p),b=vld3_u8(p+24),c=vld3_u8(p+48),table;
  unsigned blue_gain=gain[(x/8U)*2U],red_gain=gain[(x/8U)*2U+1U];
  uint8x8_t blue,green,red;uint16x8_t q;
  table.val[0]=a.val[0];table.val[1]=b.val[0];table.val[2]=c.val[0];blue=vtbl3_u8(table,idx);
  table.val[0]=a.val[1];table.val[1]=b.val[1];table.val[2]=c.val[1];green=vtbl3_u8(table,idx);
  table.val[0]=a.val[2];table.val[1]=b.val[2];table.val[2]=c.val[2];red=vtbl3_u8(table,idx);
  if(blue_gain!=128U || red_gain!=128U){
   blue=vqrshrn_n_u16(vmull_u8(blue,vdup_n_u8(blue_gain)),7);
   red=vqrshrn_n_u16(vmull_u8(red,vdup_n_u8(red_gain)),7);
  }
  q=vorrq_u16(vshll_n_u8(vand_u8(red,vdup_n_u8(0xf8)),8),vshll_n_u8(vand_u8(green,vdup_n_u8(0xfc)),3));
  q=vorrq_u16(q,vmovl_u8(vshr_n_u8(blue,3)));
  vst1q_u8(out+x*2U,vrev16q_u8(vreinterpretq_u8_u16(q)));
 }
 for(;x<DB_PREVIEW_W;++x){const uint8_t *s=src+(x*1280U/DB_PREVIEW_W)*3U;
  unsigned b=((unsigned)s[0]*gain[2*(x/8U)]+64U)>>7,r=((unsigned)s[2]*gain[2*(x/8U)+1]+64U)>>7,q;
  if(b>255U)b=255U;
  if(r>255U)r=255U;
  q=((r>>3)<<11)|((s[1]>>2)<<5)|(b>>3);out[2*x]=q>>8;out[2*x+1]=q;
 }
#else
 scalar(out,src,gain);
#endif
}
int db_preview_shading_init(void)
{
 static uint8_t input[3840+16],reference[1024],result[1026];
 uint32_t seed=0x28715219U;unsigned trial,i;ready=enabled=0;
 /* Run before queuing startup audio. Check both cameras and every map row,
  * unaligned packed input, RGB saturation, RGB565 rounding and row canaries. */
 for(trial=0;trial<DB_PREVIEW_ROWS;++trial){
  uint8_t *row=input+(trial&15U);
  const uint8_t *gain=&db_preview_shading_gain[trial/DB_PREVIEW_H][trial%DB_PREVIEW_H][0][0];
  for(i=0;i<3840;++i){seed=seed*1664525U+1013904223U;row[i]=(uint8_t)(seed>>24);}
  result[0]=0xa5;result[1025]=0x5a;
  scalar(reference,row,gain);vector(result+1,row,gain);
  if(result[0]!=0xa5 || result[1025]!=0x5a || memcmp(reference,result+1,sizeof(reference)))return 0;
 }
 ready=enabled=1;return 1;
}
void db_preview_shading_set(unsigned value){enabled=ready && value!=0;}
void db_preview_shading_pixels(uint8_t *out,const uint8_t *src,unsigned camera,unsigned row)
{
 if(!out || !src || camera>=2U || row>=DB_PREVIEW_H)return;
 if(!enabled){db_preview_pixels(out,src);return;}
 vector(out,src,&db_preview_shading_gain[camera][row][0][0]);
}

#include "db_preview.h"
#include <string.h>
#if defined(__ARM_NEON)
#include <arm_neon.h>
#endif
static unsigned use_vector;
static void scalar_pixels(uint8_t *out,const uint8_t *src)
{
 unsigned x;
 for(x=0;x<DB_PREVIEW_W;++x){unsigned sx=x*1280U/DB_PREVIEW_W;
  const uint8_t *s=src+sx*3U;unsigned q=((s[2]>>3)<<11)|((s[1]>>2)<<5)|(s[0]>>3);
  out[x*2]=q>>8;out[x*2+1]=q;
 }
}
static void vector_pixels(uint8_t *out,const uint8_t *src)
{
#if defined(__ARM_NEON)
 /* Eight output pixels sample twenty source pixels. Three deinterleaved
  * loads cover 24 pixels; leave the final group to scalar code so a row-end
  * read never crosses the validated 3840-byte input span. */
 static const uint8_t indices[8]={0,2,5,7,10,12,15,17};
 uint8x8_t idx=vld1_u8(indices);unsigned x;
 for(x=0;x+8U<DB_PREVIEW_W;x+=8U){
  const uint8_t *p=src+(x/8U)*60U;
  uint8x8x3_t a=vld3_u8(p),b=vld3_u8(p+24),c=vld3_u8(p+48),table;
  uint8x8_t blue,green,red;uint16x8_t q;
  table.val[0]=a.val[0];table.val[1]=b.val[0];table.val[2]=c.val[0];blue=vtbl3_u8(table,idx);
  table.val[0]=a.val[1];table.val[1]=b.val[1];table.val[2]=c.val[1];green=vtbl3_u8(table,idx);
  table.val[0]=a.val[2];table.val[1]=b.val[2];table.val[2]=c.val[2];red=vtbl3_u8(table,idx);
  q=vorrq_u16(vshll_n_u8(vand_u8(red,vdup_n_u8(0xf8)),8),vshll_n_u8(vand_u8(green,vdup_n_u8(0xfc)),3));
  q=vorrq_u16(q,vmovl_u8(vshr_n_u8(blue,3)));
  vst1q_u8(out+x*2U,vrev16q_u8(vreinterpretq_u8_u16(q)));
 }
 for(;x<DB_PREVIEW_W;++x){const uint8_t *s=src+(x*1280U/DB_PREVIEW_W)*3U;
  unsigned q=((s[2]>>3)<<11)|((s[1]>>2)<<5)|(s[0]>>3);out[x*2]=q>>8;out[x*2+1]=q;}
#else
 scalar_pixels(out,src);
#endif
}
int db_preview_pixels_init(void)
{
 static uint8_t input[3840+16],reference[1024],result[1026];
 uint32_t seed=0x28715219U;unsigned trial,i;use_vector=0;
 for(trial=0;trial<64;++trial){
  uint8_t *row=input+(trial&15U);
  for(i=0;i<3840;++i){seed=seed*1664525U+1013904223U;row[i]=(uint8_t)(seed>>24);}
  result[0]=0xa5;result[1025]=0x5a;
  scalar_pixels(reference,row);vector_pixels(result+1,row);
  if(result[0]!=0xa5 || result[1025]!=0x5a || memcmp(reference,result+1,sizeof(reference)))return -1;
 }
#if defined(__ARM_NEON)
 use_vector=1;return 1;
#else
 return 0;
#endif
}
void db_preview_pixels(uint8_t *out,const uint8_t *src)
{
 if(use_vector)vector_pixels(out,src);else scalar_pixels(out,src);
}

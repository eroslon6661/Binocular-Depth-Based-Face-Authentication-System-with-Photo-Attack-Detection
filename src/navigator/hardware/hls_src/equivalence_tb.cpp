#include <ap_int.h>
#include <cstdio>
#include <vector>
#include <random>
#include <cstdint>
#include <cstdlib>
typedef ap_int<8> I8;typedef ap_int<16> I16;typedef ap_int<32> I32;
typedef void (*Kernel)(const I8*,const I8*,const I32*,const I32*,const I8*,const I16*,const I8*,I8*,
 unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned);
extern "C" void face_int8_accel(const I8*,const I8*,const I32*,const I32*,const I8*,const I16*,const I8*,I8*,
 unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned);
extern "C" void face_int8_reference(const I8*,const I8*,const I32*,const I32*,const I8*,const I16*,const I8*,I8*,
 unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned);
static std::mt19937 rng(20261022U);
static unsigned checks=0;static uint64_t pixels=0;
static int run(unsigned h,unsigned w,unsigned ci,unsigned co,unsigned k,unsigned stride,unsigned pad,
 unsigned groups,unsigned act,unsigned res,FILE *fixture=NULL)
{
 unsigned oh=(h+2*pad-k)/stride+1,ow=(w+2*pad-k)/stride+1,kv=ci/groups*k*k;
 std::vector<I8> input(h*w*ci),weights(co*kv),a(oh*ow*co),b(a.size()),rv(a.size()),shift(2*co);
 std::vector<I16> slope(co);std::vector<I32> bias(co),mult(2*co);
 for(auto &x:input)x=(int)(rng()%65)-32;
 for(auto &x:rv)x=(int)(rng()%31)-15;
 if(fixture) {
  for(auto &x:weights){int8_t q;if(fread(&q,1,1,fixture)!=1)return 1;x=q;}
  for(auto &x:bias){int32_t q;if(fread(&q,4,1,fixture)!=1)return 1;x=q;}
  for(auto &x:mult){int32_t q;if(fread(&q,4,1,fixture)!=1)return 1;x=q;}
  for(auto &x:shift){int8_t q;if(fread(&q,1,1,fixture)!=1)return 1;x=q;}
  for(auto &x:slope){int16_t q;if(fread(&q,2,1,fixture)!=1)return 1;x=q;}
 } else {
  for(auto &x:weights)x=(int)(rng()%17)-8;
  for(auto &x:bias)x=(int)(rng()%201)-100;
  for(auto &x:mult)x=1073741824+(int)(rng()%1073741823U);
  for(unsigned i=0;i<co;++i){shift[i]=(int)(rng()%7)-5;shift[co+i]=(int)(rng()%4)-1;slope[i]=rng()%32768;}
 }
 face_int8_reference(input.data(),weights.data(),bias.data(),mult.data(),shift.data(),slope.data(),rv.data(),a.data(),h,w,ci,co,k,stride,pad,groups,ci/groups,co/groups,oh,ow,act,res);
 face_int8_accel(input.data(),weights.data(),bias.data(),mult.data(),shift.data(),slope.data(),rv.data(),b.data(),h,w,ci,co,k,stride,pad,groups,ci/groups,co/groups,oh,ow,act,res);
 for(unsigned i=0;i<a.size();++i)if(a[i]!=b[i]) {
  std::printf("MISMATCH case=%u h=%u w=%u ci=%u co=%u k=%u s=%u g=%u act=%u res=%u index=%u ref=%d new=%d\n",checks,h,w,ci,co,k,stride,groups,act,res,i,(int)a[i],(int)b[i]);return 1;
 }
 ++checks;pixels+=a.size();return 0;
}
int main(int argc,char **argv)
{
 for(unsigned act=0;act<3;++act)for(unsigned res=0;res<2;++res) {
  if(run(5,7,3,13,1,1,0,1,act,res)||run(6,8,6,17,3,2,1,1,act,res)||run(5,7,6,10,3,1,1,2,act,res))return 1;
  for(unsigned c: {2U,7U,8U,9U,17U,64U,128U,512U})
   if(run(5,7,c,c,3,1,1,c,act,res)||run(6,8,c,c,3,2,1,c,act,res))return 1;
  if(run(5,7,18,18,3,1,1,9,act,res)||run(3,4,9,18,1,1,0,9,act,res)||run(3,4,18,9,1,1,0,9,act,res))return 1;
  /* V3: 2x2 group tails, channel boundary 512, and grouped fallback. */
  for(unsigned c: {4U,6U,10U,18U,128U,510U,512U,514U})
   if(run(4,5,c,c,3,2,1,c/2,act,res)||run(3,4,c,c,1,1,0,c/2,act,res))return 1;
  /* 1x1 block boundaries: 36 KiB weight capacity, partial output tile,
   * coefficient capacity, stride/padding, and blocks above 512 outputs. */
  for(unsigned ci: {16U,128U,256U,512U,513U}) {
   unsigned block=(4608U/ci)*8U;if(block>512U)block=512U;
   if(run(3,4,ci,block+1U,1,1,0,1,act,res)||
      run(4,5,ci,block*2U+3U,1,2,1,1,act,res))return 1;
  }
 }
 if(run(1,8193,1,3,1,1,0,1,0,0)||run(1,1,3136,17,1,1,0,1,0,1)||run(4,56,128,128,1,1,0,1,2,0))return 1;
 /* Alternate shapes repeatedly to catch persistent row/weight contamination. */
 for(unsigned i=0;i<6;++i)if(run(3+i%3,4+i%2,16,16,3,1,1,16,i%3,0))return 1;
 if(argc>1) {
  FILE *f=std::fopen(argv[1],"rb");if(!f){std::puts("fixture open failed");return 1;}
  uint32_t n;if(fread(&n,4,1,f)!=1)return 1;
  for(unsigned i=0;i<n;++i){uint32_t p[10];if(fread(p,4,10,f)!=10)return 1;
   if(run(p[0],p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],f))return 1;
  }
  if(std::fgetc(f)!=EOF)return 1;std::fclose(f);
 }
 std::printf("FACE_SPEED_EQUIVALENCE_PASS cases=%u output_bytes=%llu; integer outputs exact\n",checks,(unsigned long long)pixels);return 0;
}

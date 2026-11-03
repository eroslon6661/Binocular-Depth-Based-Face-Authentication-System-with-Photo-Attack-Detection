#include <ap_int.h>
#include <cstdio>
#include <vector>
#include <random>
#include <cstdint>
#include <cstdlib>
#include <algorithm>
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
 std::vector<I8> input(std::max(h*w*ci,401408U)),weights(std::max(co*kv,3379200U)),a(std::max(oh*ow*co,401408U)),b(a.size()),rv(a.size()),shift(std::max(2*co,512U));
 std::vector<I16> slope(std::max(co,512U));std::vector<I32> bias(std::max(co,512U)),mult(std::max(2*co,512U));
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
 for(unsigned i=0;i<oh*ow*co;++i)if(a[i]!=b[i]) {
  std::printf("MISMATCH case=%u h=%u w=%u ci=%u co=%u k=%u s=%u g=%u act=%u res=%u index=%u ref=%d new=%d\n",checks,h,w,ci,co,k,stride,groups,act,res,i,(int)a[i],(int)b[i]);return 1;
 }
 ++checks;pixels+=oh*ow*co;return 0;
}
int main() {
 // Same argument register ABI; different modes in consecutive invocations.
 if(run(8,8,16,16,3,1,1,8,2,0))return 1;
 if(run(8,8,32,64,1,1,0,1,2,0))return 1;
 if(run(3,4,256,147,1,1,0,1,1,1))return 1;
 std::printf("FACE_RTL_SMOKE_PASS cases=%u output_bytes=%llu\n",checks,(unsigned long long)pixels);
 return 0;
}

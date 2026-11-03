#include <ap_int.h>
#include <cstdio>

extern "C" void face_int8_accel(const ap_int<8>*,const ap_int<8>*,const ap_int<32>*,
    const ap_int<32>*,const ap_int<8>*,const ap_int<16>*,const ap_int<8>*,ap_int<8>*,
    unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,unsigned,
    unsigned,unsigned,unsigned,unsigned);

int main()
{
    ap_int<8> input[3*3*2]={-3,2, 1,-2, 4,1, -1,3, 2,-4, 5,2, 0,-1, 3,4, -2,1};
    ap_int<8> weights[2*2]={2,-3, -1,4}; /* two 1x1 output channels */
    ap_int<32> bias[2]={1,-2},mult[2]={1073741824,1073741824}; /* 0.5 */
    ap_int<8> shift[2]={0,0};
    ap_int<16> slope[2]={8192,8192};
    ap_int<8> output[3*3*2]={0},residual[3*3*2]={0};
    face_int8_accel(input,weights,bias,mult,shift,slope,residual,output,
        3,3,2,2,1,1,0,1,2,2,3,3,0,0);
    for(unsigned p=0;p<9;++p)for(unsigned oc=0;oc<2;++oc) {
        int acc=(int)bias[oc]+(int)input[p*2]*(int)weights[oc*2]+
            (int)input[p*2+1]*(int)weights[oc*2+1];
        int magnitude=acc>=0?acc:-acc;
        int expected=magnitude/2;
        if((magnitude&1) && (expected&1))++expected;
        if(acc<0)expected=-expected;
        if(expected>127)expected=127;if(expected<-128)expected=-128;
        if((int)output[p*2+oc]!=expected) {
            std::printf("FAIL p=%u oc=%u got=%d expected=%d\n",p,oc,
                (int)output[p*2+oc],expected);return 1;
        }
    }
    /* Even-sized input with SAME padding has a truncated final stride window.
       This is the geometry used by YuNet's first 320 -> 160 convolution. */
    ap_int<8> stride2_input[4*4];
    ap_int<8> stride2_weights[3*3];
    ap_int<8> stride2_output[2*2]={-99,-99,-99,-99};
    ap_int<8> stride2_residual[2*2]={0,0,0,0};
    ap_int<32> stride2_bias[1]={0},stride2_mult[2]={1073741824,1073741824};
    ap_int<8> stride2_shift[2]={0,1};
    ap_int<16> stride2_slope[1]={0};
    for(unsigned i=0;i<16;++i)stride2_input[i]=1;
    for(unsigned i=0;i<9;++i)stride2_weights[i]=1;
    face_int8_accel(stride2_input,stride2_weights,stride2_bias,stride2_mult,
        stride2_shift,stride2_slope,stride2_residual,stride2_output,
        4,4,1,1,3,2,1,1,1,1,2,2,1,0);
    const int stride2_expected[4]={2,3,3,4};
    for(unsigned i=0;i<4;++i)if((int)stride2_output[i]!=stride2_expected[i]) {
        std::printf("FAIL stride2 i=%u got=%d expected=%d\n",i,
            (int)stride2_output[i],stride2_expected[i]);return 1;
    }
    std::puts("FACE_INT8_HLS_CSIM_PASS signed_weights=1");return 0;
}

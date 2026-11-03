#include <ap_int.h>

typedef ap_int<8> i8;
typedef ap_int<16> i16;
typedef ap_int<32> i32;
typedef ap_int<64> i64;

enum { FACE_ACT_NONE=0, FACE_ACT_RELU=1, FACE_ACT_PRELU=2 };
static const unsigned FACE_OC_TILE=8;
static const unsigned FACE_MAX_KERNEL_VALUES=4608; /* 512*3*3 or FC 3136 */

static i8 clamp_i8(i64 value)
{
#pragma HLS INLINE
    if(value>127)return 127;
    if(value<-128)return -128;
    return (i8)value;
}

/* ONNX QuantizeLinear uses round-to-nearest-even.  Keep the exponent inside
 * the single rounding step; the previous two-step rounding accumulated a
 * one-LSB bias at every layer. */
static i64 round_shift_even(i64 value,unsigned right)
{
#pragma HLS INLINE
    if(!right)return value;
    if(right>=64U)return 0;
    bool negative=value<0;
    ap_uint<64> magnitude=negative?(ap_uint<64>)(-value):(ap_uint<64>)value;
    ap_uint<64> quotient=magnitude>>right;
    ap_uint<64> mask=(ap_uint<64>(1)<<right)-1U;
    ap_uint<64> remainder=magnitude&mask;
    ap_uint<64> half=ap_uint<64>(1)<<(right-1U);
    if(remainder>half || (remainder==half && (quotient&1U)))++quotient;
    i64 result=(i64)quotient;
    if(negative)return (i64)(-result);
    return result;
}

/* real_multiplier = multiplier_q31 / 2^31 * 2^scale_shift.
 * extra_fraction_bits is used by PReLU's Q15 slope without an intermediate
 * integer rounding. */
static i64 requantize(i64 value,i32 multiplier_q31,ap_int<8> scale_shift,
    unsigned extra_fraction_bits=0U)
{
#pragma HLS INLINE
    i64 product=value*(i64)multiplier_q31;
    int right=31+(int)extra_fraction_bits-(int)scale_shift;
    if(right>0)return round_shift_even(product,(unsigned)right);
    if(right<0)return product<<(unsigned)(-right);
    return product;
}

extern "C" void face_int8_reference(
    const i8 *input,
    const i8 *weights,
    const i32 *bias,
    const i32 *multiplier_q31,
    const ap_int<8> *scale_shift,
    const i16 *prelu_slope_q15,
    const i8 *residual,
    i8 *output,
    unsigned in_h,
    unsigned in_w,
    unsigned in_c,
    unsigned out_c,
    unsigned kernel,
    unsigned stride,
    unsigned pad,
    unsigned groups,
    unsigned in_per_group,
    unsigned out_per_group,
    unsigned out_h,
    unsigned out_w,
    unsigned activation,
    unsigned residual_enable)
{
#pragma HLS INTERFACE m_axi port=input offset=slave bundle=gmem_act depth=401408 max_read_burst_length=64
#pragma HLS INTERFACE m_axi port=residual offset=slave bundle=gmem_act depth=401408 max_read_burst_length=64
#pragma HLS INTERFACE m_axi port=output offset=slave bundle=gmem_act depth=401408 max_write_burst_length=64
#pragma HLS INTERFACE m_axi port=weights offset=slave bundle=gmem_param depth=3379200 max_read_burst_length=64
#pragma HLS INTERFACE m_axi port=bias offset=slave bundle=gmem_param depth=512
#pragma HLS INTERFACE m_axi port=multiplier_q31 offset=slave bundle=gmem_param depth=512
#pragma HLS INTERFACE m_axi port=scale_shift offset=slave bundle=gmem_param depth=512
#pragma HLS INTERFACE m_axi port=prelu_slope_q15 offset=slave bundle=gmem_param depth=512
#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=in_h bundle=control
#pragma HLS INTERFACE s_axilite port=in_w bundle=control
#pragma HLS INTERFACE s_axilite port=in_c bundle=control
#pragma HLS INTERFACE s_axilite port=out_c bundle=control
#pragma HLS INTERFACE s_axilite port=kernel bundle=control
#pragma HLS INTERFACE s_axilite port=stride bundle=control
#pragma HLS INTERFACE s_axilite port=pad bundle=control
#pragma HLS INTERFACE s_axilite port=groups bundle=control
#pragma HLS INTERFACE s_axilite port=in_per_group bundle=control
#pragma HLS INTERFACE s_axilite port=out_per_group bundle=control
#pragma HLS INTERFACE s_axilite port=out_h bundle=control
#pragma HLS INTERFACE s_axilite port=out_w bundle=control
#pragma HLS INTERFACE s_axilite port=activation bundle=control
#pragma HLS INTERFACE s_axilite port=residual_enable bundle=control
#pragma HLS INTERFACE s_axilite port=input bundle=control
#pragma HLS INTERFACE s_axilite port=weights bundle=control
#pragma HLS INTERFACE s_axilite port=bias bundle=control
#pragma HLS INTERFACE s_axilite port=multiplier_q31 bundle=control
#pragma HLS INTERFACE s_axilite port=scale_shift bundle=control
#pragma HLS INTERFACE s_axilite port=prelu_slope_q15 bundle=control
#pragma HLS INTERFACE s_axilite port=residual bundle=control
#pragma HLS INTERFACE s_axilite port=output bundle=control

    i8 weight_cache[FACE_OC_TILE][FACE_MAX_KERNEL_VALUES];
#pragma HLS ARRAY_PARTITION variable=weight_cache complete dim=1
    i32 bias_cache[FACE_OC_TILE],mult_cache[FACE_OC_TILE],post_mult_cache[FACE_OC_TILE];
    ap_int<8> shift_cache[FACE_OC_TILE],post_shift_cache[FACE_OC_TILE];
    i16 slope_cache[FACE_OC_TILE];
#pragma HLS ARRAY_PARTITION variable=bias_cache complete
#pragma HLS ARRAY_PARTITION variable=mult_cache complete
#pragma HLS ARRAY_PARTITION variable=post_mult_cache complete
#pragma HLS ARRAY_PARTITION variable=shift_cache complete
#pragma HLS ARRAY_PARTITION variable=post_shift_cache complete
#pragma HLS ARRAY_PARTITION variable=slope_cache complete

    if(!in_h || !in_w || !in_c || !out_c || !groups || !out_h || !out_w ||
       (kernel!=1U && kernel!=3U) || (stride!=1U && stride!=2U) ||
       in_per_group*groups!=in_c || out_per_group*groups!=out_c ||
       in_h+2U*pad<kernel || in_w+2U*pad<kernel ||
       out_h!=(in_h+2U*pad-kernel)/stride+1U ||
       out_w!=(in_w+2U*pad-kernel)/stride+1U)return;
    unsigned kernel_values=in_per_group*kernel*kernel;
    if(kernel_values>FACE_MAX_KERNEL_VALUES)return;
    for(unsigned group=0;group<groups;++group) {
        unsigned input_channel_base=group*in_per_group;
        unsigned output_channel_base=group*out_per_group;
        for(unsigned tile=0;tile<out_per_group;tile+=FACE_OC_TILE) {
            unsigned tile_count=out_per_group-tile;
            if(tile_count>FACE_OC_TILE)tile_count=FACE_OC_TILE;
            for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                unsigned oc=output_channel_base+tile+lane;
                if(lane<tile_count) {
                    bias_cache[lane]=bias[oc];mult_cache[lane]=multiplier_q31[oc];
                    shift_cache[lane]=scale_shift[oc];slope_cache[lane]=prelu_slope_q15[oc];
                    if(activation==FACE_ACT_NONE) {
                        post_mult_cache[lane]=0;post_shift_cache[lane]=0;
                    } else {
                        post_mult_cache[lane]=multiplier_q31[out_c+oc];
                        post_shift_cache[lane]=scale_shift[out_c+oc];
                    }
                } else {
                    bias_cache[lane]=0;mult_cache[lane]=0;
                    post_mult_cache[lane]=0;shift_cache[lane]=0;post_shift_cache[lane]=0;
                    slope_cache[lane]=0;
                }
            }
            for(unsigned e=0;e<kernel_values;++e) {
#pragma HLS PIPELINE II=1
                for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                    unsigned oc=output_channel_base+tile+lane;
                    weight_cache[lane][e]=lane<tile_count?
                        weights[oc*kernel_values+e]:i8(0);
                }
            }
            for(unsigned oy=0;oy<out_h;++oy)for(unsigned ox=0;ox<out_w;++ox) {
                i32 accumulator[FACE_OC_TILE];
#pragma HLS ARRAY_PARTITION variable=accumulator complete
                for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                    accumulator[lane]=bias_cache[lane];
                }
                for(unsigned ky=0;ky<kernel;++ky)for(unsigned kx=0;kx<kernel;++kx)
                    for(unsigned ic=0;ic<in_per_group;++ic) {
#pragma HLS PIPELINE II=1
                        int iy=(int)(oy*stride+ky)-(int)pad;
                        int ix=(int)(ox*stride+kx)-(int)pad;
                        i8 sample=0;
                        if(iy>=0 && ix>=0 && iy<(int)in_h && ix<(int)in_w)
                            sample=input[((unsigned)iy*in_w+(unsigned)ix)*in_c+
                                input_channel_base+ic];
                        unsigned e=(ky*kernel+kx)*in_per_group+ic;
                        for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                            accumulator[lane]+=(i16)sample*(i16)weight_cache[lane][e];
                        }
                    }
                for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS PIPELINE II=1
                    if(lane<tile_count) {
                        unsigned oc=output_channel_base+tile+lane;
                        unsigned index=(oy*out_w+ox)*out_c+oc;
                        /* Reproduce Conv-QDQ -> activation -> QDQ exactly as
                         * represented by the calibrated ONNX graph. */
                        i64 value=(i64)clamp_i8(requantize(accumulator[lane],
                            mult_cache[lane],shift_cache[lane]));
                        if(activation==FACE_ACT_RELU) {
                            if(value<0)value=0;
                            value=requantize(value,post_mult_cache[lane],post_shift_cache[lane]);
                        } else if(activation==FACE_ACT_PRELU) {
                            if(value<0)value=requantize(value*(i64)slope_cache[lane],
                                post_mult_cache[lane],post_shift_cache[lane],15U);
                            else value=requantize(value,post_mult_cache[lane],post_shift_cache[lane]);
                        }
                        if(residual_enable)value+=(i64)residual[index];
                        output[index]=clamp_i8(value);
                    }
                }
            }
        }
    }
}

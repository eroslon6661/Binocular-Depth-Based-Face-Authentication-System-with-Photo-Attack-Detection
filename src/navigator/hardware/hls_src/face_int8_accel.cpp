#include <ap_int.h>

typedef ap_int<8> i8;
typedef ap_int<16> i16;
typedef ap_int<32> i32;
typedef ap_int<64> i64;

enum { FACE_ACT_NONE=0, FACE_ACT_RELU=1, FACE_ACT_PRELU=2 };
#ifndef FACE_OC_TILE_VALUE
#define FACE_OC_TILE_VALUE 8
#endif
static const unsigned FACE_OC_TILE=FACE_OC_TILE_VALUE;
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


static const unsigned FACE_ROW_BLOCKS=1024;
static const unsigned FACE_COEFFS=512;

/* Fetch complete HWC rows consecutively. Ring tags allow adjacent windows to
 * reuse rows. All tags are invalidated for every new layer invocation. */
static void load_rows(const i8 *input,i8 rows[3][FACE_OC_TILE][FACE_ROW_BLOCKS],int tag[3],
    unsigned oy,unsigned kernel,unsigned stride,unsigned pad,unsigned in_h,unsigned in_w,unsigned in_c)
{
#pragma HLS INLINE
    for(unsigned ky=0;ky<kernel;++ky) {
        int iy=(int)(oy*stride+ky)-(int)pad;
        if(iy>=0 && iy<(int)in_h) {
            unsigned bank=(unsigned)iy%3U;
            if(tag[bank]!=iy) {
                unsigned blocks=(in_c+FACE_OC_TILE-1U)/FACE_OC_TILE;
                unsigned base=(unsigned)iy*in_w*in_c;
                for(unsigned x=0;x<in_w;++x)for(unsigned c=0;c<in_c;++c) {
#pragma HLS PIPELINE II=1
                    rows[bank][c%FACE_OC_TILE][x*blocks+c/FACE_OC_TILE]=input[base+x*in_c+c];
                }
                tag[bank]=iy;
            }
        }
    }
}
static i8 finish_value(i32 acc,i32 mult,ap_int<8> shift,i32 post_mult,
    ap_int<8> post_shift,i16 slope,unsigned activation,i8 residual,unsigned residual_enable)
{
#pragma HLS INLINE off
#pragma HLS PIPELINE II=1
    /* Exact original Conv-QDQ -> activation -> QDQ. Do not fuse roundings. */
    i64 value=(i64)clamp_i8(requantize(acc,mult,shift));
    if(activation==FACE_ACT_RELU) {
        if(value<0)value=0;
        value=requantize(value,post_mult,post_shift);
    } else if(activation==FACE_ACT_PRELU) {
        if(value<0)value=requantize(value*(i64)slope,post_mult,post_shift,15U);
        else value=requantize(value,post_mult,post_shift);
    }
    if(residual_enable)value+=(i64)residual;
    return clamp_i8(value);
}

extern "C" void face_int8_accel(
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


#pragma HLS ALLOCATION instances=finish_value limit=1 function
    i8 weight_cache[FACE_OC_TILE][FACE_MAX_KERNEL_VALUES];
#pragma HLS ARRAY_PARTITION variable=weight_cache complete dim=1
#pragma HLS BIND_STORAGE variable=weight_cache type=ram_2p impl=bram
    i8 rows[3][FACE_OC_TILE][FACE_ROW_BLOCKS];
#pragma HLS ARRAY_PARTITION variable=rows complete dim=1
#pragma HLS ARRAY_PARTITION variable=rows complete dim=2
#pragma HLS BIND_STORAGE variable=rows type=ram_2p impl=bram
    int row_tag[3]={-1,-1,-1};
#pragma HLS ARRAY_PARTITION variable=row_tag complete
    i32 bias_cache[FACE_OC_TILE][FACE_COEFFS/FACE_OC_TILE],mult_cache[FACE_OC_TILE][FACE_COEFFS/FACE_OC_TILE],post_mult_cache[FACE_OC_TILE][FACE_COEFFS/FACE_OC_TILE];
    ap_int<8> shift_cache[FACE_OC_TILE][FACE_COEFFS/FACE_OC_TILE],post_shift_cache[FACE_OC_TILE][FACE_COEFFS/FACE_OC_TILE];
    i16 slope_cache[FACE_OC_TILE][FACE_COEFFS/FACE_OC_TILE];
#pragma HLS ARRAY_PARTITION variable=bias_cache complete dim=1
#pragma HLS ARRAY_PARTITION variable=mult_cache complete dim=1
#pragma HLS ARRAY_PARTITION variable=post_mult_cache complete dim=1
#pragma HLS ARRAY_PARTITION variable=shift_cache complete dim=1
#pragma HLS ARRAY_PARTITION variable=post_shift_cache complete dim=1
#pragma HLS ARRAY_PARTITION variable=slope_cache complete dim=1
#ifdef FACE_PARAM_CACHE_IMPL_BRAM
#pragma HLS BIND_STORAGE variable=bias_cache type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=mult_cache type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=post_mult_cache type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=slope_cache type=ram_2p impl=bram
#pragma HLS BIND_STORAGE variable=shift_cache type=ram_2p impl=lutram
#pragma HLS BIND_STORAGE variable=post_shift_cache type=ram_2p impl=lutram
#else
#pragma HLS BIND_STORAGE variable=bias_cache type=ram_2p impl=lutram
#pragma HLS BIND_STORAGE variable=mult_cache type=ram_2p impl=lutram
#pragma HLS BIND_STORAGE variable=post_mult_cache type=ram_2p impl=lutram
#pragma HLS BIND_STORAGE variable=shift_cache type=ram_2p impl=lutram
#pragma HLS BIND_STORAGE variable=post_shift_cache type=ram_2p impl=lutram
#pragma HLS BIND_STORAGE variable=slope_cache type=ram_2p impl=lutram
#endif
    if(!in_h || !in_w || !in_c || !out_c || !groups || !out_h || !out_w ||
       (kernel!=1U && kernel!=3U) || (stride!=1U && stride!=2U) ||
       in_per_group*groups!=in_c || out_per_group*groups!=out_c ||
       in_h+2U*pad<kernel || in_w+2U*pad<kernel ||
       out_h!=(in_h+2U*pad-kernel)/stride+1U ||
       out_w!=(in_w+2U*pad-kernel)/stride+1U)return;
    unsigned kernel_values=in_per_group*kernel*kernel;
    if(kernel_values>FACE_MAX_KERNEL_VALUES)return;
    unsigned row_blocks=(in_c+FACE_OC_TILE-1U)/FACE_OC_TILE;
    bool use_rows=in_w<=FACE_ROW_BLOCKS/row_blocks;
    bool group_two=in_per_group==2U && out_per_group==2U;
    bool group_parallel=use_rows && groups>1U && out_c<=FACE_COEFFS &&
        ((in_per_group==1U && out_per_group==1U) || group_two);
    if(group_parallel) {
        /* Depthwise or exactly two channels per group. Eight output lanes
         * process eight depthwise groups or four 2x2 groups. All coefficients
         * fit in existing storage. The row is fetched only once across groups. */
        unsigned group_channels=group_two?2U:1U;
        unsigned dw_kernel_values=kernel*kernel*group_channels;
        for(unsigned oc=0;oc<out_c;++oc) {
#pragma HLS PIPELINE II=1
            bias_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE]=bias[oc];mult_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE]=multiplier_q31[oc];
            shift_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE]=scale_shift[oc];slope_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE]=prelu_slope_q15[oc];
            post_mult_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE]=activation==FACE_ACT_NONE?i32(0):multiplier_q31[out_c+oc];
            post_shift_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE]=activation==FACE_ACT_NONE?ap_int<8>(0):scale_shift[out_c+oc];
        }
        /* Linear external addresses; the on-chip layout is banked by channel. */
        for(unsigned oc=0;oc<out_c;++oc)for(unsigned e=0;e<dw_kernel_values;++e) {
#pragma HLS PIPELINE II=1
            weight_cache[oc%FACE_OC_TILE][(oc/FACE_OC_TILE)*dw_kernel_values+e]=weights[oc*dw_kernel_values+e];
        }
        for(unsigned oy=0;oy<out_h;++oy) {
            load_rows(input,rows,row_tag,oy,kernel,stride,pad,in_h,in_w,in_c);
            for(unsigned ox=0;ox<out_w;++ox)for(unsigned tile=0;tile<out_c;tile+=FACE_OC_TILE) {
                i32 accumulator[FACE_OC_TILE];
#pragma HLS ARRAY_PARTITION variable=accumulator complete
                for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                    unsigned oc=tile+lane;
                    accumulator[lane]=oc<out_c?bias_cache[lane][tile/FACE_OC_TILE]:i32(0);
                }
                for(unsigned ky=0;ky<kernel;++ky)for(unsigned kx=0;kx<kernel;++kx)
                    for(unsigned ic=0;ic<group_channels;++ic) {
#pragma HLS PIPELINE II=1
                        int iy=(int)(oy*stride+ky)-(int)pad,ix=(int)(ox*stride+kx)-(int)pad;
                        unsigned e=(ky*kernel+kx)*group_channels+ic;
                        for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                            unsigned oc=tile+lane;i8 sample=0,w=0;
                            if(oc<out_c) {
                                if(iy>=0 && ix>=0 && iy<(int)in_h && ix<(int)in_w)
                                    /* tile is a multiple of 8, so a 2-channel
                                     * group never crosses a bank block. */
                                    sample=group_two?
                                        rows[(unsigned)iy%3U][(lane&6U)+ic][(unsigned)ix*row_blocks+tile/FACE_OC_TILE]:
                                        rows[(unsigned)iy%3U][lane][(unsigned)ix*row_blocks+tile/FACE_OC_TILE];
                                w=weight_cache[lane][(tile/FACE_OC_TILE)*dw_kernel_values+e];
                            }
                            accumulator[lane]+=(i16)sample*(i16)w;
                        }
                    }
                for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS PIPELINE II=1
                    unsigned oc=tile+lane;
                    if(oc<out_c) {
                        unsigned index=(oy*out_w+ox)*out_c+oc;
                        i8 rv=residual_enable?residual[index]:i8(0);
                        output[index]=finish_value(accumulator[lane],mult_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE],shift_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE],
                            post_mult_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE],post_shift_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE],slope_cache[oc%FACE_OC_TILE][oc/FACE_OC_TILE],activation,rv,residual_enable);
                    }
                }
            }
        }
        return;
    }
    /* 1x1: retain as many output channels' weights as the existing 36 KiB
     * cache can hold, then reuse each input row across those output tiles.
     * Large layers use multiple blocks, never exceed cache/coeff capacity.
     * Other shapes keep one eight-channel tile per sweep. */
    unsigned block_channels=FACE_OC_TILE;
    if(use_rows && groups==1U && kernel==1U) {
        unsigned tiles=FACE_MAX_KERNEL_VALUES/kernel_values;
        if(tiles>FACE_COEFFS/FACE_OC_TILE)tiles=FACE_COEFFS/FACE_OC_TILE;
        block_channels=tiles*FACE_OC_TILE;
    }
    for(unsigned group=0;group<groups;++group) {
        unsigned input_channel_base=group*in_per_group,output_channel_base=group*out_per_group;
        for(unsigned block=0;block<out_per_group;block+=block_channels) {
            unsigned count=out_per_group-block;if(count>block_channels)count=block_channels;
            for(unsigned local=0;local<count;++local) {
                unsigned lane=local%FACE_OC_TILE,slot=local/FACE_OC_TILE;
                unsigned oc=output_channel_base+block+local;
                bias_cache[lane][slot]=bias[oc];mult_cache[lane][slot]=multiplier_q31[oc];
                shift_cache[lane][slot]=scale_shift[oc];slope_cache[lane][slot]=prelu_slope_q15[oc];
                post_mult_cache[lane][slot]=activation==FACE_ACT_NONE?i32(0):multiplier_q31[out_c+oc];
                post_shift_cache[lane][slot]=activation==FACE_ACT_NONE?ap_int<8>(0):scale_shift[out_c+oc];
                for(unsigned e=0;e<kernel_values;++e) {
#pragma HLS PIPELINE II=1
                    weight_cache[lane][slot*kernel_values+e]=weights[oc*kernel_values+e];
                }
            }
            for(unsigned oy=0;oy<out_h;++oy) {
                if(use_rows)load_rows(input,rows,row_tag,oy,kernel,stride,pad,in_h,in_w,in_c);
                for(unsigned ox=0;ox<out_w;++ox)for(unsigned tile=0;tile<count;tile+=FACE_OC_TILE) {
                    unsigned tile_count=count-tile;if(tile_count>FACE_OC_TILE)tile_count=FACE_OC_TILE;
                    unsigned slot=tile/FACE_OC_TILE,weight_base=slot*kernel_values;
                    i32 accumulator[FACE_OC_TILE];
#pragma HLS ARRAY_PARTITION variable=accumulator complete
                    for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                        accumulator[lane]=lane<tile_count?bias_cache[lane][slot]:i32(0);
                    }
                    for(unsigned ky=0;ky<kernel;++ky)for(unsigned kx=0;kx<kernel;++kx)
                        for(unsigned ic=0;ic<in_per_group;++ic) {
#pragma HLS PIPELINE II=1
                            /* stride is validated to 1 or 2.  Expressing this as
                             * a general unsigned multiply made HLS build two
                             * cascaded 32-bit DSP multipliers on the critical
                             * control path.  The shift form is bit-exact. */
                            unsigned oy_stride=stride==2U?(oy<<1):oy;
                            unsigned ox_stride=stride==2U?(ox<<1):ox;
                            int iy=(int)(oy_stride+ky)-(int)pad;
                            int ix=(int)(ox_stride+kx)-(int)pad;
                            i8 sample=0;
                            if(iy>=0 && ix>=0 && iy<(int)in_h && ix<(int)in_w) {
                                unsigned offset=(unsigned)ix*in_c+input_channel_base+ic;
                                if(use_rows) {
                                    unsigned ch=input_channel_base+ic;
                                    sample=rows[(unsigned)iy%3U][ch%FACE_OC_TILE][(unsigned)ix*row_blocks+ch/FACE_OC_TILE];
                                }
                                else sample=input[(unsigned)iy*in_w*in_c+offset];
                            }
                            unsigned e=weight_base+(ky*kernel+kx)*in_per_group+ic;
                            for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS UNROLL
                                accumulator[lane]+=(i16)sample*(i16)weight_cache[lane][e];
                            }
                        }
                    for(unsigned lane=0;lane<FACE_OC_TILE;++lane) {
#pragma HLS PIPELINE II=1
                        if(lane<tile_count) {
                            unsigned oc=output_channel_base+block+tile+lane,index=(oy*out_w+ox)*out_c+oc;
                            i8 rv=residual_enable?residual[index]:i8(0);
                            output[index]=finish_value(accumulator[lane],mult_cache[lane][slot],shift_cache[lane][slot],
                                post_mult_cache[lane][slot],post_shift_cache[lane][slot],slope_cache[lane][slot],activation,rv,residual_enable);
                        }
                    }
                }
            }
        }
    }
}

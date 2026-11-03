#ifndef DB_FACE_MODEL_GENERATED_H
#define DB_FACE_MODEL_GENERATED_H
#include <stdint.h>
typedef struct {uint32_t offset,bytes;uint16_t h,w,c;float scale;} DbFaceTensorDesc;
typedef struct {uint16_t type,in0,in1,out,layer,kernel,stride,pad;} DbFaceOpDesc;
typedef struct {uint32_t weights_offset,bias_offset,multiplier_offset,shift_offset,slope_offset;uint16_t in_h,in_w,in_c,out_h,out_w,out_c,kernel,stride,pad,groups,activation;} DbFaceConvDesc;
extern const unsigned char db_yunet_pack_start[],db_yunet_pack_end[],db_mobile_pack_start[],db_mobile_pack_end[];
extern const DbFaceTensorDesc db_yunet_tensors[],db_mobile_tensors[];extern const DbFaceOpDesc db_yunet_ops[],db_mobile_ops[];extern const DbFaceConvDesc db_yunet_convs[],db_mobile_convs[];
extern const unsigned db_yunet_tensor_count,db_yunet_op_count,db_yunet_conv_count,db_yunet_input_tensor,db_yunet_arena_bytes;
extern const unsigned db_mobile_tensor_count,db_mobile_op_count,db_mobile_conv_count,db_mobile_input_tensor,db_mobile_final_tensor,db_mobile_arena_bytes;
extern const uint16_t db_yunet_heads[12];extern const float db_mobile_bn_gamma[512],db_mobile_bn_beta[512],db_mobile_bn_mean[512],db_mobile_bn_var[512],db_mobile_bn_epsilon;
extern const float db_mobile_flatten_prelu_slope[64];
#endif

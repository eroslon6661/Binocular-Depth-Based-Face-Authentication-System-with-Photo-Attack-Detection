// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
// Tool Version Limit: 2026.06
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
// control
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0 - ap_done (Read/TOW)
//        bit 1 - ap_ready (Read/TOW)
//        others - reserved
// 0x10 : Data signal of input_r
//        bit 31~0 - input_r[31:0] (Read/Write)
// 0x14 : Data signal of input_r
//        bit 31~0 - input_r[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of weights
//        bit 31~0 - weights[31:0] (Read/Write)
// 0x20 : Data signal of weights
//        bit 31~0 - weights[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of bias
//        bit 31~0 - bias[31:0] (Read/Write)
// 0x2c : Data signal of bias
//        bit 31~0 - bias[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of multiplier_q31
//        bit 31~0 - multiplier_q31[31:0] (Read/Write)
// 0x38 : Data signal of multiplier_q31
//        bit 31~0 - multiplier_q31[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of scale_shift
//        bit 31~0 - scale_shift[31:0] (Read/Write)
// 0x44 : Data signal of scale_shift
//        bit 31~0 - scale_shift[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of prelu_slope_q15
//        bit 31~0 - prelu_slope_q15[31:0] (Read/Write)
// 0x50 : Data signal of prelu_slope_q15
//        bit 31~0 - prelu_slope_q15[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of residual
//        bit 31~0 - residual[31:0] (Read/Write)
// 0x5c : Data signal of residual
//        bit 31~0 - residual[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of output_r
//        bit 31~0 - output_r[31:0] (Read/Write)
// 0x68 : Data signal of output_r
//        bit 31~0 - output_r[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of in_h
//        bit 31~0 - in_h[31:0] (Read/Write)
// 0x74 : reserved
// 0x78 : Data signal of in_w
//        bit 31~0 - in_w[31:0] (Read/Write)
// 0x7c : reserved
// 0x80 : Data signal of in_c
//        bit 31~0 - in_c[31:0] (Read/Write)
// 0x84 : reserved
// 0x88 : Data signal of out_c
//        bit 31~0 - out_c[31:0] (Read/Write)
// 0x8c : reserved
// 0x90 : Data signal of kernel
//        bit 31~0 - kernel[31:0] (Read/Write)
// 0x94 : reserved
// 0x98 : Data signal of stride
//        bit 31~0 - stride[31:0] (Read/Write)
// 0x9c : reserved
// 0xa0 : Data signal of pad
//        bit 31~0 - pad[31:0] (Read/Write)
// 0xa4 : reserved
// 0xa8 : Data signal of groups
//        bit 31~0 - groups[31:0] (Read/Write)
// 0xac : reserved
// 0xb0 : Data signal of in_per_group
//        bit 31~0 - in_per_group[31:0] (Read/Write)
// 0xb4 : reserved
// 0xb8 : Data signal of out_per_group
//        bit 31~0 - out_per_group[31:0] (Read/Write)
// 0xbc : reserved
// 0xc0 : Data signal of out_h
//        bit 31~0 - out_h[31:0] (Read/Write)
// 0xc4 : reserved
// 0xc8 : Data signal of out_w
//        bit 31~0 - out_w[31:0] (Read/Write)
// 0xcc : reserved
// 0xd0 : Data signal of activation
//        bit 31~0 - activation[31:0] (Read/Write)
// 0xd4 : reserved
// 0xd8 : Data signal of residual_enable
//        bit 31~0 - residual_enable[31:0] (Read/Write)
// 0xdc : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL              0x00
#define XFACE_INT8_ACCEL_CONTROL_ADDR_GIE                  0x04
#define XFACE_INT8_ACCEL_CONTROL_ADDR_IER                  0x08
#define XFACE_INT8_ACCEL_CONTROL_ADDR_ISR                  0x0c
#define XFACE_INT8_ACCEL_CONTROL_ADDR_INPUT_R_DATA         0x10
#define XFACE_INT8_ACCEL_CONTROL_BITS_INPUT_R_DATA         64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_WEIGHTS_DATA         0x1c
#define XFACE_INT8_ACCEL_CONTROL_BITS_WEIGHTS_DATA         64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_BIAS_DATA            0x28
#define XFACE_INT8_ACCEL_CONTROL_BITS_BIAS_DATA            64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_MULTIPLIER_Q31_DATA  0x34
#define XFACE_INT8_ACCEL_CONTROL_BITS_MULTIPLIER_Q31_DATA  64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_SCALE_SHIFT_DATA     0x40
#define XFACE_INT8_ACCEL_CONTROL_BITS_SCALE_SHIFT_DATA     64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_PRELU_SLOPE_Q15_DATA 0x4c
#define XFACE_INT8_ACCEL_CONTROL_BITS_PRELU_SLOPE_Q15_DATA 64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_DATA        0x58
#define XFACE_INT8_ACCEL_CONTROL_BITS_RESIDUAL_DATA        64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_OUTPUT_R_DATA        0x64
#define XFACE_INT8_ACCEL_CONTROL_BITS_OUTPUT_R_DATA        64
#define XFACE_INT8_ACCEL_CONTROL_ADDR_IN_H_DATA            0x70
#define XFACE_INT8_ACCEL_CONTROL_BITS_IN_H_DATA            32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_IN_W_DATA            0x78
#define XFACE_INT8_ACCEL_CONTROL_BITS_IN_W_DATA            32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_IN_C_DATA            0x80
#define XFACE_INT8_ACCEL_CONTROL_BITS_IN_C_DATA            32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_C_DATA           0x88
#define XFACE_INT8_ACCEL_CONTROL_BITS_OUT_C_DATA           32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_KERNEL_DATA          0x90
#define XFACE_INT8_ACCEL_CONTROL_BITS_KERNEL_DATA          32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_STRIDE_DATA          0x98
#define XFACE_INT8_ACCEL_CONTROL_BITS_STRIDE_DATA          32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_PAD_DATA             0xa0
#define XFACE_INT8_ACCEL_CONTROL_BITS_PAD_DATA             32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_GROUPS_DATA          0xa8
#define XFACE_INT8_ACCEL_CONTROL_BITS_GROUPS_DATA          32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_IN_PER_GROUP_DATA    0xb0
#define XFACE_INT8_ACCEL_CONTROL_BITS_IN_PER_GROUP_DATA    32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_PER_GROUP_DATA   0xb8
#define XFACE_INT8_ACCEL_CONTROL_BITS_OUT_PER_GROUP_DATA   32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_H_DATA           0xc0
#define XFACE_INT8_ACCEL_CONTROL_BITS_OUT_H_DATA           32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_W_DATA           0xc8
#define XFACE_INT8_ACCEL_CONTROL_BITS_OUT_W_DATA           32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_ACTIVATION_DATA      0xd0
#define XFACE_INT8_ACCEL_CONTROL_BITS_ACTIVATION_DATA      32
#define XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_ENABLE_DATA 0xd8
#define XFACE_INT8_ACCEL_CONTROL_BITS_RESIDUAL_ENABLE_DATA 32


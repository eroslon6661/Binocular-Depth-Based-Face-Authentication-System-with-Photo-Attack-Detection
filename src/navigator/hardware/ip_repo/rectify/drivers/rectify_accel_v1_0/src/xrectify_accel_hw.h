// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
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
// 0x10 : Data signal of source
//        bit 31~0 - source[31:0] (Read/Write)
// 0x14 : reserved
// 0x18 : Data signal of map_r
//        bit 31~0 - map_r[31:0] (Read/Write)
// 0x1c : reserved
// 0x20 : Data signal of destination
//        bit 31~0 - destination[31:0] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of valid_mask
//        bit 31~0 - valid_mask[31:0] (Read/Write)
// 0x2c : reserved
// 0x30 : Data signal of errors
//        bit 31~0 - errors[31:0] (Read)
// 0x34 : Control signal of errors
//        bit 0  - errors_ap_vld (Read/COR)
//        others - reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL          0x00
#define XRECTIFY_ACCEL_CONTROL_ADDR_GIE              0x04
#define XRECTIFY_ACCEL_CONTROL_ADDR_IER              0x08
#define XRECTIFY_ACCEL_CONTROL_ADDR_ISR              0x0c
#define XRECTIFY_ACCEL_CONTROL_ADDR_SOURCE_DATA      0x10
#define XRECTIFY_ACCEL_CONTROL_BITS_SOURCE_DATA      32
#define XRECTIFY_ACCEL_CONTROL_ADDR_MAP_R_DATA       0x18
#define XRECTIFY_ACCEL_CONTROL_BITS_MAP_R_DATA       32
#define XRECTIFY_ACCEL_CONTROL_ADDR_DESTINATION_DATA 0x20
#define XRECTIFY_ACCEL_CONTROL_BITS_DESTINATION_DATA 32
#define XRECTIFY_ACCEL_CONTROL_ADDR_VALID_MASK_DATA  0x28
#define XRECTIFY_ACCEL_CONTROL_BITS_VALID_MASK_DATA  32
#define XRECTIFY_ACCEL_CONTROL_ADDR_ERRORS_DATA      0x30
#define XRECTIFY_ACCEL_CONTROL_BITS_ERRORS_DATA      32
#define XRECTIFY_ACCEL_CONTROL_ADDR_ERRORS_CTRL      0x34


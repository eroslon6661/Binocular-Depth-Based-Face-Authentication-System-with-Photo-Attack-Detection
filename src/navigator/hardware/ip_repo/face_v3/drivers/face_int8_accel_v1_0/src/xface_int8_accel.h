// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
// Tool Version Limit: 2026.06
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XFACE_INT8_ACCEL_H
#define XFACE_INT8_ACCEL_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xface_int8_accel_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XFace_int8_accel_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XFace_int8_accel;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XFace_int8_accel_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XFace_int8_accel_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XFace_int8_accel_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XFace_int8_accel_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XFace_int8_accel_Initialize(XFace_int8_accel *InstancePtr, UINTPTR BaseAddress);
XFace_int8_accel_Config* XFace_int8_accel_LookupConfig(UINTPTR BaseAddress);
#else
int XFace_int8_accel_Initialize(XFace_int8_accel *InstancePtr, u16 DeviceId);
XFace_int8_accel_Config* XFace_int8_accel_LookupConfig(u16 DeviceId);
#endif
int XFace_int8_accel_CfgInitialize(XFace_int8_accel *InstancePtr, XFace_int8_accel_Config *ConfigPtr);
#else
int XFace_int8_accel_Initialize(XFace_int8_accel *InstancePtr, const char* InstanceName);
int XFace_int8_accel_Release(XFace_int8_accel *InstancePtr);
#endif

void XFace_int8_accel_Start(XFace_int8_accel *InstancePtr);
u32 XFace_int8_accel_IsDone(XFace_int8_accel *InstancePtr);
u32 XFace_int8_accel_IsIdle(XFace_int8_accel *InstancePtr);
u32 XFace_int8_accel_IsReady(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_EnableAutoRestart(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_DisableAutoRestart(XFace_int8_accel *InstancePtr);

void XFace_int8_accel_Set_input_r(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_input_r(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_weights(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_weights(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_bias(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_bias(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_multiplier_q31(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_multiplier_q31(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_scale_shift(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_scale_shift(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_prelu_slope_q15(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_prelu_slope_q15(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_residual(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_residual(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_output_r(XFace_int8_accel *InstancePtr, u64 Data);
u64 XFace_int8_accel_Get_output_r(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_in_h(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_in_h(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_in_w(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_in_w(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_in_c(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_in_c(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_out_c(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_out_c(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_kernel(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_kernel(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_stride(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_stride(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_pad(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_pad(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_groups(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_groups(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_in_per_group(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_in_per_group(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_out_per_group(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_out_per_group(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_out_h(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_out_h(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_out_w(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_out_w(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_activation(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_activation(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_Set_residual_enable(XFace_int8_accel *InstancePtr, u32 Data);
u32 XFace_int8_accel_Get_residual_enable(XFace_int8_accel *InstancePtr);

void XFace_int8_accel_InterruptGlobalEnable(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_InterruptGlobalDisable(XFace_int8_accel *InstancePtr);
void XFace_int8_accel_InterruptEnable(XFace_int8_accel *InstancePtr, u32 Mask);
void XFace_int8_accel_InterruptDisable(XFace_int8_accel *InstancePtr, u32 Mask);
void XFace_int8_accel_InterruptClear(XFace_int8_accel *InstancePtr, u32 Mask);
u32 XFace_int8_accel_InterruptGetEnabled(XFace_int8_accel *InstancePtr);
u32 XFace_int8_accel_InterruptGetStatus(XFace_int8_accel *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif

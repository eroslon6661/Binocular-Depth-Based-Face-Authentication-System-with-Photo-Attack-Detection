// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XRECTIFY_ACCEL_H
#define XRECTIFY_ACCEL_H

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
#include "xrectify_accel_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
    u16 DeviceId;
    u32 Control_BaseAddress;
} XRectify_accel_Config;
#endif

typedef struct {
    u32 Control_BaseAddress;
    u32 IsReady;
} XRectify_accel;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XRectify_accel_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XRectify_accel_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XRectify_accel_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XRectify_accel_ReadReg(BaseAddress, RegOffset) \
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
int XRectify_accel_Initialize(XRectify_accel *InstancePtr, u16 DeviceId);
XRectify_accel_Config* XRectify_accel_LookupConfig(u16 DeviceId);
int XRectify_accel_CfgInitialize(XRectify_accel *InstancePtr, XRectify_accel_Config *ConfigPtr);
#else
int XRectify_accel_Initialize(XRectify_accel *InstancePtr, const char* InstanceName);
int XRectify_accel_Release(XRectify_accel *InstancePtr);
#endif

void XRectify_accel_Start(XRectify_accel *InstancePtr);
u32 XRectify_accel_IsDone(XRectify_accel *InstancePtr);
u32 XRectify_accel_IsIdle(XRectify_accel *InstancePtr);
u32 XRectify_accel_IsReady(XRectify_accel *InstancePtr);
void XRectify_accel_EnableAutoRestart(XRectify_accel *InstancePtr);
void XRectify_accel_DisableAutoRestart(XRectify_accel *InstancePtr);

void XRectify_accel_Set_source(XRectify_accel *InstancePtr, u32 Data);
u32 XRectify_accel_Get_source(XRectify_accel *InstancePtr);
void XRectify_accel_Set_map_r(XRectify_accel *InstancePtr, u32 Data);
u32 XRectify_accel_Get_map_r(XRectify_accel *InstancePtr);
void XRectify_accel_Set_destination(XRectify_accel *InstancePtr, u32 Data);
u32 XRectify_accel_Get_destination(XRectify_accel *InstancePtr);
void XRectify_accel_Set_valid_mask(XRectify_accel *InstancePtr, u32 Data);
u32 XRectify_accel_Get_valid_mask(XRectify_accel *InstancePtr);
u32 XRectify_accel_Get_errors(XRectify_accel *InstancePtr);
u32 XRectify_accel_Get_errors_vld(XRectify_accel *InstancePtr);

void XRectify_accel_InterruptGlobalEnable(XRectify_accel *InstancePtr);
void XRectify_accel_InterruptGlobalDisable(XRectify_accel *InstancePtr);
void XRectify_accel_InterruptEnable(XRectify_accel *InstancePtr, u32 Mask);
void XRectify_accel_InterruptDisable(XRectify_accel *InstancePtr, u32 Mask);
void XRectify_accel_InterruptClear(XRectify_accel *InstancePtr, u32 Mask);
u32 XRectify_accel_InterruptGetEnabled(XRectify_accel *InstancePtr);
u32 XRectify_accel_InterruptGetStatus(XRectify_accel *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif

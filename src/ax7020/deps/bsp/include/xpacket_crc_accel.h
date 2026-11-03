// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XPACKET_CRC_ACCEL_H
#define XPACKET_CRC_ACCEL_H

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
#include "xpacket_crc_accel_hw.h"

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
} XPacket_crc_accel_Config;
#endif

typedef struct {
    u32 Control_BaseAddress;
    u32 IsReady;
} XPacket_crc_accel;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XPacket_crc_accel_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XPacket_crc_accel_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XPacket_crc_accel_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XPacket_crc_accel_ReadReg(BaseAddress, RegOffset) \
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
int XPacket_crc_accel_Initialize(XPacket_crc_accel *InstancePtr, u16 DeviceId);
XPacket_crc_accel_Config* XPacket_crc_accel_LookupConfig(u16 DeviceId);
int XPacket_crc_accel_CfgInitialize(XPacket_crc_accel *InstancePtr, XPacket_crc_accel_Config *ConfigPtr);
#else
int XPacket_crc_accel_Initialize(XPacket_crc_accel *InstancePtr, const char* InstanceName);
int XPacket_crc_accel_Release(XPacket_crc_accel *InstancePtr);
#endif

void XPacket_crc_accel_Start(XPacket_crc_accel *InstancePtr);
u32 XPacket_crc_accel_IsDone(XPacket_crc_accel *InstancePtr);
u32 XPacket_crc_accel_IsIdle(XPacket_crc_accel *InstancePtr);
u32 XPacket_crc_accel_IsReady(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_EnableAutoRestart(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_DisableAutoRestart(XPacket_crc_accel *InstancePtr);

void XPacket_crc_accel_Set_left_r(XPacket_crc_accel *InstancePtr, u32 Data);
u32 XPacket_crc_accel_Get_left_r(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_Set_right_r(XPacket_crc_accel *InstancePtr, u32 Data);
u32 XPacket_crc_accel_Get_right_r(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_Set_copy_left(XPacket_crc_accel *InstancePtr, u32 Data);
u32 XPacket_crc_accel_Get_copy_left(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_Set_copy_right(XPacket_crc_accel *InstancePtr, u32 Data);
u32 XPacket_crc_accel_Get_copy_right(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_Set_checksums(XPacket_crc_accel *InstancePtr, u32 Data);
u32 XPacket_crc_accel_Get_checksums(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_Set_copy_pixels(XPacket_crc_accel *InstancePtr, u32 Data);
u32 XPacket_crc_accel_Get_copy_pixels(XPacket_crc_accel *InstancePtr);
u32 XPacket_crc_accel_Get_completed(XPacket_crc_accel *InstancePtr);
u32 XPacket_crc_accel_Get_completed_vld(XPacket_crc_accel *InstancePtr);

void XPacket_crc_accel_InterruptGlobalEnable(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_InterruptGlobalDisable(XPacket_crc_accel *InstancePtr);
void XPacket_crc_accel_InterruptEnable(XPacket_crc_accel *InstancePtr, u32 Mask);
void XPacket_crc_accel_InterruptDisable(XPacket_crc_accel *InstancePtr, u32 Mask);
void XPacket_crc_accel_InterruptClear(XPacket_crc_accel *InstancePtr, u32 Mask);
u32 XPacket_crc_accel_InterruptGetEnabled(XPacket_crc_accel *InstancePtr);
u32 XPacket_crc_accel_InterruptGetStatus(XPacket_crc_accel *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif

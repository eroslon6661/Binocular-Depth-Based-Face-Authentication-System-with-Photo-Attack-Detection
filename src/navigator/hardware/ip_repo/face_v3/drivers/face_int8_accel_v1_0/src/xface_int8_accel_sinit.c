// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
// Tool Version Limit: 2026.06
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xface_int8_accel.h"

extern XFace_int8_accel_Config XFace_int8_accel_ConfigTable[];

#ifdef SDT
XFace_int8_accel_Config *XFace_int8_accel_LookupConfig(UINTPTR BaseAddress) {
	XFace_int8_accel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XFace_int8_accel_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XFace_int8_accel_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XFace_int8_accel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFace_int8_accel_Initialize(XFace_int8_accel *InstancePtr, UINTPTR BaseAddress) {
	XFace_int8_accel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFace_int8_accel_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFace_int8_accel_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XFace_int8_accel_Config *XFace_int8_accel_LookupConfig(u16 DeviceId) {
	XFace_int8_accel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XFACE_INT8_ACCEL_NUM_INSTANCES; Index++) {
		if (XFace_int8_accel_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XFace_int8_accel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XFace_int8_accel_Initialize(XFace_int8_accel *InstancePtr, u16 DeviceId) {
	XFace_int8_accel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XFace_int8_accel_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XFace_int8_accel_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif


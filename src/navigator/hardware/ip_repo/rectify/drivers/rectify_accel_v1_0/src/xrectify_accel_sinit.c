// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xrectify_accel.h"

extern XRectify_accel_Config XRectify_accel_ConfigTable[];

XRectify_accel_Config *XRectify_accel_LookupConfig(u16 DeviceId) {
	XRectify_accel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XRECTIFY_ACCEL_NUM_INSTANCES; Index++) {
		if (XRectify_accel_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XRectify_accel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XRectify_accel_Initialize(XRectify_accel *InstancePtr, u16 DeviceId) {
	XRectify_accel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XRectify_accel_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XRectify_accel_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif


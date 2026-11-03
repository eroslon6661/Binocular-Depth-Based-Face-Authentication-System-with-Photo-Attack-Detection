// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xpacket_crc_accel.h"

extern XPacket_crc_accel_Config XPacket_crc_accel_ConfigTable[];

XPacket_crc_accel_Config *XPacket_crc_accel_LookupConfig(u16 DeviceId) {
	XPacket_crc_accel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XPACKET_CRC_ACCEL_NUM_INSTANCES; Index++) {
		if (XPacket_crc_accel_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XPacket_crc_accel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XPacket_crc_accel_Initialize(XPacket_crc_accel *InstancePtr, u16 DeviceId) {
	XPacket_crc_accel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XPacket_crc_accel_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XPacket_crc_accel_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif


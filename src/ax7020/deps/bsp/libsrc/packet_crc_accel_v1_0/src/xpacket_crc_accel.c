// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xpacket_crc_accel.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XPacket_crc_accel_CfgInitialize(XPacket_crc_accel *InstancePtr, XPacket_crc_accel_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XPacket_crc_accel_Start(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XPacket_crc_accel_IsDone(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XPacket_crc_accel_IsIdle(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XPacket_crc_accel_IsReady(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XPacket_crc_accel_EnableAutoRestart(XPacket_crc_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XPacket_crc_accel_DisableAutoRestart(XPacket_crc_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_AP_CTRL, 0);
}

void XPacket_crc_accel_Set_left_r(XPacket_crc_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_LEFT_R_DATA, Data);
}

u32 XPacket_crc_accel_Get_left_r(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_LEFT_R_DATA);
    return Data;
}

void XPacket_crc_accel_Set_right_r(XPacket_crc_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_RIGHT_R_DATA, Data);
}

u32 XPacket_crc_accel_Get_right_r(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_RIGHT_R_DATA);
    return Data;
}

void XPacket_crc_accel_Set_copy_left(XPacket_crc_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COPY_LEFT_DATA, Data);
}

u32 XPacket_crc_accel_Get_copy_left(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COPY_LEFT_DATA);
    return Data;
}

void XPacket_crc_accel_Set_copy_right(XPacket_crc_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COPY_RIGHT_DATA, Data);
}

u32 XPacket_crc_accel_Get_copy_right(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COPY_RIGHT_DATA);
    return Data;
}

void XPacket_crc_accel_Set_checksums(XPacket_crc_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_CHECKSUMS_DATA, Data);
}

u32 XPacket_crc_accel_Get_checksums(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_CHECKSUMS_DATA);
    return Data;
}

void XPacket_crc_accel_Set_copy_pixels(XPacket_crc_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COPY_PIXELS_DATA, Data);
}

u32 XPacket_crc_accel_Get_copy_pixels(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COPY_PIXELS_DATA);
    return Data;
}

u32 XPacket_crc_accel_Get_completed(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COMPLETED_DATA);
    return Data;
}

u32 XPacket_crc_accel_Get_completed_vld(XPacket_crc_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_COMPLETED_CTRL);
    return Data & 0x1;
}

void XPacket_crc_accel_InterruptGlobalEnable(XPacket_crc_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_GIE, 1);
}

void XPacket_crc_accel_InterruptGlobalDisable(XPacket_crc_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_GIE, 0);
}

void XPacket_crc_accel_InterruptEnable(XPacket_crc_accel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_IER);
    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_IER, Register | Mask);
}

void XPacket_crc_accel_InterruptDisable(XPacket_crc_accel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_IER);
    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XPacket_crc_accel_InterruptClear(XPacket_crc_accel *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XPacket_crc_accel_WriteReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_ISR, Mask);
}

u32 XPacket_crc_accel_InterruptGetEnabled(XPacket_crc_accel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_IER);
}

u32 XPacket_crc_accel_InterruptGetStatus(XPacket_crc_accel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XPacket_crc_accel_ReadReg(InstancePtr->Control_BaseAddress, XPACKET_CRC_ACCEL_CONTROL_ADDR_ISR);
}


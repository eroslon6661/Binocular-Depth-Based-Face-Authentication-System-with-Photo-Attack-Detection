// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.2 (64-bit)
// Tool Version Limit: 2019.12
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xrectify_accel.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XRectify_accel_CfgInitialize(XRectify_accel *InstancePtr, XRectify_accel_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XRectify_accel_Start(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XRectify_accel_IsDone(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XRectify_accel_IsIdle(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XRectify_accel_IsReady(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XRectify_accel_EnableAutoRestart(XRectify_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XRectify_accel_DisableAutoRestart(XRectify_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_AP_CTRL, 0);
}

void XRectify_accel_Set_source(XRectify_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_SOURCE_DATA, Data);
}

u32 XRectify_accel_Get_source(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_SOURCE_DATA);
    return Data;
}

void XRectify_accel_Set_map_r(XRectify_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_MAP_R_DATA, Data);
}

u32 XRectify_accel_Get_map_r(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_MAP_R_DATA);
    return Data;
}

void XRectify_accel_Set_destination(XRectify_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_DESTINATION_DATA, Data);
}

u32 XRectify_accel_Get_destination(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_DESTINATION_DATA);
    return Data;
}

void XRectify_accel_Set_valid_mask(XRectify_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_VALID_MASK_DATA, Data);
}

u32 XRectify_accel_Get_valid_mask(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_VALID_MASK_DATA);
    return Data;
}

u32 XRectify_accel_Get_errors(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_ERRORS_DATA);
    return Data;
}

u32 XRectify_accel_Get_errors_vld(XRectify_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_ERRORS_CTRL);
    return Data & 0x1;
}

void XRectify_accel_InterruptGlobalEnable(XRectify_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_GIE, 1);
}

void XRectify_accel_InterruptGlobalDisable(XRectify_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_GIE, 0);
}

void XRectify_accel_InterruptEnable(XRectify_accel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_IER);
    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_IER, Register | Mask);
}

void XRectify_accel_InterruptDisable(XRectify_accel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_IER);
    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XRectify_accel_InterruptClear(XRectify_accel *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XRectify_accel_WriteReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_ISR, Mask);
}

u32 XRectify_accel_InterruptGetEnabled(XRectify_accel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_IER);
}

u32 XRectify_accel_InterruptGetStatus(XRectify_accel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XRectify_accel_ReadReg(InstancePtr->Control_BaseAddress, XRECTIFY_ACCEL_CONTROL_ADDR_ISR);
}


// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2026.1 (64-bit)
// Tool Version Limit: 2026.06
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xface_int8_accel.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XFace_int8_accel_CfgInitialize(XFace_int8_accel *InstancePtr, XFace_int8_accel_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XFace_int8_accel_Start(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XFace_int8_accel_IsDone(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XFace_int8_accel_IsIdle(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XFace_int8_accel_IsReady(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XFace_int8_accel_EnableAutoRestart(XFace_int8_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XFace_int8_accel_DisableAutoRestart(XFace_int8_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_AP_CTRL, 0);
}

void XFace_int8_accel_Set_input_r(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_INPUT_R_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_INPUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_input_r(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_INPUT_R_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_INPUT_R_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_weights(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_WEIGHTS_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_WEIGHTS_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_weights(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_WEIGHTS_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_WEIGHTS_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_bias(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_BIAS_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_BIAS_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_bias(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_BIAS_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_BIAS_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_multiplier_q31(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_MULTIPLIER_Q31_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_MULTIPLIER_Q31_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_multiplier_q31(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_MULTIPLIER_Q31_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_MULTIPLIER_Q31_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_scale_shift(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_SCALE_SHIFT_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_SCALE_SHIFT_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_scale_shift(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_SCALE_SHIFT_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_SCALE_SHIFT_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_prelu_slope_q15(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_PRELU_SLOPE_Q15_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_PRELU_SLOPE_Q15_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_prelu_slope_q15(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_PRELU_SLOPE_Q15_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_PRELU_SLOPE_Q15_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_residual(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_residual(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_output_r(XFace_int8_accel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUTPUT_R_DATA, (u32)(Data));
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUTPUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XFace_int8_accel_Get_output_r(XFace_int8_accel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUTPUT_R_DATA);
    Data += (u64)XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUTPUT_R_DATA + 4) << 32;
    return Data;
}

void XFace_int8_accel_Set_in_h(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_H_DATA, Data);
}

u32 XFace_int8_accel_Get_in_h(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_H_DATA);
    return Data;
}

void XFace_int8_accel_Set_in_w(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_W_DATA, Data);
}

u32 XFace_int8_accel_Get_in_w(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_W_DATA);
    return Data;
}

void XFace_int8_accel_Set_in_c(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_C_DATA, Data);
}

u32 XFace_int8_accel_Get_in_c(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_C_DATA);
    return Data;
}

void XFace_int8_accel_Set_out_c(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_C_DATA, Data);
}

u32 XFace_int8_accel_Get_out_c(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_C_DATA);
    return Data;
}

void XFace_int8_accel_Set_kernel(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_KERNEL_DATA, Data);
}

u32 XFace_int8_accel_Get_kernel(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_KERNEL_DATA);
    return Data;
}

void XFace_int8_accel_Set_stride(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_STRIDE_DATA, Data);
}

u32 XFace_int8_accel_Get_stride(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_STRIDE_DATA);
    return Data;
}

void XFace_int8_accel_Set_pad(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_PAD_DATA, Data);
}

u32 XFace_int8_accel_Get_pad(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_PAD_DATA);
    return Data;
}

void XFace_int8_accel_Set_groups(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_GROUPS_DATA, Data);
}

u32 XFace_int8_accel_Get_groups(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_GROUPS_DATA);
    return Data;
}

void XFace_int8_accel_Set_in_per_group(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_PER_GROUP_DATA, Data);
}

u32 XFace_int8_accel_Get_in_per_group(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IN_PER_GROUP_DATA);
    return Data;
}

void XFace_int8_accel_Set_out_per_group(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_PER_GROUP_DATA, Data);
}

u32 XFace_int8_accel_Get_out_per_group(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_PER_GROUP_DATA);
    return Data;
}

void XFace_int8_accel_Set_out_h(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_H_DATA, Data);
}

u32 XFace_int8_accel_Get_out_h(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_H_DATA);
    return Data;
}

void XFace_int8_accel_Set_out_w(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_W_DATA, Data);
}

u32 XFace_int8_accel_Get_out_w(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_OUT_W_DATA);
    return Data;
}

void XFace_int8_accel_Set_activation(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_ACTIVATION_DATA, Data);
}

u32 XFace_int8_accel_Get_activation(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_ACTIVATION_DATA);
    return Data;
}

void XFace_int8_accel_Set_residual_enable(XFace_int8_accel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_ENABLE_DATA, Data);
}

u32 XFace_int8_accel_Get_residual_enable(XFace_int8_accel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_RESIDUAL_ENABLE_DATA);
    return Data;
}

void XFace_int8_accel_InterruptGlobalEnable(XFace_int8_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_GIE, 1);
}

void XFace_int8_accel_InterruptGlobalDisable(XFace_int8_accel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_GIE, 0);
}

void XFace_int8_accel_InterruptEnable(XFace_int8_accel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IER);
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IER, Register | Mask);
}

void XFace_int8_accel_InterruptDisable(XFace_int8_accel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IER);
    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XFace_int8_accel_InterruptClear(XFace_int8_accel *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XFace_int8_accel_WriteReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_ISR, Mask);
}

u32 XFace_int8_accel_InterruptGetEnabled(XFace_int8_accel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_IER);
}

u32 XFace_int8_accel_InterruptGetStatus(XFace_int8_accel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XFace_int8_accel_ReadReg(InstancePtr->Control_BaseAddress, XFACE_INT8_ACCEL_CONTROL_ADDR_ISR);
}


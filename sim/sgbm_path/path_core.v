`timescale 1ns / 1ps
module sgbm_path_core_bus #(
    parameter DISP_NUM     = 65,
    parameter COST_BITS    = 4,
    parameter AGG_BITS     = 4,
    parameter P1           = 4'd2,
    parameter P2           = 4'd8,
    parameter INVALID_COST = 4'hf
)(
    input  wire [DISP_NUM*COST_BITS-1:0]         cost_bus,
    input  wire [DISP_NUM*AGG_BITS+AGG_BITS-1:0] prev_state,
    input  wire                                  boundary,
    output wire [DISP_NUM*AGG_BITS+AGG_BITS-1:0] next_state
);

// This source is intentionally fully unrolled for DISP_NUM=65.
// The project uses 65 disparities, and removing generate/for usage
// keeps older synthesis tools from spending excessive time expanding loops.

localparam integer STATEW = DISP_NUM * AGG_BITS;
localparam integer L1N = (DISP_NUM + 1) / 2;
localparam integer L2N = (L1N + 1) / 2;
localparam integer L3N = (L2N + 1) / 2;
localparam integer L4N = (L3N + 1) / 2;
localparam integer L5N = (L4N + 1) / 2;
localparam integer L6N = (L5N + 1) / 2;
localparam integer L7N = (L6N + 1) / 2;

wire [AGG_BITS-1:0] prev_min = prev_state[STATEW +: AGG_BITS];
wire [AGG_BITS:0]   p1_ext   = {1'b0, P1};

wire [STATEW-1:0] rel_bus;
wire [STATEW-1:0] self_delta_bus;
wire [STATEW-1:0] adj_delta_bus;
wire [STATEW-1:0] nb_bus;

wire [L1N*AGG_BITS-1:0] min_l1_bus;
wire [L2N*AGG_BITS-1:0] min_l2_bus;
wire [L3N*AGG_BITS-1:0] min_l3_bus;
wire [L4N*AGG_BITS-1:0] min_l4_bus;
wire [L5N*AGG_BITS-1:0] min_l5_bus;
wire [L6N*AGG_BITS-1:0] min_l6_bus;
wire [L7N*AGG_BITS-1:0] min_l7_bus;

function [AGG_BITS-1:0] min2_agg;
    input [AGG_BITS-1:0] a;
    input [AGG_BITS-1:0] b;
    begin
        min2_agg = (a < b) ? a : b;
    end
endfunction

function [AGG_BITS-1:0] clamp_to_p2;
    input [AGG_BITS:0] val;
    begin
        if (val > {1'b0, P2})
            clamp_to_p2 = P2[AGG_BITS-1:0];
        else
            clamp_to_p2 = val[AGG_BITS-1:0];
    end
endfunction

function [AGG_BITS-1:0] sat_add_cost_delta;
    input [COST_BITS-1:0] cost_val;
    input [AGG_BITS-1:0]  delta_val;
    reg   [AGG_BITS:0]    sum_val;
    begin
        sum_val = cost_val + delta_val;
        if (sum_val[AGG_BITS])
            sat_add_cost_delta = {AGG_BITS{1'b1}};
        else
            sat_add_cost_delta = sum_val[AGG_BITS-1:0];
    end
endfunction

wire [AGG_BITS-1:0] p_0 = prev_state[0*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_0 = p_0 - prev_min;
assign rel_bus[0*AGG_BITS +: AGG_BITS] = rel_0;
assign self_delta_bus[0*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_0});
assign adj_delta_bus[0*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_0} + p1_ext);

wire [AGG_BITS-1:0] p_1 = prev_state[1*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_1 = p_1 - prev_min;
assign rel_bus[1*AGG_BITS +: AGG_BITS] = rel_1;
assign self_delta_bus[1*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_1});
assign adj_delta_bus[1*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_1} + p1_ext);

wire [AGG_BITS-1:0] p_2 = prev_state[2*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_2 = p_2 - prev_min;
assign rel_bus[2*AGG_BITS +: AGG_BITS] = rel_2;
assign self_delta_bus[2*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_2});
assign adj_delta_bus[2*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_2} + p1_ext);

wire [AGG_BITS-1:0] p_3 = prev_state[3*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_3 = p_3 - prev_min;
assign rel_bus[3*AGG_BITS +: AGG_BITS] = rel_3;
assign self_delta_bus[3*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_3});
assign adj_delta_bus[3*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_3} + p1_ext);

wire [AGG_BITS-1:0] p_4 = prev_state[4*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_4 = p_4 - prev_min;
assign rel_bus[4*AGG_BITS +: AGG_BITS] = rel_4;
assign self_delta_bus[4*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_4});
assign adj_delta_bus[4*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_4} + p1_ext);

wire [AGG_BITS-1:0] p_5 = prev_state[5*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_5 = p_5 - prev_min;
assign rel_bus[5*AGG_BITS +: AGG_BITS] = rel_5;
assign self_delta_bus[5*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_5});
assign adj_delta_bus[5*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_5} + p1_ext);

wire [AGG_BITS-1:0] p_6 = prev_state[6*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_6 = p_6 - prev_min;
assign rel_bus[6*AGG_BITS +: AGG_BITS] = rel_6;
assign self_delta_bus[6*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_6});
assign adj_delta_bus[6*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_6} + p1_ext);

wire [AGG_BITS-1:0] p_7 = prev_state[7*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_7 = p_7 - prev_min;
assign rel_bus[7*AGG_BITS +: AGG_BITS] = rel_7;
assign self_delta_bus[7*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_7});
assign adj_delta_bus[7*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_7} + p1_ext);

wire [AGG_BITS-1:0] p_8 = prev_state[8*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_8 = p_8 - prev_min;
assign rel_bus[8*AGG_BITS +: AGG_BITS] = rel_8;
assign self_delta_bus[8*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_8});
assign adj_delta_bus[8*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_8} + p1_ext);

wire [AGG_BITS-1:0] p_9 = prev_state[9*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_9 = p_9 - prev_min;
assign rel_bus[9*AGG_BITS +: AGG_BITS] = rel_9;
assign self_delta_bus[9*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_9});
assign adj_delta_bus[9*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_9} + p1_ext);

wire [AGG_BITS-1:0] p_10 = prev_state[10*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_10 = p_10 - prev_min;
assign rel_bus[10*AGG_BITS +: AGG_BITS] = rel_10;
assign self_delta_bus[10*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_10});
assign adj_delta_bus[10*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_10} + p1_ext);

wire [AGG_BITS-1:0] p_11 = prev_state[11*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_11 = p_11 - prev_min;
assign rel_bus[11*AGG_BITS +: AGG_BITS] = rel_11;
assign self_delta_bus[11*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_11});
assign adj_delta_bus[11*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_11} + p1_ext);

wire [AGG_BITS-1:0] p_12 = prev_state[12*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_12 = p_12 - prev_min;
assign rel_bus[12*AGG_BITS +: AGG_BITS] = rel_12;
assign self_delta_bus[12*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_12});
assign adj_delta_bus[12*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_12} + p1_ext);

wire [AGG_BITS-1:0] p_13 = prev_state[13*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_13 = p_13 - prev_min;
assign rel_bus[13*AGG_BITS +: AGG_BITS] = rel_13;
assign self_delta_bus[13*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_13});
assign adj_delta_bus[13*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_13} + p1_ext);

wire [AGG_BITS-1:0] p_14 = prev_state[14*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_14 = p_14 - prev_min;
assign rel_bus[14*AGG_BITS +: AGG_BITS] = rel_14;
assign self_delta_bus[14*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_14});
assign adj_delta_bus[14*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_14} + p1_ext);

wire [AGG_BITS-1:0] p_15 = prev_state[15*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_15 = p_15 - prev_min;
assign rel_bus[15*AGG_BITS +: AGG_BITS] = rel_15;
assign self_delta_bus[15*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_15});
assign adj_delta_bus[15*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_15} + p1_ext);

wire [AGG_BITS-1:0] p_16 = prev_state[16*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_16 = p_16 - prev_min;
assign rel_bus[16*AGG_BITS +: AGG_BITS] = rel_16;
assign self_delta_bus[16*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_16});
assign adj_delta_bus[16*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_16} + p1_ext);

wire [AGG_BITS-1:0] p_17 = prev_state[17*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_17 = p_17 - prev_min;
assign rel_bus[17*AGG_BITS +: AGG_BITS] = rel_17;
assign self_delta_bus[17*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_17});
assign adj_delta_bus[17*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_17} + p1_ext);

wire [AGG_BITS-1:0] p_18 = prev_state[18*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_18 = p_18 - prev_min;
assign rel_bus[18*AGG_BITS +: AGG_BITS] = rel_18;
assign self_delta_bus[18*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_18});
assign adj_delta_bus[18*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_18} + p1_ext);

wire [AGG_BITS-1:0] p_19 = prev_state[19*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_19 = p_19 - prev_min;
assign rel_bus[19*AGG_BITS +: AGG_BITS] = rel_19;
assign self_delta_bus[19*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_19});
assign adj_delta_bus[19*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_19} + p1_ext);

wire [AGG_BITS-1:0] p_20 = prev_state[20*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_20 = p_20 - prev_min;
assign rel_bus[20*AGG_BITS +: AGG_BITS] = rel_20;
assign self_delta_bus[20*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_20});
assign adj_delta_bus[20*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_20} + p1_ext);

wire [AGG_BITS-1:0] p_21 = prev_state[21*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_21 = p_21 - prev_min;
assign rel_bus[21*AGG_BITS +: AGG_BITS] = rel_21;
assign self_delta_bus[21*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_21});
assign adj_delta_bus[21*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_21} + p1_ext);

wire [AGG_BITS-1:0] p_22 = prev_state[22*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_22 = p_22 - prev_min;
assign rel_bus[22*AGG_BITS +: AGG_BITS] = rel_22;
assign self_delta_bus[22*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_22});
assign adj_delta_bus[22*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_22} + p1_ext);

wire [AGG_BITS-1:0] p_23 = prev_state[23*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_23 = p_23 - prev_min;
assign rel_bus[23*AGG_BITS +: AGG_BITS] = rel_23;
assign self_delta_bus[23*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_23});
assign adj_delta_bus[23*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_23} + p1_ext);

wire [AGG_BITS-1:0] p_24 = prev_state[24*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_24 = p_24 - prev_min;
assign rel_bus[24*AGG_BITS +: AGG_BITS] = rel_24;
assign self_delta_bus[24*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_24});
assign adj_delta_bus[24*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_24} + p1_ext);

wire [AGG_BITS-1:0] p_25 = prev_state[25*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_25 = p_25 - prev_min;
assign rel_bus[25*AGG_BITS +: AGG_BITS] = rel_25;
assign self_delta_bus[25*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_25});
assign adj_delta_bus[25*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_25} + p1_ext);

wire [AGG_BITS-1:0] p_26 = prev_state[26*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_26 = p_26 - prev_min;
assign rel_bus[26*AGG_BITS +: AGG_BITS] = rel_26;
assign self_delta_bus[26*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_26});
assign adj_delta_bus[26*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_26} + p1_ext);

wire [AGG_BITS-1:0] p_27 = prev_state[27*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_27 = p_27 - prev_min;
assign rel_bus[27*AGG_BITS +: AGG_BITS] = rel_27;
assign self_delta_bus[27*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_27});
assign adj_delta_bus[27*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_27} + p1_ext);

wire [AGG_BITS-1:0] p_28 = prev_state[28*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_28 = p_28 - prev_min;
assign rel_bus[28*AGG_BITS +: AGG_BITS] = rel_28;
assign self_delta_bus[28*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_28});
assign adj_delta_bus[28*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_28} + p1_ext);

wire [AGG_BITS-1:0] p_29 = prev_state[29*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_29 = p_29 - prev_min;
assign rel_bus[29*AGG_BITS +: AGG_BITS] = rel_29;
assign self_delta_bus[29*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_29});
assign adj_delta_bus[29*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_29} + p1_ext);

wire [AGG_BITS-1:0] p_30 = prev_state[30*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_30 = p_30 - prev_min;
assign rel_bus[30*AGG_BITS +: AGG_BITS] = rel_30;
assign self_delta_bus[30*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_30});
assign adj_delta_bus[30*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_30} + p1_ext);

wire [AGG_BITS-1:0] p_31 = prev_state[31*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_31 = p_31 - prev_min;
assign rel_bus[31*AGG_BITS +: AGG_BITS] = rel_31;
assign self_delta_bus[31*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_31});
assign adj_delta_bus[31*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_31} + p1_ext);

wire [AGG_BITS-1:0] p_32 = prev_state[32*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_32 = p_32 - prev_min;
assign rel_bus[32*AGG_BITS +: AGG_BITS] = rel_32;
assign self_delta_bus[32*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_32});
assign adj_delta_bus[32*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_32} + p1_ext);

wire [AGG_BITS-1:0] p_33 = prev_state[33*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_33 = p_33 - prev_min;
assign rel_bus[33*AGG_BITS +: AGG_BITS] = rel_33;
assign self_delta_bus[33*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_33});
assign adj_delta_bus[33*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_33} + p1_ext);

wire [AGG_BITS-1:0] p_34 = prev_state[34*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_34 = p_34 - prev_min;
assign rel_bus[34*AGG_BITS +: AGG_BITS] = rel_34;
assign self_delta_bus[34*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_34});
assign adj_delta_bus[34*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_34} + p1_ext);

wire [AGG_BITS-1:0] p_35 = prev_state[35*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_35 = p_35 - prev_min;
assign rel_bus[35*AGG_BITS +: AGG_BITS] = rel_35;
assign self_delta_bus[35*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_35});
assign adj_delta_bus[35*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_35} + p1_ext);

wire [AGG_BITS-1:0] p_36 = prev_state[36*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_36 = p_36 - prev_min;
assign rel_bus[36*AGG_BITS +: AGG_BITS] = rel_36;
assign self_delta_bus[36*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_36});
assign adj_delta_bus[36*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_36} + p1_ext);

wire [AGG_BITS-1:0] p_37 = prev_state[37*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_37 = p_37 - prev_min;
assign rel_bus[37*AGG_BITS +: AGG_BITS] = rel_37;
assign self_delta_bus[37*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_37});
assign adj_delta_bus[37*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_37} + p1_ext);

wire [AGG_BITS-1:0] p_38 = prev_state[38*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_38 = p_38 - prev_min;
assign rel_bus[38*AGG_BITS +: AGG_BITS] = rel_38;
assign self_delta_bus[38*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_38});
assign adj_delta_bus[38*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_38} + p1_ext);

wire [AGG_BITS-1:0] p_39 = prev_state[39*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_39 = p_39 - prev_min;
assign rel_bus[39*AGG_BITS +: AGG_BITS] = rel_39;
assign self_delta_bus[39*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_39});
assign adj_delta_bus[39*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_39} + p1_ext);

wire [AGG_BITS-1:0] p_40 = prev_state[40*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_40 = p_40 - prev_min;
assign rel_bus[40*AGG_BITS +: AGG_BITS] = rel_40;
assign self_delta_bus[40*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_40});
assign adj_delta_bus[40*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_40} + p1_ext);

wire [AGG_BITS-1:0] p_41 = prev_state[41*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_41 = p_41 - prev_min;
assign rel_bus[41*AGG_BITS +: AGG_BITS] = rel_41;
assign self_delta_bus[41*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_41});
assign adj_delta_bus[41*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_41} + p1_ext);

wire [AGG_BITS-1:0] p_42 = prev_state[42*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_42 = p_42 - prev_min;
assign rel_bus[42*AGG_BITS +: AGG_BITS] = rel_42;
assign self_delta_bus[42*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_42});
assign adj_delta_bus[42*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_42} + p1_ext);

wire [AGG_BITS-1:0] p_43 = prev_state[43*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_43 = p_43 - prev_min;
assign rel_bus[43*AGG_BITS +: AGG_BITS] = rel_43;
assign self_delta_bus[43*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_43});
assign adj_delta_bus[43*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_43} + p1_ext);

wire [AGG_BITS-1:0] p_44 = prev_state[44*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_44 = p_44 - prev_min;
assign rel_bus[44*AGG_BITS +: AGG_BITS] = rel_44;
assign self_delta_bus[44*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_44});
assign adj_delta_bus[44*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_44} + p1_ext);

wire [AGG_BITS-1:0] p_45 = prev_state[45*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_45 = p_45 - prev_min;
assign rel_bus[45*AGG_BITS +: AGG_BITS] = rel_45;
assign self_delta_bus[45*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_45});
assign adj_delta_bus[45*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_45} + p1_ext);

wire [AGG_BITS-1:0] p_46 = prev_state[46*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_46 = p_46 - prev_min;
assign rel_bus[46*AGG_BITS +: AGG_BITS] = rel_46;
assign self_delta_bus[46*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_46});
assign adj_delta_bus[46*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_46} + p1_ext);

wire [AGG_BITS-1:0] p_47 = prev_state[47*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_47 = p_47 - prev_min;
assign rel_bus[47*AGG_BITS +: AGG_BITS] = rel_47;
assign self_delta_bus[47*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_47});
assign adj_delta_bus[47*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_47} + p1_ext);

wire [AGG_BITS-1:0] p_48 = prev_state[48*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_48 = p_48 - prev_min;
assign rel_bus[48*AGG_BITS +: AGG_BITS] = rel_48;
assign self_delta_bus[48*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_48});
assign adj_delta_bus[48*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_48} + p1_ext);

wire [AGG_BITS-1:0] p_49 = prev_state[49*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_49 = p_49 - prev_min;
assign rel_bus[49*AGG_BITS +: AGG_BITS] = rel_49;
assign self_delta_bus[49*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_49});
assign adj_delta_bus[49*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_49} + p1_ext);

wire [AGG_BITS-1:0] p_50 = prev_state[50*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_50 = p_50 - prev_min;
assign rel_bus[50*AGG_BITS +: AGG_BITS] = rel_50;
assign self_delta_bus[50*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_50});
assign adj_delta_bus[50*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_50} + p1_ext);

wire [AGG_BITS-1:0] p_51 = prev_state[51*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_51 = p_51 - prev_min;
assign rel_bus[51*AGG_BITS +: AGG_BITS] = rel_51;
assign self_delta_bus[51*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_51});
assign adj_delta_bus[51*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_51} + p1_ext);

wire [AGG_BITS-1:0] p_52 = prev_state[52*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_52 = p_52 - prev_min;
assign rel_bus[52*AGG_BITS +: AGG_BITS] = rel_52;
assign self_delta_bus[52*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_52});
assign adj_delta_bus[52*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_52} + p1_ext);

wire [AGG_BITS-1:0] p_53 = prev_state[53*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_53 = p_53 - prev_min;
assign rel_bus[53*AGG_BITS +: AGG_BITS] = rel_53;
assign self_delta_bus[53*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_53});
assign adj_delta_bus[53*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_53} + p1_ext);

wire [AGG_BITS-1:0] p_54 = prev_state[54*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_54 = p_54 - prev_min;
assign rel_bus[54*AGG_BITS +: AGG_BITS] = rel_54;
assign self_delta_bus[54*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_54});
assign adj_delta_bus[54*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_54} + p1_ext);

wire [AGG_BITS-1:0] p_55 = prev_state[55*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_55 = p_55 - prev_min;
assign rel_bus[55*AGG_BITS +: AGG_BITS] = rel_55;
assign self_delta_bus[55*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_55});
assign adj_delta_bus[55*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_55} + p1_ext);

wire [AGG_BITS-1:0] p_56 = prev_state[56*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_56 = p_56 - prev_min;
assign rel_bus[56*AGG_BITS +: AGG_BITS] = rel_56;
assign self_delta_bus[56*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_56});
assign adj_delta_bus[56*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_56} + p1_ext);

wire [AGG_BITS-1:0] p_57 = prev_state[57*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_57 = p_57 - prev_min;
assign rel_bus[57*AGG_BITS +: AGG_BITS] = rel_57;
assign self_delta_bus[57*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_57});
assign adj_delta_bus[57*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_57} + p1_ext);

wire [AGG_BITS-1:0] p_58 = prev_state[58*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_58 = p_58 - prev_min;
assign rel_bus[58*AGG_BITS +: AGG_BITS] = rel_58;
assign self_delta_bus[58*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_58});
assign adj_delta_bus[58*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_58} + p1_ext);

wire [AGG_BITS-1:0] p_59 = prev_state[59*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_59 = p_59 - prev_min;
assign rel_bus[59*AGG_BITS +: AGG_BITS] = rel_59;
assign self_delta_bus[59*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_59});
assign adj_delta_bus[59*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_59} + p1_ext);

wire [AGG_BITS-1:0] p_60 = prev_state[60*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_60 = p_60 - prev_min;
assign rel_bus[60*AGG_BITS +: AGG_BITS] = rel_60;
assign self_delta_bus[60*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_60});
assign adj_delta_bus[60*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_60} + p1_ext);

wire [AGG_BITS-1:0] p_61 = prev_state[61*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_61 = p_61 - prev_min;
assign rel_bus[61*AGG_BITS +: AGG_BITS] = rel_61;
assign self_delta_bus[61*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_61});
assign adj_delta_bus[61*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_61} + p1_ext);

wire [AGG_BITS-1:0] p_62 = prev_state[62*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_62 = p_62 - prev_min;
assign rel_bus[62*AGG_BITS +: AGG_BITS] = rel_62;
assign self_delta_bus[62*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_62});
assign adj_delta_bus[62*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_62} + p1_ext);

wire [AGG_BITS-1:0] p_63 = prev_state[63*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_63 = p_63 - prev_min;
assign rel_bus[63*AGG_BITS +: AGG_BITS] = rel_63;
assign self_delta_bus[63*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_63});
assign adj_delta_bus[63*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_63} + p1_ext);

wire [AGG_BITS-1:0] p_64 = prev_state[64*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] rel_64 = p_64 - prev_min;
assign rel_bus[64*AGG_BITS +: AGG_BITS] = rel_64;
assign self_delta_bus[64*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_64});
assign adj_delta_bus[64*AGG_BITS +: AGG_BITS] = clamp_to_p2({1'b0, rel_64} + p1_ext);

wire [COST_BITS-1:0] cost_0 = cost_bus[0*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_0 = self_delta_bus[0*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_0 = P2[AGG_BITS-1:0];
wire [AGG_BITS-1:0] right_delta_0 = adj_delta_bus[1*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_0 = min2_agg(self_delta_0, min2_agg(left_delta_0, right_delta_0));
wire [AGG_BITS-1:0] nb_0 = boundary ? cost_0[AGG_BITS-1:0] : sat_add_cost_delta(cost_0, delta_0);
assign nb_bus[0*AGG_BITS +: AGG_BITS] = nb_0;
assign next_state[0*AGG_BITS +: AGG_BITS] = nb_0;

wire [COST_BITS-1:0] cost_1 = cost_bus[1*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_1 = self_delta_bus[1*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_1 = adj_delta_bus[0*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_1 = adj_delta_bus[2*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_1 = min2_agg(self_delta_1, min2_agg(left_delta_1, right_delta_1));
wire [AGG_BITS-1:0] nb_1 = boundary ? cost_1[AGG_BITS-1:0] : sat_add_cost_delta(cost_1, delta_1);
assign nb_bus[1*AGG_BITS +: AGG_BITS] = nb_1;
assign next_state[1*AGG_BITS +: AGG_BITS] = nb_1;

wire [COST_BITS-1:0] cost_2 = cost_bus[2*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_2 = self_delta_bus[2*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_2 = adj_delta_bus[1*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_2 = adj_delta_bus[3*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_2 = min2_agg(self_delta_2, min2_agg(left_delta_2, right_delta_2));
wire [AGG_BITS-1:0] nb_2 = boundary ? cost_2[AGG_BITS-1:0] : sat_add_cost_delta(cost_2, delta_2);
assign nb_bus[2*AGG_BITS +: AGG_BITS] = nb_2;
assign next_state[2*AGG_BITS +: AGG_BITS] = nb_2;

wire [COST_BITS-1:0] cost_3 = cost_bus[3*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_3 = self_delta_bus[3*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_3 = adj_delta_bus[2*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_3 = adj_delta_bus[4*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_3 = min2_agg(self_delta_3, min2_agg(left_delta_3, right_delta_3));
wire [AGG_BITS-1:0] nb_3 = boundary ? cost_3[AGG_BITS-1:0] : sat_add_cost_delta(cost_3, delta_3);
assign nb_bus[3*AGG_BITS +: AGG_BITS] = nb_3;
assign next_state[3*AGG_BITS +: AGG_BITS] = nb_3;

wire [COST_BITS-1:0] cost_4 = cost_bus[4*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_4 = self_delta_bus[4*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_4 = adj_delta_bus[3*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_4 = adj_delta_bus[5*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_4 = min2_agg(self_delta_4, min2_agg(left_delta_4, right_delta_4));
wire [AGG_BITS-1:0] nb_4 = boundary ? cost_4[AGG_BITS-1:0] : sat_add_cost_delta(cost_4, delta_4);
assign nb_bus[4*AGG_BITS +: AGG_BITS] = nb_4;
assign next_state[4*AGG_BITS +: AGG_BITS] = nb_4;

wire [COST_BITS-1:0] cost_5 = cost_bus[5*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_5 = self_delta_bus[5*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_5 = adj_delta_bus[4*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_5 = adj_delta_bus[6*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_5 = min2_agg(self_delta_5, min2_agg(left_delta_5, right_delta_5));
wire [AGG_BITS-1:0] nb_5 = boundary ? cost_5[AGG_BITS-1:0] : sat_add_cost_delta(cost_5, delta_5);
assign nb_bus[5*AGG_BITS +: AGG_BITS] = nb_5;
assign next_state[5*AGG_BITS +: AGG_BITS] = nb_5;

wire [COST_BITS-1:0] cost_6 = cost_bus[6*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_6 = self_delta_bus[6*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_6 = adj_delta_bus[5*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_6 = adj_delta_bus[7*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_6 = min2_agg(self_delta_6, min2_agg(left_delta_6, right_delta_6));
wire [AGG_BITS-1:0] nb_6 = boundary ? cost_6[AGG_BITS-1:0] : sat_add_cost_delta(cost_6, delta_6);
assign nb_bus[6*AGG_BITS +: AGG_BITS] = nb_6;
assign next_state[6*AGG_BITS +: AGG_BITS] = nb_6;

wire [COST_BITS-1:0] cost_7 = cost_bus[7*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_7 = self_delta_bus[7*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_7 = adj_delta_bus[6*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_7 = adj_delta_bus[8*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_7 = min2_agg(self_delta_7, min2_agg(left_delta_7, right_delta_7));
wire [AGG_BITS-1:0] nb_7 = boundary ? cost_7[AGG_BITS-1:0] : sat_add_cost_delta(cost_7, delta_7);
assign nb_bus[7*AGG_BITS +: AGG_BITS] = nb_7;
assign next_state[7*AGG_BITS +: AGG_BITS] = nb_7;

wire [COST_BITS-1:0] cost_8 = cost_bus[8*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_8 = self_delta_bus[8*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_8 = adj_delta_bus[7*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_8 = adj_delta_bus[9*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_8 = min2_agg(self_delta_8, min2_agg(left_delta_8, right_delta_8));
wire [AGG_BITS-1:0] nb_8 = boundary ? cost_8[AGG_BITS-1:0] : sat_add_cost_delta(cost_8, delta_8);
assign nb_bus[8*AGG_BITS +: AGG_BITS] = nb_8;
assign next_state[8*AGG_BITS +: AGG_BITS] = nb_8;

wire [COST_BITS-1:0] cost_9 = cost_bus[9*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_9 = self_delta_bus[9*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_9 = adj_delta_bus[8*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_9 = adj_delta_bus[10*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_9 = min2_agg(self_delta_9, min2_agg(left_delta_9, right_delta_9));
wire [AGG_BITS-1:0] nb_9 = boundary ? cost_9[AGG_BITS-1:0] : sat_add_cost_delta(cost_9, delta_9);
assign nb_bus[9*AGG_BITS +: AGG_BITS] = nb_9;
assign next_state[9*AGG_BITS +: AGG_BITS] = nb_9;

wire [COST_BITS-1:0] cost_10 = cost_bus[10*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_10 = self_delta_bus[10*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_10 = adj_delta_bus[9*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_10 = adj_delta_bus[11*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_10 = min2_agg(self_delta_10, min2_agg(left_delta_10, right_delta_10));
wire [AGG_BITS-1:0] nb_10 = boundary ? cost_10[AGG_BITS-1:0] : sat_add_cost_delta(cost_10, delta_10);
assign nb_bus[10*AGG_BITS +: AGG_BITS] = nb_10;
assign next_state[10*AGG_BITS +: AGG_BITS] = nb_10;

wire [COST_BITS-1:0] cost_11 = cost_bus[11*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_11 = self_delta_bus[11*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_11 = adj_delta_bus[10*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_11 = adj_delta_bus[12*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_11 = min2_agg(self_delta_11, min2_agg(left_delta_11, right_delta_11));
wire [AGG_BITS-1:0] nb_11 = boundary ? cost_11[AGG_BITS-1:0] : sat_add_cost_delta(cost_11, delta_11);
assign nb_bus[11*AGG_BITS +: AGG_BITS] = nb_11;
assign next_state[11*AGG_BITS +: AGG_BITS] = nb_11;

wire [COST_BITS-1:0] cost_12 = cost_bus[12*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_12 = self_delta_bus[12*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_12 = adj_delta_bus[11*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_12 = adj_delta_bus[13*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_12 = min2_agg(self_delta_12, min2_agg(left_delta_12, right_delta_12));
wire [AGG_BITS-1:0] nb_12 = boundary ? cost_12[AGG_BITS-1:0] : sat_add_cost_delta(cost_12, delta_12);
assign nb_bus[12*AGG_BITS +: AGG_BITS] = nb_12;
assign next_state[12*AGG_BITS +: AGG_BITS] = nb_12;

wire [COST_BITS-1:0] cost_13 = cost_bus[13*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_13 = self_delta_bus[13*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_13 = adj_delta_bus[12*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_13 = adj_delta_bus[14*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_13 = min2_agg(self_delta_13, min2_agg(left_delta_13, right_delta_13));
wire [AGG_BITS-1:0] nb_13 = boundary ? cost_13[AGG_BITS-1:0] : sat_add_cost_delta(cost_13, delta_13);
assign nb_bus[13*AGG_BITS +: AGG_BITS] = nb_13;
assign next_state[13*AGG_BITS +: AGG_BITS] = nb_13;

wire [COST_BITS-1:0] cost_14 = cost_bus[14*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_14 = self_delta_bus[14*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_14 = adj_delta_bus[13*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_14 = adj_delta_bus[15*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_14 = min2_agg(self_delta_14, min2_agg(left_delta_14, right_delta_14));
wire [AGG_BITS-1:0] nb_14 = boundary ? cost_14[AGG_BITS-1:0] : sat_add_cost_delta(cost_14, delta_14);
assign nb_bus[14*AGG_BITS +: AGG_BITS] = nb_14;
assign next_state[14*AGG_BITS +: AGG_BITS] = nb_14;

wire [COST_BITS-1:0] cost_15 = cost_bus[15*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_15 = self_delta_bus[15*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_15 = adj_delta_bus[14*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_15 = adj_delta_bus[16*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_15 = min2_agg(self_delta_15, min2_agg(left_delta_15, right_delta_15));
wire [AGG_BITS-1:0] nb_15 = boundary ? cost_15[AGG_BITS-1:0] : sat_add_cost_delta(cost_15, delta_15);
assign nb_bus[15*AGG_BITS +: AGG_BITS] = nb_15;
assign next_state[15*AGG_BITS +: AGG_BITS] = nb_15;

wire [COST_BITS-1:0] cost_16 = cost_bus[16*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_16 = self_delta_bus[16*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_16 = adj_delta_bus[15*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_16 = adj_delta_bus[17*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_16 = min2_agg(self_delta_16, min2_agg(left_delta_16, right_delta_16));
wire [AGG_BITS-1:0] nb_16 = boundary ? cost_16[AGG_BITS-1:0] : sat_add_cost_delta(cost_16, delta_16);
assign nb_bus[16*AGG_BITS +: AGG_BITS] = nb_16;
assign next_state[16*AGG_BITS +: AGG_BITS] = nb_16;

wire [COST_BITS-1:0] cost_17 = cost_bus[17*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_17 = self_delta_bus[17*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_17 = adj_delta_bus[16*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_17 = adj_delta_bus[18*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_17 = min2_agg(self_delta_17, min2_agg(left_delta_17, right_delta_17));
wire [AGG_BITS-1:0] nb_17 = boundary ? cost_17[AGG_BITS-1:0] : sat_add_cost_delta(cost_17, delta_17);
assign nb_bus[17*AGG_BITS +: AGG_BITS] = nb_17;
assign next_state[17*AGG_BITS +: AGG_BITS] = nb_17;

wire [COST_BITS-1:0] cost_18 = cost_bus[18*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_18 = self_delta_bus[18*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_18 = adj_delta_bus[17*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_18 = adj_delta_bus[19*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_18 = min2_agg(self_delta_18, min2_agg(left_delta_18, right_delta_18));
wire [AGG_BITS-1:0] nb_18 = boundary ? cost_18[AGG_BITS-1:0] : sat_add_cost_delta(cost_18, delta_18);
assign nb_bus[18*AGG_BITS +: AGG_BITS] = nb_18;
assign next_state[18*AGG_BITS +: AGG_BITS] = nb_18;

wire [COST_BITS-1:0] cost_19 = cost_bus[19*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_19 = self_delta_bus[19*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_19 = adj_delta_bus[18*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_19 = adj_delta_bus[20*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_19 = min2_agg(self_delta_19, min2_agg(left_delta_19, right_delta_19));
wire [AGG_BITS-1:0] nb_19 = boundary ? cost_19[AGG_BITS-1:0] : sat_add_cost_delta(cost_19, delta_19);
assign nb_bus[19*AGG_BITS +: AGG_BITS] = nb_19;
assign next_state[19*AGG_BITS +: AGG_BITS] = nb_19;

wire [COST_BITS-1:0] cost_20 = cost_bus[20*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_20 = self_delta_bus[20*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_20 = adj_delta_bus[19*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_20 = adj_delta_bus[21*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_20 = min2_agg(self_delta_20, min2_agg(left_delta_20, right_delta_20));
wire [AGG_BITS-1:0] nb_20 = boundary ? cost_20[AGG_BITS-1:0] : sat_add_cost_delta(cost_20, delta_20);
assign nb_bus[20*AGG_BITS +: AGG_BITS] = nb_20;
assign next_state[20*AGG_BITS +: AGG_BITS] = nb_20;

wire [COST_BITS-1:0] cost_21 = cost_bus[21*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_21 = self_delta_bus[21*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_21 = adj_delta_bus[20*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_21 = adj_delta_bus[22*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_21 = min2_agg(self_delta_21, min2_agg(left_delta_21, right_delta_21));
wire [AGG_BITS-1:0] nb_21 = boundary ? cost_21[AGG_BITS-1:0] : sat_add_cost_delta(cost_21, delta_21);
assign nb_bus[21*AGG_BITS +: AGG_BITS] = nb_21;
assign next_state[21*AGG_BITS +: AGG_BITS] = nb_21;

wire [COST_BITS-1:0] cost_22 = cost_bus[22*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_22 = self_delta_bus[22*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_22 = adj_delta_bus[21*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_22 = adj_delta_bus[23*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_22 = min2_agg(self_delta_22, min2_agg(left_delta_22, right_delta_22));
wire [AGG_BITS-1:0] nb_22 = boundary ? cost_22[AGG_BITS-1:0] : sat_add_cost_delta(cost_22, delta_22);
assign nb_bus[22*AGG_BITS +: AGG_BITS] = nb_22;
assign next_state[22*AGG_BITS +: AGG_BITS] = nb_22;

wire [COST_BITS-1:0] cost_23 = cost_bus[23*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_23 = self_delta_bus[23*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_23 = adj_delta_bus[22*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_23 = adj_delta_bus[24*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_23 = min2_agg(self_delta_23, min2_agg(left_delta_23, right_delta_23));
wire [AGG_BITS-1:0] nb_23 = boundary ? cost_23[AGG_BITS-1:0] : sat_add_cost_delta(cost_23, delta_23);
assign nb_bus[23*AGG_BITS +: AGG_BITS] = nb_23;
assign next_state[23*AGG_BITS +: AGG_BITS] = nb_23;

wire [COST_BITS-1:0] cost_24 = cost_bus[24*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_24 = self_delta_bus[24*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_24 = adj_delta_bus[23*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_24 = adj_delta_bus[25*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_24 = min2_agg(self_delta_24, min2_agg(left_delta_24, right_delta_24));
wire [AGG_BITS-1:0] nb_24 = boundary ? cost_24[AGG_BITS-1:0] : sat_add_cost_delta(cost_24, delta_24);
assign nb_bus[24*AGG_BITS +: AGG_BITS] = nb_24;
assign next_state[24*AGG_BITS +: AGG_BITS] = nb_24;

wire [COST_BITS-1:0] cost_25 = cost_bus[25*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_25 = self_delta_bus[25*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_25 = adj_delta_bus[24*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_25 = adj_delta_bus[26*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_25 = min2_agg(self_delta_25, min2_agg(left_delta_25, right_delta_25));
wire [AGG_BITS-1:0] nb_25 = boundary ? cost_25[AGG_BITS-1:0] : sat_add_cost_delta(cost_25, delta_25);
assign nb_bus[25*AGG_BITS +: AGG_BITS] = nb_25;
assign next_state[25*AGG_BITS +: AGG_BITS] = nb_25;

wire [COST_BITS-1:0] cost_26 = cost_bus[26*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_26 = self_delta_bus[26*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_26 = adj_delta_bus[25*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_26 = adj_delta_bus[27*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_26 = min2_agg(self_delta_26, min2_agg(left_delta_26, right_delta_26));
wire [AGG_BITS-1:0] nb_26 = boundary ? cost_26[AGG_BITS-1:0] : sat_add_cost_delta(cost_26, delta_26);
assign nb_bus[26*AGG_BITS +: AGG_BITS] = nb_26;
assign next_state[26*AGG_BITS +: AGG_BITS] = nb_26;

wire [COST_BITS-1:0] cost_27 = cost_bus[27*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_27 = self_delta_bus[27*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_27 = adj_delta_bus[26*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_27 = adj_delta_bus[28*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_27 = min2_agg(self_delta_27, min2_agg(left_delta_27, right_delta_27));
wire [AGG_BITS-1:0] nb_27 = boundary ? cost_27[AGG_BITS-1:0] : sat_add_cost_delta(cost_27, delta_27);
assign nb_bus[27*AGG_BITS +: AGG_BITS] = nb_27;
assign next_state[27*AGG_BITS +: AGG_BITS] = nb_27;

wire [COST_BITS-1:0] cost_28 = cost_bus[28*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_28 = self_delta_bus[28*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_28 = adj_delta_bus[27*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_28 = adj_delta_bus[29*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_28 = min2_agg(self_delta_28, min2_agg(left_delta_28, right_delta_28));
wire [AGG_BITS-1:0] nb_28 = boundary ? cost_28[AGG_BITS-1:0] : sat_add_cost_delta(cost_28, delta_28);
assign nb_bus[28*AGG_BITS +: AGG_BITS] = nb_28;
assign next_state[28*AGG_BITS +: AGG_BITS] = nb_28;

wire [COST_BITS-1:0] cost_29 = cost_bus[29*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_29 = self_delta_bus[29*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_29 = adj_delta_bus[28*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_29 = adj_delta_bus[30*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_29 = min2_agg(self_delta_29, min2_agg(left_delta_29, right_delta_29));
wire [AGG_BITS-1:0] nb_29 = boundary ? cost_29[AGG_BITS-1:0] : sat_add_cost_delta(cost_29, delta_29);
assign nb_bus[29*AGG_BITS +: AGG_BITS] = nb_29;
assign next_state[29*AGG_BITS +: AGG_BITS] = nb_29;

wire [COST_BITS-1:0] cost_30 = cost_bus[30*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_30 = self_delta_bus[30*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_30 = adj_delta_bus[29*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_30 = adj_delta_bus[31*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_30 = min2_agg(self_delta_30, min2_agg(left_delta_30, right_delta_30));
wire [AGG_BITS-1:0] nb_30 = boundary ? cost_30[AGG_BITS-1:0] : sat_add_cost_delta(cost_30, delta_30);
assign nb_bus[30*AGG_BITS +: AGG_BITS] = nb_30;
assign next_state[30*AGG_BITS +: AGG_BITS] = nb_30;

wire [COST_BITS-1:0] cost_31 = cost_bus[31*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_31 = self_delta_bus[31*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_31 = adj_delta_bus[30*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_31 = adj_delta_bus[32*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_31 = min2_agg(self_delta_31, min2_agg(left_delta_31, right_delta_31));
wire [AGG_BITS-1:0] nb_31 = boundary ? cost_31[AGG_BITS-1:0] : sat_add_cost_delta(cost_31, delta_31);
assign nb_bus[31*AGG_BITS +: AGG_BITS] = nb_31;
assign next_state[31*AGG_BITS +: AGG_BITS] = nb_31;

wire [COST_BITS-1:0] cost_32 = cost_bus[32*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_32 = self_delta_bus[32*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_32 = adj_delta_bus[31*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_32 = adj_delta_bus[33*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_32 = min2_agg(self_delta_32, min2_agg(left_delta_32, right_delta_32));
wire [AGG_BITS-1:0] nb_32 = boundary ? cost_32[AGG_BITS-1:0] : sat_add_cost_delta(cost_32, delta_32);
assign nb_bus[32*AGG_BITS +: AGG_BITS] = nb_32;
assign next_state[32*AGG_BITS +: AGG_BITS] = nb_32;

wire [COST_BITS-1:0] cost_33 = cost_bus[33*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_33 = self_delta_bus[33*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_33 = adj_delta_bus[32*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_33 = adj_delta_bus[34*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_33 = min2_agg(self_delta_33, min2_agg(left_delta_33, right_delta_33));
wire [AGG_BITS-1:0] nb_33 = boundary ? cost_33[AGG_BITS-1:0] : sat_add_cost_delta(cost_33, delta_33);
assign nb_bus[33*AGG_BITS +: AGG_BITS] = nb_33;
assign next_state[33*AGG_BITS +: AGG_BITS] = nb_33;

wire [COST_BITS-1:0] cost_34 = cost_bus[34*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_34 = self_delta_bus[34*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_34 = adj_delta_bus[33*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_34 = adj_delta_bus[35*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_34 = min2_agg(self_delta_34, min2_agg(left_delta_34, right_delta_34));
wire [AGG_BITS-1:0] nb_34 = boundary ? cost_34[AGG_BITS-1:0] : sat_add_cost_delta(cost_34, delta_34);
assign nb_bus[34*AGG_BITS +: AGG_BITS] = nb_34;
assign next_state[34*AGG_BITS +: AGG_BITS] = nb_34;

wire [COST_BITS-1:0] cost_35 = cost_bus[35*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_35 = self_delta_bus[35*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_35 = adj_delta_bus[34*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_35 = adj_delta_bus[36*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_35 = min2_agg(self_delta_35, min2_agg(left_delta_35, right_delta_35));
wire [AGG_BITS-1:0] nb_35 = boundary ? cost_35[AGG_BITS-1:0] : sat_add_cost_delta(cost_35, delta_35);
assign nb_bus[35*AGG_BITS +: AGG_BITS] = nb_35;
assign next_state[35*AGG_BITS +: AGG_BITS] = nb_35;

wire [COST_BITS-1:0] cost_36 = cost_bus[36*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_36 = self_delta_bus[36*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_36 = adj_delta_bus[35*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_36 = adj_delta_bus[37*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_36 = min2_agg(self_delta_36, min2_agg(left_delta_36, right_delta_36));
wire [AGG_BITS-1:0] nb_36 = boundary ? cost_36[AGG_BITS-1:0] : sat_add_cost_delta(cost_36, delta_36);
assign nb_bus[36*AGG_BITS +: AGG_BITS] = nb_36;
assign next_state[36*AGG_BITS +: AGG_BITS] = nb_36;

wire [COST_BITS-1:0] cost_37 = cost_bus[37*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_37 = self_delta_bus[37*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_37 = adj_delta_bus[36*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_37 = adj_delta_bus[38*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_37 = min2_agg(self_delta_37, min2_agg(left_delta_37, right_delta_37));
wire [AGG_BITS-1:0] nb_37 = boundary ? cost_37[AGG_BITS-1:0] : sat_add_cost_delta(cost_37, delta_37);
assign nb_bus[37*AGG_BITS +: AGG_BITS] = nb_37;
assign next_state[37*AGG_BITS +: AGG_BITS] = nb_37;

wire [COST_BITS-1:0] cost_38 = cost_bus[38*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_38 = self_delta_bus[38*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_38 = adj_delta_bus[37*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_38 = adj_delta_bus[39*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_38 = min2_agg(self_delta_38, min2_agg(left_delta_38, right_delta_38));
wire [AGG_BITS-1:0] nb_38 = boundary ? cost_38[AGG_BITS-1:0] : sat_add_cost_delta(cost_38, delta_38);
assign nb_bus[38*AGG_BITS +: AGG_BITS] = nb_38;
assign next_state[38*AGG_BITS +: AGG_BITS] = nb_38;

wire [COST_BITS-1:0] cost_39 = cost_bus[39*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_39 = self_delta_bus[39*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_39 = adj_delta_bus[38*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_39 = adj_delta_bus[40*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_39 = min2_agg(self_delta_39, min2_agg(left_delta_39, right_delta_39));
wire [AGG_BITS-1:0] nb_39 = boundary ? cost_39[AGG_BITS-1:0] : sat_add_cost_delta(cost_39, delta_39);
assign nb_bus[39*AGG_BITS +: AGG_BITS] = nb_39;
assign next_state[39*AGG_BITS +: AGG_BITS] = nb_39;

wire [COST_BITS-1:0] cost_40 = cost_bus[40*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_40 = self_delta_bus[40*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_40 = adj_delta_bus[39*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_40 = adj_delta_bus[41*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_40 = min2_agg(self_delta_40, min2_agg(left_delta_40, right_delta_40));
wire [AGG_BITS-1:0] nb_40 = boundary ? cost_40[AGG_BITS-1:0] : sat_add_cost_delta(cost_40, delta_40);
assign nb_bus[40*AGG_BITS +: AGG_BITS] = nb_40;
assign next_state[40*AGG_BITS +: AGG_BITS] = nb_40;

wire [COST_BITS-1:0] cost_41 = cost_bus[41*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_41 = self_delta_bus[41*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_41 = adj_delta_bus[40*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_41 = adj_delta_bus[42*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_41 = min2_agg(self_delta_41, min2_agg(left_delta_41, right_delta_41));
wire [AGG_BITS-1:0] nb_41 = boundary ? cost_41[AGG_BITS-1:0] : sat_add_cost_delta(cost_41, delta_41);
assign nb_bus[41*AGG_BITS +: AGG_BITS] = nb_41;
assign next_state[41*AGG_BITS +: AGG_BITS] = nb_41;

wire [COST_BITS-1:0] cost_42 = cost_bus[42*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_42 = self_delta_bus[42*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_42 = adj_delta_bus[41*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_42 = adj_delta_bus[43*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_42 = min2_agg(self_delta_42, min2_agg(left_delta_42, right_delta_42));
wire [AGG_BITS-1:0] nb_42 = boundary ? cost_42[AGG_BITS-1:0] : sat_add_cost_delta(cost_42, delta_42);
assign nb_bus[42*AGG_BITS +: AGG_BITS] = nb_42;
assign next_state[42*AGG_BITS +: AGG_BITS] = nb_42;

wire [COST_BITS-1:0] cost_43 = cost_bus[43*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_43 = self_delta_bus[43*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_43 = adj_delta_bus[42*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_43 = adj_delta_bus[44*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_43 = min2_agg(self_delta_43, min2_agg(left_delta_43, right_delta_43));
wire [AGG_BITS-1:0] nb_43 = boundary ? cost_43[AGG_BITS-1:0] : sat_add_cost_delta(cost_43, delta_43);
assign nb_bus[43*AGG_BITS +: AGG_BITS] = nb_43;
assign next_state[43*AGG_BITS +: AGG_BITS] = nb_43;

wire [COST_BITS-1:0] cost_44 = cost_bus[44*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_44 = self_delta_bus[44*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_44 = adj_delta_bus[43*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_44 = adj_delta_bus[45*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_44 = min2_agg(self_delta_44, min2_agg(left_delta_44, right_delta_44));
wire [AGG_BITS-1:0] nb_44 = boundary ? cost_44[AGG_BITS-1:0] : sat_add_cost_delta(cost_44, delta_44);
assign nb_bus[44*AGG_BITS +: AGG_BITS] = nb_44;
assign next_state[44*AGG_BITS +: AGG_BITS] = nb_44;

wire [COST_BITS-1:0] cost_45 = cost_bus[45*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_45 = self_delta_bus[45*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_45 = adj_delta_bus[44*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_45 = adj_delta_bus[46*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_45 = min2_agg(self_delta_45, min2_agg(left_delta_45, right_delta_45));
wire [AGG_BITS-1:0] nb_45 = boundary ? cost_45[AGG_BITS-1:0] : sat_add_cost_delta(cost_45, delta_45);
assign nb_bus[45*AGG_BITS +: AGG_BITS] = nb_45;
assign next_state[45*AGG_BITS +: AGG_BITS] = nb_45;

wire [COST_BITS-1:0] cost_46 = cost_bus[46*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_46 = self_delta_bus[46*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_46 = adj_delta_bus[45*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_46 = adj_delta_bus[47*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_46 = min2_agg(self_delta_46, min2_agg(left_delta_46, right_delta_46));
wire [AGG_BITS-1:0] nb_46 = boundary ? cost_46[AGG_BITS-1:0] : sat_add_cost_delta(cost_46, delta_46);
assign nb_bus[46*AGG_BITS +: AGG_BITS] = nb_46;
assign next_state[46*AGG_BITS +: AGG_BITS] = nb_46;

wire [COST_BITS-1:0] cost_47 = cost_bus[47*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_47 = self_delta_bus[47*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_47 = adj_delta_bus[46*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_47 = adj_delta_bus[48*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_47 = min2_agg(self_delta_47, min2_agg(left_delta_47, right_delta_47));
wire [AGG_BITS-1:0] nb_47 = boundary ? cost_47[AGG_BITS-1:0] : sat_add_cost_delta(cost_47, delta_47);
assign nb_bus[47*AGG_BITS +: AGG_BITS] = nb_47;
assign next_state[47*AGG_BITS +: AGG_BITS] = nb_47;

wire [COST_BITS-1:0] cost_48 = cost_bus[48*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_48 = self_delta_bus[48*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_48 = adj_delta_bus[47*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_48 = adj_delta_bus[49*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_48 = min2_agg(self_delta_48, min2_agg(left_delta_48, right_delta_48));
wire [AGG_BITS-1:0] nb_48 = boundary ? cost_48[AGG_BITS-1:0] : sat_add_cost_delta(cost_48, delta_48);
assign nb_bus[48*AGG_BITS +: AGG_BITS] = nb_48;
assign next_state[48*AGG_BITS +: AGG_BITS] = nb_48;

wire [COST_BITS-1:0] cost_49 = cost_bus[49*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_49 = self_delta_bus[49*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_49 = adj_delta_bus[48*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_49 = adj_delta_bus[50*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_49 = min2_agg(self_delta_49, min2_agg(left_delta_49, right_delta_49));
wire [AGG_BITS-1:0] nb_49 = boundary ? cost_49[AGG_BITS-1:0] : sat_add_cost_delta(cost_49, delta_49);
assign nb_bus[49*AGG_BITS +: AGG_BITS] = nb_49;
assign next_state[49*AGG_BITS +: AGG_BITS] = nb_49;

wire [COST_BITS-1:0] cost_50 = cost_bus[50*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_50 = self_delta_bus[50*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_50 = adj_delta_bus[49*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_50 = adj_delta_bus[51*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_50 = min2_agg(self_delta_50, min2_agg(left_delta_50, right_delta_50));
wire [AGG_BITS-1:0] nb_50 = boundary ? cost_50[AGG_BITS-1:0] : sat_add_cost_delta(cost_50, delta_50);
assign nb_bus[50*AGG_BITS +: AGG_BITS] = nb_50;
assign next_state[50*AGG_BITS +: AGG_BITS] = nb_50;

wire [COST_BITS-1:0] cost_51 = cost_bus[51*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_51 = self_delta_bus[51*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_51 = adj_delta_bus[50*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_51 = adj_delta_bus[52*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_51 = min2_agg(self_delta_51, min2_agg(left_delta_51, right_delta_51));
wire [AGG_BITS-1:0] nb_51 = boundary ? cost_51[AGG_BITS-1:0] : sat_add_cost_delta(cost_51, delta_51);
assign nb_bus[51*AGG_BITS +: AGG_BITS] = nb_51;
assign next_state[51*AGG_BITS +: AGG_BITS] = nb_51;

wire [COST_BITS-1:0] cost_52 = cost_bus[52*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_52 = self_delta_bus[52*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_52 = adj_delta_bus[51*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_52 = adj_delta_bus[53*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_52 = min2_agg(self_delta_52, min2_agg(left_delta_52, right_delta_52));
wire [AGG_BITS-1:0] nb_52 = boundary ? cost_52[AGG_BITS-1:0] : sat_add_cost_delta(cost_52, delta_52);
assign nb_bus[52*AGG_BITS +: AGG_BITS] = nb_52;
assign next_state[52*AGG_BITS +: AGG_BITS] = nb_52;

wire [COST_BITS-1:0] cost_53 = cost_bus[53*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_53 = self_delta_bus[53*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_53 = adj_delta_bus[52*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_53 = adj_delta_bus[54*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_53 = min2_agg(self_delta_53, min2_agg(left_delta_53, right_delta_53));
wire [AGG_BITS-1:0] nb_53 = boundary ? cost_53[AGG_BITS-1:0] : sat_add_cost_delta(cost_53, delta_53);
assign nb_bus[53*AGG_BITS +: AGG_BITS] = nb_53;
assign next_state[53*AGG_BITS +: AGG_BITS] = nb_53;

wire [COST_BITS-1:0] cost_54 = cost_bus[54*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_54 = self_delta_bus[54*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_54 = adj_delta_bus[53*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_54 = adj_delta_bus[55*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_54 = min2_agg(self_delta_54, min2_agg(left_delta_54, right_delta_54));
wire [AGG_BITS-1:0] nb_54 = boundary ? cost_54[AGG_BITS-1:0] : sat_add_cost_delta(cost_54, delta_54);
assign nb_bus[54*AGG_BITS +: AGG_BITS] = nb_54;
assign next_state[54*AGG_BITS +: AGG_BITS] = nb_54;

wire [COST_BITS-1:0] cost_55 = cost_bus[55*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_55 = self_delta_bus[55*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_55 = adj_delta_bus[54*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_55 = adj_delta_bus[56*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_55 = min2_agg(self_delta_55, min2_agg(left_delta_55, right_delta_55));
wire [AGG_BITS-1:0] nb_55 = boundary ? cost_55[AGG_BITS-1:0] : sat_add_cost_delta(cost_55, delta_55);
assign nb_bus[55*AGG_BITS +: AGG_BITS] = nb_55;
assign next_state[55*AGG_BITS +: AGG_BITS] = nb_55;

wire [COST_BITS-1:0] cost_56 = cost_bus[56*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_56 = self_delta_bus[56*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_56 = adj_delta_bus[55*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_56 = adj_delta_bus[57*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_56 = min2_agg(self_delta_56, min2_agg(left_delta_56, right_delta_56));
wire [AGG_BITS-1:0] nb_56 = boundary ? cost_56[AGG_BITS-1:0] : sat_add_cost_delta(cost_56, delta_56);
assign nb_bus[56*AGG_BITS +: AGG_BITS] = nb_56;
assign next_state[56*AGG_BITS +: AGG_BITS] = nb_56;

wire [COST_BITS-1:0] cost_57 = cost_bus[57*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_57 = self_delta_bus[57*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_57 = adj_delta_bus[56*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_57 = adj_delta_bus[58*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_57 = min2_agg(self_delta_57, min2_agg(left_delta_57, right_delta_57));
wire [AGG_BITS-1:0] nb_57 = boundary ? cost_57[AGG_BITS-1:0] : sat_add_cost_delta(cost_57, delta_57);
assign nb_bus[57*AGG_BITS +: AGG_BITS] = nb_57;
assign next_state[57*AGG_BITS +: AGG_BITS] = nb_57;

wire [COST_BITS-1:0] cost_58 = cost_bus[58*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_58 = self_delta_bus[58*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_58 = adj_delta_bus[57*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_58 = adj_delta_bus[59*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_58 = min2_agg(self_delta_58, min2_agg(left_delta_58, right_delta_58));
wire [AGG_BITS-1:0] nb_58 = boundary ? cost_58[AGG_BITS-1:0] : sat_add_cost_delta(cost_58, delta_58);
assign nb_bus[58*AGG_BITS +: AGG_BITS] = nb_58;
assign next_state[58*AGG_BITS +: AGG_BITS] = nb_58;

wire [COST_BITS-1:0] cost_59 = cost_bus[59*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_59 = self_delta_bus[59*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_59 = adj_delta_bus[58*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_59 = adj_delta_bus[60*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_59 = min2_agg(self_delta_59, min2_agg(left_delta_59, right_delta_59));
wire [AGG_BITS-1:0] nb_59 = boundary ? cost_59[AGG_BITS-1:0] : sat_add_cost_delta(cost_59, delta_59);
assign nb_bus[59*AGG_BITS +: AGG_BITS] = nb_59;
assign next_state[59*AGG_BITS +: AGG_BITS] = nb_59;

wire [COST_BITS-1:0] cost_60 = cost_bus[60*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_60 = self_delta_bus[60*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_60 = adj_delta_bus[59*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_60 = adj_delta_bus[61*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_60 = min2_agg(self_delta_60, min2_agg(left_delta_60, right_delta_60));
wire [AGG_BITS-1:0] nb_60 = boundary ? cost_60[AGG_BITS-1:0] : sat_add_cost_delta(cost_60, delta_60);
assign nb_bus[60*AGG_BITS +: AGG_BITS] = nb_60;
assign next_state[60*AGG_BITS +: AGG_BITS] = nb_60;

wire [COST_BITS-1:0] cost_61 = cost_bus[61*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_61 = self_delta_bus[61*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_61 = adj_delta_bus[60*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_61 = adj_delta_bus[62*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_61 = min2_agg(self_delta_61, min2_agg(left_delta_61, right_delta_61));
wire [AGG_BITS-1:0] nb_61 = boundary ? cost_61[AGG_BITS-1:0] : sat_add_cost_delta(cost_61, delta_61);
assign nb_bus[61*AGG_BITS +: AGG_BITS] = nb_61;
assign next_state[61*AGG_BITS +: AGG_BITS] = nb_61;

wire [COST_BITS-1:0] cost_62 = cost_bus[62*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_62 = self_delta_bus[62*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_62 = adj_delta_bus[61*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_62 = adj_delta_bus[63*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_62 = min2_agg(self_delta_62, min2_agg(left_delta_62, right_delta_62));
wire [AGG_BITS-1:0] nb_62 = boundary ? cost_62[AGG_BITS-1:0] : sat_add_cost_delta(cost_62, delta_62);
assign nb_bus[62*AGG_BITS +: AGG_BITS] = nb_62;
assign next_state[62*AGG_BITS +: AGG_BITS] = nb_62;

wire [COST_BITS-1:0] cost_63 = cost_bus[63*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_63 = self_delta_bus[63*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_63 = adj_delta_bus[62*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_63 = adj_delta_bus[64*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] delta_63 = min2_agg(self_delta_63, min2_agg(left_delta_63, right_delta_63));
wire [AGG_BITS-1:0] nb_63 = boundary ? cost_63[AGG_BITS-1:0] : sat_add_cost_delta(cost_63, delta_63);
assign nb_bus[63*AGG_BITS +: AGG_BITS] = nb_63;
assign next_state[63*AGG_BITS +: AGG_BITS] = nb_63;

wire [COST_BITS-1:0] cost_64 = cost_bus[64*COST_BITS +: COST_BITS];
wire [AGG_BITS-1:0] self_delta_64 = self_delta_bus[64*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] left_delta_64 = adj_delta_bus[63*AGG_BITS +: AGG_BITS];
wire [AGG_BITS-1:0] right_delta_64 = P2[AGG_BITS-1:0];
wire [AGG_BITS-1:0] delta_64 = min2_agg(self_delta_64, min2_agg(left_delta_64, right_delta_64));
wire [AGG_BITS-1:0] nb_64 = boundary ? cost_64[AGG_BITS-1:0] : sat_add_cost_delta(cost_64, delta_64);
assign nb_bus[64*AGG_BITS +: AGG_BITS] = nb_64;
assign next_state[64*AGG_BITS +: AGG_BITS] = nb_64;

assign min_l1_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[0*AGG_BITS +: AGG_BITS], nb_bus[1*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[1*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[2*AGG_BITS +: AGG_BITS], nb_bus[3*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[2*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[4*AGG_BITS +: AGG_BITS], nb_bus[5*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[3*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[6*AGG_BITS +: AGG_BITS], nb_bus[7*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[4*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[8*AGG_BITS +: AGG_BITS], nb_bus[9*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[5*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[10*AGG_BITS +: AGG_BITS], nb_bus[11*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[6*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[12*AGG_BITS +: AGG_BITS], nb_bus[13*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[7*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[14*AGG_BITS +: AGG_BITS], nb_bus[15*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[8*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[16*AGG_BITS +: AGG_BITS], nb_bus[17*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[9*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[18*AGG_BITS +: AGG_BITS], nb_bus[19*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[10*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[20*AGG_BITS +: AGG_BITS], nb_bus[21*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[11*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[22*AGG_BITS +: AGG_BITS], nb_bus[23*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[12*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[24*AGG_BITS +: AGG_BITS], nb_bus[25*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[13*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[26*AGG_BITS +: AGG_BITS], nb_bus[27*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[14*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[28*AGG_BITS +: AGG_BITS], nb_bus[29*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[15*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[30*AGG_BITS +: AGG_BITS], nb_bus[31*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[16*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[32*AGG_BITS +: AGG_BITS], nb_bus[33*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[17*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[34*AGG_BITS +: AGG_BITS], nb_bus[35*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[18*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[36*AGG_BITS +: AGG_BITS], nb_bus[37*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[19*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[38*AGG_BITS +: AGG_BITS], nb_bus[39*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[20*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[40*AGG_BITS +: AGG_BITS], nb_bus[41*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[21*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[42*AGG_BITS +: AGG_BITS], nb_bus[43*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[22*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[44*AGG_BITS +: AGG_BITS], nb_bus[45*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[23*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[46*AGG_BITS +: AGG_BITS], nb_bus[47*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[24*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[48*AGG_BITS +: AGG_BITS], nb_bus[49*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[25*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[50*AGG_BITS +: AGG_BITS], nb_bus[51*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[26*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[52*AGG_BITS +: AGG_BITS], nb_bus[53*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[27*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[54*AGG_BITS +: AGG_BITS], nb_bus[55*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[28*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[56*AGG_BITS +: AGG_BITS], nb_bus[57*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[29*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[58*AGG_BITS +: AGG_BITS], nb_bus[59*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[30*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[60*AGG_BITS +: AGG_BITS], nb_bus[61*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[31*AGG_BITS +: AGG_BITS] = min2_agg(nb_bus[62*AGG_BITS +: AGG_BITS], nb_bus[63*AGG_BITS +: AGG_BITS]);
assign min_l1_bus[32*AGG_BITS +: AGG_BITS] = nb_bus[64*AGG_BITS +: AGG_BITS];

assign min_l2_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[0*AGG_BITS +: AGG_BITS], min_l1_bus[1*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[1*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[2*AGG_BITS +: AGG_BITS], min_l1_bus[3*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[2*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[4*AGG_BITS +: AGG_BITS], min_l1_bus[5*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[3*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[6*AGG_BITS +: AGG_BITS], min_l1_bus[7*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[4*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[8*AGG_BITS +: AGG_BITS], min_l1_bus[9*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[5*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[10*AGG_BITS +: AGG_BITS], min_l1_bus[11*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[6*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[12*AGG_BITS +: AGG_BITS], min_l1_bus[13*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[7*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[14*AGG_BITS +: AGG_BITS], min_l1_bus[15*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[8*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[16*AGG_BITS +: AGG_BITS], min_l1_bus[17*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[9*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[18*AGG_BITS +: AGG_BITS], min_l1_bus[19*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[10*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[20*AGG_BITS +: AGG_BITS], min_l1_bus[21*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[11*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[22*AGG_BITS +: AGG_BITS], min_l1_bus[23*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[12*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[24*AGG_BITS +: AGG_BITS], min_l1_bus[25*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[13*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[26*AGG_BITS +: AGG_BITS], min_l1_bus[27*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[14*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[28*AGG_BITS +: AGG_BITS], min_l1_bus[29*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[15*AGG_BITS +: AGG_BITS] = min2_agg(min_l1_bus[30*AGG_BITS +: AGG_BITS], min_l1_bus[31*AGG_BITS +: AGG_BITS]);
assign min_l2_bus[16*AGG_BITS +: AGG_BITS] = min_l1_bus[32*AGG_BITS +: AGG_BITS];

assign min_l3_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[0*AGG_BITS +: AGG_BITS], min_l2_bus[1*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[1*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[2*AGG_BITS +: AGG_BITS], min_l2_bus[3*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[2*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[4*AGG_BITS +: AGG_BITS], min_l2_bus[5*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[3*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[6*AGG_BITS +: AGG_BITS], min_l2_bus[7*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[4*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[8*AGG_BITS +: AGG_BITS], min_l2_bus[9*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[5*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[10*AGG_BITS +: AGG_BITS], min_l2_bus[11*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[6*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[12*AGG_BITS +: AGG_BITS], min_l2_bus[13*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[7*AGG_BITS +: AGG_BITS] = min2_agg(min_l2_bus[14*AGG_BITS +: AGG_BITS], min_l2_bus[15*AGG_BITS +: AGG_BITS]);
assign min_l3_bus[8*AGG_BITS +: AGG_BITS] = min_l2_bus[16*AGG_BITS +: AGG_BITS];

assign min_l4_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(min_l3_bus[0*AGG_BITS +: AGG_BITS], min_l3_bus[1*AGG_BITS +: AGG_BITS]);
assign min_l4_bus[1*AGG_BITS +: AGG_BITS] = min2_agg(min_l3_bus[2*AGG_BITS +: AGG_BITS], min_l3_bus[3*AGG_BITS +: AGG_BITS]);
assign min_l4_bus[2*AGG_BITS +: AGG_BITS] = min2_agg(min_l3_bus[4*AGG_BITS +: AGG_BITS], min_l3_bus[5*AGG_BITS +: AGG_BITS]);
assign min_l4_bus[3*AGG_BITS +: AGG_BITS] = min2_agg(min_l3_bus[6*AGG_BITS +: AGG_BITS], min_l3_bus[7*AGG_BITS +: AGG_BITS]);
assign min_l4_bus[4*AGG_BITS +: AGG_BITS] = min_l3_bus[8*AGG_BITS +: AGG_BITS];

assign min_l5_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(min_l4_bus[0*AGG_BITS +: AGG_BITS], min_l4_bus[1*AGG_BITS +: AGG_BITS]);
assign min_l5_bus[1*AGG_BITS +: AGG_BITS] = min2_agg(min_l4_bus[2*AGG_BITS +: AGG_BITS], min_l4_bus[3*AGG_BITS +: AGG_BITS]);
assign min_l5_bus[2*AGG_BITS +: AGG_BITS] = min_l4_bus[4*AGG_BITS +: AGG_BITS];

assign min_l6_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(min_l5_bus[0*AGG_BITS +: AGG_BITS], min_l5_bus[1*AGG_BITS +: AGG_BITS]);
assign min_l6_bus[1*AGG_BITS +: AGG_BITS] = min_l5_bus[2*AGG_BITS +: AGG_BITS];

assign min_l7_bus[0*AGG_BITS +: AGG_BITS] = min2_agg(min_l6_bus[0*AGG_BITS +: AGG_BITS], min_l6_bus[1*AGG_BITS +: AGG_BITS]);

assign next_state[STATEW +: AGG_BITS] = min_l7_bus[0 +: AGG_BITS];

endmodule

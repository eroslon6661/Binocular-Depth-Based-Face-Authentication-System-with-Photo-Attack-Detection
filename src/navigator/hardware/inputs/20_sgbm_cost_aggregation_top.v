`timescale 1ns / 1ps
module sgbm_cost_aggregation_top #(
    parameter IMG_WIDTH         = 1280,
    parameter IMG_HEIGHT        = 720,
    parameter DISP_NUM          = 65,
    parameter COST_BITS         = 4,
    parameter SINGLE_PATH_BITS  = 4,
    parameter AGG_COST_BITS     = 6,
    parameter P1                = 4'd2,
    parameter P2                = 4'd8,
    parameter INVALID_COST      = 4'hf
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         cost_in_valid,
    input  wire [10:0]                  x_in,
    input  wire [9:0]                   y_in,
    input  wire [COST_BITS-1:0] cost0_in,
    input  wire [COST_BITS-1:0] cost1_in,
    input  wire [COST_BITS-1:0] cost2_in,
    input  wire [COST_BITS-1:0] cost3_in,
    input  wire [COST_BITS-1:0] cost4_in,
    input  wire [COST_BITS-1:0] cost5_in,
    input  wire [COST_BITS-1:0] cost6_in,
    input  wire [COST_BITS-1:0] cost7_in,
    input  wire [COST_BITS-1:0] cost8_in,
    input  wire [COST_BITS-1:0] cost9_in,
    input  wire [COST_BITS-1:0] cost10_in,
    input  wire [COST_BITS-1:0] cost11_in,
    input  wire [COST_BITS-1:0] cost12_in,
    input  wire [COST_BITS-1:0] cost13_in,
    input  wire [COST_BITS-1:0] cost14_in,
    input  wire [COST_BITS-1:0] cost15_in,
    input  wire [COST_BITS-1:0] cost16_in,
    input  wire [COST_BITS-1:0] cost17_in,
    input  wire [COST_BITS-1:0] cost18_in,
    input  wire [COST_BITS-1:0] cost19_in,
    input  wire [COST_BITS-1:0] cost20_in,
    input  wire [COST_BITS-1:0] cost21_in,
    input  wire [COST_BITS-1:0] cost22_in,
    input  wire [COST_BITS-1:0] cost23_in,
    input  wire [COST_BITS-1:0] cost24_in,
    input  wire [COST_BITS-1:0] cost25_in,
    input  wire [COST_BITS-1:0] cost26_in,
    input  wire [COST_BITS-1:0] cost27_in,
    input  wire [COST_BITS-1:0] cost28_in,
    input  wire [COST_BITS-1:0] cost29_in,
    input  wire [COST_BITS-1:0] cost30_in,
    input  wire [COST_BITS-1:0] cost31_in,
    input  wire [COST_BITS-1:0] cost32_in,
    input  wire [COST_BITS-1:0] cost33_in,
    input  wire [COST_BITS-1:0] cost34_in,
    input  wire [COST_BITS-1:0] cost35_in,
    input  wire [COST_BITS-1:0] cost36_in,
    input  wire [COST_BITS-1:0] cost37_in,
    input  wire [COST_BITS-1:0] cost38_in,
    input  wire [COST_BITS-1:0] cost39_in,
    input  wire [COST_BITS-1:0] cost40_in,
    input  wire [COST_BITS-1:0] cost41_in,
    input  wire [COST_BITS-1:0] cost42_in,
    input  wire [COST_BITS-1:0] cost43_in,
    input  wire [COST_BITS-1:0] cost44_in,
    input  wire [COST_BITS-1:0] cost45_in,
    input  wire [COST_BITS-1:0] cost46_in,
    input  wire [COST_BITS-1:0] cost47_in,
    input  wire [COST_BITS-1:0] cost48_in,
    input  wire [COST_BITS-1:0] cost49_in,
    input  wire [COST_BITS-1:0] cost50_in,
    input  wire [COST_BITS-1:0] cost51_in,
    input  wire [COST_BITS-1:0] cost52_in,
    input  wire [COST_BITS-1:0] cost53_in,
    input  wire [COST_BITS-1:0] cost54_in,
    input  wire [COST_BITS-1:0] cost55_in,
    input  wire [COST_BITS-1:0] cost56_in,
    input  wire [COST_BITS-1:0] cost57_in,
    input  wire [COST_BITS-1:0] cost58_in,
    input  wire [COST_BITS-1:0] cost59_in,
    input  wire [COST_BITS-1:0] cost60_in,
    input  wire [COST_BITS-1:0] cost61_in,
    input  wire [COST_BITS-1:0] cost62_in,
    input  wire [COST_BITS-1:0] cost63_in,
    input  wire [COST_BITS-1:0] cost64_in,

    output reg                          cost_out_valid,
    output reg  [10:0]                  x_out,
    output reg  [9:0]                   y_out,
    output wire [AGG_COST_BITS-1:0] cost0_out,
    output wire [AGG_COST_BITS-1:0] cost1_out,
    output wire [AGG_COST_BITS-1:0] cost2_out,
    output wire [AGG_COST_BITS-1:0] cost3_out,
    output wire [AGG_COST_BITS-1:0] cost4_out,
    output wire [AGG_COST_BITS-1:0] cost5_out,
    output wire [AGG_COST_BITS-1:0] cost6_out,
    output wire [AGG_COST_BITS-1:0] cost7_out,
    output wire [AGG_COST_BITS-1:0] cost8_out,
    output wire [AGG_COST_BITS-1:0] cost9_out,
    output wire [AGG_COST_BITS-1:0] cost10_out,
    output wire [AGG_COST_BITS-1:0] cost11_out,
    output wire [AGG_COST_BITS-1:0] cost12_out,
    output wire [AGG_COST_BITS-1:0] cost13_out,
    output wire [AGG_COST_BITS-1:0] cost14_out,
    output wire [AGG_COST_BITS-1:0] cost15_out,
    output wire [AGG_COST_BITS-1:0] cost16_out,
    output wire [AGG_COST_BITS-1:0] cost17_out,
    output wire [AGG_COST_BITS-1:0] cost18_out,
    output wire [AGG_COST_BITS-1:0] cost19_out,
    output wire [AGG_COST_BITS-1:0] cost20_out,
    output wire [AGG_COST_BITS-1:0] cost21_out,
    output wire [AGG_COST_BITS-1:0] cost22_out,
    output wire [AGG_COST_BITS-1:0] cost23_out,
    output wire [AGG_COST_BITS-1:0] cost24_out,
    output wire [AGG_COST_BITS-1:0] cost25_out,
    output wire [AGG_COST_BITS-1:0] cost26_out,
    output wire [AGG_COST_BITS-1:0] cost27_out,
    output wire [AGG_COST_BITS-1:0] cost28_out,
    output wire [AGG_COST_BITS-1:0] cost29_out,
    output wire [AGG_COST_BITS-1:0] cost30_out,
    output wire [AGG_COST_BITS-1:0] cost31_out,
    output wire [AGG_COST_BITS-1:0] cost32_out,
    output wire [AGG_COST_BITS-1:0] cost33_out,
    output wire [AGG_COST_BITS-1:0] cost34_out,
    output wire [AGG_COST_BITS-1:0] cost35_out,
    output wire [AGG_COST_BITS-1:0] cost36_out,
    output wire [AGG_COST_BITS-1:0] cost37_out,
    output wire [AGG_COST_BITS-1:0] cost38_out,
    output wire [AGG_COST_BITS-1:0] cost39_out,
    output wire [AGG_COST_BITS-1:0] cost40_out,
    output wire [AGG_COST_BITS-1:0] cost41_out,
    output wire [AGG_COST_BITS-1:0] cost42_out,
    output wire [AGG_COST_BITS-1:0] cost43_out,
    output wire [AGG_COST_BITS-1:0] cost44_out,
    output wire [AGG_COST_BITS-1:0] cost45_out,
    output wire [AGG_COST_BITS-1:0] cost46_out,
    output wire [AGG_COST_BITS-1:0] cost47_out,
    output wire [AGG_COST_BITS-1:0] cost48_out,
    output wire [AGG_COST_BITS-1:0] cost49_out,
    output wire [AGG_COST_BITS-1:0] cost50_out,
    output wire [AGG_COST_BITS-1:0] cost51_out,
    output wire [AGG_COST_BITS-1:0] cost52_out,
    output wire [AGG_COST_BITS-1:0] cost53_out,
    output wire [AGG_COST_BITS-1:0] cost54_out,
    output wire [AGG_COST_BITS-1:0] cost55_out,
    output wire [AGG_COST_BITS-1:0] cost56_out,
    output wire [AGG_COST_BITS-1:0] cost57_out,
    output wire [AGG_COST_BITS-1:0] cost58_out,
    output wire [AGG_COST_BITS-1:0] cost59_out,
    output wire [AGG_COST_BITS-1:0] cost60_out,
    output wire [AGG_COST_BITS-1:0] cost61_out,
    output wire [AGG_COST_BITS-1:0] cost62_out,
    output wire [AGG_COST_BITS-1:0] cost63_out,
    output wire [AGG_COST_BITS-1:0] cost64_out
);

wire [SINGLE_PATH_BITS-1:0] lr_cost_0; wire [SINGLE_PATH_BITS-1:0] ud_cost_0; wire [SINGLE_PATH_BITS-1:0] d0_cost_0; wire [SINGLE_PATH_BITS-1:0] d1_cost_0;
wire [SINGLE_PATH_BITS-1:0] lr_cost_1; wire [SINGLE_PATH_BITS-1:0] ud_cost_1; wire [SINGLE_PATH_BITS-1:0] d0_cost_1; wire [SINGLE_PATH_BITS-1:0] d1_cost_1;
wire [SINGLE_PATH_BITS-1:0] lr_cost_2; wire [SINGLE_PATH_BITS-1:0] ud_cost_2; wire [SINGLE_PATH_BITS-1:0] d0_cost_2; wire [SINGLE_PATH_BITS-1:0] d1_cost_2;
wire [SINGLE_PATH_BITS-1:0] lr_cost_3; wire [SINGLE_PATH_BITS-1:0] ud_cost_3; wire [SINGLE_PATH_BITS-1:0] d0_cost_3; wire [SINGLE_PATH_BITS-1:0] d1_cost_3;
wire [SINGLE_PATH_BITS-1:0] lr_cost_4; wire [SINGLE_PATH_BITS-1:0] ud_cost_4; wire [SINGLE_PATH_BITS-1:0] d0_cost_4; wire [SINGLE_PATH_BITS-1:0] d1_cost_4;
wire [SINGLE_PATH_BITS-1:0] lr_cost_5; wire [SINGLE_PATH_BITS-1:0] ud_cost_5; wire [SINGLE_PATH_BITS-1:0] d0_cost_5; wire [SINGLE_PATH_BITS-1:0] d1_cost_5;
wire [SINGLE_PATH_BITS-1:0] lr_cost_6; wire [SINGLE_PATH_BITS-1:0] ud_cost_6; wire [SINGLE_PATH_BITS-1:0] d0_cost_6; wire [SINGLE_PATH_BITS-1:0] d1_cost_6;
wire [SINGLE_PATH_BITS-1:0] lr_cost_7; wire [SINGLE_PATH_BITS-1:0] ud_cost_7; wire [SINGLE_PATH_BITS-1:0] d0_cost_7; wire [SINGLE_PATH_BITS-1:0] d1_cost_7;
wire [SINGLE_PATH_BITS-1:0] lr_cost_8; wire [SINGLE_PATH_BITS-1:0] ud_cost_8; wire [SINGLE_PATH_BITS-1:0] d0_cost_8; wire [SINGLE_PATH_BITS-1:0] d1_cost_8;
wire [SINGLE_PATH_BITS-1:0] lr_cost_9; wire [SINGLE_PATH_BITS-1:0] ud_cost_9; wire [SINGLE_PATH_BITS-1:0] d0_cost_9; wire [SINGLE_PATH_BITS-1:0] d1_cost_9;
wire [SINGLE_PATH_BITS-1:0] lr_cost_10; wire [SINGLE_PATH_BITS-1:0] ud_cost_10; wire [SINGLE_PATH_BITS-1:0] d0_cost_10; wire [SINGLE_PATH_BITS-1:0] d1_cost_10;
wire [SINGLE_PATH_BITS-1:0] lr_cost_11; wire [SINGLE_PATH_BITS-1:0] ud_cost_11; wire [SINGLE_PATH_BITS-1:0] d0_cost_11; wire [SINGLE_PATH_BITS-1:0] d1_cost_11;
wire [SINGLE_PATH_BITS-1:0] lr_cost_12; wire [SINGLE_PATH_BITS-1:0] ud_cost_12; wire [SINGLE_PATH_BITS-1:0] d0_cost_12; wire [SINGLE_PATH_BITS-1:0] d1_cost_12;
wire [SINGLE_PATH_BITS-1:0] lr_cost_13; wire [SINGLE_PATH_BITS-1:0] ud_cost_13; wire [SINGLE_PATH_BITS-1:0] d0_cost_13; wire [SINGLE_PATH_BITS-1:0] d1_cost_13;
wire [SINGLE_PATH_BITS-1:0] lr_cost_14; wire [SINGLE_PATH_BITS-1:0] ud_cost_14; wire [SINGLE_PATH_BITS-1:0] d0_cost_14; wire [SINGLE_PATH_BITS-1:0] d1_cost_14;
wire [SINGLE_PATH_BITS-1:0] lr_cost_15; wire [SINGLE_PATH_BITS-1:0] ud_cost_15; wire [SINGLE_PATH_BITS-1:0] d0_cost_15; wire [SINGLE_PATH_BITS-1:0] d1_cost_15;
wire [SINGLE_PATH_BITS-1:0] lr_cost_16; wire [SINGLE_PATH_BITS-1:0] ud_cost_16; wire [SINGLE_PATH_BITS-1:0] d0_cost_16; wire [SINGLE_PATH_BITS-1:0] d1_cost_16;
wire [SINGLE_PATH_BITS-1:0] lr_cost_17; wire [SINGLE_PATH_BITS-1:0] ud_cost_17; wire [SINGLE_PATH_BITS-1:0] d0_cost_17; wire [SINGLE_PATH_BITS-1:0] d1_cost_17;
wire [SINGLE_PATH_BITS-1:0] lr_cost_18; wire [SINGLE_PATH_BITS-1:0] ud_cost_18; wire [SINGLE_PATH_BITS-1:0] d0_cost_18; wire [SINGLE_PATH_BITS-1:0] d1_cost_18;
wire [SINGLE_PATH_BITS-1:0] lr_cost_19; wire [SINGLE_PATH_BITS-1:0] ud_cost_19; wire [SINGLE_PATH_BITS-1:0] d0_cost_19; wire [SINGLE_PATH_BITS-1:0] d1_cost_19;
wire [SINGLE_PATH_BITS-1:0] lr_cost_20; wire [SINGLE_PATH_BITS-1:0] ud_cost_20; wire [SINGLE_PATH_BITS-1:0] d0_cost_20; wire [SINGLE_PATH_BITS-1:0] d1_cost_20;
wire [SINGLE_PATH_BITS-1:0] lr_cost_21; wire [SINGLE_PATH_BITS-1:0] ud_cost_21; wire [SINGLE_PATH_BITS-1:0] d0_cost_21; wire [SINGLE_PATH_BITS-1:0] d1_cost_21;
wire [SINGLE_PATH_BITS-1:0] lr_cost_22; wire [SINGLE_PATH_BITS-1:0] ud_cost_22; wire [SINGLE_PATH_BITS-1:0] d0_cost_22; wire [SINGLE_PATH_BITS-1:0] d1_cost_22;
wire [SINGLE_PATH_BITS-1:0] lr_cost_23; wire [SINGLE_PATH_BITS-1:0] ud_cost_23; wire [SINGLE_PATH_BITS-1:0] d0_cost_23; wire [SINGLE_PATH_BITS-1:0] d1_cost_23;
wire [SINGLE_PATH_BITS-1:0] lr_cost_24; wire [SINGLE_PATH_BITS-1:0] ud_cost_24; wire [SINGLE_PATH_BITS-1:0] d0_cost_24; wire [SINGLE_PATH_BITS-1:0] d1_cost_24;
wire [SINGLE_PATH_BITS-1:0] lr_cost_25; wire [SINGLE_PATH_BITS-1:0] ud_cost_25; wire [SINGLE_PATH_BITS-1:0] d0_cost_25; wire [SINGLE_PATH_BITS-1:0] d1_cost_25;
wire [SINGLE_PATH_BITS-1:0] lr_cost_26; wire [SINGLE_PATH_BITS-1:0] ud_cost_26; wire [SINGLE_PATH_BITS-1:0] d0_cost_26; wire [SINGLE_PATH_BITS-1:0] d1_cost_26;
wire [SINGLE_PATH_BITS-1:0] lr_cost_27; wire [SINGLE_PATH_BITS-1:0] ud_cost_27; wire [SINGLE_PATH_BITS-1:0] d0_cost_27; wire [SINGLE_PATH_BITS-1:0] d1_cost_27;
wire [SINGLE_PATH_BITS-1:0] lr_cost_28; wire [SINGLE_PATH_BITS-1:0] ud_cost_28; wire [SINGLE_PATH_BITS-1:0] d0_cost_28; wire [SINGLE_PATH_BITS-1:0] d1_cost_28;
wire [SINGLE_PATH_BITS-1:0] lr_cost_29; wire [SINGLE_PATH_BITS-1:0] ud_cost_29; wire [SINGLE_PATH_BITS-1:0] d0_cost_29; wire [SINGLE_PATH_BITS-1:0] d1_cost_29;
wire [SINGLE_PATH_BITS-1:0] lr_cost_30; wire [SINGLE_PATH_BITS-1:0] ud_cost_30; wire [SINGLE_PATH_BITS-1:0] d0_cost_30; wire [SINGLE_PATH_BITS-1:0] d1_cost_30;
wire [SINGLE_PATH_BITS-1:0] lr_cost_31; wire [SINGLE_PATH_BITS-1:0] ud_cost_31; wire [SINGLE_PATH_BITS-1:0] d0_cost_31; wire [SINGLE_PATH_BITS-1:0] d1_cost_31;
wire [SINGLE_PATH_BITS-1:0] lr_cost_32; wire [SINGLE_PATH_BITS-1:0] ud_cost_32; wire [SINGLE_PATH_BITS-1:0] d0_cost_32; wire [SINGLE_PATH_BITS-1:0] d1_cost_32;
wire [SINGLE_PATH_BITS-1:0] lr_cost_33; wire [SINGLE_PATH_BITS-1:0] ud_cost_33; wire [SINGLE_PATH_BITS-1:0] d0_cost_33; wire [SINGLE_PATH_BITS-1:0] d1_cost_33;
wire [SINGLE_PATH_BITS-1:0] lr_cost_34; wire [SINGLE_PATH_BITS-1:0] ud_cost_34; wire [SINGLE_PATH_BITS-1:0] d0_cost_34; wire [SINGLE_PATH_BITS-1:0] d1_cost_34;
wire [SINGLE_PATH_BITS-1:0] lr_cost_35; wire [SINGLE_PATH_BITS-1:0] ud_cost_35; wire [SINGLE_PATH_BITS-1:0] d0_cost_35; wire [SINGLE_PATH_BITS-1:0] d1_cost_35;
wire [SINGLE_PATH_BITS-1:0] lr_cost_36; wire [SINGLE_PATH_BITS-1:0] ud_cost_36; wire [SINGLE_PATH_BITS-1:0] d0_cost_36; wire [SINGLE_PATH_BITS-1:0] d1_cost_36;
wire [SINGLE_PATH_BITS-1:0] lr_cost_37; wire [SINGLE_PATH_BITS-1:0] ud_cost_37; wire [SINGLE_PATH_BITS-1:0] d0_cost_37; wire [SINGLE_PATH_BITS-1:0] d1_cost_37;
wire [SINGLE_PATH_BITS-1:0] lr_cost_38; wire [SINGLE_PATH_BITS-1:0] ud_cost_38; wire [SINGLE_PATH_BITS-1:0] d0_cost_38; wire [SINGLE_PATH_BITS-1:0] d1_cost_38;
wire [SINGLE_PATH_BITS-1:0] lr_cost_39; wire [SINGLE_PATH_BITS-1:0] ud_cost_39; wire [SINGLE_PATH_BITS-1:0] d0_cost_39; wire [SINGLE_PATH_BITS-1:0] d1_cost_39;
wire [SINGLE_PATH_BITS-1:0] lr_cost_40; wire [SINGLE_PATH_BITS-1:0] ud_cost_40; wire [SINGLE_PATH_BITS-1:0] d0_cost_40; wire [SINGLE_PATH_BITS-1:0] d1_cost_40;
wire [SINGLE_PATH_BITS-1:0] lr_cost_41; wire [SINGLE_PATH_BITS-1:0] ud_cost_41; wire [SINGLE_PATH_BITS-1:0] d0_cost_41; wire [SINGLE_PATH_BITS-1:0] d1_cost_41;
wire [SINGLE_PATH_BITS-1:0] lr_cost_42; wire [SINGLE_PATH_BITS-1:0] ud_cost_42; wire [SINGLE_PATH_BITS-1:0] d0_cost_42; wire [SINGLE_PATH_BITS-1:0] d1_cost_42;
wire [SINGLE_PATH_BITS-1:0] lr_cost_43; wire [SINGLE_PATH_BITS-1:0] ud_cost_43; wire [SINGLE_PATH_BITS-1:0] d0_cost_43; wire [SINGLE_PATH_BITS-1:0] d1_cost_43;
wire [SINGLE_PATH_BITS-1:0] lr_cost_44; wire [SINGLE_PATH_BITS-1:0] ud_cost_44; wire [SINGLE_PATH_BITS-1:0] d0_cost_44; wire [SINGLE_PATH_BITS-1:0] d1_cost_44;
wire [SINGLE_PATH_BITS-1:0] lr_cost_45; wire [SINGLE_PATH_BITS-1:0] ud_cost_45; wire [SINGLE_PATH_BITS-1:0] d0_cost_45; wire [SINGLE_PATH_BITS-1:0] d1_cost_45;
wire [SINGLE_PATH_BITS-1:0] lr_cost_46; wire [SINGLE_PATH_BITS-1:0] ud_cost_46; wire [SINGLE_PATH_BITS-1:0] d0_cost_46; wire [SINGLE_PATH_BITS-1:0] d1_cost_46;
wire [SINGLE_PATH_BITS-1:0] lr_cost_47; wire [SINGLE_PATH_BITS-1:0] ud_cost_47; wire [SINGLE_PATH_BITS-1:0] d0_cost_47; wire [SINGLE_PATH_BITS-1:0] d1_cost_47;
wire [SINGLE_PATH_BITS-1:0] lr_cost_48; wire [SINGLE_PATH_BITS-1:0] ud_cost_48; wire [SINGLE_PATH_BITS-1:0] d0_cost_48; wire [SINGLE_PATH_BITS-1:0] d1_cost_48;
wire [SINGLE_PATH_BITS-1:0] lr_cost_49; wire [SINGLE_PATH_BITS-1:0] ud_cost_49; wire [SINGLE_PATH_BITS-1:0] d0_cost_49; wire [SINGLE_PATH_BITS-1:0] d1_cost_49;
wire [SINGLE_PATH_BITS-1:0] lr_cost_50; wire [SINGLE_PATH_BITS-1:0] ud_cost_50; wire [SINGLE_PATH_BITS-1:0] d0_cost_50; wire [SINGLE_PATH_BITS-1:0] d1_cost_50;
wire [SINGLE_PATH_BITS-1:0] lr_cost_51; wire [SINGLE_PATH_BITS-1:0] ud_cost_51; wire [SINGLE_PATH_BITS-1:0] d0_cost_51; wire [SINGLE_PATH_BITS-1:0] d1_cost_51;
wire [SINGLE_PATH_BITS-1:0] lr_cost_52; wire [SINGLE_PATH_BITS-1:0] ud_cost_52; wire [SINGLE_PATH_BITS-1:0] d0_cost_52; wire [SINGLE_PATH_BITS-1:0] d1_cost_52;
wire [SINGLE_PATH_BITS-1:0] lr_cost_53; wire [SINGLE_PATH_BITS-1:0] ud_cost_53; wire [SINGLE_PATH_BITS-1:0] d0_cost_53; wire [SINGLE_PATH_BITS-1:0] d1_cost_53;
wire [SINGLE_PATH_BITS-1:0] lr_cost_54; wire [SINGLE_PATH_BITS-1:0] ud_cost_54; wire [SINGLE_PATH_BITS-1:0] d0_cost_54; wire [SINGLE_PATH_BITS-1:0] d1_cost_54;
wire [SINGLE_PATH_BITS-1:0] lr_cost_55; wire [SINGLE_PATH_BITS-1:0] ud_cost_55; wire [SINGLE_PATH_BITS-1:0] d0_cost_55; wire [SINGLE_PATH_BITS-1:0] d1_cost_55;
wire [SINGLE_PATH_BITS-1:0] lr_cost_56; wire [SINGLE_PATH_BITS-1:0] ud_cost_56; wire [SINGLE_PATH_BITS-1:0] d0_cost_56; wire [SINGLE_PATH_BITS-1:0] d1_cost_56;
wire [SINGLE_PATH_BITS-1:0] lr_cost_57; wire [SINGLE_PATH_BITS-1:0] ud_cost_57; wire [SINGLE_PATH_BITS-1:0] d0_cost_57; wire [SINGLE_PATH_BITS-1:0] d1_cost_57;
wire [SINGLE_PATH_BITS-1:0] lr_cost_58; wire [SINGLE_PATH_BITS-1:0] ud_cost_58; wire [SINGLE_PATH_BITS-1:0] d0_cost_58; wire [SINGLE_PATH_BITS-1:0] d1_cost_58;
wire [SINGLE_PATH_BITS-1:0] lr_cost_59; wire [SINGLE_PATH_BITS-1:0] ud_cost_59; wire [SINGLE_PATH_BITS-1:0] d0_cost_59; wire [SINGLE_PATH_BITS-1:0] d1_cost_59;
wire [SINGLE_PATH_BITS-1:0] lr_cost_60; wire [SINGLE_PATH_BITS-1:0] ud_cost_60; wire [SINGLE_PATH_BITS-1:0] d0_cost_60; wire [SINGLE_PATH_BITS-1:0] d1_cost_60;
wire [SINGLE_PATH_BITS-1:0] lr_cost_61; wire [SINGLE_PATH_BITS-1:0] ud_cost_61; wire [SINGLE_PATH_BITS-1:0] d0_cost_61; wire [SINGLE_PATH_BITS-1:0] d1_cost_61;
wire [SINGLE_PATH_BITS-1:0] lr_cost_62; wire [SINGLE_PATH_BITS-1:0] ud_cost_62; wire [SINGLE_PATH_BITS-1:0] d0_cost_62; wire [SINGLE_PATH_BITS-1:0] d1_cost_62;
wire [SINGLE_PATH_BITS-1:0] lr_cost_63; wire [SINGLE_PATH_BITS-1:0] ud_cost_63; wire [SINGLE_PATH_BITS-1:0] d0_cost_63; wire [SINGLE_PATH_BITS-1:0] d1_cost_63;
wire [SINGLE_PATH_BITS-1:0] lr_cost_64; wire [SINGLE_PATH_BITS-1:0] ud_cost_64; wire [SINGLE_PATH_BITS-1:0] d0_cost_64; wire [SINGLE_PATH_BITS-1:0] d1_cost_64;

reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_0;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_1;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_2;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_3;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_4;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_5;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_6;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_7;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_8;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_9;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_10;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_11;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_12;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_13;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_14;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_15;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_16;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_17;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_18;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_19;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_20;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_21;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_22;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_23;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_24;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_25;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_26;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_27;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_28;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_29;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_30;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_31;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_32;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_33;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_34;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_35;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_36;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_37;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_38;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_39;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_40;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_41;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_42;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_43;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_44;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_45;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_46;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_47;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_48;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_49;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_50;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_51;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_52;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_53;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_54;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_55;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_56;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_57;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_58;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_59;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_60;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_61;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_62;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_63;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a1_64;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_0;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_1;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_2;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_3;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_4;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_5;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_6;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_7;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_8;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_9;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_10;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_11;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_12;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_13;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_14;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_15;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_16;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_17;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_18;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_19;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_20;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_21;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_22;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_23;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_24;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_25;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_26;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_27;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_28;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_29;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_30;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_31;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_32;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_33;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_34;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_35;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_36;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_37;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_38;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_39;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_40;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_41;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_42;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_43;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_44;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_45;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_46;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_47;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_48;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_49;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_50;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_51;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_52;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_53;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_54;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_55;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_56;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_57;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_58;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_59;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_60;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_61;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_62;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_63;
reg [SINGLE_PATH_BITS-1:0] lr_cost_a2_64;

reg [AGG_COST_BITS-1:0] sum01_r_0; reg [AGG_COST_BITS-1:0] sum23_r_0; reg [AGG_COST_BITS-1:0] sum_r_0;
reg [AGG_COST_BITS-1:0] sum01_r_1; reg [AGG_COST_BITS-1:0] sum23_r_1; reg [AGG_COST_BITS-1:0] sum_r_1;
reg [AGG_COST_BITS-1:0] sum01_r_2; reg [AGG_COST_BITS-1:0] sum23_r_2; reg [AGG_COST_BITS-1:0] sum_r_2;
reg [AGG_COST_BITS-1:0] sum01_r_3; reg [AGG_COST_BITS-1:0] sum23_r_3; reg [AGG_COST_BITS-1:0] sum_r_3;
reg [AGG_COST_BITS-1:0] sum01_r_4; reg [AGG_COST_BITS-1:0] sum23_r_4; reg [AGG_COST_BITS-1:0] sum_r_4;
reg [AGG_COST_BITS-1:0] sum01_r_5; reg [AGG_COST_BITS-1:0] sum23_r_5; reg [AGG_COST_BITS-1:0] sum_r_5;
reg [AGG_COST_BITS-1:0] sum01_r_6; reg [AGG_COST_BITS-1:0] sum23_r_6; reg [AGG_COST_BITS-1:0] sum_r_6;
reg [AGG_COST_BITS-1:0] sum01_r_7; reg [AGG_COST_BITS-1:0] sum23_r_7; reg [AGG_COST_BITS-1:0] sum_r_7;
reg [AGG_COST_BITS-1:0] sum01_r_8; reg [AGG_COST_BITS-1:0] sum23_r_8; reg [AGG_COST_BITS-1:0] sum_r_8;
reg [AGG_COST_BITS-1:0] sum01_r_9; reg [AGG_COST_BITS-1:0] sum23_r_9; reg [AGG_COST_BITS-1:0] sum_r_9;
reg [AGG_COST_BITS-1:0] sum01_r_10; reg [AGG_COST_BITS-1:0] sum23_r_10; reg [AGG_COST_BITS-1:0] sum_r_10;
reg [AGG_COST_BITS-1:0] sum01_r_11; reg [AGG_COST_BITS-1:0] sum23_r_11; reg [AGG_COST_BITS-1:0] sum_r_11;
reg [AGG_COST_BITS-1:0] sum01_r_12; reg [AGG_COST_BITS-1:0] sum23_r_12; reg [AGG_COST_BITS-1:0] sum_r_12;
reg [AGG_COST_BITS-1:0] sum01_r_13; reg [AGG_COST_BITS-1:0] sum23_r_13; reg [AGG_COST_BITS-1:0] sum_r_13;
reg [AGG_COST_BITS-1:0] sum01_r_14; reg [AGG_COST_BITS-1:0] sum23_r_14; reg [AGG_COST_BITS-1:0] sum_r_14;
reg [AGG_COST_BITS-1:0] sum01_r_15; reg [AGG_COST_BITS-1:0] sum23_r_15; reg [AGG_COST_BITS-1:0] sum_r_15;
reg [AGG_COST_BITS-1:0] sum01_r_16; reg [AGG_COST_BITS-1:0] sum23_r_16; reg [AGG_COST_BITS-1:0] sum_r_16;
reg [AGG_COST_BITS-1:0] sum01_r_17; reg [AGG_COST_BITS-1:0] sum23_r_17; reg [AGG_COST_BITS-1:0] sum_r_17;
reg [AGG_COST_BITS-1:0] sum01_r_18; reg [AGG_COST_BITS-1:0] sum23_r_18; reg [AGG_COST_BITS-1:0] sum_r_18;
reg [AGG_COST_BITS-1:0] sum01_r_19; reg [AGG_COST_BITS-1:0] sum23_r_19; reg [AGG_COST_BITS-1:0] sum_r_19;
reg [AGG_COST_BITS-1:0] sum01_r_20; reg [AGG_COST_BITS-1:0] sum23_r_20; reg [AGG_COST_BITS-1:0] sum_r_20;
reg [AGG_COST_BITS-1:0] sum01_r_21; reg [AGG_COST_BITS-1:0] sum23_r_21; reg [AGG_COST_BITS-1:0] sum_r_21;
reg [AGG_COST_BITS-1:0] sum01_r_22; reg [AGG_COST_BITS-1:0] sum23_r_22; reg [AGG_COST_BITS-1:0] sum_r_22;
reg [AGG_COST_BITS-1:0] sum01_r_23; reg [AGG_COST_BITS-1:0] sum23_r_23; reg [AGG_COST_BITS-1:0] sum_r_23;
reg [AGG_COST_BITS-1:0] sum01_r_24; reg [AGG_COST_BITS-1:0] sum23_r_24; reg [AGG_COST_BITS-1:0] sum_r_24;
reg [AGG_COST_BITS-1:0] sum01_r_25; reg [AGG_COST_BITS-1:0] sum23_r_25; reg [AGG_COST_BITS-1:0] sum_r_25;
reg [AGG_COST_BITS-1:0] sum01_r_26; reg [AGG_COST_BITS-1:0] sum23_r_26; reg [AGG_COST_BITS-1:0] sum_r_26;
reg [AGG_COST_BITS-1:0] sum01_r_27; reg [AGG_COST_BITS-1:0] sum23_r_27; reg [AGG_COST_BITS-1:0] sum_r_27;
reg [AGG_COST_BITS-1:0] sum01_r_28; reg [AGG_COST_BITS-1:0] sum23_r_28; reg [AGG_COST_BITS-1:0] sum_r_28;
reg [AGG_COST_BITS-1:0] sum01_r_29; reg [AGG_COST_BITS-1:0] sum23_r_29; reg [AGG_COST_BITS-1:0] sum_r_29;
reg [AGG_COST_BITS-1:0] sum01_r_30; reg [AGG_COST_BITS-1:0] sum23_r_30; reg [AGG_COST_BITS-1:0] sum_r_30;
reg [AGG_COST_BITS-1:0] sum01_r_31; reg [AGG_COST_BITS-1:0] sum23_r_31; reg [AGG_COST_BITS-1:0] sum_r_31;
reg [AGG_COST_BITS-1:0] sum01_r_32; reg [AGG_COST_BITS-1:0] sum23_r_32; reg [AGG_COST_BITS-1:0] sum_r_32;
reg [AGG_COST_BITS-1:0] sum01_r_33; reg [AGG_COST_BITS-1:0] sum23_r_33; reg [AGG_COST_BITS-1:0] sum_r_33;
reg [AGG_COST_BITS-1:0] sum01_r_34; reg [AGG_COST_BITS-1:0] sum23_r_34; reg [AGG_COST_BITS-1:0] sum_r_34;
reg [AGG_COST_BITS-1:0] sum01_r_35; reg [AGG_COST_BITS-1:0] sum23_r_35; reg [AGG_COST_BITS-1:0] sum_r_35;
reg [AGG_COST_BITS-1:0] sum01_r_36; reg [AGG_COST_BITS-1:0] sum23_r_36; reg [AGG_COST_BITS-1:0] sum_r_36;
reg [AGG_COST_BITS-1:0] sum01_r_37; reg [AGG_COST_BITS-1:0] sum23_r_37; reg [AGG_COST_BITS-1:0] sum_r_37;
reg [AGG_COST_BITS-1:0] sum01_r_38; reg [AGG_COST_BITS-1:0] sum23_r_38; reg [AGG_COST_BITS-1:0] sum_r_38;
reg [AGG_COST_BITS-1:0] sum01_r_39; reg [AGG_COST_BITS-1:0] sum23_r_39; reg [AGG_COST_BITS-1:0] sum_r_39;
reg [AGG_COST_BITS-1:0] sum01_r_40; reg [AGG_COST_BITS-1:0] sum23_r_40; reg [AGG_COST_BITS-1:0] sum_r_40;
reg [AGG_COST_BITS-1:0] sum01_r_41; reg [AGG_COST_BITS-1:0] sum23_r_41; reg [AGG_COST_BITS-1:0] sum_r_41;
reg [AGG_COST_BITS-1:0] sum01_r_42; reg [AGG_COST_BITS-1:0] sum23_r_42; reg [AGG_COST_BITS-1:0] sum_r_42;
reg [AGG_COST_BITS-1:0] sum01_r_43; reg [AGG_COST_BITS-1:0] sum23_r_43; reg [AGG_COST_BITS-1:0] sum_r_43;
reg [AGG_COST_BITS-1:0] sum01_r_44; reg [AGG_COST_BITS-1:0] sum23_r_44; reg [AGG_COST_BITS-1:0] sum_r_44;
reg [AGG_COST_BITS-1:0] sum01_r_45; reg [AGG_COST_BITS-1:0] sum23_r_45; reg [AGG_COST_BITS-1:0] sum_r_45;
reg [AGG_COST_BITS-1:0] sum01_r_46; reg [AGG_COST_BITS-1:0] sum23_r_46; reg [AGG_COST_BITS-1:0] sum_r_46;
reg [AGG_COST_BITS-1:0] sum01_r_47; reg [AGG_COST_BITS-1:0] sum23_r_47; reg [AGG_COST_BITS-1:0] sum_r_47;
reg [AGG_COST_BITS-1:0] sum01_r_48; reg [AGG_COST_BITS-1:0] sum23_r_48; reg [AGG_COST_BITS-1:0] sum_r_48;
reg [AGG_COST_BITS-1:0] sum01_r_49; reg [AGG_COST_BITS-1:0] sum23_r_49; reg [AGG_COST_BITS-1:0] sum_r_49;
reg [AGG_COST_BITS-1:0] sum01_r_50; reg [AGG_COST_BITS-1:0] sum23_r_50; reg [AGG_COST_BITS-1:0] sum_r_50;
reg [AGG_COST_BITS-1:0] sum01_r_51; reg [AGG_COST_BITS-1:0] sum23_r_51; reg [AGG_COST_BITS-1:0] sum_r_51;
reg [AGG_COST_BITS-1:0] sum01_r_52; reg [AGG_COST_BITS-1:0] sum23_r_52; reg [AGG_COST_BITS-1:0] sum_r_52;
reg [AGG_COST_BITS-1:0] sum01_r_53; reg [AGG_COST_BITS-1:0] sum23_r_53; reg [AGG_COST_BITS-1:0] sum_r_53;
reg [AGG_COST_BITS-1:0] sum01_r_54; reg [AGG_COST_BITS-1:0] sum23_r_54; reg [AGG_COST_BITS-1:0] sum_r_54;
reg [AGG_COST_BITS-1:0] sum01_r_55; reg [AGG_COST_BITS-1:0] sum23_r_55; reg [AGG_COST_BITS-1:0] sum_r_55;
reg [AGG_COST_BITS-1:0] sum01_r_56; reg [AGG_COST_BITS-1:0] sum23_r_56; reg [AGG_COST_BITS-1:0] sum_r_56;
reg [AGG_COST_BITS-1:0] sum01_r_57; reg [AGG_COST_BITS-1:0] sum23_r_57; reg [AGG_COST_BITS-1:0] sum_r_57;
reg [AGG_COST_BITS-1:0] sum01_r_58; reg [AGG_COST_BITS-1:0] sum23_r_58; reg [AGG_COST_BITS-1:0] sum_r_58;
reg [AGG_COST_BITS-1:0] sum01_r_59; reg [AGG_COST_BITS-1:0] sum23_r_59; reg [AGG_COST_BITS-1:0] sum_r_59;
reg [AGG_COST_BITS-1:0] sum01_r_60; reg [AGG_COST_BITS-1:0] sum23_r_60; reg [AGG_COST_BITS-1:0] sum_r_60;
reg [AGG_COST_BITS-1:0] sum01_r_61; reg [AGG_COST_BITS-1:0] sum23_r_61; reg [AGG_COST_BITS-1:0] sum_r_61;
reg [AGG_COST_BITS-1:0] sum01_r_62; reg [AGG_COST_BITS-1:0] sum23_r_62; reg [AGG_COST_BITS-1:0] sum_r_62;
reg [AGG_COST_BITS-1:0] sum01_r_63; reg [AGG_COST_BITS-1:0] sum23_r_63; reg [AGG_COST_BITS-1:0] sum_r_63;
reg [AGG_COST_BITS-1:0] sum01_r_64; reg [AGG_COST_BITS-1:0] sum23_r_64; reg [AGG_COST_BITS-1:0] sum_r_64;

wire lr_valid_raw;
wire [10:0] lr_x_raw;
wire [9:0]  lr_y_raw;

wire ud_valid_raw;
wire [10:0] ud_x_raw;
wire [9:0]  ud_y_raw;

wire d0_valid_raw;
wire [10:0] d0_x_raw;
wire [9:0]  d0_y_raw;

wire d1_valid_raw;
wire [10:0] d1_x_raw;
wire [9:0]  d1_y_raw;

reg  lr_valid_a1, lr_valid_a2;
reg  [10:0] lr_x_a1, lr_x_a2;
reg  [9:0]  lr_y_a1, lr_y_a2;


////////////////////////////
reg        lr_valid_a3;
reg [10:0] lr_x_a3;
reg [9:0]  lr_y_a3;
//////////////////////////


reg  sum_valid_r;
reg  [10:0] sum_x_r;
reg  [9:0]  sum_y_r;

wire stage1_match =
    lr_valid_a2 & ud_valid_raw & d0_valid_raw & d1_valid_raw &
    (lr_x_a2 == ud_x_raw) & (lr_y_a2 == ud_y_raw) &
    (lr_x_a2 == d0_x_raw) & (lr_y_a2 == d0_y_raw) &
    (lr_x_a2 == d1_x_raw) & (lr_y_a2 == d1_y_raw);

sgbm_agg_lr #(
    .DISP_NUM      (DISP_NUM),
    .COST_BITS     (COST_BITS),
    .AGG_COST_BITS (SINGLE_PATH_BITS),
    .P1            (P1),
    .P2            (P2),
    .INVALID_COST  (INVALID_COST)
) u_lr (
    .clk           (clk),
    .rst_n         (rst_n),
    .cost_valid    (cost_in_valid),
    .x_in          (x_in),
    .y_in          (y_in),
        .cost0_in(cost0_in),
        .cost1_in(cost1_in),
        .cost2_in(cost2_in),
        .cost3_in(cost3_in),
        .cost4_in(cost4_in),
        .cost5_in(cost5_in),
        .cost6_in(cost6_in),
        .cost7_in(cost7_in),
        .cost8_in(cost8_in),
        .cost9_in(cost9_in),
        .cost10_in(cost10_in),
        .cost11_in(cost11_in),
        .cost12_in(cost12_in),
        .cost13_in(cost13_in),
        .cost14_in(cost14_in),
        .cost15_in(cost15_in),
        .cost16_in(cost16_in),
        .cost17_in(cost17_in),
        .cost18_in(cost18_in),
        .cost19_in(cost19_in),
        .cost20_in(cost20_in),
        .cost21_in(cost21_in),
        .cost22_in(cost22_in),
        .cost23_in(cost23_in),
        .cost24_in(cost24_in),
        .cost25_in(cost25_in),
        .cost26_in(cost26_in),
        .cost27_in(cost27_in),
        .cost28_in(cost28_in),
        .cost29_in(cost29_in),
        .cost30_in(cost30_in),
        .cost31_in(cost31_in),
        .cost32_in(cost32_in),
        .cost33_in(cost33_in),
        .cost34_in(cost34_in),
        .cost35_in(cost35_in),
        .cost36_in(cost36_in),
        .cost37_in(cost37_in),
        .cost38_in(cost38_in),
        .cost39_in(cost39_in),
        .cost40_in(cost40_in),
        .cost41_in(cost41_in),
        .cost42_in(cost42_in),
        .cost43_in(cost43_in),
        .cost44_in(cost44_in),
        .cost45_in(cost45_in),
        .cost46_in(cost46_in),
        .cost47_in(cost47_in),
        .cost48_in(cost48_in),
        .cost49_in(cost49_in),
        .cost50_in(cost50_in),
        .cost51_in(cost51_in),
        .cost52_in(cost52_in),
        .cost53_in(cost53_in),
        .cost54_in(cost54_in),
        .cost55_in(cost55_in),
        .cost56_in(cost56_in),
        .cost57_in(cost57_in),
        .cost58_in(cost58_in),
        .cost59_in(cost59_in),
        .cost60_in(cost60_in),
        .cost61_in(cost61_in),
        .cost62_in(cost62_in),
        .cost63_in(cost63_in),
        .cost64_in(cost64_in),
    .cost_out_valid(lr_valid_raw),
    .x_out         (lr_x_raw),
    .y_out         (lr_y_raw),
        .cost0_out(lr_cost_0),
        .cost1_out(lr_cost_1),
        .cost2_out(lr_cost_2),
        .cost3_out(lr_cost_3),
        .cost4_out(lr_cost_4),
        .cost5_out(lr_cost_5),
        .cost6_out(lr_cost_6),
        .cost7_out(lr_cost_7),
        .cost8_out(lr_cost_8),
        .cost9_out(lr_cost_9),
        .cost10_out(lr_cost_10),
        .cost11_out(lr_cost_11),
        .cost12_out(lr_cost_12),
        .cost13_out(lr_cost_13),
        .cost14_out(lr_cost_14),
        .cost15_out(lr_cost_15),
        .cost16_out(lr_cost_16),
        .cost17_out(lr_cost_17),
        .cost18_out(lr_cost_18),
        .cost19_out(lr_cost_19),
        .cost20_out(lr_cost_20),
        .cost21_out(lr_cost_21),
        .cost22_out(lr_cost_22),
        .cost23_out(lr_cost_23),
        .cost24_out(lr_cost_24),
        .cost25_out(lr_cost_25),
        .cost26_out(lr_cost_26),
        .cost27_out(lr_cost_27),
        .cost28_out(lr_cost_28),
        .cost29_out(lr_cost_29),
        .cost30_out(lr_cost_30),
        .cost31_out(lr_cost_31),
        .cost32_out(lr_cost_32),
        .cost33_out(lr_cost_33),
        .cost34_out(lr_cost_34),
        .cost35_out(lr_cost_35),
        .cost36_out(lr_cost_36),
        .cost37_out(lr_cost_37),
        .cost38_out(lr_cost_38),
        .cost39_out(lr_cost_39),
        .cost40_out(lr_cost_40),
        .cost41_out(lr_cost_41),
        .cost42_out(lr_cost_42),
        .cost43_out(lr_cost_43),
        .cost44_out(lr_cost_44),
        .cost45_out(lr_cost_45),
        .cost46_out(lr_cost_46),
        .cost47_out(lr_cost_47),
        .cost48_out(lr_cost_48),
        .cost49_out(lr_cost_49),
        .cost50_out(lr_cost_50),
        .cost51_out(lr_cost_51),
        .cost52_out(lr_cost_52),
        .cost53_out(lr_cost_53),
        .cost54_out(lr_cost_54),
        .cost55_out(lr_cost_55),
        .cost56_out(lr_cost_56),
        .cost57_out(lr_cost_57),
        .cost58_out(lr_cost_58),
        .cost59_out(lr_cost_59),
        .cost60_out(lr_cost_60),
        .cost61_out(lr_cost_61),
        .cost62_out(lr_cost_62),
        .cost63_out(lr_cost_63),
        .cost64_out(lr_cost_64)
);

sgbm_agg_ud #(
    .IMG_WIDTH     (IMG_WIDTH),
    .DISP_NUM      (DISP_NUM),
    .COST_BITS     (COST_BITS),
    .AGG_COST_BITS (SINGLE_PATH_BITS),
    .P1            (P1),
    .P2            (P2),
    .INVALID_COST  (INVALID_COST)
) u_ud (
    .clk           (clk),
    .rst_n         (rst_n),
    .cost_valid    (cost_in_valid),
    .x_in          (x_in),
    .y_in          (y_in),
        .cost0_in(cost0_in),
        .cost1_in(cost1_in),
        .cost2_in(cost2_in),
        .cost3_in(cost3_in),
        .cost4_in(cost4_in),
        .cost5_in(cost5_in),
        .cost6_in(cost6_in),
        .cost7_in(cost7_in),
        .cost8_in(cost8_in),
        .cost9_in(cost9_in),
        .cost10_in(cost10_in),
        .cost11_in(cost11_in),
        .cost12_in(cost12_in),
        .cost13_in(cost13_in),
        .cost14_in(cost14_in),
        .cost15_in(cost15_in),
        .cost16_in(cost16_in),
        .cost17_in(cost17_in),
        .cost18_in(cost18_in),
        .cost19_in(cost19_in),
        .cost20_in(cost20_in),
        .cost21_in(cost21_in),
        .cost22_in(cost22_in),
        .cost23_in(cost23_in),
        .cost24_in(cost24_in),
        .cost25_in(cost25_in),
        .cost26_in(cost26_in),
        .cost27_in(cost27_in),
        .cost28_in(cost28_in),
        .cost29_in(cost29_in),
        .cost30_in(cost30_in),
        .cost31_in(cost31_in),
        .cost32_in(cost32_in),
        .cost33_in(cost33_in),
        .cost34_in(cost34_in),
        .cost35_in(cost35_in),
        .cost36_in(cost36_in),
        .cost37_in(cost37_in),
        .cost38_in(cost38_in),
        .cost39_in(cost39_in),
        .cost40_in(cost40_in),
        .cost41_in(cost41_in),
        .cost42_in(cost42_in),
        .cost43_in(cost43_in),
        .cost44_in(cost44_in),
        .cost45_in(cost45_in),
        .cost46_in(cost46_in),
        .cost47_in(cost47_in),
        .cost48_in(cost48_in),
        .cost49_in(cost49_in),
        .cost50_in(cost50_in),
        .cost51_in(cost51_in),
        .cost52_in(cost52_in),
        .cost53_in(cost53_in),
        .cost54_in(cost54_in),
        .cost55_in(cost55_in),
        .cost56_in(cost56_in),
        .cost57_in(cost57_in),
        .cost58_in(cost58_in),
        .cost59_in(cost59_in),
        .cost60_in(cost60_in),
        .cost61_in(cost61_in),
        .cost62_in(cost62_in),
        .cost63_in(cost63_in),
        .cost64_in(cost64_in),
    .cost_out_valid(ud_valid_raw),
    .x_out         (ud_x_raw),
    .y_out         (ud_y_raw),
        .cost0_out(ud_cost_0),
        .cost1_out(ud_cost_1),
        .cost2_out(ud_cost_2),
        .cost3_out(ud_cost_3),
        .cost4_out(ud_cost_4),
        .cost5_out(ud_cost_5),
        .cost6_out(ud_cost_6),
        .cost7_out(ud_cost_7),
        .cost8_out(ud_cost_8),
        .cost9_out(ud_cost_9),
        .cost10_out(ud_cost_10),
        .cost11_out(ud_cost_11),
        .cost12_out(ud_cost_12),
        .cost13_out(ud_cost_13),
        .cost14_out(ud_cost_14),
        .cost15_out(ud_cost_15),
        .cost16_out(ud_cost_16),
        .cost17_out(ud_cost_17),
        .cost18_out(ud_cost_18),
        .cost19_out(ud_cost_19),
        .cost20_out(ud_cost_20),
        .cost21_out(ud_cost_21),
        .cost22_out(ud_cost_22),
        .cost23_out(ud_cost_23),
        .cost24_out(ud_cost_24),
        .cost25_out(ud_cost_25),
        .cost26_out(ud_cost_26),
        .cost27_out(ud_cost_27),
        .cost28_out(ud_cost_28),
        .cost29_out(ud_cost_29),
        .cost30_out(ud_cost_30),
        .cost31_out(ud_cost_31),
        .cost32_out(ud_cost_32),
        .cost33_out(ud_cost_33),
        .cost34_out(ud_cost_34),
        .cost35_out(ud_cost_35),
        .cost36_out(ud_cost_36),
        .cost37_out(ud_cost_37),
        .cost38_out(ud_cost_38),
        .cost39_out(ud_cost_39),
        .cost40_out(ud_cost_40),
        .cost41_out(ud_cost_41),
        .cost42_out(ud_cost_42),
        .cost43_out(ud_cost_43),
        .cost44_out(ud_cost_44),
        .cost45_out(ud_cost_45),
        .cost46_out(ud_cost_46),
        .cost47_out(ud_cost_47),
        .cost48_out(ud_cost_48),
        .cost49_out(ud_cost_49),
        .cost50_out(ud_cost_50),
        .cost51_out(ud_cost_51),
        .cost52_out(ud_cost_52),
        .cost53_out(ud_cost_53),
        .cost54_out(ud_cost_54),
        .cost55_out(ud_cost_55),
        .cost56_out(ud_cost_56),
        .cost57_out(ud_cost_57),
        .cost58_out(ud_cost_58),
        .cost59_out(ud_cost_59),
        .cost60_out(ud_cost_60),
        .cost61_out(ud_cost_61),
        .cost62_out(ud_cost_62),
        .cost63_out(ud_cost_63),
        .cost64_out(ud_cost_64)
);

sgbm_agg_diag #(
    .IMG_WIDTH     (IMG_WIDTH),
    .DISP_NUM      (DISP_NUM),
    .COST_BITS     (COST_BITS),
    .AGG_COST_BITS (SINGLE_PATH_BITS),
    .P1            (P1),
    .P2            (P2),
    .INVALID_COST  (INVALID_COST),
    .DIAG_MODE     (0)
) u_d0 (
    .clk           (clk),
    .rst_n         (rst_n),
    .cost_valid    (cost_in_valid),
    .x_in          (x_in),
    .y_in          (y_in),
        .cost0_in(cost0_in),
        .cost1_in(cost1_in),
        .cost2_in(cost2_in),
        .cost3_in(cost3_in),
        .cost4_in(cost4_in),
        .cost5_in(cost5_in),
        .cost6_in(cost6_in),
        .cost7_in(cost7_in),
        .cost8_in(cost8_in),
        .cost9_in(cost9_in),
        .cost10_in(cost10_in),
        .cost11_in(cost11_in),
        .cost12_in(cost12_in),
        .cost13_in(cost13_in),
        .cost14_in(cost14_in),
        .cost15_in(cost15_in),
        .cost16_in(cost16_in),
        .cost17_in(cost17_in),
        .cost18_in(cost18_in),
        .cost19_in(cost19_in),
        .cost20_in(cost20_in),
        .cost21_in(cost21_in),
        .cost22_in(cost22_in),
        .cost23_in(cost23_in),
        .cost24_in(cost24_in),
        .cost25_in(cost25_in),
        .cost26_in(cost26_in),
        .cost27_in(cost27_in),
        .cost28_in(cost28_in),
        .cost29_in(cost29_in),
        .cost30_in(cost30_in),
        .cost31_in(cost31_in),
        .cost32_in(cost32_in),
        .cost33_in(cost33_in),
        .cost34_in(cost34_in),
        .cost35_in(cost35_in),
        .cost36_in(cost36_in),
        .cost37_in(cost37_in),
        .cost38_in(cost38_in),
        .cost39_in(cost39_in),
        .cost40_in(cost40_in),
        .cost41_in(cost41_in),
        .cost42_in(cost42_in),
        .cost43_in(cost43_in),
        .cost44_in(cost44_in),
        .cost45_in(cost45_in),
        .cost46_in(cost46_in),
        .cost47_in(cost47_in),
        .cost48_in(cost48_in),
        .cost49_in(cost49_in),
        .cost50_in(cost50_in),
        .cost51_in(cost51_in),
        .cost52_in(cost52_in),
        .cost53_in(cost53_in),
        .cost54_in(cost54_in),
        .cost55_in(cost55_in),
        .cost56_in(cost56_in),
        .cost57_in(cost57_in),
        .cost58_in(cost58_in),
        .cost59_in(cost59_in),
        .cost60_in(cost60_in),
        .cost61_in(cost61_in),
        .cost62_in(cost62_in),
        .cost63_in(cost63_in),
        .cost64_in(cost64_in),
    .cost_out_valid(d0_valid_raw),
    .x_out         (d0_x_raw),
    .y_out         (d0_y_raw),
        .cost0_out(d0_cost_0),
        .cost1_out(d0_cost_1),
        .cost2_out(d0_cost_2),
        .cost3_out(d0_cost_3),
        .cost4_out(d0_cost_4),
        .cost5_out(d0_cost_5),
        .cost6_out(d0_cost_6),
        .cost7_out(d0_cost_7),
        .cost8_out(d0_cost_8),
        .cost9_out(d0_cost_9),
        .cost10_out(d0_cost_10),
        .cost11_out(d0_cost_11),
        .cost12_out(d0_cost_12),
        .cost13_out(d0_cost_13),
        .cost14_out(d0_cost_14),
        .cost15_out(d0_cost_15),
        .cost16_out(d0_cost_16),
        .cost17_out(d0_cost_17),
        .cost18_out(d0_cost_18),
        .cost19_out(d0_cost_19),
        .cost20_out(d0_cost_20),
        .cost21_out(d0_cost_21),
        .cost22_out(d0_cost_22),
        .cost23_out(d0_cost_23),
        .cost24_out(d0_cost_24),
        .cost25_out(d0_cost_25),
        .cost26_out(d0_cost_26),
        .cost27_out(d0_cost_27),
        .cost28_out(d0_cost_28),
        .cost29_out(d0_cost_29),
        .cost30_out(d0_cost_30),
        .cost31_out(d0_cost_31),
        .cost32_out(d0_cost_32),
        .cost33_out(d0_cost_33),
        .cost34_out(d0_cost_34),
        .cost35_out(d0_cost_35),
        .cost36_out(d0_cost_36),
        .cost37_out(d0_cost_37),
        .cost38_out(d0_cost_38),
        .cost39_out(d0_cost_39),
        .cost40_out(d0_cost_40),
        .cost41_out(d0_cost_41),
        .cost42_out(d0_cost_42),
        .cost43_out(d0_cost_43),
        .cost44_out(d0_cost_44),
        .cost45_out(d0_cost_45),
        .cost46_out(d0_cost_46),
        .cost47_out(d0_cost_47),
        .cost48_out(d0_cost_48),
        .cost49_out(d0_cost_49),
        .cost50_out(d0_cost_50),
        .cost51_out(d0_cost_51),
        .cost52_out(d0_cost_52),
        .cost53_out(d0_cost_53),
        .cost54_out(d0_cost_54),
        .cost55_out(d0_cost_55),
        .cost56_out(d0_cost_56),
        .cost57_out(d0_cost_57),
        .cost58_out(d0_cost_58),
        .cost59_out(d0_cost_59),
        .cost60_out(d0_cost_60),
        .cost61_out(d0_cost_61),
        .cost62_out(d0_cost_62),
        .cost63_out(d0_cost_63),
        .cost64_out(d0_cost_64)
);

sgbm_agg_diag #(
    .IMG_WIDTH     (IMG_WIDTH),
    .DISP_NUM      (DISP_NUM),
    .COST_BITS     (COST_BITS),
    .AGG_COST_BITS (SINGLE_PATH_BITS),
    .P1            (P1),
    .P2            (P2),
    .INVALID_COST  (INVALID_COST),
    .DIAG_MODE     (1)
) u_d1 (
    .clk           (clk),
    .rst_n         (rst_n),
    .cost_valid    (cost_in_valid),
    .x_in          (x_in),
    .y_in          (y_in),
        .cost0_in(cost0_in),
        .cost1_in(cost1_in),
        .cost2_in(cost2_in),
        .cost3_in(cost3_in),
        .cost4_in(cost4_in),
        .cost5_in(cost5_in),
        .cost6_in(cost6_in),
        .cost7_in(cost7_in),
        .cost8_in(cost8_in),
        .cost9_in(cost9_in),
        .cost10_in(cost10_in),
        .cost11_in(cost11_in),
        .cost12_in(cost12_in),
        .cost13_in(cost13_in),
        .cost14_in(cost14_in),
        .cost15_in(cost15_in),
        .cost16_in(cost16_in),
        .cost17_in(cost17_in),
        .cost18_in(cost18_in),
        .cost19_in(cost19_in),
        .cost20_in(cost20_in),
        .cost21_in(cost21_in),
        .cost22_in(cost22_in),
        .cost23_in(cost23_in),
        .cost24_in(cost24_in),
        .cost25_in(cost25_in),
        .cost26_in(cost26_in),
        .cost27_in(cost27_in),
        .cost28_in(cost28_in),
        .cost29_in(cost29_in),
        .cost30_in(cost30_in),
        .cost31_in(cost31_in),
        .cost32_in(cost32_in),
        .cost33_in(cost33_in),
        .cost34_in(cost34_in),
        .cost35_in(cost35_in),
        .cost36_in(cost36_in),
        .cost37_in(cost37_in),
        .cost38_in(cost38_in),
        .cost39_in(cost39_in),
        .cost40_in(cost40_in),
        .cost41_in(cost41_in),
        .cost42_in(cost42_in),
        .cost43_in(cost43_in),
        .cost44_in(cost44_in),
        .cost45_in(cost45_in),
        .cost46_in(cost46_in),
        .cost47_in(cost47_in),
        .cost48_in(cost48_in),
        .cost49_in(cost49_in),
        .cost50_in(cost50_in),
        .cost51_in(cost51_in),
        .cost52_in(cost52_in),
        .cost53_in(cost53_in),
        .cost54_in(cost54_in),
        .cost55_in(cost55_in),
        .cost56_in(cost56_in),
        .cost57_in(cost57_in),
        .cost58_in(cost58_in),
        .cost59_in(cost59_in),
        .cost60_in(cost60_in),
        .cost61_in(cost61_in),
        .cost62_in(cost62_in),
        .cost63_in(cost63_in),
        .cost64_in(cost64_in),
    .cost_out_valid(d1_valid_raw),
    .x_out         (d1_x_raw),
    .y_out         (d1_y_raw),
        .cost0_out(d1_cost_0),
        .cost1_out(d1_cost_1),
        .cost2_out(d1_cost_2),
        .cost3_out(d1_cost_3),
        .cost4_out(d1_cost_4),
        .cost5_out(d1_cost_5),
        .cost6_out(d1_cost_6),
        .cost7_out(d1_cost_7),
        .cost8_out(d1_cost_8),
        .cost9_out(d1_cost_9),
        .cost10_out(d1_cost_10),
        .cost11_out(d1_cost_11),
        .cost12_out(d1_cost_12),
        .cost13_out(d1_cost_13),
        .cost14_out(d1_cost_14),
        .cost15_out(d1_cost_15),
        .cost16_out(d1_cost_16),
        .cost17_out(d1_cost_17),
        .cost18_out(d1_cost_18),
        .cost19_out(d1_cost_19),
        .cost20_out(d1_cost_20),
        .cost21_out(d1_cost_21),
        .cost22_out(d1_cost_22),
        .cost23_out(d1_cost_23),
        .cost24_out(d1_cost_24),
        .cost25_out(d1_cost_25),
        .cost26_out(d1_cost_26),
        .cost27_out(d1_cost_27),
        .cost28_out(d1_cost_28),
        .cost29_out(d1_cost_29),
        .cost30_out(d1_cost_30),
        .cost31_out(d1_cost_31),
        .cost32_out(d1_cost_32),
        .cost33_out(d1_cost_33),
        .cost34_out(d1_cost_34),
        .cost35_out(d1_cost_35),
        .cost36_out(d1_cost_36),
        .cost37_out(d1_cost_37),
        .cost38_out(d1_cost_38),
        .cost39_out(d1_cost_39),
        .cost40_out(d1_cost_40),
        .cost41_out(d1_cost_41),
        .cost42_out(d1_cost_42),
        .cost43_out(d1_cost_43),
        .cost44_out(d1_cost_44),
        .cost45_out(d1_cost_45),
        .cost46_out(d1_cost_46),
        .cost47_out(d1_cost_47),
        .cost48_out(d1_cost_48),
        .cost49_out(d1_cost_49),
        .cost50_out(d1_cost_50),
        .cost51_out(d1_cost_51),
        .cost52_out(d1_cost_52),
        .cost53_out(d1_cost_53),
        .cost54_out(d1_cost_54),
        .cost55_out(d1_cost_55),
        .cost56_out(d1_cost_56),
        .cost57_out(d1_cost_57),
        .cost58_out(d1_cost_58),
        .cost59_out(d1_cost_59),
        .cost60_out(d1_cost_60),
        .cost61_out(d1_cost_61),
        .cost62_out(d1_cost_62),
        .cost63_out(d1_cost_63),
        .cost64_out(d1_cost_64)
);

// Stage A1/A2: align LR to the v4 UD/diag latency (UD/diag are 2 cycles later than LR)
always @(posedge clk) begin
    if (!rst_n) begin
       /* lr_valid_a1 <= 1'b0;
        lr_x_a1     <= 11'd0;
        lr_y_a1     <= 10'd0;
        lr_cost_a1_0 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_1 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_2 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_3 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_4 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_5 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_6 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_7 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_8 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_9 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_10 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_11 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_12 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_13 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_14 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_15 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_16 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_17 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_18 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_19 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_20 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_21 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_22 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_23 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_24 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_25 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_26 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_27 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_28 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_29 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_30 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_31 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_32 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_33 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_34 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_35 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_36 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_37 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_38 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_39 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_40 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_41 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_42 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_43 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_44 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_45 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_46 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_47 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_48 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_49 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_50 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_51 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_52 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_53 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_54 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_55 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_56 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_57 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_58 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_59 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_60 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_61 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_62 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_63 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a1_64 <= {SINGLE_PATH_BITS{1'b0}};
        lr_valid_a2 <= 1'b0;
        lr_x_a2     <= 11'd0;
        lr_y_a2     <= 10'd0;
        lr_cost_a2_0 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_1 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_2 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_3 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_4 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_5 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_6 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_7 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_8 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_9 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_10 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_11 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_12 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_13 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_14 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_15 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_16 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_17 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_18 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_19 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_20 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_21 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_22 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_23 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_24 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_25 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_26 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_27 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_28 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_29 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_30 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_31 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_32 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_33 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_34 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_35 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_36 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_37 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_38 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_39 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_40 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_41 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_42 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_43 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_44 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_45 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_46 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_47 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_48 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_49 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_50 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_51 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_52 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_53 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_54 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_55 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_56 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_57 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_58 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_59 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_60 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_61 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_62 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_63 <= {SINGLE_PATH_BITS{1'b0}};
        lr_cost_a2_64 <= {SINGLE_PATH_BITS{1'b0}};
		*/
    lr_valid_a1 <= 1'b0;
    lr_x_a1     <= 11'd0;
    lr_y_a1     <= 10'd0;

    lr_valid_a2 <= 1'b0;
    lr_x_a2     <= 11'd0;
    lr_y_a2     <= 10'd0;
    end else begin
        lr_valid_a1 <= lr_valid_raw;
        lr_x_a1     <= lr_x_raw;
        lr_y_a1     <= lr_y_raw;
        lr_cost_a1_0 <= lr_cost_0;
        lr_cost_a1_1 <= lr_cost_1;
        lr_cost_a1_2 <= lr_cost_2;
        lr_cost_a1_3 <= lr_cost_3;
        lr_cost_a1_4 <= lr_cost_4;
        lr_cost_a1_5 <= lr_cost_5;
        lr_cost_a1_6 <= lr_cost_6;
        lr_cost_a1_7 <= lr_cost_7;
        lr_cost_a1_8 <= lr_cost_8;
        lr_cost_a1_9 <= lr_cost_9;
        lr_cost_a1_10 <= lr_cost_10;
        lr_cost_a1_11 <= lr_cost_11;
        lr_cost_a1_12 <= lr_cost_12;
        lr_cost_a1_13 <= lr_cost_13;
        lr_cost_a1_14 <= lr_cost_14;
        lr_cost_a1_15 <= lr_cost_15;
        lr_cost_a1_16 <= lr_cost_16;
        lr_cost_a1_17 <= lr_cost_17;
        lr_cost_a1_18 <= lr_cost_18;
        lr_cost_a1_19 <= lr_cost_19;
        lr_cost_a1_20 <= lr_cost_20;
        lr_cost_a1_21 <= lr_cost_21;
        lr_cost_a1_22 <= lr_cost_22;
        lr_cost_a1_23 <= lr_cost_23;
        lr_cost_a1_24 <= lr_cost_24;
        lr_cost_a1_25 <= lr_cost_25;
        lr_cost_a1_26 <= lr_cost_26;
        lr_cost_a1_27 <= lr_cost_27;
        lr_cost_a1_28 <= lr_cost_28;
        lr_cost_a1_29 <= lr_cost_29;
        lr_cost_a1_30 <= lr_cost_30;
        lr_cost_a1_31 <= lr_cost_31;
        lr_cost_a1_32 <= lr_cost_32;
        lr_cost_a1_33 <= lr_cost_33;
        lr_cost_a1_34 <= lr_cost_34;
        lr_cost_a1_35 <= lr_cost_35;
        lr_cost_a1_36 <= lr_cost_36;
        lr_cost_a1_37 <= lr_cost_37;
        lr_cost_a1_38 <= lr_cost_38;
        lr_cost_a1_39 <= lr_cost_39;
        lr_cost_a1_40 <= lr_cost_40;
        lr_cost_a1_41 <= lr_cost_41;
        lr_cost_a1_42 <= lr_cost_42;
        lr_cost_a1_43 <= lr_cost_43;
        lr_cost_a1_44 <= lr_cost_44;
        lr_cost_a1_45 <= lr_cost_45;
        lr_cost_a1_46 <= lr_cost_46;
        lr_cost_a1_47 <= lr_cost_47;
        lr_cost_a1_48 <= lr_cost_48;
        lr_cost_a1_49 <= lr_cost_49;
        lr_cost_a1_50 <= lr_cost_50;
        lr_cost_a1_51 <= lr_cost_51;
        lr_cost_a1_52 <= lr_cost_52;
        lr_cost_a1_53 <= lr_cost_53;
        lr_cost_a1_54 <= lr_cost_54;
        lr_cost_a1_55 <= lr_cost_55;
        lr_cost_a1_56 <= lr_cost_56;
        lr_cost_a1_57 <= lr_cost_57;
        lr_cost_a1_58 <= lr_cost_58;
        lr_cost_a1_59 <= lr_cost_59;
        lr_cost_a1_60 <= lr_cost_60;
        lr_cost_a1_61 <= lr_cost_61;
        lr_cost_a1_62 <= lr_cost_62;
        lr_cost_a1_63 <= lr_cost_63;
        lr_cost_a1_64 <= lr_cost_64;
        lr_valid_a2 <= lr_valid_a1;
        lr_x_a2     <= lr_x_a1;
        lr_y_a2     <= lr_y_a1;
        lr_cost_a2_0 <= lr_cost_a1_0;
        lr_cost_a2_1 <= lr_cost_a1_1;
        lr_cost_a2_2 <= lr_cost_a1_2;
        lr_cost_a2_3 <= lr_cost_a1_3;
        lr_cost_a2_4 <= lr_cost_a1_4;
        lr_cost_a2_5 <= lr_cost_a1_5;
        lr_cost_a2_6 <= lr_cost_a1_6;
        lr_cost_a2_7 <= lr_cost_a1_7;
        lr_cost_a2_8 <= lr_cost_a1_8;
        lr_cost_a2_9 <= lr_cost_a1_9;
        lr_cost_a2_10 <= lr_cost_a1_10;
        lr_cost_a2_11 <= lr_cost_a1_11;
        lr_cost_a2_12 <= lr_cost_a1_12;
        lr_cost_a2_13 <= lr_cost_a1_13;
        lr_cost_a2_14 <= lr_cost_a1_14;
        lr_cost_a2_15 <= lr_cost_a1_15;
        lr_cost_a2_16 <= lr_cost_a1_16;
        lr_cost_a2_17 <= lr_cost_a1_17;
        lr_cost_a2_18 <= lr_cost_a1_18;
        lr_cost_a2_19 <= lr_cost_a1_19;
        lr_cost_a2_20 <= lr_cost_a1_20;
        lr_cost_a2_21 <= lr_cost_a1_21;
        lr_cost_a2_22 <= lr_cost_a1_22;
        lr_cost_a2_23 <= lr_cost_a1_23;
        lr_cost_a2_24 <= lr_cost_a1_24;
        lr_cost_a2_25 <= lr_cost_a1_25;
        lr_cost_a2_26 <= lr_cost_a1_26;
        lr_cost_a2_27 <= lr_cost_a1_27;
        lr_cost_a2_28 <= lr_cost_a1_28;
        lr_cost_a2_29 <= lr_cost_a1_29;
        lr_cost_a2_30 <= lr_cost_a1_30;
        lr_cost_a2_31 <= lr_cost_a1_31;
        lr_cost_a2_32 <= lr_cost_a1_32;
        lr_cost_a2_33 <= lr_cost_a1_33;
        lr_cost_a2_34 <= lr_cost_a1_34;
        lr_cost_a2_35 <= lr_cost_a1_35;
        lr_cost_a2_36 <= lr_cost_a1_36;
        lr_cost_a2_37 <= lr_cost_a1_37;
        lr_cost_a2_38 <= lr_cost_a1_38;
        lr_cost_a2_39 <= lr_cost_a1_39;
        lr_cost_a2_40 <= lr_cost_a1_40;
        lr_cost_a2_41 <= lr_cost_a1_41;
        lr_cost_a2_42 <= lr_cost_a1_42;
        lr_cost_a2_43 <= lr_cost_a1_43;
        lr_cost_a2_44 <= lr_cost_a1_44;
        lr_cost_a2_45 <= lr_cost_a1_45;
        lr_cost_a2_46 <= lr_cost_a1_46;
        lr_cost_a2_47 <= lr_cost_a1_47;
        lr_cost_a2_48 <= lr_cost_a1_48;
        lr_cost_a2_49 <= lr_cost_a1_49;
        lr_cost_a2_50 <= lr_cost_a1_50;
        lr_cost_a2_51 <= lr_cost_a1_51;
        lr_cost_a2_52 <= lr_cost_a1_52;
        lr_cost_a2_53 <= lr_cost_a1_53;
        lr_cost_a2_54 <= lr_cost_a1_54;
        lr_cost_a2_55 <= lr_cost_a1_55;
        lr_cost_a2_56 <= lr_cost_a1_56;
        lr_cost_a2_57 <= lr_cost_a1_57;
        lr_cost_a2_58 <= lr_cost_a1_58;
        lr_cost_a2_59 <= lr_cost_a1_59;
        lr_cost_a2_60 <= lr_cost_a1_60;
        lr_cost_a2_61 <= lr_cost_a1_61;
        lr_cost_a2_62 <= lr_cost_a1_62;
        lr_cost_a2_63 <= lr_cost_a1_63;
        lr_cost_a2_64 <= lr_cost_a1_64;
    end
end

// Stage B: pairwise sum
always @(posedge clk) begin
    if (!rst_n) begin
        /*sum_valid_r <= 1'b0;
        sum_x_r     <= 11'd0;
        sum_y_r     <= 10'd0;
        sum01_r_0 <= {AGG_COST_BITS{1'b0}}; sum23_r_0 <= {AGG_COST_BITS{1'b0}};
        sum01_r_1 <= {AGG_COST_BITS{1'b0}}; sum23_r_1 <= {AGG_COST_BITS{1'b0}};
        sum01_r_2 <= {AGG_COST_BITS{1'b0}}; sum23_r_2 <= {AGG_COST_BITS{1'b0}};
        sum01_r_3 <= {AGG_COST_BITS{1'b0}}; sum23_r_3 <= {AGG_COST_BITS{1'b0}};
        sum01_r_4 <= {AGG_COST_BITS{1'b0}}; sum23_r_4 <= {AGG_COST_BITS{1'b0}};
        sum01_r_5 <= {AGG_COST_BITS{1'b0}}; sum23_r_5 <= {AGG_COST_BITS{1'b0}};
        sum01_r_6 <= {AGG_COST_BITS{1'b0}}; sum23_r_6 <= {AGG_COST_BITS{1'b0}};
        sum01_r_7 <= {AGG_COST_BITS{1'b0}}; sum23_r_7 <= {AGG_COST_BITS{1'b0}};
        sum01_r_8 <= {AGG_COST_BITS{1'b0}}; sum23_r_8 <= {AGG_COST_BITS{1'b0}};
        sum01_r_9 <= {AGG_COST_BITS{1'b0}}; sum23_r_9 <= {AGG_COST_BITS{1'b0}};
        sum01_r_10 <= {AGG_COST_BITS{1'b0}}; sum23_r_10 <= {AGG_COST_BITS{1'b0}};
        sum01_r_11 <= {AGG_COST_BITS{1'b0}}; sum23_r_11 <= {AGG_COST_BITS{1'b0}};
        sum01_r_12 <= {AGG_COST_BITS{1'b0}}; sum23_r_12 <= {AGG_COST_BITS{1'b0}};
        sum01_r_13 <= {AGG_COST_BITS{1'b0}}; sum23_r_13 <= {AGG_COST_BITS{1'b0}};
        sum01_r_14 <= {AGG_COST_BITS{1'b0}}; sum23_r_14 <= {AGG_COST_BITS{1'b0}};
        sum01_r_15 <= {AGG_COST_BITS{1'b0}}; sum23_r_15 <= {AGG_COST_BITS{1'b0}};
        sum01_r_16 <= {AGG_COST_BITS{1'b0}}; sum23_r_16 <= {AGG_COST_BITS{1'b0}};
        sum01_r_17 <= {AGG_COST_BITS{1'b0}}; sum23_r_17 <= {AGG_COST_BITS{1'b0}};
        sum01_r_18 <= {AGG_COST_BITS{1'b0}}; sum23_r_18 <= {AGG_COST_BITS{1'b0}};
        sum01_r_19 <= {AGG_COST_BITS{1'b0}}; sum23_r_19 <= {AGG_COST_BITS{1'b0}};
        sum01_r_20 <= {AGG_COST_BITS{1'b0}}; sum23_r_20 <= {AGG_COST_BITS{1'b0}};
        sum01_r_21 <= {AGG_COST_BITS{1'b0}}; sum23_r_21 <= {AGG_COST_BITS{1'b0}};
        sum01_r_22 <= {AGG_COST_BITS{1'b0}}; sum23_r_22 <= {AGG_COST_BITS{1'b0}};
        sum01_r_23 <= {AGG_COST_BITS{1'b0}}; sum23_r_23 <= {AGG_COST_BITS{1'b0}};
        sum01_r_24 <= {AGG_COST_BITS{1'b0}}; sum23_r_24 <= {AGG_COST_BITS{1'b0}};
        sum01_r_25 <= {AGG_COST_BITS{1'b0}}; sum23_r_25 <= {AGG_COST_BITS{1'b0}};
        sum01_r_26 <= {AGG_COST_BITS{1'b0}}; sum23_r_26 <= {AGG_COST_BITS{1'b0}};
        sum01_r_27 <= {AGG_COST_BITS{1'b0}}; sum23_r_27 <= {AGG_COST_BITS{1'b0}};
        sum01_r_28 <= {AGG_COST_BITS{1'b0}}; sum23_r_28 <= {AGG_COST_BITS{1'b0}};
        sum01_r_29 <= {AGG_COST_BITS{1'b0}}; sum23_r_29 <= {AGG_COST_BITS{1'b0}};
        sum01_r_30 <= {AGG_COST_BITS{1'b0}}; sum23_r_30 <= {AGG_COST_BITS{1'b0}};
        sum01_r_31 <= {AGG_COST_BITS{1'b0}}; sum23_r_31 <= {AGG_COST_BITS{1'b0}};
        sum01_r_32 <= {AGG_COST_BITS{1'b0}}; sum23_r_32 <= {AGG_COST_BITS{1'b0}};
        sum01_r_33 <= {AGG_COST_BITS{1'b0}}; sum23_r_33 <= {AGG_COST_BITS{1'b0}};
        sum01_r_34 <= {AGG_COST_BITS{1'b0}}; sum23_r_34 <= {AGG_COST_BITS{1'b0}};
        sum01_r_35 <= {AGG_COST_BITS{1'b0}}; sum23_r_35 <= {AGG_COST_BITS{1'b0}};
        sum01_r_36 <= {AGG_COST_BITS{1'b0}}; sum23_r_36 <= {AGG_COST_BITS{1'b0}};
        sum01_r_37 <= {AGG_COST_BITS{1'b0}}; sum23_r_37 <= {AGG_COST_BITS{1'b0}};
        sum01_r_38 <= {AGG_COST_BITS{1'b0}}; sum23_r_38 <= {AGG_COST_BITS{1'b0}};
        sum01_r_39 <= {AGG_COST_BITS{1'b0}}; sum23_r_39 <= {AGG_COST_BITS{1'b0}};
        sum01_r_40 <= {AGG_COST_BITS{1'b0}}; sum23_r_40 <= {AGG_COST_BITS{1'b0}};
        sum01_r_41 <= {AGG_COST_BITS{1'b0}}; sum23_r_41 <= {AGG_COST_BITS{1'b0}};
        sum01_r_42 <= {AGG_COST_BITS{1'b0}}; sum23_r_42 <= {AGG_COST_BITS{1'b0}};
        sum01_r_43 <= {AGG_COST_BITS{1'b0}}; sum23_r_43 <= {AGG_COST_BITS{1'b0}};
        sum01_r_44 <= {AGG_COST_BITS{1'b0}}; sum23_r_44 <= {AGG_COST_BITS{1'b0}};
        sum01_r_45 <= {AGG_COST_BITS{1'b0}}; sum23_r_45 <= {AGG_COST_BITS{1'b0}};
        sum01_r_46 <= {AGG_COST_BITS{1'b0}}; sum23_r_46 <= {AGG_COST_BITS{1'b0}};
        sum01_r_47 <= {AGG_COST_BITS{1'b0}}; sum23_r_47 <= {AGG_COST_BITS{1'b0}};
        sum01_r_48 <= {AGG_COST_BITS{1'b0}}; sum23_r_48 <= {AGG_COST_BITS{1'b0}};
        sum01_r_49 <= {AGG_COST_BITS{1'b0}}; sum23_r_49 <= {AGG_COST_BITS{1'b0}};
        sum01_r_50 <= {AGG_COST_BITS{1'b0}}; sum23_r_50 <= {AGG_COST_BITS{1'b0}};
        sum01_r_51 <= {AGG_COST_BITS{1'b0}}; sum23_r_51 <= {AGG_COST_BITS{1'b0}};
        sum01_r_52 <= {AGG_COST_BITS{1'b0}}; sum23_r_52 <= {AGG_COST_BITS{1'b0}};
        sum01_r_53 <= {AGG_COST_BITS{1'b0}}; sum23_r_53 <= {AGG_COST_BITS{1'b0}};
        sum01_r_54 <= {AGG_COST_BITS{1'b0}}; sum23_r_54 <= {AGG_COST_BITS{1'b0}};
        sum01_r_55 <= {AGG_COST_BITS{1'b0}}; sum23_r_55 <= {AGG_COST_BITS{1'b0}};
        sum01_r_56 <= {AGG_COST_BITS{1'b0}}; sum23_r_56 <= {AGG_COST_BITS{1'b0}};
        sum01_r_57 <= {AGG_COST_BITS{1'b0}}; sum23_r_57 <= {AGG_COST_BITS{1'b0}};
        sum01_r_58 <= {AGG_COST_BITS{1'b0}}; sum23_r_58 <= {AGG_COST_BITS{1'b0}};
        sum01_r_59 <= {AGG_COST_BITS{1'b0}}; sum23_r_59 <= {AGG_COST_BITS{1'b0}};
        sum01_r_60 <= {AGG_COST_BITS{1'b0}}; sum23_r_60 <= {AGG_COST_BITS{1'b0}};
        sum01_r_61 <= {AGG_COST_BITS{1'b0}}; sum23_r_61 <= {AGG_COST_BITS{1'b0}};
        sum01_r_62 <= {AGG_COST_BITS{1'b0}}; sum23_r_62 <= {AGG_COST_BITS{1'b0}};
        sum01_r_63 <= {AGG_COST_BITS{1'b0}}; sum23_r_63 <= {AGG_COST_BITS{1'b0}};
        sum01_r_64 <= {AGG_COST_BITS{1'b0}}; sum23_r_64 <= {AGG_COST_BITS{1'b0}};
		*/
	sum_valid_r <= 1'b0;
    sum_x_r     <= 11'd0;
    sum_y_r     <= 10'd0;
    end else begin
        sum_valid_r <= stage1_match;
        sum_x_r     <= lr_x_a2;
        sum_y_r     <= lr_y_a2;
        sum01_r_0 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_0} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_0};
        sum23_r_0 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_0} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_0};
        sum01_r_1 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_1} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_1};
        sum23_r_1 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_1} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_1};
        sum01_r_2 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_2} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_2};
        sum23_r_2 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_2} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_2};
        sum01_r_3 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_3} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_3};
        sum23_r_3 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_3} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_3};
        sum01_r_4 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_4} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_4};
        sum23_r_4 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_4} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_4};
        sum01_r_5 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_5} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_5};
        sum23_r_5 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_5} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_5};
        sum01_r_6 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_6} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_6};
        sum23_r_6 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_6} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_6};
        sum01_r_7 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_7} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_7};
        sum23_r_7 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_7} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_7};
        sum01_r_8 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_8} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_8};
        sum23_r_8 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_8} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_8};
        sum01_r_9 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_9} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_9};
        sum23_r_9 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_9} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_9};
        sum01_r_10 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_10} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_10};
        sum23_r_10 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_10} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_10};
        sum01_r_11 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_11} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_11};
        sum23_r_11 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_11} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_11};
        sum01_r_12 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_12} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_12};
        sum23_r_12 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_12} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_12};
        sum01_r_13 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_13} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_13};
        sum23_r_13 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_13} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_13};
        sum01_r_14 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_14} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_14};
        sum23_r_14 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_14} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_14};
        sum01_r_15 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_15} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_15};
        sum23_r_15 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_15} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_15};
        sum01_r_16 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_16} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_16};
        sum23_r_16 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_16} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_16};
        sum01_r_17 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_17} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_17};
        sum23_r_17 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_17} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_17};
        sum01_r_18 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_18} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_18};
        sum23_r_18 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_18} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_18};
        sum01_r_19 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_19} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_19};
        sum23_r_19 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_19} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_19};
        sum01_r_20 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_20} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_20};
        sum23_r_20 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_20} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_20};
        sum01_r_21 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_21} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_21};
        sum23_r_21 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_21} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_21};
        sum01_r_22 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_22} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_22};
        sum23_r_22 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_22} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_22};
        sum01_r_23 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_23} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_23};
        sum23_r_23 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_23} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_23};
        sum01_r_24 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_24} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_24};
        sum23_r_24 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_24} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_24};
        sum01_r_25 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_25} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_25};
        sum23_r_25 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_25} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_25};
        sum01_r_26 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_26} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_26};
        sum23_r_26 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_26} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_26};
        sum01_r_27 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_27} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_27};
        sum23_r_27 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_27} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_27};
        sum01_r_28 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_28} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_28};
        sum23_r_28 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_28} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_28};
        sum01_r_29 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_29} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_29};
        sum23_r_29 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_29} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_29};
        sum01_r_30 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_30} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_30};
        sum23_r_30 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_30} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_30};
        sum01_r_31 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_31} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_31};
        sum23_r_31 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_31} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_31};
        sum01_r_32 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_32} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_32};
        sum23_r_32 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_32} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_32};
        sum01_r_33 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_33} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_33};
        sum23_r_33 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_33} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_33};
        sum01_r_34 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_34} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_34};
        sum23_r_34 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_34} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_34};
        sum01_r_35 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_35} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_35};
        sum23_r_35 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_35} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_35};
        sum01_r_36 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_36} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_36};
        sum23_r_36 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_36} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_36};
        sum01_r_37 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_37} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_37};
        sum23_r_37 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_37} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_37};
        sum01_r_38 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_38} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_38};
        sum23_r_38 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_38} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_38};
        sum01_r_39 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_39} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_39};
        sum23_r_39 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_39} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_39};
        sum01_r_40 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_40} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_40};
        sum23_r_40 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_40} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_40};
        sum01_r_41 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_41} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_41};
        sum23_r_41 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_41} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_41};
        sum01_r_42 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_42} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_42};
        sum23_r_42 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_42} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_42};
        sum01_r_43 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_43} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_43};
        sum23_r_43 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_43} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_43};
        sum01_r_44 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_44} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_44};
        sum23_r_44 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_44} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_44};
        sum01_r_45 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_45} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_45};
        sum23_r_45 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_45} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_45};
        sum01_r_46 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_46} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_46};
        sum23_r_46 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_46} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_46};
        sum01_r_47 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_47} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_47};
        sum23_r_47 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_47} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_47};
        sum01_r_48 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_48} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_48};
        sum23_r_48 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_48} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_48};
        sum01_r_49 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_49} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_49};
        sum23_r_49 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_49} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_49};
        sum01_r_50 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_50} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_50};
        sum23_r_50 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_50} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_50};
        sum01_r_51 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_51} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_51};
        sum23_r_51 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_51} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_51};
        sum01_r_52 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_52} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_52};
        sum23_r_52 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_52} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_52};
        sum01_r_53 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_53} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_53};
        sum23_r_53 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_53} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_53};
        sum01_r_54 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_54} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_54};
        sum23_r_54 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_54} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_54};
        sum01_r_55 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_55} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_55};
        sum23_r_55 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_55} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_55};
        sum01_r_56 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_56} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_56};
        sum23_r_56 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_56} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_56};
        sum01_r_57 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_57} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_57};
        sum23_r_57 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_57} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_57};
        sum01_r_58 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_58} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_58};
        sum23_r_58 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_58} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_58};
        sum01_r_59 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_59} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_59};
        sum23_r_59 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_59} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_59};
        sum01_r_60 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_60} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_60};
        sum23_r_60 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_60} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_60};
        sum01_r_61 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_61} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_61};
        sum23_r_61 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_61} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_61};
        sum01_r_62 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_62} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_62};
        sum23_r_62 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_62} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_62};
        sum01_r_63 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_63} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_63};
        sum23_r_63 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_63} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_63};
        sum01_r_64 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, lr_cost_a2_64} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, ud_cost_64};
        sum23_r_64 <= {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d0_cost_64} + {{(AGG_COST_BITS-SINGLE_PATH_BITS){1'b0}}, d1_cost_64};
    end
end

// Stage C: final sum
always @(posedge clk) begin
    if (!rst_n) begin
        /*cost_out_valid <= 1'b0;
        x_out          <= 11'd0;
        y_out          <= 10'd0;
        sum_r_0 <= {AGG_COST_BITS{1'b0}};
        sum_r_1 <= {AGG_COST_BITS{1'b0}};
        sum_r_2 <= {AGG_COST_BITS{1'b0}};
        sum_r_3 <= {AGG_COST_BITS{1'b0}};
        sum_r_4 <= {AGG_COST_BITS{1'b0}};
        sum_r_5 <= {AGG_COST_BITS{1'b0}};
        sum_r_6 <= {AGG_COST_BITS{1'b0}};
        sum_r_7 <= {AGG_COST_BITS{1'b0}};
        sum_r_8 <= {AGG_COST_BITS{1'b0}};
        sum_r_9 <= {AGG_COST_BITS{1'b0}};
        sum_r_10 <= {AGG_COST_BITS{1'b0}};
        sum_r_11 <= {AGG_COST_BITS{1'b0}};
        sum_r_12 <= {AGG_COST_BITS{1'b0}};
        sum_r_13 <= {AGG_COST_BITS{1'b0}};
        sum_r_14 <= {AGG_COST_BITS{1'b0}};
        sum_r_15 <= {AGG_COST_BITS{1'b0}};
        sum_r_16 <= {AGG_COST_BITS{1'b0}};
        sum_r_17 <= {AGG_COST_BITS{1'b0}};
        sum_r_18 <= {AGG_COST_BITS{1'b0}};
        sum_r_19 <= {AGG_COST_BITS{1'b0}};
        sum_r_20 <= {AGG_COST_BITS{1'b0}};
        sum_r_21 <= {AGG_COST_BITS{1'b0}};
        sum_r_22 <= {AGG_COST_BITS{1'b0}};
        sum_r_23 <= {AGG_COST_BITS{1'b0}};
        sum_r_24 <= {AGG_COST_BITS{1'b0}};
        sum_r_25 <= {AGG_COST_BITS{1'b0}};
        sum_r_26 <= {AGG_COST_BITS{1'b0}};
        sum_r_27 <= {AGG_COST_BITS{1'b0}};
        sum_r_28 <= {AGG_COST_BITS{1'b0}};
        sum_r_29 <= {AGG_COST_BITS{1'b0}};
        sum_r_30 <= {AGG_COST_BITS{1'b0}};
        sum_r_31 <= {AGG_COST_BITS{1'b0}};
        sum_r_32 <= {AGG_COST_BITS{1'b0}};
        sum_r_33 <= {AGG_COST_BITS{1'b0}};
        sum_r_34 <= {AGG_COST_BITS{1'b0}};
        sum_r_35 <= {AGG_COST_BITS{1'b0}};
        sum_r_36 <= {AGG_COST_BITS{1'b0}};
        sum_r_37 <= {AGG_COST_BITS{1'b0}};
        sum_r_38 <= {AGG_COST_BITS{1'b0}};
        sum_r_39 <= {AGG_COST_BITS{1'b0}};
        sum_r_40 <= {AGG_COST_BITS{1'b0}};
        sum_r_41 <= {AGG_COST_BITS{1'b0}};
        sum_r_42 <= {AGG_COST_BITS{1'b0}};
        sum_r_43 <= {AGG_COST_BITS{1'b0}};
        sum_r_44 <= {AGG_COST_BITS{1'b0}};
        sum_r_45 <= {AGG_COST_BITS{1'b0}};
        sum_r_46 <= {AGG_COST_BITS{1'b0}};
        sum_r_47 <= {AGG_COST_BITS{1'b0}};
        sum_r_48 <= {AGG_COST_BITS{1'b0}};
        sum_r_49 <= {AGG_COST_BITS{1'b0}};
        sum_r_50 <= {AGG_COST_BITS{1'b0}};
        sum_r_51 <= {AGG_COST_BITS{1'b0}};
        sum_r_52 <= {AGG_COST_BITS{1'b0}};
        sum_r_53 <= {AGG_COST_BITS{1'b0}};
        sum_r_54 <= {AGG_COST_BITS{1'b0}};
        sum_r_55 <= {AGG_COST_BITS{1'b0}};
        sum_r_56 <= {AGG_COST_BITS{1'b0}};
        sum_r_57 <= {AGG_COST_BITS{1'b0}};
        sum_r_58 <= {AGG_COST_BITS{1'b0}};
        sum_r_59 <= {AGG_COST_BITS{1'b0}};
        sum_r_60 <= {AGG_COST_BITS{1'b0}};
        sum_r_61 <= {AGG_COST_BITS{1'b0}};
        sum_r_62 <= {AGG_COST_BITS{1'b0}};
        sum_r_63 <= {AGG_COST_BITS{1'b0}};
        sum_r_64 <= {AGG_COST_BITS{1'b0}};
		*/
		cost_out_valid <= 1'b0;
    x_out          <= 11'd0;
    y_out          <= 10'd0;
    end else begin
        cost_out_valid <= sum_valid_r;
        x_out          <= sum_x_r;
        y_out          <= sum_y_r;
        sum_r_0 <= sum01_r_0 + sum23_r_0;
        sum_r_1 <= sum01_r_1 + sum23_r_1;
        sum_r_2 <= sum01_r_2 + sum23_r_2;
        sum_r_3 <= sum01_r_3 + sum23_r_3;
        sum_r_4 <= sum01_r_4 + sum23_r_4;
        sum_r_5 <= sum01_r_5 + sum23_r_5;
        sum_r_6 <= sum01_r_6 + sum23_r_6;
        sum_r_7 <= sum01_r_7 + sum23_r_7;
        sum_r_8 <= sum01_r_8 + sum23_r_8;
        sum_r_9 <= sum01_r_9 + sum23_r_9;
        sum_r_10 <= sum01_r_10 + sum23_r_10;
        sum_r_11 <= sum01_r_11 + sum23_r_11;
        sum_r_12 <= sum01_r_12 + sum23_r_12;
        sum_r_13 <= sum01_r_13 + sum23_r_13;
        sum_r_14 <= sum01_r_14 + sum23_r_14;
        sum_r_15 <= sum01_r_15 + sum23_r_15;
        sum_r_16 <= sum01_r_16 + sum23_r_16;
        sum_r_17 <= sum01_r_17 + sum23_r_17;
        sum_r_18 <= sum01_r_18 + sum23_r_18;
        sum_r_19 <= sum01_r_19 + sum23_r_19;
        sum_r_20 <= sum01_r_20 + sum23_r_20;
        sum_r_21 <= sum01_r_21 + sum23_r_21;
        sum_r_22 <= sum01_r_22 + sum23_r_22;
        sum_r_23 <= sum01_r_23 + sum23_r_23;
        sum_r_24 <= sum01_r_24 + sum23_r_24;
        sum_r_25 <= sum01_r_25 + sum23_r_25;
        sum_r_26 <= sum01_r_26 + sum23_r_26;
        sum_r_27 <= sum01_r_27 + sum23_r_27;
        sum_r_28 <= sum01_r_28 + sum23_r_28;
        sum_r_29 <= sum01_r_29 + sum23_r_29;
        sum_r_30 <= sum01_r_30 + sum23_r_30;
        sum_r_31 <= sum01_r_31 + sum23_r_31;
        sum_r_32 <= sum01_r_32 + sum23_r_32;
        sum_r_33 <= sum01_r_33 + sum23_r_33;
        sum_r_34 <= sum01_r_34 + sum23_r_34;
        sum_r_35 <= sum01_r_35 + sum23_r_35;
        sum_r_36 <= sum01_r_36 + sum23_r_36;
        sum_r_37 <= sum01_r_37 + sum23_r_37;
        sum_r_38 <= sum01_r_38 + sum23_r_38;
        sum_r_39 <= sum01_r_39 + sum23_r_39;
        sum_r_40 <= sum01_r_40 + sum23_r_40;
        sum_r_41 <= sum01_r_41 + sum23_r_41;
        sum_r_42 <= sum01_r_42 + sum23_r_42;
        sum_r_43 <= sum01_r_43 + sum23_r_43;
        sum_r_44 <= sum01_r_44 + sum23_r_44;
        sum_r_45 <= sum01_r_45 + sum23_r_45;
        sum_r_46 <= sum01_r_46 + sum23_r_46;
        sum_r_47 <= sum01_r_47 + sum23_r_47;
        sum_r_48 <= sum01_r_48 + sum23_r_48;
        sum_r_49 <= sum01_r_49 + sum23_r_49;
        sum_r_50 <= sum01_r_50 + sum23_r_50;
        sum_r_51 <= sum01_r_51 + sum23_r_51;
        sum_r_52 <= sum01_r_52 + sum23_r_52;
        sum_r_53 <= sum01_r_53 + sum23_r_53;
        sum_r_54 <= sum01_r_54 + sum23_r_54;
        sum_r_55 <= sum01_r_55 + sum23_r_55;
        sum_r_56 <= sum01_r_56 + sum23_r_56;
        sum_r_57 <= sum01_r_57 + sum23_r_57;
        sum_r_58 <= sum01_r_58 + sum23_r_58;
        sum_r_59 <= sum01_r_59 + sum23_r_59;
        sum_r_60 <= sum01_r_60 + sum23_r_60;
        sum_r_61 <= sum01_r_61 + sum23_r_61;
        sum_r_62 <= sum01_r_62 + sum23_r_62;
        sum_r_63 <= sum01_r_63 + sum23_r_63;
        sum_r_64 <= sum01_r_64 + sum23_r_64;
    end
end

assign cost0_out = sum_r_0;
assign cost1_out = sum_r_1;
assign cost2_out = sum_r_2;
assign cost3_out = sum_r_3;
assign cost4_out = sum_r_4;
assign cost5_out = sum_r_5;
assign cost6_out = sum_r_6;
assign cost7_out = sum_r_7;
assign cost8_out = sum_r_8;
assign cost9_out = sum_r_9;
assign cost10_out = sum_r_10;
assign cost11_out = sum_r_11;
assign cost12_out = sum_r_12;
assign cost13_out = sum_r_13;
assign cost14_out = sum_r_14;
assign cost15_out = sum_r_15;
assign cost16_out = sum_r_16;
assign cost17_out = sum_r_17;
assign cost18_out = sum_r_18;
assign cost19_out = sum_r_19;
assign cost20_out = sum_r_20;
assign cost21_out = sum_r_21;
assign cost22_out = sum_r_22;
assign cost23_out = sum_r_23;
assign cost24_out = sum_r_24;
assign cost25_out = sum_r_25;
assign cost26_out = sum_r_26;
assign cost27_out = sum_r_27;
assign cost28_out = sum_r_28;
assign cost29_out = sum_r_29;
assign cost30_out = sum_r_30;
assign cost31_out = sum_r_31;
assign cost32_out = sum_r_32;
assign cost33_out = sum_r_33;
assign cost34_out = sum_r_34;
assign cost35_out = sum_r_35;
assign cost36_out = sum_r_36;
assign cost37_out = sum_r_37;
assign cost38_out = sum_r_38;
assign cost39_out = sum_r_39;
assign cost40_out = sum_r_40;
assign cost41_out = sum_r_41;
assign cost42_out = sum_r_42;
assign cost43_out = sum_r_43;
assign cost44_out = sum_r_44;
assign cost45_out = sum_r_45;
assign cost46_out = sum_r_46;
assign cost47_out = sum_r_47;
assign cost48_out = sum_r_48;
assign cost49_out = sum_r_49;
assign cost50_out = sum_r_50;
assign cost51_out = sum_r_51;
assign cost52_out = sum_r_52;
assign cost53_out = sum_r_53;
assign cost54_out = sum_r_54;
assign cost55_out = sum_r_55;
assign cost56_out = sum_r_56;
assign cost57_out = sum_r_57;
assign cost58_out = sum_r_58;
assign cost59_out = sum_r_59;
assign cost60_out = sum_r_60;
assign cost61_out = sum_r_61;
assign cost62_out = sum_r_62;
assign cost63_out = sum_r_63;
assign cost64_out = sum_r_64;

endmodule
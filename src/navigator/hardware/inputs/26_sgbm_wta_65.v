`timescale 1ns / 1ps
module sgbm_wta_65 #(
    parameter COST_BITS = 6,
    parameter DISP_BITS = 7
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    cost_valid,
    input  wire [10:0]             x_in,
    input  wire [9:0]              y_in,
    input  wire [COST_BITS-1:0]    cost0_in,
    input  wire [COST_BITS-1:0]    cost1_in,
    input  wire [COST_BITS-1:0]    cost2_in,
    input  wire [COST_BITS-1:0]    cost3_in,
    input  wire [COST_BITS-1:0]    cost4_in,
    input  wire [COST_BITS-1:0]    cost5_in,
    input  wire [COST_BITS-1:0]    cost6_in,
    input  wire [COST_BITS-1:0]    cost7_in,
    input  wire [COST_BITS-1:0]    cost8_in,
    input  wire [COST_BITS-1:0]    cost9_in,
    input  wire [COST_BITS-1:0]    cost10_in,
    input  wire [COST_BITS-1:0]    cost11_in,
    input  wire [COST_BITS-1:0]    cost12_in,
    input  wire [COST_BITS-1:0]    cost13_in,
    input  wire [COST_BITS-1:0]    cost14_in,
    input  wire [COST_BITS-1:0]    cost15_in,
    input  wire [COST_BITS-1:0]    cost16_in,
    input  wire [COST_BITS-1:0]    cost17_in,
    input  wire [COST_BITS-1:0]    cost18_in,
    input  wire [COST_BITS-1:0]    cost19_in,
    input  wire [COST_BITS-1:0]    cost20_in,
    input  wire [COST_BITS-1:0]    cost21_in,
    input  wire [COST_BITS-1:0]    cost22_in,
    input  wire [COST_BITS-1:0]    cost23_in,
    input  wire [COST_BITS-1:0]    cost24_in,
    input  wire [COST_BITS-1:0]    cost25_in,
    input  wire [COST_BITS-1:0]    cost26_in,
    input  wire [COST_BITS-1:0]    cost27_in,
    input  wire [COST_BITS-1:0]    cost28_in,
    input  wire [COST_BITS-1:0]    cost29_in,
    input  wire [COST_BITS-1:0]    cost30_in,
    input  wire [COST_BITS-1:0]    cost31_in,
    input  wire [COST_BITS-1:0]    cost32_in,
    input  wire [COST_BITS-1:0]    cost33_in,
    input  wire [COST_BITS-1:0]    cost34_in,
    input  wire [COST_BITS-1:0]    cost35_in,
    input  wire [COST_BITS-1:0]    cost36_in,
    input  wire [COST_BITS-1:0]    cost37_in,
    input  wire [COST_BITS-1:0]    cost38_in,
    input  wire [COST_BITS-1:0]    cost39_in,
    input  wire [COST_BITS-1:0]    cost40_in,
    input  wire [COST_BITS-1:0]    cost41_in,
    input  wire [COST_BITS-1:0]    cost42_in,
    input  wire [COST_BITS-1:0]    cost43_in,
    input  wire [COST_BITS-1:0]    cost44_in,
    input  wire [COST_BITS-1:0]    cost45_in,
    input  wire [COST_BITS-1:0]    cost46_in,
    input  wire [COST_BITS-1:0]    cost47_in,
    input  wire [COST_BITS-1:0]    cost48_in,
    input  wire [COST_BITS-1:0]    cost49_in,
    input  wire [COST_BITS-1:0]    cost50_in,
    input  wire [COST_BITS-1:0]    cost51_in,
    input  wire [COST_BITS-1:0]    cost52_in,
    input  wire [COST_BITS-1:0]    cost53_in,
    input  wire [COST_BITS-1:0]    cost54_in,
    input  wire [COST_BITS-1:0]    cost55_in,
    input  wire [COST_BITS-1:0]    cost56_in,
    input  wire [COST_BITS-1:0]    cost57_in,
    input  wire [COST_BITS-1:0]    cost58_in,
    input  wire [COST_BITS-1:0]    cost59_in,
    input  wire [COST_BITS-1:0]    cost60_in,
    input  wire [COST_BITS-1:0]    cost61_in,
    input  wire [COST_BITS-1:0]    cost62_in,
    input  wire [COST_BITS-1:0]    cost63_in,
    input  wire [COST_BITS-1:0]    cost64_in,
    output reg                     wta_valid,
    output reg  [10:0]             x_out,
    output reg  [9:0]              y_out,
    output reg  [DISP_BITS-1:0]    disp_out,
    output reg  [COST_BITS-1:0]    min1_cost_out,
    output reg  [COST_BITS-1:0]    min2_cost_out
);

localparam [COST_BITS-1:0] COST_INF = {COST_BITS{1'b1}};

wire [COST_BITS-1:0] leaf_best_cost_0   = cost0_in;
wire [DISP_BITS-1:0] leaf_best_disp_0   = 0;
wire [COST_BITS-1:0] leaf_second_cost_0 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_1   = cost1_in;
wire [DISP_BITS-1:0] leaf_best_disp_1   = 1;
wire [COST_BITS-1:0] leaf_second_cost_1 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_2   = cost2_in;
wire [DISP_BITS-1:0] leaf_best_disp_2   = 2;
wire [COST_BITS-1:0] leaf_second_cost_2 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_3   = cost3_in;
wire [DISP_BITS-1:0] leaf_best_disp_3   = 3;
wire [COST_BITS-1:0] leaf_second_cost_3 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_4   = cost4_in;
wire [DISP_BITS-1:0] leaf_best_disp_4   = 4;
wire [COST_BITS-1:0] leaf_second_cost_4 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_5   = cost5_in;
wire [DISP_BITS-1:0] leaf_best_disp_5   = 5;
wire [COST_BITS-1:0] leaf_second_cost_5 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_6   = cost6_in;
wire [DISP_BITS-1:0] leaf_best_disp_6   = 6;
wire [COST_BITS-1:0] leaf_second_cost_6 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_7   = cost7_in;
wire [DISP_BITS-1:0] leaf_best_disp_7   = 7;
wire [COST_BITS-1:0] leaf_second_cost_7 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_8   = cost8_in;
wire [DISP_BITS-1:0] leaf_best_disp_8   = 8;
wire [COST_BITS-1:0] leaf_second_cost_8 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_9   = cost9_in;
wire [DISP_BITS-1:0] leaf_best_disp_9   = 9;
wire [COST_BITS-1:0] leaf_second_cost_9 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_10   = cost10_in;
wire [DISP_BITS-1:0] leaf_best_disp_10   = 10;
wire [COST_BITS-1:0] leaf_second_cost_10 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_11   = cost11_in;
wire [DISP_BITS-1:0] leaf_best_disp_11   = 11;
wire [COST_BITS-1:0] leaf_second_cost_11 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_12   = cost12_in;
wire [DISP_BITS-1:0] leaf_best_disp_12   = 12;
wire [COST_BITS-1:0] leaf_second_cost_12 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_13   = cost13_in;
wire [DISP_BITS-1:0] leaf_best_disp_13   = 13;
wire [COST_BITS-1:0] leaf_second_cost_13 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_14   = cost14_in;
wire [DISP_BITS-1:0] leaf_best_disp_14   = 14;
wire [COST_BITS-1:0] leaf_second_cost_14 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_15   = cost15_in;
wire [DISP_BITS-1:0] leaf_best_disp_15   = 15;
wire [COST_BITS-1:0] leaf_second_cost_15 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_16   = cost16_in;
wire [DISP_BITS-1:0] leaf_best_disp_16   = 16;
wire [COST_BITS-1:0] leaf_second_cost_16 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_17   = cost17_in;
wire [DISP_BITS-1:0] leaf_best_disp_17   = 17;
wire [COST_BITS-1:0] leaf_second_cost_17 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_18   = cost18_in;
wire [DISP_BITS-1:0] leaf_best_disp_18   = 18;
wire [COST_BITS-1:0] leaf_second_cost_18 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_19   = cost19_in;
wire [DISP_BITS-1:0] leaf_best_disp_19   = 19;
wire [COST_BITS-1:0] leaf_second_cost_19 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_20   = cost20_in;
wire [DISP_BITS-1:0] leaf_best_disp_20   = 20;
wire [COST_BITS-1:0] leaf_second_cost_20 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_21   = cost21_in;
wire [DISP_BITS-1:0] leaf_best_disp_21   = 21;
wire [COST_BITS-1:0] leaf_second_cost_21 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_22   = cost22_in;
wire [DISP_BITS-1:0] leaf_best_disp_22   = 22;
wire [COST_BITS-1:0] leaf_second_cost_22 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_23   = cost23_in;
wire [DISP_BITS-1:0] leaf_best_disp_23   = 23;
wire [COST_BITS-1:0] leaf_second_cost_23 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_24   = cost24_in;
wire [DISP_BITS-1:0] leaf_best_disp_24   = 24;
wire [COST_BITS-1:0] leaf_second_cost_24 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_25   = cost25_in;
wire [DISP_BITS-1:0] leaf_best_disp_25   = 25;
wire [COST_BITS-1:0] leaf_second_cost_25 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_26   = cost26_in;
wire [DISP_BITS-1:0] leaf_best_disp_26   = 26;
wire [COST_BITS-1:0] leaf_second_cost_26 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_27   = cost27_in;
wire [DISP_BITS-1:0] leaf_best_disp_27   = 27;
wire [COST_BITS-1:0] leaf_second_cost_27 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_28   = cost28_in;
wire [DISP_BITS-1:0] leaf_best_disp_28   = 28;
wire [COST_BITS-1:0] leaf_second_cost_28 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_29   = cost29_in;
wire [DISP_BITS-1:0] leaf_best_disp_29   = 29;
wire [COST_BITS-1:0] leaf_second_cost_29 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_30   = cost30_in;
wire [DISP_BITS-1:0] leaf_best_disp_30   = 30;
wire [COST_BITS-1:0] leaf_second_cost_30 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_31   = cost31_in;
wire [DISP_BITS-1:0] leaf_best_disp_31   = 31;
wire [COST_BITS-1:0] leaf_second_cost_31 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_32   = cost32_in;
wire [DISP_BITS-1:0] leaf_best_disp_32   = 32;
wire [COST_BITS-1:0] leaf_second_cost_32 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_33   = cost33_in;
wire [DISP_BITS-1:0] leaf_best_disp_33   = 33;
wire [COST_BITS-1:0] leaf_second_cost_33 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_34   = cost34_in;
wire [DISP_BITS-1:0] leaf_best_disp_34   = 34;
wire [COST_BITS-1:0] leaf_second_cost_34 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_35   = cost35_in;
wire [DISP_BITS-1:0] leaf_best_disp_35   = 35;
wire [COST_BITS-1:0] leaf_second_cost_35 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_36   = cost36_in;
wire [DISP_BITS-1:0] leaf_best_disp_36   = 36;
wire [COST_BITS-1:0] leaf_second_cost_36 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_37   = cost37_in;
wire [DISP_BITS-1:0] leaf_best_disp_37   = 37;
wire [COST_BITS-1:0] leaf_second_cost_37 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_38   = cost38_in;
wire [DISP_BITS-1:0] leaf_best_disp_38   = 38;
wire [COST_BITS-1:0] leaf_second_cost_38 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_39   = cost39_in;
wire [DISP_BITS-1:0] leaf_best_disp_39   = 39;
wire [COST_BITS-1:0] leaf_second_cost_39 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_40   = cost40_in;
wire [DISP_BITS-1:0] leaf_best_disp_40   = 40;
wire [COST_BITS-1:0] leaf_second_cost_40 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_41   = cost41_in;
wire [DISP_BITS-1:0] leaf_best_disp_41   = 41;
wire [COST_BITS-1:0] leaf_second_cost_41 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_42   = cost42_in;
wire [DISP_BITS-1:0] leaf_best_disp_42   = 42;
wire [COST_BITS-1:0] leaf_second_cost_42 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_43   = cost43_in;
wire [DISP_BITS-1:0] leaf_best_disp_43   = 43;
wire [COST_BITS-1:0] leaf_second_cost_43 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_44   = cost44_in;
wire [DISP_BITS-1:0] leaf_best_disp_44   = 44;
wire [COST_BITS-1:0] leaf_second_cost_44 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_45   = cost45_in;
wire [DISP_BITS-1:0] leaf_best_disp_45   = 45;
wire [COST_BITS-1:0] leaf_second_cost_45 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_46   = cost46_in;
wire [DISP_BITS-1:0] leaf_best_disp_46   = 46;
wire [COST_BITS-1:0] leaf_second_cost_46 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_47   = cost47_in;
wire [DISP_BITS-1:0] leaf_best_disp_47   = 47;
wire [COST_BITS-1:0] leaf_second_cost_47 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_48   = cost48_in;
wire [DISP_BITS-1:0] leaf_best_disp_48   = 48;
wire [COST_BITS-1:0] leaf_second_cost_48 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_49   = cost49_in;
wire [DISP_BITS-1:0] leaf_best_disp_49   = 49;
wire [COST_BITS-1:0] leaf_second_cost_49 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_50   = cost50_in;
wire [DISP_BITS-1:0] leaf_best_disp_50   = 50;
wire [COST_BITS-1:0] leaf_second_cost_50 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_51   = cost51_in;
wire [DISP_BITS-1:0] leaf_best_disp_51   = 51;
wire [COST_BITS-1:0] leaf_second_cost_51 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_52   = cost52_in;
wire [DISP_BITS-1:0] leaf_best_disp_52   = 52;
wire [COST_BITS-1:0] leaf_second_cost_52 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_53   = cost53_in;
wire [DISP_BITS-1:0] leaf_best_disp_53   = 53;
wire [COST_BITS-1:0] leaf_second_cost_53 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_54   = cost54_in;
wire [DISP_BITS-1:0] leaf_best_disp_54   = 54;
wire [COST_BITS-1:0] leaf_second_cost_54 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_55   = cost55_in;
wire [DISP_BITS-1:0] leaf_best_disp_55   = 55;
wire [COST_BITS-1:0] leaf_second_cost_55 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_56   = cost56_in;
wire [DISP_BITS-1:0] leaf_best_disp_56   = 56;
wire [COST_BITS-1:0] leaf_second_cost_56 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_57   = cost57_in;
wire [DISP_BITS-1:0] leaf_best_disp_57   = 57;
wire [COST_BITS-1:0] leaf_second_cost_57 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_58   = cost58_in;
wire [DISP_BITS-1:0] leaf_best_disp_58   = 58;
wire [COST_BITS-1:0] leaf_second_cost_58 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_59   = cost59_in;
wire [DISP_BITS-1:0] leaf_best_disp_59   = 59;
wire [COST_BITS-1:0] leaf_second_cost_59 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_60   = cost60_in;
wire [DISP_BITS-1:0] leaf_best_disp_60   = 60;
wire [COST_BITS-1:0] leaf_second_cost_60 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_61   = cost61_in;
wire [DISP_BITS-1:0] leaf_best_disp_61   = 61;
wire [COST_BITS-1:0] leaf_second_cost_61 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_62   = cost62_in;
wire [DISP_BITS-1:0] leaf_best_disp_62   = 62;
wire [COST_BITS-1:0] leaf_second_cost_62 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_63   = cost63_in;
wire [DISP_BITS-1:0] leaf_best_disp_63   = 63;
wire [COST_BITS-1:0] leaf_second_cost_63 = COST_INF;
wire [COST_BITS-1:0] leaf_best_cost_64   = cost64_in;
wire [DISP_BITS-1:0] leaf_best_disp_64   = 64;
wire [COST_BITS-1:0] leaf_second_cost_64 = COST_INF;

wire [COST_BITS-1:0] s1_best_cost_w_0;
wire [DISP_BITS-1:0] s1_best_disp_w_0;
wire [COST_BITS-1:0] s1_second_cost_w_0;
wire [COST_BITS-1:0] s1_best_cost_w_1;
wire [DISP_BITS-1:0] s1_best_disp_w_1;
wire [COST_BITS-1:0] s1_second_cost_w_1;
wire [COST_BITS-1:0] s1_best_cost_w_2;
wire [DISP_BITS-1:0] s1_best_disp_w_2;
wire [COST_BITS-1:0] s1_second_cost_w_2;
wire [COST_BITS-1:0] s1_best_cost_w_3;
wire [DISP_BITS-1:0] s1_best_disp_w_3;
wire [COST_BITS-1:0] s1_second_cost_w_3;
wire [COST_BITS-1:0] s1_best_cost_w_4;
wire [DISP_BITS-1:0] s1_best_disp_w_4;
wire [COST_BITS-1:0] s1_second_cost_w_4;
wire [COST_BITS-1:0] s1_best_cost_w_5;
wire [DISP_BITS-1:0] s1_best_disp_w_5;
wire [COST_BITS-1:0] s1_second_cost_w_5;
wire [COST_BITS-1:0] s1_best_cost_w_6;
wire [DISP_BITS-1:0] s1_best_disp_w_6;
wire [COST_BITS-1:0] s1_second_cost_w_6;
wire [COST_BITS-1:0] s1_best_cost_w_7;
wire [DISP_BITS-1:0] s1_best_disp_w_7;
wire [COST_BITS-1:0] s1_second_cost_w_7;
wire [COST_BITS-1:0] s1_best_cost_w_8;
wire [DISP_BITS-1:0] s1_best_disp_w_8;
wire [COST_BITS-1:0] s1_second_cost_w_8;
wire [COST_BITS-1:0] s1_best_cost_w_9;
wire [DISP_BITS-1:0] s1_best_disp_w_9;
wire [COST_BITS-1:0] s1_second_cost_w_9;
wire [COST_BITS-1:0] s1_best_cost_w_10;
wire [DISP_BITS-1:0] s1_best_disp_w_10;
wire [COST_BITS-1:0] s1_second_cost_w_10;
wire [COST_BITS-1:0] s1_best_cost_w_11;
wire [DISP_BITS-1:0] s1_best_disp_w_11;
wire [COST_BITS-1:0] s1_second_cost_w_11;
wire [COST_BITS-1:0] s1_best_cost_w_12;
wire [DISP_BITS-1:0] s1_best_disp_w_12;
wire [COST_BITS-1:0] s1_second_cost_w_12;
wire [COST_BITS-1:0] s1_best_cost_w_13;
wire [DISP_BITS-1:0] s1_best_disp_w_13;
wire [COST_BITS-1:0] s1_second_cost_w_13;
wire [COST_BITS-1:0] s1_best_cost_w_14;
wire [DISP_BITS-1:0] s1_best_disp_w_14;
wire [COST_BITS-1:0] s1_second_cost_w_14;
wire [COST_BITS-1:0] s1_best_cost_w_15;
wire [DISP_BITS-1:0] s1_best_disp_w_15;
wire [COST_BITS-1:0] s1_second_cost_w_15;
wire [COST_BITS-1:0] s1_best_cost_w_16;
wire [DISP_BITS-1:0] s1_best_disp_w_16;
wire [COST_BITS-1:0] s1_second_cost_w_16;
wire [COST_BITS-1:0] s1_best_cost_w_17;
wire [DISP_BITS-1:0] s1_best_disp_w_17;
wire [COST_BITS-1:0] s1_second_cost_w_17;
wire [COST_BITS-1:0] s1_best_cost_w_18;
wire [DISP_BITS-1:0] s1_best_disp_w_18;
wire [COST_BITS-1:0] s1_second_cost_w_18;
wire [COST_BITS-1:0] s1_best_cost_w_19;
wire [DISP_BITS-1:0] s1_best_disp_w_19;
wire [COST_BITS-1:0] s1_second_cost_w_19;
wire [COST_BITS-1:0] s1_best_cost_w_20;
wire [DISP_BITS-1:0] s1_best_disp_w_20;
wire [COST_BITS-1:0] s1_second_cost_w_20;
wire [COST_BITS-1:0] s1_best_cost_w_21;
wire [DISP_BITS-1:0] s1_best_disp_w_21;
wire [COST_BITS-1:0] s1_second_cost_w_21;
wire [COST_BITS-1:0] s1_best_cost_w_22;
wire [DISP_BITS-1:0] s1_best_disp_w_22;
wire [COST_BITS-1:0] s1_second_cost_w_22;
wire [COST_BITS-1:0] s1_best_cost_w_23;
wire [DISP_BITS-1:0] s1_best_disp_w_23;
wire [COST_BITS-1:0] s1_second_cost_w_23;
wire [COST_BITS-1:0] s1_best_cost_w_24;
wire [DISP_BITS-1:0] s1_best_disp_w_24;
wire [COST_BITS-1:0] s1_second_cost_w_24;
wire [COST_BITS-1:0] s1_best_cost_w_25;
wire [DISP_BITS-1:0] s1_best_disp_w_25;
wire [COST_BITS-1:0] s1_second_cost_w_25;
wire [COST_BITS-1:0] s1_best_cost_w_26;
wire [DISP_BITS-1:0] s1_best_disp_w_26;
wire [COST_BITS-1:0] s1_second_cost_w_26;
wire [COST_BITS-1:0] s1_best_cost_w_27;
wire [DISP_BITS-1:0] s1_best_disp_w_27;
wire [COST_BITS-1:0] s1_second_cost_w_27;
wire [COST_BITS-1:0] s1_best_cost_w_28;
wire [DISP_BITS-1:0] s1_best_disp_w_28;
wire [COST_BITS-1:0] s1_second_cost_w_28;
wire [COST_BITS-1:0] s1_best_cost_w_29;
wire [DISP_BITS-1:0] s1_best_disp_w_29;
wire [COST_BITS-1:0] s1_second_cost_w_29;
wire [COST_BITS-1:0] s1_best_cost_w_30;
wire [DISP_BITS-1:0] s1_best_disp_w_30;
wire [COST_BITS-1:0] s1_second_cost_w_30;
wire [COST_BITS-1:0] s1_best_cost_w_31;
wire [DISP_BITS-1:0] s1_best_disp_w_31;
wire [COST_BITS-1:0] s1_second_cost_w_31;
wire [COST_BITS-1:0] s1_best_cost_w_32;
wire [DISP_BITS-1:0] s1_best_disp_w_32;
wire [COST_BITS-1:0] s1_second_cost_w_32;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m0 (
    .a_best_cost   (leaf_best_cost_0),
    .a_best_disp   (leaf_best_disp_0),
    .a_second_cost (leaf_second_cost_0),
    .b_best_cost   (leaf_best_cost_1),
    .b_best_disp   (leaf_best_disp_1),
    .b_second_cost (leaf_second_cost_1),
    .o_best_cost   (s1_best_cost_w_0),
    .o_best_disp   (s1_best_disp_w_0),
    .o_second_cost (s1_second_cost_w_0)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m1 (
    .a_best_cost   (leaf_best_cost_2),
    .a_best_disp   (leaf_best_disp_2),
    .a_second_cost (leaf_second_cost_2),
    .b_best_cost   (leaf_best_cost_3),
    .b_best_disp   (leaf_best_disp_3),
    .b_second_cost (leaf_second_cost_3),
    .o_best_cost   (s1_best_cost_w_1),
    .o_best_disp   (s1_best_disp_w_1),
    .o_second_cost (s1_second_cost_w_1)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m2 (
    .a_best_cost   (leaf_best_cost_4),
    .a_best_disp   (leaf_best_disp_4),
    .a_second_cost (leaf_second_cost_4),
    .b_best_cost   (leaf_best_cost_5),
    .b_best_disp   (leaf_best_disp_5),
    .b_second_cost (leaf_second_cost_5),
    .o_best_cost   (s1_best_cost_w_2),
    .o_best_disp   (s1_best_disp_w_2),
    .o_second_cost (s1_second_cost_w_2)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m3 (
    .a_best_cost   (leaf_best_cost_6),
    .a_best_disp   (leaf_best_disp_6),
    .a_second_cost (leaf_second_cost_6),
    .b_best_cost   (leaf_best_cost_7),
    .b_best_disp   (leaf_best_disp_7),
    .b_second_cost (leaf_second_cost_7),
    .o_best_cost   (s1_best_cost_w_3),
    .o_best_disp   (s1_best_disp_w_3),
    .o_second_cost (s1_second_cost_w_3)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m4 (
    .a_best_cost   (leaf_best_cost_8),
    .a_best_disp   (leaf_best_disp_8),
    .a_second_cost (leaf_second_cost_8),
    .b_best_cost   (leaf_best_cost_9),
    .b_best_disp   (leaf_best_disp_9),
    .b_second_cost (leaf_second_cost_9),
    .o_best_cost   (s1_best_cost_w_4),
    .o_best_disp   (s1_best_disp_w_4),
    .o_second_cost (s1_second_cost_w_4)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m5 (
    .a_best_cost   (leaf_best_cost_10),
    .a_best_disp   (leaf_best_disp_10),
    .a_second_cost (leaf_second_cost_10),
    .b_best_cost   (leaf_best_cost_11),
    .b_best_disp   (leaf_best_disp_11),
    .b_second_cost (leaf_second_cost_11),
    .o_best_cost   (s1_best_cost_w_5),
    .o_best_disp   (s1_best_disp_w_5),
    .o_second_cost (s1_second_cost_w_5)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m6 (
    .a_best_cost   (leaf_best_cost_12),
    .a_best_disp   (leaf_best_disp_12),
    .a_second_cost (leaf_second_cost_12),
    .b_best_cost   (leaf_best_cost_13),
    .b_best_disp   (leaf_best_disp_13),
    .b_second_cost (leaf_second_cost_13),
    .o_best_cost   (s1_best_cost_w_6),
    .o_best_disp   (s1_best_disp_w_6),
    .o_second_cost (s1_second_cost_w_6)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m7 (
    .a_best_cost   (leaf_best_cost_14),
    .a_best_disp   (leaf_best_disp_14),
    .a_second_cost (leaf_second_cost_14),
    .b_best_cost   (leaf_best_cost_15),
    .b_best_disp   (leaf_best_disp_15),
    .b_second_cost (leaf_second_cost_15),
    .o_best_cost   (s1_best_cost_w_7),
    .o_best_disp   (s1_best_disp_w_7),
    .o_second_cost (s1_second_cost_w_7)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m8 (
    .a_best_cost   (leaf_best_cost_16),
    .a_best_disp   (leaf_best_disp_16),
    .a_second_cost (leaf_second_cost_16),
    .b_best_cost   (leaf_best_cost_17),
    .b_best_disp   (leaf_best_disp_17),
    .b_second_cost (leaf_second_cost_17),
    .o_best_cost   (s1_best_cost_w_8),
    .o_best_disp   (s1_best_disp_w_8),
    .o_second_cost (s1_second_cost_w_8)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m9 (
    .a_best_cost   (leaf_best_cost_18),
    .a_best_disp   (leaf_best_disp_18),
    .a_second_cost (leaf_second_cost_18),
    .b_best_cost   (leaf_best_cost_19),
    .b_best_disp   (leaf_best_disp_19),
    .b_second_cost (leaf_second_cost_19),
    .o_best_cost   (s1_best_cost_w_9),
    .o_best_disp   (s1_best_disp_w_9),
    .o_second_cost (s1_second_cost_w_9)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m10 (
    .a_best_cost   (leaf_best_cost_20),
    .a_best_disp   (leaf_best_disp_20),
    .a_second_cost (leaf_second_cost_20),
    .b_best_cost   (leaf_best_cost_21),
    .b_best_disp   (leaf_best_disp_21),
    .b_second_cost (leaf_second_cost_21),
    .o_best_cost   (s1_best_cost_w_10),
    .o_best_disp   (s1_best_disp_w_10),
    .o_second_cost (s1_second_cost_w_10)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m11 (
    .a_best_cost   (leaf_best_cost_22),
    .a_best_disp   (leaf_best_disp_22),
    .a_second_cost (leaf_second_cost_22),
    .b_best_cost   (leaf_best_cost_23),
    .b_best_disp   (leaf_best_disp_23),
    .b_second_cost (leaf_second_cost_23),
    .o_best_cost   (s1_best_cost_w_11),
    .o_best_disp   (s1_best_disp_w_11),
    .o_second_cost (s1_second_cost_w_11)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m12 (
    .a_best_cost   (leaf_best_cost_24),
    .a_best_disp   (leaf_best_disp_24),
    .a_second_cost (leaf_second_cost_24),
    .b_best_cost   (leaf_best_cost_25),
    .b_best_disp   (leaf_best_disp_25),
    .b_second_cost (leaf_second_cost_25),
    .o_best_cost   (s1_best_cost_w_12),
    .o_best_disp   (s1_best_disp_w_12),
    .o_second_cost (s1_second_cost_w_12)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m13 (
    .a_best_cost   (leaf_best_cost_26),
    .a_best_disp   (leaf_best_disp_26),
    .a_second_cost (leaf_second_cost_26),
    .b_best_cost   (leaf_best_cost_27),
    .b_best_disp   (leaf_best_disp_27),
    .b_second_cost (leaf_second_cost_27),
    .o_best_cost   (s1_best_cost_w_13),
    .o_best_disp   (s1_best_disp_w_13),
    .o_second_cost (s1_second_cost_w_13)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m14 (
    .a_best_cost   (leaf_best_cost_28),
    .a_best_disp   (leaf_best_disp_28),
    .a_second_cost (leaf_second_cost_28),
    .b_best_cost   (leaf_best_cost_29),
    .b_best_disp   (leaf_best_disp_29),
    .b_second_cost (leaf_second_cost_29),
    .o_best_cost   (s1_best_cost_w_14),
    .o_best_disp   (s1_best_disp_w_14),
    .o_second_cost (s1_second_cost_w_14)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m15 (
    .a_best_cost   (leaf_best_cost_30),
    .a_best_disp   (leaf_best_disp_30),
    .a_second_cost (leaf_second_cost_30),
    .b_best_cost   (leaf_best_cost_31),
    .b_best_disp   (leaf_best_disp_31),
    .b_second_cost (leaf_second_cost_31),
    .o_best_cost   (s1_best_cost_w_15),
    .o_best_disp   (s1_best_disp_w_15),
    .o_second_cost (s1_second_cost_w_15)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m16 (
    .a_best_cost   (leaf_best_cost_32),
    .a_best_disp   (leaf_best_disp_32),
    .a_second_cost (leaf_second_cost_32),
    .b_best_cost   (leaf_best_cost_33),
    .b_best_disp   (leaf_best_disp_33),
    .b_second_cost (leaf_second_cost_33),
    .o_best_cost   (s1_best_cost_w_16),
    .o_best_disp   (s1_best_disp_w_16),
    .o_second_cost (s1_second_cost_w_16)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m17 (
    .a_best_cost   (leaf_best_cost_34),
    .a_best_disp   (leaf_best_disp_34),
    .a_second_cost (leaf_second_cost_34),
    .b_best_cost   (leaf_best_cost_35),
    .b_best_disp   (leaf_best_disp_35),
    .b_second_cost (leaf_second_cost_35),
    .o_best_cost   (s1_best_cost_w_17),
    .o_best_disp   (s1_best_disp_w_17),
    .o_second_cost (s1_second_cost_w_17)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m18 (
    .a_best_cost   (leaf_best_cost_36),
    .a_best_disp   (leaf_best_disp_36),
    .a_second_cost (leaf_second_cost_36),
    .b_best_cost   (leaf_best_cost_37),
    .b_best_disp   (leaf_best_disp_37),
    .b_second_cost (leaf_second_cost_37),
    .o_best_cost   (s1_best_cost_w_18),
    .o_best_disp   (s1_best_disp_w_18),
    .o_second_cost (s1_second_cost_w_18)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m19 (
    .a_best_cost   (leaf_best_cost_38),
    .a_best_disp   (leaf_best_disp_38),
    .a_second_cost (leaf_second_cost_38),
    .b_best_cost   (leaf_best_cost_39),
    .b_best_disp   (leaf_best_disp_39),
    .b_second_cost (leaf_second_cost_39),
    .o_best_cost   (s1_best_cost_w_19),
    .o_best_disp   (s1_best_disp_w_19),
    .o_second_cost (s1_second_cost_w_19)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m20 (
    .a_best_cost   (leaf_best_cost_40),
    .a_best_disp   (leaf_best_disp_40),
    .a_second_cost (leaf_second_cost_40),
    .b_best_cost   (leaf_best_cost_41),
    .b_best_disp   (leaf_best_disp_41),
    .b_second_cost (leaf_second_cost_41),
    .o_best_cost   (s1_best_cost_w_20),
    .o_best_disp   (s1_best_disp_w_20),
    .o_second_cost (s1_second_cost_w_20)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m21 (
    .a_best_cost   (leaf_best_cost_42),
    .a_best_disp   (leaf_best_disp_42),
    .a_second_cost (leaf_second_cost_42),
    .b_best_cost   (leaf_best_cost_43),
    .b_best_disp   (leaf_best_disp_43),
    .b_second_cost (leaf_second_cost_43),
    .o_best_cost   (s1_best_cost_w_21),
    .o_best_disp   (s1_best_disp_w_21),
    .o_second_cost (s1_second_cost_w_21)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m22 (
    .a_best_cost   (leaf_best_cost_44),
    .a_best_disp   (leaf_best_disp_44),
    .a_second_cost (leaf_second_cost_44),
    .b_best_cost   (leaf_best_cost_45),
    .b_best_disp   (leaf_best_disp_45),
    .b_second_cost (leaf_second_cost_45),
    .o_best_cost   (s1_best_cost_w_22),
    .o_best_disp   (s1_best_disp_w_22),
    .o_second_cost (s1_second_cost_w_22)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m23 (
    .a_best_cost   (leaf_best_cost_46),
    .a_best_disp   (leaf_best_disp_46),
    .a_second_cost (leaf_second_cost_46),
    .b_best_cost   (leaf_best_cost_47),
    .b_best_disp   (leaf_best_disp_47),
    .b_second_cost (leaf_second_cost_47),
    .o_best_cost   (s1_best_cost_w_23),
    .o_best_disp   (s1_best_disp_w_23),
    .o_second_cost (s1_second_cost_w_23)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m24 (
    .a_best_cost   (leaf_best_cost_48),
    .a_best_disp   (leaf_best_disp_48),
    .a_second_cost (leaf_second_cost_48),
    .b_best_cost   (leaf_best_cost_49),
    .b_best_disp   (leaf_best_disp_49),
    .b_second_cost (leaf_second_cost_49),
    .o_best_cost   (s1_best_cost_w_24),
    .o_best_disp   (s1_best_disp_w_24),
    .o_second_cost (s1_second_cost_w_24)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m25 (
    .a_best_cost   (leaf_best_cost_50),
    .a_best_disp   (leaf_best_disp_50),
    .a_second_cost (leaf_second_cost_50),
    .b_best_cost   (leaf_best_cost_51),
    .b_best_disp   (leaf_best_disp_51),
    .b_second_cost (leaf_second_cost_51),
    .o_best_cost   (s1_best_cost_w_25),
    .o_best_disp   (s1_best_disp_w_25),
    .o_second_cost (s1_second_cost_w_25)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m26 (
    .a_best_cost   (leaf_best_cost_52),
    .a_best_disp   (leaf_best_disp_52),
    .a_second_cost (leaf_second_cost_52),
    .b_best_cost   (leaf_best_cost_53),
    .b_best_disp   (leaf_best_disp_53),
    .b_second_cost (leaf_second_cost_53),
    .o_best_cost   (s1_best_cost_w_26),
    .o_best_disp   (s1_best_disp_w_26),
    .o_second_cost (s1_second_cost_w_26)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m27 (
    .a_best_cost   (leaf_best_cost_54),
    .a_best_disp   (leaf_best_disp_54),
    .a_second_cost (leaf_second_cost_54),
    .b_best_cost   (leaf_best_cost_55),
    .b_best_disp   (leaf_best_disp_55),
    .b_second_cost (leaf_second_cost_55),
    .o_best_cost   (s1_best_cost_w_27),
    .o_best_disp   (s1_best_disp_w_27),
    .o_second_cost (s1_second_cost_w_27)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m28 (
    .a_best_cost   (leaf_best_cost_56),
    .a_best_disp   (leaf_best_disp_56),
    .a_second_cost (leaf_second_cost_56),
    .b_best_cost   (leaf_best_cost_57),
    .b_best_disp   (leaf_best_disp_57),
    .b_second_cost (leaf_second_cost_57),
    .o_best_cost   (s1_best_cost_w_28),
    .o_best_disp   (s1_best_disp_w_28),
    .o_second_cost (s1_second_cost_w_28)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m29 (
    .a_best_cost   (leaf_best_cost_58),
    .a_best_disp   (leaf_best_disp_58),
    .a_second_cost (leaf_second_cost_58),
    .b_best_cost   (leaf_best_cost_59),
    .b_best_disp   (leaf_best_disp_59),
    .b_second_cost (leaf_second_cost_59),
    .o_best_cost   (s1_best_cost_w_29),
    .o_best_disp   (s1_best_disp_w_29),
    .o_second_cost (s1_second_cost_w_29)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m30 (
    .a_best_cost   (leaf_best_cost_60),
    .a_best_disp   (leaf_best_disp_60),
    .a_second_cost (leaf_second_cost_60),
    .b_best_cost   (leaf_best_cost_61),
    .b_best_disp   (leaf_best_disp_61),
    .b_second_cost (leaf_second_cost_61),
    .o_best_cost   (s1_best_cost_w_30),
    .o_best_disp   (s1_best_disp_w_30),
    .o_second_cost (s1_second_cost_w_30)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s1_m31 (
    .a_best_cost   (leaf_best_cost_62),
    .a_best_disp   (leaf_best_disp_62),
    .a_second_cost (leaf_second_cost_62),
    .b_best_cost   (leaf_best_cost_63),
    .b_best_disp   (leaf_best_disp_63),
    .b_second_cost (leaf_second_cost_63),
    .o_best_cost   (s1_best_cost_w_31),
    .o_best_disp   (s1_best_disp_w_31),
    .o_second_cost (s1_second_cost_w_31)
);
assign s1_best_cost_w_32   = leaf_best_cost_64;
assign s1_best_disp_w_32   = leaf_best_disp_64;
assign s1_second_cost_w_32 = leaf_second_cost_64;

reg [COST_BITS-1:0] s1_best_cost_r_0;
reg [DISP_BITS-1:0] s1_best_disp_r_0;
reg [COST_BITS-1:0] s1_second_cost_r_0;
reg [COST_BITS-1:0] s1_best_cost_r_1;
reg [DISP_BITS-1:0] s1_best_disp_r_1;
reg [COST_BITS-1:0] s1_second_cost_r_1;
reg [COST_BITS-1:0] s1_best_cost_r_2;
reg [DISP_BITS-1:0] s1_best_disp_r_2;
reg [COST_BITS-1:0] s1_second_cost_r_2;
reg [COST_BITS-1:0] s1_best_cost_r_3;
reg [DISP_BITS-1:0] s1_best_disp_r_3;
reg [COST_BITS-1:0] s1_second_cost_r_3;
reg [COST_BITS-1:0] s1_best_cost_r_4;
reg [DISP_BITS-1:0] s1_best_disp_r_4;
reg [COST_BITS-1:0] s1_second_cost_r_4;
reg [COST_BITS-1:0] s1_best_cost_r_5;
reg [DISP_BITS-1:0] s1_best_disp_r_5;
reg [COST_BITS-1:0] s1_second_cost_r_5;
reg [COST_BITS-1:0] s1_best_cost_r_6;
reg [DISP_BITS-1:0] s1_best_disp_r_6;
reg [COST_BITS-1:0] s1_second_cost_r_6;
reg [COST_BITS-1:0] s1_best_cost_r_7;
reg [DISP_BITS-1:0] s1_best_disp_r_7;
reg [COST_BITS-1:0] s1_second_cost_r_7;
reg [COST_BITS-1:0] s1_best_cost_r_8;
reg [DISP_BITS-1:0] s1_best_disp_r_8;
reg [COST_BITS-1:0] s1_second_cost_r_8;
reg [COST_BITS-1:0] s1_best_cost_r_9;
reg [DISP_BITS-1:0] s1_best_disp_r_9;
reg [COST_BITS-1:0] s1_second_cost_r_9;
reg [COST_BITS-1:0] s1_best_cost_r_10;
reg [DISP_BITS-1:0] s1_best_disp_r_10;
reg [COST_BITS-1:0] s1_second_cost_r_10;
reg [COST_BITS-1:0] s1_best_cost_r_11;
reg [DISP_BITS-1:0] s1_best_disp_r_11;
reg [COST_BITS-1:0] s1_second_cost_r_11;
reg [COST_BITS-1:0] s1_best_cost_r_12;
reg [DISP_BITS-1:0] s1_best_disp_r_12;
reg [COST_BITS-1:0] s1_second_cost_r_12;
reg [COST_BITS-1:0] s1_best_cost_r_13;
reg [DISP_BITS-1:0] s1_best_disp_r_13;
reg [COST_BITS-1:0] s1_second_cost_r_13;
reg [COST_BITS-1:0] s1_best_cost_r_14;
reg [DISP_BITS-1:0] s1_best_disp_r_14;
reg [COST_BITS-1:0] s1_second_cost_r_14;
reg [COST_BITS-1:0] s1_best_cost_r_15;
reg [DISP_BITS-1:0] s1_best_disp_r_15;
reg [COST_BITS-1:0] s1_second_cost_r_15;
reg [COST_BITS-1:0] s1_best_cost_r_16;
reg [DISP_BITS-1:0] s1_best_disp_r_16;
reg [COST_BITS-1:0] s1_second_cost_r_16;
reg [COST_BITS-1:0] s1_best_cost_r_17;
reg [DISP_BITS-1:0] s1_best_disp_r_17;
reg [COST_BITS-1:0] s1_second_cost_r_17;
reg [COST_BITS-1:0] s1_best_cost_r_18;
reg [DISP_BITS-1:0] s1_best_disp_r_18;
reg [COST_BITS-1:0] s1_second_cost_r_18;
reg [COST_BITS-1:0] s1_best_cost_r_19;
reg [DISP_BITS-1:0] s1_best_disp_r_19;
reg [COST_BITS-1:0] s1_second_cost_r_19;
reg [COST_BITS-1:0] s1_best_cost_r_20;
reg [DISP_BITS-1:0] s1_best_disp_r_20;
reg [COST_BITS-1:0] s1_second_cost_r_20;
reg [COST_BITS-1:0] s1_best_cost_r_21;
reg [DISP_BITS-1:0] s1_best_disp_r_21;
reg [COST_BITS-1:0] s1_second_cost_r_21;
reg [COST_BITS-1:0] s1_best_cost_r_22;
reg [DISP_BITS-1:0] s1_best_disp_r_22;
reg [COST_BITS-1:0] s1_second_cost_r_22;
reg [COST_BITS-1:0] s1_best_cost_r_23;
reg [DISP_BITS-1:0] s1_best_disp_r_23;
reg [COST_BITS-1:0] s1_second_cost_r_23;
reg [COST_BITS-1:0] s1_best_cost_r_24;
reg [DISP_BITS-1:0] s1_best_disp_r_24;
reg [COST_BITS-1:0] s1_second_cost_r_24;
reg [COST_BITS-1:0] s1_best_cost_r_25;
reg [DISP_BITS-1:0] s1_best_disp_r_25;
reg [COST_BITS-1:0] s1_second_cost_r_25;
reg [COST_BITS-1:0] s1_best_cost_r_26;
reg [DISP_BITS-1:0] s1_best_disp_r_26;
reg [COST_BITS-1:0] s1_second_cost_r_26;
reg [COST_BITS-1:0] s1_best_cost_r_27;
reg [DISP_BITS-1:0] s1_best_disp_r_27;
reg [COST_BITS-1:0] s1_second_cost_r_27;
reg [COST_BITS-1:0] s1_best_cost_r_28;
reg [DISP_BITS-1:0] s1_best_disp_r_28;
reg [COST_BITS-1:0] s1_second_cost_r_28;
reg [COST_BITS-1:0] s1_best_cost_r_29;
reg [DISP_BITS-1:0] s1_best_disp_r_29;
reg [COST_BITS-1:0] s1_second_cost_r_29;
reg [COST_BITS-1:0] s1_best_cost_r_30;
reg [DISP_BITS-1:0] s1_best_disp_r_30;
reg [COST_BITS-1:0] s1_second_cost_r_30;
reg [COST_BITS-1:0] s1_best_cost_r_31;
reg [DISP_BITS-1:0] s1_best_disp_r_31;
reg [COST_BITS-1:0] s1_second_cost_r_31;
reg [COST_BITS-1:0] s1_best_cost_r_32;
reg [DISP_BITS-1:0] s1_best_disp_r_32;
reg [COST_BITS-1:0] s1_second_cost_r_32;

wire [COST_BITS-1:0] s2_best_cost_w_0;
wire [DISP_BITS-1:0] s2_best_disp_w_0;
wire [COST_BITS-1:0] s2_second_cost_w_0;
wire [COST_BITS-1:0] s2_best_cost_w_1;
wire [DISP_BITS-1:0] s2_best_disp_w_1;
wire [COST_BITS-1:0] s2_second_cost_w_1;
wire [COST_BITS-1:0] s2_best_cost_w_2;
wire [DISP_BITS-1:0] s2_best_disp_w_2;
wire [COST_BITS-1:0] s2_second_cost_w_2;
wire [COST_BITS-1:0] s2_best_cost_w_3;
wire [DISP_BITS-1:0] s2_best_disp_w_3;
wire [COST_BITS-1:0] s2_second_cost_w_3;
wire [COST_BITS-1:0] s2_best_cost_w_4;
wire [DISP_BITS-1:0] s2_best_disp_w_4;
wire [COST_BITS-1:0] s2_second_cost_w_4;
wire [COST_BITS-1:0] s2_best_cost_w_5;
wire [DISP_BITS-1:0] s2_best_disp_w_5;
wire [COST_BITS-1:0] s2_second_cost_w_5;
wire [COST_BITS-1:0] s2_best_cost_w_6;
wire [DISP_BITS-1:0] s2_best_disp_w_6;
wire [COST_BITS-1:0] s2_second_cost_w_6;
wire [COST_BITS-1:0] s2_best_cost_w_7;
wire [DISP_BITS-1:0] s2_best_disp_w_7;
wire [COST_BITS-1:0] s2_second_cost_w_7;
wire [COST_BITS-1:0] s2_best_cost_w_8;
wire [DISP_BITS-1:0] s2_best_disp_w_8;
wire [COST_BITS-1:0] s2_second_cost_w_8;
wire [COST_BITS-1:0] s2_best_cost_w_9;
wire [DISP_BITS-1:0] s2_best_disp_w_9;
wire [COST_BITS-1:0] s2_second_cost_w_9;
wire [COST_BITS-1:0] s2_best_cost_w_10;
wire [DISP_BITS-1:0] s2_best_disp_w_10;
wire [COST_BITS-1:0] s2_second_cost_w_10;
wire [COST_BITS-1:0] s2_best_cost_w_11;
wire [DISP_BITS-1:0] s2_best_disp_w_11;
wire [COST_BITS-1:0] s2_second_cost_w_11;
wire [COST_BITS-1:0] s2_best_cost_w_12;
wire [DISP_BITS-1:0] s2_best_disp_w_12;
wire [COST_BITS-1:0] s2_second_cost_w_12;
wire [COST_BITS-1:0] s2_best_cost_w_13;
wire [DISP_BITS-1:0] s2_best_disp_w_13;
wire [COST_BITS-1:0] s2_second_cost_w_13;
wire [COST_BITS-1:0] s2_best_cost_w_14;
wire [DISP_BITS-1:0] s2_best_disp_w_14;
wire [COST_BITS-1:0] s2_second_cost_w_14;
wire [COST_BITS-1:0] s2_best_cost_w_15;
wire [DISP_BITS-1:0] s2_best_disp_w_15;
wire [COST_BITS-1:0] s2_second_cost_w_15;
wire [COST_BITS-1:0] s2_best_cost_w_16;
wire [DISP_BITS-1:0] s2_best_disp_w_16;
wire [COST_BITS-1:0] s2_second_cost_w_16;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m0 (
    .a_best_cost   (s1_best_cost_r_0),
    .a_best_disp   (s1_best_disp_r_0),
    .a_second_cost (s1_second_cost_r_0),
    .b_best_cost   (s1_best_cost_r_1),
    .b_best_disp   (s1_best_disp_r_1),
    .b_second_cost (s1_second_cost_r_1),
    .o_best_cost   (s2_best_cost_w_0),
    .o_best_disp   (s2_best_disp_w_0),
    .o_second_cost (s2_second_cost_w_0)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m1 (
    .a_best_cost   (s1_best_cost_r_2),
    .a_best_disp   (s1_best_disp_r_2),
    .a_second_cost (s1_second_cost_r_2),
    .b_best_cost   (s1_best_cost_r_3),
    .b_best_disp   (s1_best_disp_r_3),
    .b_second_cost (s1_second_cost_r_3),
    .o_best_cost   (s2_best_cost_w_1),
    .o_best_disp   (s2_best_disp_w_1),
    .o_second_cost (s2_second_cost_w_1)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m2 (
    .a_best_cost   (s1_best_cost_r_4),
    .a_best_disp   (s1_best_disp_r_4),
    .a_second_cost (s1_second_cost_r_4),
    .b_best_cost   (s1_best_cost_r_5),
    .b_best_disp   (s1_best_disp_r_5),
    .b_second_cost (s1_second_cost_r_5),
    .o_best_cost   (s2_best_cost_w_2),
    .o_best_disp   (s2_best_disp_w_2),
    .o_second_cost (s2_second_cost_w_2)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m3 (
    .a_best_cost   (s1_best_cost_r_6),
    .a_best_disp   (s1_best_disp_r_6),
    .a_second_cost (s1_second_cost_r_6),
    .b_best_cost   (s1_best_cost_r_7),
    .b_best_disp   (s1_best_disp_r_7),
    .b_second_cost (s1_second_cost_r_7),
    .o_best_cost   (s2_best_cost_w_3),
    .o_best_disp   (s2_best_disp_w_3),
    .o_second_cost (s2_second_cost_w_3)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m4 (
    .a_best_cost   (s1_best_cost_r_8),
    .a_best_disp   (s1_best_disp_r_8),
    .a_second_cost (s1_second_cost_r_8),
    .b_best_cost   (s1_best_cost_r_9),
    .b_best_disp   (s1_best_disp_r_9),
    .b_second_cost (s1_second_cost_r_9),
    .o_best_cost   (s2_best_cost_w_4),
    .o_best_disp   (s2_best_disp_w_4),
    .o_second_cost (s2_second_cost_w_4)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m5 (
    .a_best_cost   (s1_best_cost_r_10),
    .a_best_disp   (s1_best_disp_r_10),
    .a_second_cost (s1_second_cost_r_10),
    .b_best_cost   (s1_best_cost_r_11),
    .b_best_disp   (s1_best_disp_r_11),
    .b_second_cost (s1_second_cost_r_11),
    .o_best_cost   (s2_best_cost_w_5),
    .o_best_disp   (s2_best_disp_w_5),
    .o_second_cost (s2_second_cost_w_5)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m6 (
    .a_best_cost   (s1_best_cost_r_12),
    .a_best_disp   (s1_best_disp_r_12),
    .a_second_cost (s1_second_cost_r_12),
    .b_best_cost   (s1_best_cost_r_13),
    .b_best_disp   (s1_best_disp_r_13),
    .b_second_cost (s1_second_cost_r_13),
    .o_best_cost   (s2_best_cost_w_6),
    .o_best_disp   (s2_best_disp_w_6),
    .o_second_cost (s2_second_cost_w_6)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m7 (
    .a_best_cost   (s1_best_cost_r_14),
    .a_best_disp   (s1_best_disp_r_14),
    .a_second_cost (s1_second_cost_r_14),
    .b_best_cost   (s1_best_cost_r_15),
    .b_best_disp   (s1_best_disp_r_15),
    .b_second_cost (s1_second_cost_r_15),
    .o_best_cost   (s2_best_cost_w_7),
    .o_best_disp   (s2_best_disp_w_7),
    .o_second_cost (s2_second_cost_w_7)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m8 (
    .a_best_cost   (s1_best_cost_r_16),
    .a_best_disp   (s1_best_disp_r_16),
    .a_second_cost (s1_second_cost_r_16),
    .b_best_cost   (s1_best_cost_r_17),
    .b_best_disp   (s1_best_disp_r_17),
    .b_second_cost (s1_second_cost_r_17),
    .o_best_cost   (s2_best_cost_w_8),
    .o_best_disp   (s2_best_disp_w_8),
    .o_second_cost (s2_second_cost_w_8)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m9 (
    .a_best_cost   (s1_best_cost_r_18),
    .a_best_disp   (s1_best_disp_r_18),
    .a_second_cost (s1_second_cost_r_18),
    .b_best_cost   (s1_best_cost_r_19),
    .b_best_disp   (s1_best_disp_r_19),
    .b_second_cost (s1_second_cost_r_19),
    .o_best_cost   (s2_best_cost_w_9),
    .o_best_disp   (s2_best_disp_w_9),
    .o_second_cost (s2_second_cost_w_9)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m10 (
    .a_best_cost   (s1_best_cost_r_20),
    .a_best_disp   (s1_best_disp_r_20),
    .a_second_cost (s1_second_cost_r_20),
    .b_best_cost   (s1_best_cost_r_21),
    .b_best_disp   (s1_best_disp_r_21),
    .b_second_cost (s1_second_cost_r_21),
    .o_best_cost   (s2_best_cost_w_10),
    .o_best_disp   (s2_best_disp_w_10),
    .o_second_cost (s2_second_cost_w_10)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m11 (
    .a_best_cost   (s1_best_cost_r_22),
    .a_best_disp   (s1_best_disp_r_22),
    .a_second_cost (s1_second_cost_r_22),
    .b_best_cost   (s1_best_cost_r_23),
    .b_best_disp   (s1_best_disp_r_23),
    .b_second_cost (s1_second_cost_r_23),
    .o_best_cost   (s2_best_cost_w_11),
    .o_best_disp   (s2_best_disp_w_11),
    .o_second_cost (s2_second_cost_w_11)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m12 (
    .a_best_cost   (s1_best_cost_r_24),
    .a_best_disp   (s1_best_disp_r_24),
    .a_second_cost (s1_second_cost_r_24),
    .b_best_cost   (s1_best_cost_r_25),
    .b_best_disp   (s1_best_disp_r_25),
    .b_second_cost (s1_second_cost_r_25),
    .o_best_cost   (s2_best_cost_w_12),
    .o_best_disp   (s2_best_disp_w_12),
    .o_second_cost (s2_second_cost_w_12)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m13 (
    .a_best_cost   (s1_best_cost_r_26),
    .a_best_disp   (s1_best_disp_r_26),
    .a_second_cost (s1_second_cost_r_26),
    .b_best_cost   (s1_best_cost_r_27),
    .b_best_disp   (s1_best_disp_r_27),
    .b_second_cost (s1_second_cost_r_27),
    .o_best_cost   (s2_best_cost_w_13),
    .o_best_disp   (s2_best_disp_w_13),
    .o_second_cost (s2_second_cost_w_13)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m14 (
    .a_best_cost   (s1_best_cost_r_28),
    .a_best_disp   (s1_best_disp_r_28),
    .a_second_cost (s1_second_cost_r_28),
    .b_best_cost   (s1_best_cost_r_29),
    .b_best_disp   (s1_best_disp_r_29),
    .b_second_cost (s1_second_cost_r_29),
    .o_best_cost   (s2_best_cost_w_14),
    .o_best_disp   (s2_best_disp_w_14),
    .o_second_cost (s2_second_cost_w_14)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s2_m15 (
    .a_best_cost   (s1_best_cost_r_30),
    .a_best_disp   (s1_best_disp_r_30),
    .a_second_cost (s1_second_cost_r_30),
    .b_best_cost   (s1_best_cost_r_31),
    .b_best_disp   (s1_best_disp_r_31),
    .b_second_cost (s1_second_cost_r_31),
    .o_best_cost   (s2_best_cost_w_15),
    .o_best_disp   (s2_best_disp_w_15),
    .o_second_cost (s2_second_cost_w_15)
);
assign s2_best_cost_w_16   = s1_best_cost_r_32;
assign s2_best_disp_w_16   = s1_best_disp_r_32;
assign s2_second_cost_w_16 = s1_second_cost_r_32;

reg [COST_BITS-1:0] s2_best_cost_r_0;
reg [DISP_BITS-1:0] s2_best_disp_r_0;
reg [COST_BITS-1:0] s2_second_cost_r_0;
reg [COST_BITS-1:0] s2_best_cost_r_1;
reg [DISP_BITS-1:0] s2_best_disp_r_1;
reg [COST_BITS-1:0] s2_second_cost_r_1;
reg [COST_BITS-1:0] s2_best_cost_r_2;
reg [DISP_BITS-1:0] s2_best_disp_r_2;
reg [COST_BITS-1:0] s2_second_cost_r_2;
reg [COST_BITS-1:0] s2_best_cost_r_3;
reg [DISP_BITS-1:0] s2_best_disp_r_3;
reg [COST_BITS-1:0] s2_second_cost_r_3;
reg [COST_BITS-1:0] s2_best_cost_r_4;
reg [DISP_BITS-1:0] s2_best_disp_r_4;
reg [COST_BITS-1:0] s2_second_cost_r_4;
reg [COST_BITS-1:0] s2_best_cost_r_5;
reg [DISP_BITS-1:0] s2_best_disp_r_5;
reg [COST_BITS-1:0] s2_second_cost_r_5;
reg [COST_BITS-1:0] s2_best_cost_r_6;
reg [DISP_BITS-1:0] s2_best_disp_r_6;
reg [COST_BITS-1:0] s2_second_cost_r_6;
reg [COST_BITS-1:0] s2_best_cost_r_7;
reg [DISP_BITS-1:0] s2_best_disp_r_7;
reg [COST_BITS-1:0] s2_second_cost_r_7;
reg [COST_BITS-1:0] s2_best_cost_r_8;
reg [DISP_BITS-1:0] s2_best_disp_r_8;
reg [COST_BITS-1:0] s2_second_cost_r_8;
reg [COST_BITS-1:0] s2_best_cost_r_9;
reg [DISP_BITS-1:0] s2_best_disp_r_9;
reg [COST_BITS-1:0] s2_second_cost_r_9;
reg [COST_BITS-1:0] s2_best_cost_r_10;
reg [DISP_BITS-1:0] s2_best_disp_r_10;
reg [COST_BITS-1:0] s2_second_cost_r_10;
reg [COST_BITS-1:0] s2_best_cost_r_11;
reg [DISP_BITS-1:0] s2_best_disp_r_11;
reg [COST_BITS-1:0] s2_second_cost_r_11;
reg [COST_BITS-1:0] s2_best_cost_r_12;
reg [DISP_BITS-1:0] s2_best_disp_r_12;
reg [COST_BITS-1:0] s2_second_cost_r_12;
reg [COST_BITS-1:0] s2_best_cost_r_13;
reg [DISP_BITS-1:0] s2_best_disp_r_13;
reg [COST_BITS-1:0] s2_second_cost_r_13;
reg [COST_BITS-1:0] s2_best_cost_r_14;
reg [DISP_BITS-1:0] s2_best_disp_r_14;
reg [COST_BITS-1:0] s2_second_cost_r_14;
reg [COST_BITS-1:0] s2_best_cost_r_15;
reg [DISP_BITS-1:0] s2_best_disp_r_15;
reg [COST_BITS-1:0] s2_second_cost_r_15;
reg [COST_BITS-1:0] s2_best_cost_r_16;
reg [DISP_BITS-1:0] s2_best_disp_r_16;
reg [COST_BITS-1:0] s2_second_cost_r_16;

wire [COST_BITS-1:0] s3_best_cost_w_0;
wire [DISP_BITS-1:0] s3_best_disp_w_0;
wire [COST_BITS-1:0] s3_second_cost_w_0;
wire [COST_BITS-1:0] s3_best_cost_w_1;
wire [DISP_BITS-1:0] s3_best_disp_w_1;
wire [COST_BITS-1:0] s3_second_cost_w_1;
wire [COST_BITS-1:0] s3_best_cost_w_2;
wire [DISP_BITS-1:0] s3_best_disp_w_2;
wire [COST_BITS-1:0] s3_second_cost_w_2;
wire [COST_BITS-1:0] s3_best_cost_w_3;
wire [DISP_BITS-1:0] s3_best_disp_w_3;
wire [COST_BITS-1:0] s3_second_cost_w_3;
wire [COST_BITS-1:0] s3_best_cost_w_4;
wire [DISP_BITS-1:0] s3_best_disp_w_4;
wire [COST_BITS-1:0] s3_second_cost_w_4;
wire [COST_BITS-1:0] s3_best_cost_w_5;
wire [DISP_BITS-1:0] s3_best_disp_w_5;
wire [COST_BITS-1:0] s3_second_cost_w_5;
wire [COST_BITS-1:0] s3_best_cost_w_6;
wire [DISP_BITS-1:0] s3_best_disp_w_6;
wire [COST_BITS-1:0] s3_second_cost_w_6;
wire [COST_BITS-1:0] s3_best_cost_w_7;
wire [DISP_BITS-1:0] s3_best_disp_w_7;
wire [COST_BITS-1:0] s3_second_cost_w_7;
wire [COST_BITS-1:0] s3_best_cost_w_8;
wire [DISP_BITS-1:0] s3_best_disp_w_8;
wire [COST_BITS-1:0] s3_second_cost_w_8;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m0 (
    .a_best_cost   (s2_best_cost_r_0),
    .a_best_disp   (s2_best_disp_r_0),
    .a_second_cost (s2_second_cost_r_0),
    .b_best_cost   (s2_best_cost_r_1),
    .b_best_disp   (s2_best_disp_r_1),
    .b_second_cost (s2_second_cost_r_1),
    .o_best_cost   (s3_best_cost_w_0),
    .o_best_disp   (s3_best_disp_w_0),
    .o_second_cost (s3_second_cost_w_0)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m1 (
    .a_best_cost   (s2_best_cost_r_2),
    .a_best_disp   (s2_best_disp_r_2),
    .a_second_cost (s2_second_cost_r_2),
    .b_best_cost   (s2_best_cost_r_3),
    .b_best_disp   (s2_best_disp_r_3),
    .b_second_cost (s2_second_cost_r_3),
    .o_best_cost   (s3_best_cost_w_1),
    .o_best_disp   (s3_best_disp_w_1),
    .o_second_cost (s3_second_cost_w_1)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m2 (
    .a_best_cost   (s2_best_cost_r_4),
    .a_best_disp   (s2_best_disp_r_4),
    .a_second_cost (s2_second_cost_r_4),
    .b_best_cost   (s2_best_cost_r_5),
    .b_best_disp   (s2_best_disp_r_5),
    .b_second_cost (s2_second_cost_r_5),
    .o_best_cost   (s3_best_cost_w_2),
    .o_best_disp   (s3_best_disp_w_2),
    .o_second_cost (s3_second_cost_w_2)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m3 (
    .a_best_cost   (s2_best_cost_r_6),
    .a_best_disp   (s2_best_disp_r_6),
    .a_second_cost (s2_second_cost_r_6),
    .b_best_cost   (s2_best_cost_r_7),
    .b_best_disp   (s2_best_disp_r_7),
    .b_second_cost (s2_second_cost_r_7),
    .o_best_cost   (s3_best_cost_w_3),
    .o_best_disp   (s3_best_disp_w_3),
    .o_second_cost (s3_second_cost_w_3)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m4 (
    .a_best_cost   (s2_best_cost_r_8),
    .a_best_disp   (s2_best_disp_r_8),
    .a_second_cost (s2_second_cost_r_8),
    .b_best_cost   (s2_best_cost_r_9),
    .b_best_disp   (s2_best_disp_r_9),
    .b_second_cost (s2_second_cost_r_9),
    .o_best_cost   (s3_best_cost_w_4),
    .o_best_disp   (s3_best_disp_w_4),
    .o_second_cost (s3_second_cost_w_4)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m5 (
    .a_best_cost   (s2_best_cost_r_10),
    .a_best_disp   (s2_best_disp_r_10),
    .a_second_cost (s2_second_cost_r_10),
    .b_best_cost   (s2_best_cost_r_11),
    .b_best_disp   (s2_best_disp_r_11),
    .b_second_cost (s2_second_cost_r_11),
    .o_best_cost   (s3_best_cost_w_5),
    .o_best_disp   (s3_best_disp_w_5),
    .o_second_cost (s3_second_cost_w_5)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m6 (
    .a_best_cost   (s2_best_cost_r_12),
    .a_best_disp   (s2_best_disp_r_12),
    .a_second_cost (s2_second_cost_r_12),
    .b_best_cost   (s2_best_cost_r_13),
    .b_best_disp   (s2_best_disp_r_13),
    .b_second_cost (s2_second_cost_r_13),
    .o_best_cost   (s3_best_cost_w_6),
    .o_best_disp   (s3_best_disp_w_6),
    .o_second_cost (s3_second_cost_w_6)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s3_m7 (
    .a_best_cost   (s2_best_cost_r_14),
    .a_best_disp   (s2_best_disp_r_14),
    .a_second_cost (s2_second_cost_r_14),
    .b_best_cost   (s2_best_cost_r_15),
    .b_best_disp   (s2_best_disp_r_15),
    .b_second_cost (s2_second_cost_r_15),
    .o_best_cost   (s3_best_cost_w_7),
    .o_best_disp   (s3_best_disp_w_7),
    .o_second_cost (s3_second_cost_w_7)
);
assign s3_best_cost_w_8   = s2_best_cost_r_16;
assign s3_best_disp_w_8   = s2_best_disp_r_16;
assign s3_second_cost_w_8 = s2_second_cost_r_16;

reg [COST_BITS-1:0] s3_best_cost_r_0;
reg [DISP_BITS-1:0] s3_best_disp_r_0;
reg [COST_BITS-1:0] s3_second_cost_r_0;
reg [COST_BITS-1:0] s3_best_cost_r_1;
reg [DISP_BITS-1:0] s3_best_disp_r_1;
reg [COST_BITS-1:0] s3_second_cost_r_1;
reg [COST_BITS-1:0] s3_best_cost_r_2;
reg [DISP_BITS-1:0] s3_best_disp_r_2;
reg [COST_BITS-1:0] s3_second_cost_r_2;
reg [COST_BITS-1:0] s3_best_cost_r_3;
reg [DISP_BITS-1:0] s3_best_disp_r_3;
reg [COST_BITS-1:0] s3_second_cost_r_3;
reg [COST_BITS-1:0] s3_best_cost_r_4;
reg [DISP_BITS-1:0] s3_best_disp_r_4;
reg [COST_BITS-1:0] s3_second_cost_r_4;
reg [COST_BITS-1:0] s3_best_cost_r_5;
reg [DISP_BITS-1:0] s3_best_disp_r_5;
reg [COST_BITS-1:0] s3_second_cost_r_5;
reg [COST_BITS-1:0] s3_best_cost_r_6;
reg [DISP_BITS-1:0] s3_best_disp_r_6;
reg [COST_BITS-1:0] s3_second_cost_r_6;
reg [COST_BITS-1:0] s3_best_cost_r_7;
reg [DISP_BITS-1:0] s3_best_disp_r_7;
reg [COST_BITS-1:0] s3_second_cost_r_7;
reg [COST_BITS-1:0] s3_best_cost_r_8;
reg [DISP_BITS-1:0] s3_best_disp_r_8;
reg [COST_BITS-1:0] s3_second_cost_r_8;

wire [COST_BITS-1:0] s4_best_cost_w_0;
wire [DISP_BITS-1:0] s4_best_disp_w_0;
wire [COST_BITS-1:0] s4_second_cost_w_0;
wire [COST_BITS-1:0] s4_best_cost_w_1;
wire [DISP_BITS-1:0] s4_best_disp_w_1;
wire [COST_BITS-1:0] s4_second_cost_w_1;
wire [COST_BITS-1:0] s4_best_cost_w_2;
wire [DISP_BITS-1:0] s4_best_disp_w_2;
wire [COST_BITS-1:0] s4_second_cost_w_2;
wire [COST_BITS-1:0] s4_best_cost_w_3;
wire [DISP_BITS-1:0] s4_best_disp_w_3;
wire [COST_BITS-1:0] s4_second_cost_w_3;
wire [COST_BITS-1:0] s4_best_cost_w_4;
wire [DISP_BITS-1:0] s4_best_disp_w_4;
wire [COST_BITS-1:0] s4_second_cost_w_4;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s4_m0 (
    .a_best_cost   (s3_best_cost_r_0),
    .a_best_disp   (s3_best_disp_r_0),
    .a_second_cost (s3_second_cost_r_0),
    .b_best_cost   (s3_best_cost_r_1),
    .b_best_disp   (s3_best_disp_r_1),
    .b_second_cost (s3_second_cost_r_1),
    .o_best_cost   (s4_best_cost_w_0),
    .o_best_disp   (s4_best_disp_w_0),
    .o_second_cost (s4_second_cost_w_0)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s4_m1 (
    .a_best_cost   (s3_best_cost_r_2),
    .a_best_disp   (s3_best_disp_r_2),
    .a_second_cost (s3_second_cost_r_2),
    .b_best_cost   (s3_best_cost_r_3),
    .b_best_disp   (s3_best_disp_r_3),
    .b_second_cost (s3_second_cost_r_3),
    .o_best_cost   (s4_best_cost_w_1),
    .o_best_disp   (s4_best_disp_w_1),
    .o_second_cost (s4_second_cost_w_1)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s4_m2 (
    .a_best_cost   (s3_best_cost_r_4),
    .a_best_disp   (s3_best_disp_r_4),
    .a_second_cost (s3_second_cost_r_4),
    .b_best_cost   (s3_best_cost_r_5),
    .b_best_disp   (s3_best_disp_r_5),
    .b_second_cost (s3_second_cost_r_5),
    .o_best_cost   (s4_best_cost_w_2),
    .o_best_disp   (s4_best_disp_w_2),
    .o_second_cost (s4_second_cost_w_2)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s4_m3 (
    .a_best_cost   (s3_best_cost_r_6),
    .a_best_disp   (s3_best_disp_r_6),
    .a_second_cost (s3_second_cost_r_6),
    .b_best_cost   (s3_best_cost_r_7),
    .b_best_disp   (s3_best_disp_r_7),
    .b_second_cost (s3_second_cost_r_7),
    .o_best_cost   (s4_best_cost_w_3),
    .o_best_disp   (s4_best_disp_w_3),
    .o_second_cost (s4_second_cost_w_3)
);
assign s4_best_cost_w_4   = s3_best_cost_r_8;
assign s4_best_disp_w_4   = s3_best_disp_r_8;
assign s4_second_cost_w_4 = s3_second_cost_r_8;

reg [COST_BITS-1:0] s4_best_cost_r_0;
reg [DISP_BITS-1:0] s4_best_disp_r_0;
reg [COST_BITS-1:0] s4_second_cost_r_0;
reg [COST_BITS-1:0] s4_best_cost_r_1;
reg [DISP_BITS-1:0] s4_best_disp_r_1;
reg [COST_BITS-1:0] s4_second_cost_r_1;
reg [COST_BITS-1:0] s4_best_cost_r_2;
reg [DISP_BITS-1:0] s4_best_disp_r_2;
reg [COST_BITS-1:0] s4_second_cost_r_2;
reg [COST_BITS-1:0] s4_best_cost_r_3;
reg [DISP_BITS-1:0] s4_best_disp_r_3;
reg [COST_BITS-1:0] s4_second_cost_r_3;
reg [COST_BITS-1:0] s4_best_cost_r_4;
reg [DISP_BITS-1:0] s4_best_disp_r_4;
reg [COST_BITS-1:0] s4_second_cost_r_4;

wire [COST_BITS-1:0] s5_best_cost_w_0;
wire [DISP_BITS-1:0] s5_best_disp_w_0;
wire [COST_BITS-1:0] s5_second_cost_w_0;
wire [COST_BITS-1:0] s5_best_cost_w_1;
wire [DISP_BITS-1:0] s5_best_disp_w_1;
wire [COST_BITS-1:0] s5_second_cost_w_1;
wire [COST_BITS-1:0] s5_best_cost_w_2;
wire [DISP_BITS-1:0] s5_best_disp_w_2;
wire [COST_BITS-1:0] s5_second_cost_w_2;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s5_m0 (
    .a_best_cost   (s4_best_cost_r_0),
    .a_best_disp   (s4_best_disp_r_0),
    .a_second_cost (s4_second_cost_r_0),
    .b_best_cost   (s4_best_cost_r_1),
    .b_best_disp   (s4_best_disp_r_1),
    .b_second_cost (s4_second_cost_r_1),
    .o_best_cost   (s5_best_cost_w_0),
    .o_best_disp   (s5_best_disp_w_0),
    .o_second_cost (s5_second_cost_w_0)
);
wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s5_m1 (
    .a_best_cost   (s4_best_cost_r_2),
    .a_best_disp   (s4_best_disp_r_2),
    .a_second_cost (s4_second_cost_r_2),
    .b_best_cost   (s4_best_cost_r_3),
    .b_best_disp   (s4_best_disp_r_3),
    .b_second_cost (s4_second_cost_r_3),
    .o_best_cost   (s5_best_cost_w_1),
    .o_best_disp   (s5_best_disp_w_1),
    .o_second_cost (s5_second_cost_w_1)
);
assign s5_best_cost_w_2   = s4_best_cost_r_4;
assign s5_best_disp_w_2   = s4_best_disp_r_4;
assign s5_second_cost_w_2 = s4_second_cost_r_4;

reg [COST_BITS-1:0] s5_best_cost_r_0;
reg [DISP_BITS-1:0] s5_best_disp_r_0;
reg [COST_BITS-1:0] s5_second_cost_r_0;
reg [COST_BITS-1:0] s5_best_cost_r_1;
reg [DISP_BITS-1:0] s5_best_disp_r_1;
reg [COST_BITS-1:0] s5_second_cost_r_1;
reg [COST_BITS-1:0] s5_best_cost_r_2;
reg [DISP_BITS-1:0] s5_best_disp_r_2;
reg [COST_BITS-1:0] s5_second_cost_r_2;

wire [COST_BITS-1:0] s6_best_cost_w_0;
wire [DISP_BITS-1:0] s6_best_disp_w_0;
wire [COST_BITS-1:0] s6_second_cost_w_0;
wire [COST_BITS-1:0] s6_best_cost_w_1;
wire [DISP_BITS-1:0] s6_best_disp_w_1;
wire [COST_BITS-1:0] s6_second_cost_w_1;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s6_m0 (
    .a_best_cost   (s5_best_cost_r_0),
    .a_best_disp   (s5_best_disp_r_0),
    .a_second_cost (s5_second_cost_r_0),
    .b_best_cost   (s5_best_cost_r_1),
    .b_best_disp   (s5_best_disp_r_1),
    .b_second_cost (s5_second_cost_r_1),
    .o_best_cost   (s6_best_cost_w_0),
    .o_best_disp   (s6_best_disp_w_0),
    .o_second_cost (s6_second_cost_w_0)
);
assign s6_best_cost_w_1   = s5_best_cost_r_2;
assign s6_best_disp_w_1   = s5_best_disp_r_2;
assign s6_second_cost_w_1 = s5_second_cost_r_2;

reg [COST_BITS-1:0] s6_best_cost_r_0;
reg [DISP_BITS-1:0] s6_best_disp_r_0;
reg [COST_BITS-1:0] s6_second_cost_r_0;
reg [COST_BITS-1:0] s6_best_cost_r_1;
reg [DISP_BITS-1:0] s6_best_disp_r_1;
reg [COST_BITS-1:0] s6_second_cost_r_1;

wire [COST_BITS-1:0] s7_best_cost_w_0;
wire [DISP_BITS-1:0] s7_best_disp_w_0;
wire [COST_BITS-1:0] s7_second_cost_w_0;

wta_merge2 #(.COST_BITS(COST_BITS), .DISP_BITS(DISP_BITS)) u_s7_m0 (
    .a_best_cost   (s6_best_cost_r_0),
    .a_best_disp   (s6_best_disp_r_0),
    .a_second_cost (s6_second_cost_r_0),
    .b_best_cost   (s6_best_cost_r_1),
    .b_best_disp   (s6_best_disp_r_1),
    .b_second_cost (s6_second_cost_r_1),
    .o_best_cost   (s7_best_cost_w_0),
    .o_best_disp   (s7_best_disp_w_0),
    .o_second_cost (s7_second_cost_w_0)
);

reg [COST_BITS-1:0] s7_best_cost_r_0;
reg [DISP_BITS-1:0] s7_best_disp_r_0;
reg [COST_BITS-1:0] s7_second_cost_r_0;

reg        valid_d1;
reg [10:0] x_d1;
reg [9:0]  y_d1;
reg        valid_d2;
reg [10:0] x_d2;
reg [9:0]  y_d2;
reg        valid_d3;
reg [10:0] x_d3;
reg [9:0]  y_d3;
reg        valid_d4;
reg [10:0] x_d4;
reg [9:0]  y_d4;
reg        valid_d5;
reg [10:0] x_d5;
reg [9:0]  y_d5;
reg        valid_d6;
reg [10:0] x_d6;
reg [9:0]  y_d6;
reg        valid_d7;
reg [10:0] x_d7;
reg [9:0]  y_d7;

always @(posedge clk) begin
    if (!rst_n) begin
       /* valid_d1 <= 1'b0;
        x_d1     <= 11'd0;
        y_d1     <= 10'd0;
        valid_d2 <= 1'b0;
        x_d2     <= 11'd0;
        y_d2     <= 10'd0;
        valid_d3 <= 1'b0;
        x_d3     <= 11'd0;
        y_d3     <= 10'd0;
        valid_d4 <= 1'b0;
        x_d4     <= 11'd0;
        y_d4     <= 10'd0;
        valid_d5 <= 1'b0;
        x_d5     <= 11'd0;
        y_d5     <= 10'd0;
        valid_d6 <= 1'b0;
        x_d6     <= 11'd0;
        y_d6     <= 10'd0;
        valid_d7 <= 1'b0;
        x_d7     <= 11'd0;
        y_d7     <= 10'd0;
        s1_best_cost_r_0   <= {COST_BITS{1'b0}};
        s1_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_0 <= COST_INF;
        s1_best_cost_r_1   <= {COST_BITS{1'b0}};
        s1_best_disp_r_1   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_1 <= COST_INF;
        s1_best_cost_r_2   <= {COST_BITS{1'b0}};
        s1_best_disp_r_2   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_2 <= COST_INF;
        s1_best_cost_r_3   <= {COST_BITS{1'b0}};
        s1_best_disp_r_3   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_3 <= COST_INF;
        s1_best_cost_r_4   <= {COST_BITS{1'b0}};
        s1_best_disp_r_4   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_4 <= COST_INF;
        s1_best_cost_r_5   <= {COST_BITS{1'b0}};
        s1_best_disp_r_5   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_5 <= COST_INF;
        s1_best_cost_r_6   <= {COST_BITS{1'b0}};
        s1_best_disp_r_6   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_6 <= COST_INF;
        s1_best_cost_r_7   <= {COST_BITS{1'b0}};
        s1_best_disp_r_7   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_7 <= COST_INF;
        s1_best_cost_r_8   <= {COST_BITS{1'b0}};
        s1_best_disp_r_8   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_8 <= COST_INF;
        s1_best_cost_r_9   <= {COST_BITS{1'b0}};
        s1_best_disp_r_9   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_9 <= COST_INF;
        s1_best_cost_r_10   <= {COST_BITS{1'b0}};
        s1_best_disp_r_10   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_10 <= COST_INF;
        s1_best_cost_r_11   <= {COST_BITS{1'b0}};
        s1_best_disp_r_11   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_11 <= COST_INF;
        s1_best_cost_r_12   <= {COST_BITS{1'b0}};
        s1_best_disp_r_12   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_12 <= COST_INF;
        s1_best_cost_r_13   <= {COST_BITS{1'b0}};
        s1_best_disp_r_13   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_13 <= COST_INF;
        s1_best_cost_r_14   <= {COST_BITS{1'b0}};
        s1_best_disp_r_14   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_14 <= COST_INF;
        s1_best_cost_r_15   <= {COST_BITS{1'b0}};
        s1_best_disp_r_15   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_15 <= COST_INF;
        s1_best_cost_r_16   <= {COST_BITS{1'b0}};
        s1_best_disp_r_16   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_16 <= COST_INF;
        s1_best_cost_r_17   <= {COST_BITS{1'b0}};
        s1_best_disp_r_17   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_17 <= COST_INF;
        s1_best_cost_r_18   <= {COST_BITS{1'b0}};
        s1_best_disp_r_18   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_18 <= COST_INF;
        s1_best_cost_r_19   <= {COST_BITS{1'b0}};
        s1_best_disp_r_19   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_19 <= COST_INF;
        s1_best_cost_r_20   <= {COST_BITS{1'b0}};
        s1_best_disp_r_20   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_20 <= COST_INF;
        s1_best_cost_r_21   <= {COST_BITS{1'b0}};
        s1_best_disp_r_21   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_21 <= COST_INF;
        s1_best_cost_r_22   <= {COST_BITS{1'b0}};
        s1_best_disp_r_22   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_22 <= COST_INF;
        s1_best_cost_r_23   <= {COST_BITS{1'b0}};
        s1_best_disp_r_23   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_23 <= COST_INF;
        s1_best_cost_r_24   <= {COST_BITS{1'b0}};
        s1_best_disp_r_24   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_24 <= COST_INF;
        s1_best_cost_r_25   <= {COST_BITS{1'b0}};
        s1_best_disp_r_25   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_25 <= COST_INF;
        s1_best_cost_r_26   <= {COST_BITS{1'b0}};
        s1_best_disp_r_26   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_26 <= COST_INF;
        s1_best_cost_r_27   <= {COST_BITS{1'b0}};
        s1_best_disp_r_27   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_27 <= COST_INF;
        s1_best_cost_r_28   <= {COST_BITS{1'b0}};
        s1_best_disp_r_28   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_28 <= COST_INF;
        s1_best_cost_r_29   <= {COST_BITS{1'b0}};
        s1_best_disp_r_29   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_29 <= COST_INF;
        s1_best_cost_r_30   <= {COST_BITS{1'b0}};
        s1_best_disp_r_30   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_30 <= COST_INF;
        s1_best_cost_r_31   <= {COST_BITS{1'b0}};
        s1_best_disp_r_31   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_31 <= COST_INF;
        s1_best_cost_r_32   <= {COST_BITS{1'b0}};
        s1_best_disp_r_32   <= {DISP_BITS{1'b0}};
        s1_second_cost_r_32 <= COST_INF;
        s2_best_cost_r_0   <= {COST_BITS{1'b0}};
        s2_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_0 <= COST_INF;
        s2_best_cost_r_1   <= {COST_BITS{1'b0}};
        s2_best_disp_r_1   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_1 <= COST_INF;
        s2_best_cost_r_2   <= {COST_BITS{1'b0}};
        s2_best_disp_r_2   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_2 <= COST_INF;
        s2_best_cost_r_3   <= {COST_BITS{1'b0}};
        s2_best_disp_r_3   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_3 <= COST_INF;
        s2_best_cost_r_4   <= {COST_BITS{1'b0}};
        s2_best_disp_r_4   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_4 <= COST_INF;
        s2_best_cost_r_5   <= {COST_BITS{1'b0}};
        s2_best_disp_r_5   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_5 <= COST_INF;
        s2_best_cost_r_6   <= {COST_BITS{1'b0}};
        s2_best_disp_r_6   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_6 <= COST_INF;
        s2_best_cost_r_7   <= {COST_BITS{1'b0}};
        s2_best_disp_r_7   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_7 <= COST_INF;
        s2_best_cost_r_8   <= {COST_BITS{1'b0}};
        s2_best_disp_r_8   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_8 <= COST_INF;
        s2_best_cost_r_9   <= {COST_BITS{1'b0}};
        s2_best_disp_r_9   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_9 <= COST_INF;
        s2_best_cost_r_10   <= {COST_BITS{1'b0}};
        s2_best_disp_r_10   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_10 <= COST_INF;
        s2_best_cost_r_11   <= {COST_BITS{1'b0}};
        s2_best_disp_r_11   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_11 <= COST_INF;
        s2_best_cost_r_12   <= {COST_BITS{1'b0}};
        s2_best_disp_r_12   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_12 <= COST_INF;
        s2_best_cost_r_13   <= {COST_BITS{1'b0}};
        s2_best_disp_r_13   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_13 <= COST_INF;
        s2_best_cost_r_14   <= {COST_BITS{1'b0}};
        s2_best_disp_r_14   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_14 <= COST_INF;
        s2_best_cost_r_15   <= {COST_BITS{1'b0}};
        s2_best_disp_r_15   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_15 <= COST_INF;
        s2_best_cost_r_16   <= {COST_BITS{1'b0}};
        s2_best_disp_r_16   <= {DISP_BITS{1'b0}};
        s2_second_cost_r_16 <= COST_INF;
        s3_best_cost_r_0   <= {COST_BITS{1'b0}};
        s3_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_0 <= COST_INF;
        s3_best_cost_r_1   <= {COST_BITS{1'b0}};
        s3_best_disp_r_1   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_1 <= COST_INF;
        s3_best_cost_r_2   <= {COST_BITS{1'b0}};
        s3_best_disp_r_2   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_2 <= COST_INF;
        s3_best_cost_r_3   <= {COST_BITS{1'b0}};
        s3_best_disp_r_3   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_3 <= COST_INF;
        s3_best_cost_r_4   <= {COST_BITS{1'b0}};
        s3_best_disp_r_4   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_4 <= COST_INF;
        s3_best_cost_r_5   <= {COST_BITS{1'b0}};
        s3_best_disp_r_5   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_5 <= COST_INF;
        s3_best_cost_r_6   <= {COST_BITS{1'b0}};
        s3_best_disp_r_6   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_6 <= COST_INF;
        s3_best_cost_r_7   <= {COST_BITS{1'b0}};
        s3_best_disp_r_7   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_7 <= COST_INF;
        s3_best_cost_r_8   <= {COST_BITS{1'b0}};
        s3_best_disp_r_8   <= {DISP_BITS{1'b0}};
        s3_second_cost_r_8 <= COST_INF;
        s4_best_cost_r_0   <= {COST_BITS{1'b0}};
        s4_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s4_second_cost_r_0 <= COST_INF;
        s4_best_cost_r_1   <= {COST_BITS{1'b0}};
        s4_best_disp_r_1   <= {DISP_BITS{1'b0}};
        s4_second_cost_r_1 <= COST_INF;
        s4_best_cost_r_2   <= {COST_BITS{1'b0}};
        s4_best_disp_r_2   <= {DISP_BITS{1'b0}};
        s4_second_cost_r_2 <= COST_INF;
        s4_best_cost_r_3   <= {COST_BITS{1'b0}};
        s4_best_disp_r_3   <= {DISP_BITS{1'b0}};
        s4_second_cost_r_3 <= COST_INF;
        s4_best_cost_r_4   <= {COST_BITS{1'b0}};
        s4_best_disp_r_4   <= {DISP_BITS{1'b0}};
        s4_second_cost_r_4 <= COST_INF;
        s5_best_cost_r_0   <= {COST_BITS{1'b0}};
        s5_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s5_second_cost_r_0 <= COST_INF;
        s5_best_cost_r_1   <= {COST_BITS{1'b0}};
        s5_best_disp_r_1   <= {DISP_BITS{1'b0}};
        s5_second_cost_r_1 <= COST_INF;
        s5_best_cost_r_2   <= {COST_BITS{1'b0}};
        s5_best_disp_r_2   <= {DISP_BITS{1'b0}};
        s5_second_cost_r_2 <= COST_INF;
        s6_best_cost_r_0   <= {COST_BITS{1'b0}};
        s6_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s6_second_cost_r_0 <= COST_INF;
        s6_best_cost_r_1   <= {COST_BITS{1'b0}};
        s6_best_disp_r_1   <= {DISP_BITS{1'b0}};
        s6_second_cost_r_1 <= COST_INF;
        s7_best_cost_r_0   <= {COST_BITS{1'b0}};
        s7_best_disp_r_0   <= {DISP_BITS{1'b0}};
        s7_second_cost_r_0 <= COST_INF;
        wta_valid      <= 1'b0;
        x_out          <= 11'd0;
        y_out          <= 10'd0;
        disp_out       <= {DISP_BITS{1'b0}};
        min1_cost_out  <= {COST_BITS{1'b0}};
        min2_cost_out  <= {COST_BITS{1'b0}};
		*/
		valid_d1 <= 1'b0;
    x_d1     <= 11'd0;
    y_d1     <= 10'd0;

    valid_d2 <= 1'b0;
    x_d2     <= 11'd0;
    y_d2     <= 10'd0;

    valid_d3 <= 1'b0;
    x_d3     <= 11'd0;
    y_d3     <= 10'd0;

    valid_d4 <= 1'b0;
    x_d4     <= 11'd0;
    y_d4     <= 10'd0;

    valid_d5 <= 1'b0;
    x_d5     <= 11'd0;
    y_d5     <= 10'd0;

    valid_d6 <= 1'b0;
    x_d6     <= 11'd0;
    y_d6     <= 10'd0;

    valid_d7 <= 1'b0;
    x_d7     <= 11'd0;
    y_d7     <= 10'd0;

    wta_valid     <= 1'b0;
    x_out         <= 11'd0;
    y_out         <= 10'd0;
    disp_out      <= {DISP_BITS{1'b0}};
    min1_cost_out <= {COST_BITS{1'b0}};
    min2_cost_out <= {COST_BITS{1'b0}};
    end else begin
        valid_d1 <= cost_valid;
        x_d1     <= x_in;
        y_d1     <= y_in;
        valid_d2 <= valid_d1;
        x_d2     <= x_d1;
        y_d2     <= y_d1;
        valid_d3 <= valid_d2;
        x_d3     <= x_d2;
        y_d3     <= y_d2;
        valid_d4 <= valid_d3;
        x_d4     <= x_d3;
        y_d4     <= y_d3;
        valid_d5 <= valid_d4;
        x_d5     <= x_d4;
        y_d5     <= y_d4;
        valid_d6 <= valid_d5;
        x_d6     <= x_d5;
        y_d6     <= y_d5;
        valid_d7 <= valid_d6;
        x_d7     <= x_d6;
        y_d7     <= y_d6;
        s1_best_cost_r_0   <= s1_best_cost_w_0;
        s1_best_disp_r_0   <= s1_best_disp_w_0;
        s1_second_cost_r_0 <= s1_second_cost_w_0;
        s1_best_cost_r_1   <= s1_best_cost_w_1;
        s1_best_disp_r_1   <= s1_best_disp_w_1;
        s1_second_cost_r_1 <= s1_second_cost_w_1;
        s1_best_cost_r_2   <= s1_best_cost_w_2;
        s1_best_disp_r_2   <= s1_best_disp_w_2;
        s1_second_cost_r_2 <= s1_second_cost_w_2;
        s1_best_cost_r_3   <= s1_best_cost_w_3;
        s1_best_disp_r_3   <= s1_best_disp_w_3;
        s1_second_cost_r_3 <= s1_second_cost_w_3;
        s1_best_cost_r_4   <= s1_best_cost_w_4;
        s1_best_disp_r_4   <= s1_best_disp_w_4;
        s1_second_cost_r_4 <= s1_second_cost_w_4;
        s1_best_cost_r_5   <= s1_best_cost_w_5;
        s1_best_disp_r_5   <= s1_best_disp_w_5;
        s1_second_cost_r_5 <= s1_second_cost_w_5;
        s1_best_cost_r_6   <= s1_best_cost_w_6;
        s1_best_disp_r_6   <= s1_best_disp_w_6;
        s1_second_cost_r_6 <= s1_second_cost_w_6;
        s1_best_cost_r_7   <= s1_best_cost_w_7;
        s1_best_disp_r_7   <= s1_best_disp_w_7;
        s1_second_cost_r_7 <= s1_second_cost_w_7;
        s1_best_cost_r_8   <= s1_best_cost_w_8;
        s1_best_disp_r_8   <= s1_best_disp_w_8;
        s1_second_cost_r_8 <= s1_second_cost_w_8;
        s1_best_cost_r_9   <= s1_best_cost_w_9;
        s1_best_disp_r_9   <= s1_best_disp_w_9;
        s1_second_cost_r_9 <= s1_second_cost_w_9;
        s1_best_cost_r_10   <= s1_best_cost_w_10;
        s1_best_disp_r_10   <= s1_best_disp_w_10;
        s1_second_cost_r_10 <= s1_second_cost_w_10;
        s1_best_cost_r_11   <= s1_best_cost_w_11;
        s1_best_disp_r_11   <= s1_best_disp_w_11;
        s1_second_cost_r_11 <= s1_second_cost_w_11;
        s1_best_cost_r_12   <= s1_best_cost_w_12;
        s1_best_disp_r_12   <= s1_best_disp_w_12;
        s1_second_cost_r_12 <= s1_second_cost_w_12;
        s1_best_cost_r_13   <= s1_best_cost_w_13;
        s1_best_disp_r_13   <= s1_best_disp_w_13;
        s1_second_cost_r_13 <= s1_second_cost_w_13;
        s1_best_cost_r_14   <= s1_best_cost_w_14;
        s1_best_disp_r_14   <= s1_best_disp_w_14;
        s1_second_cost_r_14 <= s1_second_cost_w_14;
        s1_best_cost_r_15   <= s1_best_cost_w_15;
        s1_best_disp_r_15   <= s1_best_disp_w_15;
        s1_second_cost_r_15 <= s1_second_cost_w_15;
        s1_best_cost_r_16   <= s1_best_cost_w_16;
        s1_best_disp_r_16   <= s1_best_disp_w_16;
        s1_second_cost_r_16 <= s1_second_cost_w_16;
        s1_best_cost_r_17   <= s1_best_cost_w_17;
        s1_best_disp_r_17   <= s1_best_disp_w_17;
        s1_second_cost_r_17 <= s1_second_cost_w_17;
        s1_best_cost_r_18   <= s1_best_cost_w_18;
        s1_best_disp_r_18   <= s1_best_disp_w_18;
        s1_second_cost_r_18 <= s1_second_cost_w_18;
        s1_best_cost_r_19   <= s1_best_cost_w_19;
        s1_best_disp_r_19   <= s1_best_disp_w_19;
        s1_second_cost_r_19 <= s1_second_cost_w_19;
        s1_best_cost_r_20   <= s1_best_cost_w_20;
        s1_best_disp_r_20   <= s1_best_disp_w_20;
        s1_second_cost_r_20 <= s1_second_cost_w_20;
        s1_best_cost_r_21   <= s1_best_cost_w_21;
        s1_best_disp_r_21   <= s1_best_disp_w_21;
        s1_second_cost_r_21 <= s1_second_cost_w_21;
        s1_best_cost_r_22   <= s1_best_cost_w_22;
        s1_best_disp_r_22   <= s1_best_disp_w_22;
        s1_second_cost_r_22 <= s1_second_cost_w_22;
        s1_best_cost_r_23   <= s1_best_cost_w_23;
        s1_best_disp_r_23   <= s1_best_disp_w_23;
        s1_second_cost_r_23 <= s1_second_cost_w_23;
        s1_best_cost_r_24   <= s1_best_cost_w_24;
        s1_best_disp_r_24   <= s1_best_disp_w_24;
        s1_second_cost_r_24 <= s1_second_cost_w_24;
        s1_best_cost_r_25   <= s1_best_cost_w_25;
        s1_best_disp_r_25   <= s1_best_disp_w_25;
        s1_second_cost_r_25 <= s1_second_cost_w_25;
        s1_best_cost_r_26   <= s1_best_cost_w_26;
        s1_best_disp_r_26   <= s1_best_disp_w_26;
        s1_second_cost_r_26 <= s1_second_cost_w_26;
        s1_best_cost_r_27   <= s1_best_cost_w_27;
        s1_best_disp_r_27   <= s1_best_disp_w_27;
        s1_second_cost_r_27 <= s1_second_cost_w_27;
        s1_best_cost_r_28   <= s1_best_cost_w_28;
        s1_best_disp_r_28   <= s1_best_disp_w_28;
        s1_second_cost_r_28 <= s1_second_cost_w_28;
        s1_best_cost_r_29   <= s1_best_cost_w_29;
        s1_best_disp_r_29   <= s1_best_disp_w_29;
        s1_second_cost_r_29 <= s1_second_cost_w_29;
        s1_best_cost_r_30   <= s1_best_cost_w_30;
        s1_best_disp_r_30   <= s1_best_disp_w_30;
        s1_second_cost_r_30 <= s1_second_cost_w_30;
        s1_best_cost_r_31   <= s1_best_cost_w_31;
        s1_best_disp_r_31   <= s1_best_disp_w_31;
        s1_second_cost_r_31 <= s1_second_cost_w_31;
        s1_best_cost_r_32   <= s1_best_cost_w_32;
        s1_best_disp_r_32   <= s1_best_disp_w_32;
        s1_second_cost_r_32 <= s1_second_cost_w_32;
        s2_best_cost_r_0   <= s2_best_cost_w_0;
        s2_best_disp_r_0   <= s2_best_disp_w_0;
        s2_second_cost_r_0 <= s2_second_cost_w_0;
        s2_best_cost_r_1   <= s2_best_cost_w_1;
        s2_best_disp_r_1   <= s2_best_disp_w_1;
        s2_second_cost_r_1 <= s2_second_cost_w_1;
        s2_best_cost_r_2   <= s2_best_cost_w_2;
        s2_best_disp_r_2   <= s2_best_disp_w_2;
        s2_second_cost_r_2 <= s2_second_cost_w_2;
        s2_best_cost_r_3   <= s2_best_cost_w_3;
        s2_best_disp_r_3   <= s2_best_disp_w_3;
        s2_second_cost_r_3 <= s2_second_cost_w_3;
        s2_best_cost_r_4   <= s2_best_cost_w_4;
        s2_best_disp_r_4   <= s2_best_disp_w_4;
        s2_second_cost_r_4 <= s2_second_cost_w_4;
        s2_best_cost_r_5   <= s2_best_cost_w_5;
        s2_best_disp_r_5   <= s2_best_disp_w_5;
        s2_second_cost_r_5 <= s2_second_cost_w_5;
        s2_best_cost_r_6   <= s2_best_cost_w_6;
        s2_best_disp_r_6   <= s2_best_disp_w_6;
        s2_second_cost_r_6 <= s2_second_cost_w_6;
        s2_best_cost_r_7   <= s2_best_cost_w_7;
        s2_best_disp_r_7   <= s2_best_disp_w_7;
        s2_second_cost_r_7 <= s2_second_cost_w_7;
        s2_best_cost_r_8   <= s2_best_cost_w_8;
        s2_best_disp_r_8   <= s2_best_disp_w_8;
        s2_second_cost_r_8 <= s2_second_cost_w_8;
        s2_best_cost_r_9   <= s2_best_cost_w_9;
        s2_best_disp_r_9   <= s2_best_disp_w_9;
        s2_second_cost_r_9 <= s2_second_cost_w_9;
        s2_best_cost_r_10   <= s2_best_cost_w_10;
        s2_best_disp_r_10   <= s2_best_disp_w_10;
        s2_second_cost_r_10 <= s2_second_cost_w_10;
        s2_best_cost_r_11   <= s2_best_cost_w_11;
        s2_best_disp_r_11   <= s2_best_disp_w_11;
        s2_second_cost_r_11 <= s2_second_cost_w_11;
        s2_best_cost_r_12   <= s2_best_cost_w_12;
        s2_best_disp_r_12   <= s2_best_disp_w_12;
        s2_second_cost_r_12 <= s2_second_cost_w_12;
        s2_best_cost_r_13   <= s2_best_cost_w_13;
        s2_best_disp_r_13   <= s2_best_disp_w_13;
        s2_second_cost_r_13 <= s2_second_cost_w_13;
        s2_best_cost_r_14   <= s2_best_cost_w_14;
        s2_best_disp_r_14   <= s2_best_disp_w_14;
        s2_second_cost_r_14 <= s2_second_cost_w_14;
        s2_best_cost_r_15   <= s2_best_cost_w_15;
        s2_best_disp_r_15   <= s2_best_disp_w_15;
        s2_second_cost_r_15 <= s2_second_cost_w_15;
        s2_best_cost_r_16   <= s2_best_cost_w_16;
        s2_best_disp_r_16   <= s2_best_disp_w_16;
        s2_second_cost_r_16 <= s2_second_cost_w_16;
        s3_best_cost_r_0   <= s3_best_cost_w_0;
        s3_best_disp_r_0   <= s3_best_disp_w_0;
        s3_second_cost_r_0 <= s3_second_cost_w_0;
        s3_best_cost_r_1   <= s3_best_cost_w_1;
        s3_best_disp_r_1   <= s3_best_disp_w_1;
        s3_second_cost_r_1 <= s3_second_cost_w_1;
        s3_best_cost_r_2   <= s3_best_cost_w_2;
        s3_best_disp_r_2   <= s3_best_disp_w_2;
        s3_second_cost_r_2 <= s3_second_cost_w_2;
        s3_best_cost_r_3   <= s3_best_cost_w_3;
        s3_best_disp_r_3   <= s3_best_disp_w_3;
        s3_second_cost_r_3 <= s3_second_cost_w_3;
        s3_best_cost_r_4   <= s3_best_cost_w_4;
        s3_best_disp_r_4   <= s3_best_disp_w_4;
        s3_second_cost_r_4 <= s3_second_cost_w_4;
        s3_best_cost_r_5   <= s3_best_cost_w_5;
        s3_best_disp_r_5   <= s3_best_disp_w_5;
        s3_second_cost_r_5 <= s3_second_cost_w_5;
        s3_best_cost_r_6   <= s3_best_cost_w_6;
        s3_best_disp_r_6   <= s3_best_disp_w_6;
        s3_second_cost_r_6 <= s3_second_cost_w_6;
        s3_best_cost_r_7   <= s3_best_cost_w_7;
        s3_best_disp_r_7   <= s3_best_disp_w_7;
        s3_second_cost_r_7 <= s3_second_cost_w_7;
        s3_best_cost_r_8   <= s3_best_cost_w_8;
        s3_best_disp_r_8   <= s3_best_disp_w_8;
        s3_second_cost_r_8 <= s3_second_cost_w_8;
        s4_best_cost_r_0   <= s4_best_cost_w_0;
        s4_best_disp_r_0   <= s4_best_disp_w_0;
        s4_second_cost_r_0 <= s4_second_cost_w_0;
        s4_best_cost_r_1   <= s4_best_cost_w_1;
        s4_best_disp_r_1   <= s4_best_disp_w_1;
        s4_second_cost_r_1 <= s4_second_cost_w_1;
        s4_best_cost_r_2   <= s4_best_cost_w_2;
        s4_best_disp_r_2   <= s4_best_disp_w_2;
        s4_second_cost_r_2 <= s4_second_cost_w_2;
        s4_best_cost_r_3   <= s4_best_cost_w_3;
        s4_best_disp_r_3   <= s4_best_disp_w_3;
        s4_second_cost_r_3 <= s4_second_cost_w_3;
        s4_best_cost_r_4   <= s4_best_cost_w_4;
        s4_best_disp_r_4   <= s4_best_disp_w_4;
        s4_second_cost_r_4 <= s4_second_cost_w_4;
        s5_best_cost_r_0   <= s5_best_cost_w_0;
        s5_best_disp_r_0   <= s5_best_disp_w_0;
        s5_second_cost_r_0 <= s5_second_cost_w_0;
        s5_best_cost_r_1   <= s5_best_cost_w_1;
        s5_best_disp_r_1   <= s5_best_disp_w_1;
        s5_second_cost_r_1 <= s5_second_cost_w_1;
        s5_best_cost_r_2   <= s5_best_cost_w_2;
        s5_best_disp_r_2   <= s5_best_disp_w_2;
        s5_second_cost_r_2 <= s5_second_cost_w_2;
        s6_best_cost_r_0   <= s6_best_cost_w_0;
        s6_best_disp_r_0   <= s6_best_disp_w_0;
        s6_second_cost_r_0 <= s6_second_cost_w_0;
        s6_best_cost_r_1   <= s6_best_cost_w_1;
        s6_best_disp_r_1   <= s6_best_disp_w_1;
        s6_second_cost_r_1 <= s6_second_cost_w_1;
        s7_best_cost_r_0   <= s7_best_cost_w_0;
        s7_best_disp_r_0   <= s7_best_disp_w_0;
        s7_second_cost_r_0 <= s7_second_cost_w_0;
        wta_valid      <= valid_d7;
        x_out          <= x_d7;
        y_out          <= y_d7;
        disp_out       <= s7_best_disp_r_0;
        min1_cost_out  <= s7_best_cost_r_0;
        min2_cost_out  <= s7_second_cost_r_0;
    end
end

endmodule
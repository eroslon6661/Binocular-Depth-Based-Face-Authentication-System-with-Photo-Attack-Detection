`timescale 1ns / 1ps
module top_sgbm_cost_aggr #(
    parameter IMG_WIDTH         = 1280,
    parameter IMG_HEIGHT        = 720,
    parameter PIXEL_BITS        = 8,
    parameter SINGLE_PATH_BITS  = 4,
    parameter AGG_COST_BITS     = 6,
    parameter DISP_BITS         = 7,
    parameter P1                = 4'd2,
    parameter P2                = 4'd8
)(
    input                       clk,
    input                       rst_n,
    input                       pixel_valid,
    input  [PIXEL_BITS-1:0]     left_pixel,
    input  [PIXEL_BITS-1:0]     right_pixel,

    // final WTA result only
    output                      disp_valid,
    output      [10:0]          disp_x_out,
    output      [9:0]           disp_y_out,
    output      [DISP_BITS-1:0] disp_out,
    output      [AGG_COST_BITS-1:0] min1_cost_out,
    output      [AGG_COST_BITS-1:0] min2_cost_out
);

// -----------------------------------------------------------------------------
// internal signals: cost generation
// -----------------------------------------------------------------------------
wire window_valid;
wire census_valid;
wire [7:0] left_census_code;
wire [7:0] right_census_code;
wire [3:0] hamming_raw0;

wire cost_valid;
wire [10:0] x_cost;
wire [9:0]  y_cost;
wire [3:0] cost0;
wire [3:0] cost1;
wire [3:0] cost2;
wire [3:0] cost3;
wire [3:0] cost4;
wire [3:0] cost5;
wire [3:0] cost6;
wire [3:0] cost7;
wire [3:0] cost8;
wire [3:0] cost9;
wire [3:0] cost10;
wire [3:0] cost11;
wire [3:0] cost12;
wire [3:0] cost13;
wire [3:0] cost14;
wire [3:0] cost15;
wire [3:0] cost16;
wire [3:0] cost17;
wire [3:0] cost18;
wire [3:0] cost19;
wire [3:0] cost20;
wire [3:0] cost21;
wire [3:0] cost22;
wire [3:0] cost23;
wire [3:0] cost24;
wire [3:0] cost25;
wire [3:0] cost26;
wire [3:0] cost27;
wire [3:0] cost28;
wire [3:0] cost29;
wire [3:0] cost30;
wire [3:0] cost31;
wire [3:0] cost32;
wire [3:0] cost33;
wire [3:0] cost34;
wire [3:0] cost35;
wire [3:0] cost36;
wire [3:0] cost37;
wire [3:0] cost38;
wire [3:0] cost39;
wire [3:0] cost40;
wire [3:0] cost41;
wire [3:0] cost42;
wire [3:0] cost43;
wire [3:0] cost44;
wire [3:0] cost45;
wire [3:0] cost46;
wire [3:0] cost47;
wire [3:0] cost48;
wire [3:0] cost49;
wire [3:0] cost50;
wire [3:0] cost51;
wire [3:0] cost52;
wire [3:0] cost53;
wire [3:0] cost54;
wire [3:0] cost55;
wire [3:0] cost56;
wire [3:0] cost57;
wire [3:0] cost58;
wire [3:0] cost59;
wire [3:0] cost60;
wire [3:0] cost61;
wire [3:0] cost62;
wire [3:0] cost63;
wire [3:0] cost64;


// -----------------------------------------------------------------------------
// internal signals: aggregated 65-way cost volume
// -----------------------------------------------------------------------------
wire agg_cost_valid;
wire [10:0] agg_x_out;
wire [9:0]  agg_y_out;
wire [AGG_COST_BITS-1:0] agg_cost0;
wire [AGG_COST_BITS-1:0] agg_cost1;
wire [AGG_COST_BITS-1:0] agg_cost2;
wire [AGG_COST_BITS-1:0] agg_cost3;
wire [AGG_COST_BITS-1:0] agg_cost4;
wire [AGG_COST_BITS-1:0] agg_cost5;
wire [AGG_COST_BITS-1:0] agg_cost6;
wire [AGG_COST_BITS-1:0] agg_cost7;
wire [AGG_COST_BITS-1:0] agg_cost8;
wire [AGG_COST_BITS-1:0] agg_cost9;
wire [AGG_COST_BITS-1:0] agg_cost10;
wire [AGG_COST_BITS-1:0] agg_cost11;
wire [AGG_COST_BITS-1:0] agg_cost12;
wire [AGG_COST_BITS-1:0] agg_cost13;
wire [AGG_COST_BITS-1:0] agg_cost14;
wire [AGG_COST_BITS-1:0] agg_cost15;
wire [AGG_COST_BITS-1:0] agg_cost16;
wire [AGG_COST_BITS-1:0] agg_cost17;
wire [AGG_COST_BITS-1:0] agg_cost18;
wire [AGG_COST_BITS-1:0] agg_cost19;
wire [AGG_COST_BITS-1:0] agg_cost20;
wire [AGG_COST_BITS-1:0] agg_cost21;
wire [AGG_COST_BITS-1:0] agg_cost22;
wire [AGG_COST_BITS-1:0] agg_cost23;
wire [AGG_COST_BITS-1:0] agg_cost24;
wire [AGG_COST_BITS-1:0] agg_cost25;
wire [AGG_COST_BITS-1:0] agg_cost26;
wire [AGG_COST_BITS-1:0] agg_cost27;
wire [AGG_COST_BITS-1:0] agg_cost28;
wire [AGG_COST_BITS-1:0] agg_cost29;
wire [AGG_COST_BITS-1:0] agg_cost30;
wire [AGG_COST_BITS-1:0] agg_cost31;
wire [AGG_COST_BITS-1:0] agg_cost32;
wire [AGG_COST_BITS-1:0] agg_cost33;
wire [AGG_COST_BITS-1:0] agg_cost34;
wire [AGG_COST_BITS-1:0] agg_cost35;
wire [AGG_COST_BITS-1:0] agg_cost36;
wire [AGG_COST_BITS-1:0] agg_cost37;
wire [AGG_COST_BITS-1:0] agg_cost38;
wire [AGG_COST_BITS-1:0] agg_cost39;
wire [AGG_COST_BITS-1:0] agg_cost40;
wire [AGG_COST_BITS-1:0] agg_cost41;
wire [AGG_COST_BITS-1:0] agg_cost42;
wire [AGG_COST_BITS-1:0] agg_cost43;
wire [AGG_COST_BITS-1:0] agg_cost44;
wire [AGG_COST_BITS-1:0] agg_cost45;
wire [AGG_COST_BITS-1:0] agg_cost46;
wire [AGG_COST_BITS-1:0] agg_cost47;
wire [AGG_COST_BITS-1:0] agg_cost48;
wire [AGG_COST_BITS-1:0] agg_cost49;
wire [AGG_COST_BITS-1:0] agg_cost50;
wire [AGG_COST_BITS-1:0] agg_cost51;
wire [AGG_COST_BITS-1:0] agg_cost52;
wire [AGG_COST_BITS-1:0] agg_cost53;
wire [AGG_COST_BITS-1:0] agg_cost54;
wire [AGG_COST_BITS-1:0] agg_cost55;
wire [AGG_COST_BITS-1:0] agg_cost56;
wire [AGG_COST_BITS-1:0] agg_cost57;
wire [AGG_COST_BITS-1:0] agg_cost58;
wire [AGG_COST_BITS-1:0] agg_cost59;
wire [AGG_COST_BITS-1:0] agg_cost60;
wire [AGG_COST_BITS-1:0] agg_cost61;
wire [AGG_COST_BITS-1:0] agg_cost62;
wire [AGG_COST_BITS-1:0] agg_cost63;
wire [AGG_COST_BITS-1:0] agg_cost64;

// -----------------------------------------------------------------------------
// stage 1: census / hamming / 65-way raw matching cost
// -----------------------------------------------------------------------------
top_sgbm_cost #(
    .IMG_WIDTH  (IMG_WIDTH),
    .IMG_HEIGHT (IMG_HEIGHT),
    .PIXEL_BITS (PIXEL_BITS)
) u_cost_top (
    .clk             (clk),
    .rst_n           (rst_n),
    .pixel_valid     (pixel_valid),
    .left_pixel      (left_pixel),
    .right_pixel     (right_pixel),
    .window_valid    (window_valid),
    .census_valid    (census_valid),
    .left_census_code(left_census_code),
    .right_census_code(right_census_code),
    .cost_valid      (cost_valid),
    .x_out           (x_cost),
    .y_out           (y_cost),
    .hamming_raw0    (hamming_raw0),
    .cost0(cost0),
    .cost1(cost1),
    .cost2(cost2),
    .cost3(cost3),
    .cost4(cost4),
    .cost5(cost5),
    .cost6(cost6),
    .cost7(cost7),
    .cost8(cost8),
    .cost9(cost9),
    .cost10(cost10),
    .cost11(cost11),
    .cost12(cost12),
    .cost13(cost13),
    .cost14(cost14),
    .cost15(cost15),
    .cost16(cost16),
    .cost17(cost17),
    .cost18(cost18),
    .cost19(cost19),
    .cost20(cost20),
    .cost21(cost21),
    .cost22(cost22),
    .cost23(cost23),
    .cost24(cost24),
    .cost25(cost25),
    .cost26(cost26),
    .cost27(cost27),
    .cost28(cost28),
    .cost29(cost29),
    .cost30(cost30),
    .cost31(cost31),
    .cost32(cost32),
    .cost33(cost33),
    .cost34(cost34),
    .cost35(cost35),
    .cost36(cost36),
    .cost37(cost37),
    .cost38(cost38),
    .cost39(cost39),
    .cost40(cost40),
    .cost41(cost41),
    .cost42(cost42),
    .cost43(cost43),
    .cost44(cost44),
    .cost45(cost45),
    .cost46(cost46),
    .cost47(cost47),
    .cost48(cost48),
    .cost49(cost49),
    .cost50(cost50),
    .cost51(cost51),
    .cost52(cost52),
    .cost53(cost53),
    .cost54(cost54),
    .cost55(cost55),
    .cost56(cost56),
    .cost57(cost57),
    .cost58(cost58),
    .cost59(cost59),
    .cost60(cost60),
    .cost61(cost61),
    .cost62(cost62),
    .cost63(cost63),
    .cost64(cost64)
);

// -----------------------------------------------------------------------------
// stage 2: 4-path SGBM aggregation
// NOTE:
// top_sgbm_cost is based on a 3x3 census window, so the effective valid image
// size is reduced by 2 pixels in both width and height.
// -----------------------------------------------------------------------------
sgbm_cost_aggregation_top #(
    .IMG_WIDTH        (IMG_WIDTH-2),
    .IMG_HEIGHT       (IMG_HEIGHT-2),
    .DISP_NUM         (65),
    .COST_BITS        (4),
    .SINGLE_PATH_BITS (SINGLE_PATH_BITS),
    .AGG_COST_BITS    (AGG_COST_BITS),
    .P1               (P1),
    .P2               (P2),
    .INVALID_COST     (4'hf)
) u_aggr (
    .clk              (clk),
    .rst_n            (rst_n),
    .cost_in_valid    (cost_valid),
    .x_in             (x_cost),
    .y_in             (y_cost),
    .cost0_in(cost0),
    .cost1_in(cost1),
    .cost2_in(cost2),
    .cost3_in(cost3),
    .cost4_in(cost4),
    .cost5_in(cost5),
    .cost6_in(cost6),
    .cost7_in(cost7),
    .cost8_in(cost8),
    .cost9_in(cost9),
    .cost10_in(cost10),
    .cost11_in(cost11),
    .cost12_in(cost12),
    .cost13_in(cost13),
    .cost14_in(cost14),
    .cost15_in(cost15),
    .cost16_in(cost16),
    .cost17_in(cost17),
    .cost18_in(cost18),
    .cost19_in(cost19),
    .cost20_in(cost20),
    .cost21_in(cost21),
    .cost22_in(cost22),
    .cost23_in(cost23),
    .cost24_in(cost24),
    .cost25_in(cost25),
    .cost26_in(cost26),
    .cost27_in(cost27),
    .cost28_in(cost28),
    .cost29_in(cost29),
    .cost30_in(cost30),
    .cost31_in(cost31),
    .cost32_in(cost32),
    .cost33_in(cost33),
    .cost34_in(cost34),
    .cost35_in(cost35),
    .cost36_in(cost36),
    .cost37_in(cost37),
    .cost38_in(cost38),
    .cost39_in(cost39),
    .cost40_in(cost40),
    .cost41_in(cost41),
    .cost42_in(cost42),
    .cost43_in(cost43),
    .cost44_in(cost44),
    .cost45_in(cost45),
    .cost46_in(cost46),
    .cost47_in(cost47),
    .cost48_in(cost48),
    .cost49_in(cost49),
    .cost50_in(cost50),
    .cost51_in(cost51),
    .cost52_in(cost52),
    .cost53_in(cost53),
    .cost54_in(cost54),
    .cost55_in(cost55),
    .cost56_in(cost56),
    .cost57_in(cost57),
    .cost58_in(cost58),
    .cost59_in(cost59),
    .cost60_in(cost60),
    .cost61_in(cost61),
    .cost62_in(cost62),
    .cost63_in(cost63),
    .cost64_in(cost64),
    .cost_out_valid   (agg_cost_valid),
    .x_out            (agg_x_out),
    .y_out            (agg_y_out),
    .cost0_out(agg_cost0),
    .cost1_out(agg_cost1),
    .cost2_out(agg_cost2),
    .cost3_out(agg_cost3),
    .cost4_out(agg_cost4),
    .cost5_out(agg_cost5),
    .cost6_out(agg_cost6),
    .cost7_out(agg_cost7),
    .cost8_out(agg_cost8),
    .cost9_out(agg_cost9),
    .cost10_out(agg_cost10),
    .cost11_out(agg_cost11),
    .cost12_out(agg_cost12),
    .cost13_out(agg_cost13),
    .cost14_out(agg_cost14),
    .cost15_out(agg_cost15),
    .cost16_out(agg_cost16),
    .cost17_out(agg_cost17),
    .cost18_out(agg_cost18),
    .cost19_out(agg_cost19),
    .cost20_out(agg_cost20),
    .cost21_out(agg_cost21),
    .cost22_out(agg_cost22),
    .cost23_out(agg_cost23),
    .cost24_out(agg_cost24),
    .cost25_out(agg_cost25),
    .cost26_out(agg_cost26),
    .cost27_out(agg_cost27),
    .cost28_out(agg_cost28),
    .cost29_out(agg_cost29),
    .cost30_out(agg_cost30),
    .cost31_out(agg_cost31),
    .cost32_out(agg_cost32),
    .cost33_out(agg_cost33),
    .cost34_out(agg_cost34),
    .cost35_out(agg_cost35),
    .cost36_out(agg_cost36),
    .cost37_out(agg_cost37),
    .cost38_out(agg_cost38),
    .cost39_out(agg_cost39),
    .cost40_out(agg_cost40),
    .cost41_out(agg_cost41),
    .cost42_out(agg_cost42),
    .cost43_out(agg_cost43),
    .cost44_out(agg_cost44),
    .cost45_out(agg_cost45),
    .cost46_out(agg_cost46),
    .cost47_out(agg_cost47),
    .cost48_out(agg_cost48),
    .cost49_out(agg_cost49),
    .cost50_out(agg_cost50),
    .cost51_out(agg_cost51),
    .cost52_out(agg_cost52),
    .cost53_out(agg_cost53),
    .cost54_out(agg_cost54),
    .cost55_out(agg_cost55),
    .cost56_out(agg_cost56),
    .cost57_out(agg_cost57),
    .cost58_out(agg_cost58),
    .cost59_out(agg_cost59),
    .cost60_out(agg_cost60),
    .cost61_out(agg_cost61),
    .cost62_out(agg_cost62),
    .cost63_out(agg_cost63),
    .cost64_out(agg_cost64)
);

// -----------------------------------------------------------------------------
// stage 3: WTA
// This module is internally aligned.
// disp_valid / disp_x_out / disp_y_out correspond to disp_out / min1 / min2.
// WTA adds a 7-cycle latency relative to agg_cost_valid.
// -----------------------------------------------------------------------------
sgbm_wta_65 #(
    .COST_BITS        (AGG_COST_BITS),
    .DISP_BITS        (DISP_BITS)
) u_wta (
    .clk              (clk),
    .rst_n            (rst_n),
    .cost_valid       (agg_cost_valid),
    .x_in             (agg_x_out),
    .y_in             (agg_y_out),
    .cost0_in(agg_cost0),
    .cost1_in(agg_cost1),
    .cost2_in(agg_cost2),
    .cost3_in(agg_cost3),
    .cost4_in(agg_cost4),
    .cost5_in(agg_cost5),
    .cost6_in(agg_cost6),
    .cost7_in(agg_cost7),
    .cost8_in(agg_cost8),
    .cost9_in(agg_cost9),
    .cost10_in(agg_cost10),
    .cost11_in(agg_cost11),
    .cost12_in(agg_cost12),
    .cost13_in(agg_cost13),
    .cost14_in(agg_cost14),
    .cost15_in(agg_cost15),
    .cost16_in(agg_cost16),
    .cost17_in(agg_cost17),
    .cost18_in(agg_cost18),
    .cost19_in(agg_cost19),
    .cost20_in(agg_cost20),
    .cost21_in(agg_cost21),
    .cost22_in(agg_cost22),
    .cost23_in(agg_cost23),
    .cost24_in(agg_cost24),
    .cost25_in(agg_cost25),
    .cost26_in(agg_cost26),
    .cost27_in(agg_cost27),
    .cost28_in(agg_cost28),
    .cost29_in(agg_cost29),
    .cost30_in(agg_cost30),
    .cost31_in(agg_cost31),
    .cost32_in(agg_cost32),
    .cost33_in(agg_cost33),
    .cost34_in(agg_cost34),
    .cost35_in(agg_cost35),
    .cost36_in(agg_cost36),
    .cost37_in(agg_cost37),
    .cost38_in(agg_cost38),
    .cost39_in(agg_cost39),
    .cost40_in(agg_cost40),
    .cost41_in(agg_cost41),
    .cost42_in(agg_cost42),
    .cost43_in(agg_cost43),
    .cost44_in(agg_cost44),
    .cost45_in(agg_cost45),
    .cost46_in(agg_cost46),
    .cost47_in(agg_cost47),
    .cost48_in(agg_cost48),
    .cost49_in(agg_cost49),
    .cost50_in(agg_cost50),
    .cost51_in(agg_cost51),
    .cost52_in(agg_cost52),
    .cost53_in(agg_cost53),
    .cost54_in(agg_cost54),
    .cost55_in(agg_cost55),
    .cost56_in(agg_cost56),
    .cost57_in(agg_cost57),
    .cost58_in(agg_cost58),
    .cost59_in(agg_cost59),
    .cost60_in(agg_cost60),
    .cost61_in(agg_cost61),
    .cost62_in(agg_cost62),
    .cost63_in(agg_cost63),
    .cost64_in(agg_cost64),
    .wta_valid        (disp_valid),
    .x_out            (disp_x_out),
    .y_out            (disp_y_out),
    .disp_out         (disp_out),
    .min1_cost_out    (min1_cost_out),
    .min2_cost_out    (min2_cost_out)
);

endmodule

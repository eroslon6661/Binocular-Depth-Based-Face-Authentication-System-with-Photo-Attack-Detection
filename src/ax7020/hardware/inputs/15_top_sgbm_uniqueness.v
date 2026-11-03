`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Top with WTA + Uniqueness Check
//
// Pipeline:
//   left/right pixels
//      -> top_sgbm_cost_aggr
//      -> sgbm_uniqueness_check
//
// Final outputs:
//   disp_valid
//   disp_x_out / disp_y_out
//   disp_out      : filtered disparity (0 when rejected)
//   unique_pass   : 1 means disparity kept, 0 means rejected
//   raw_disp_out  : original WTA disparity before uniqueness check
//   min1_cost_out / min2_cost_out : forwarded for debug / later confidence logic
// -----------------------------------------------------------------------------
module top_sgbm_uniqueness #(
    parameter IMG_WIDTH         = 1280,
    parameter IMG_HEIGHT        = 720,
    parameter PIXEL_BITS        = 8,
    parameter SINGLE_PATH_BITS  = 4,
    parameter AGG_COST_BITS     = 6,
    parameter DISP_BITS         = 7,
    parameter P1                = 4'd2,
    parameter P2                = 4'd8,
    parameter TH_DIFF           = 3,
    parameter BYPASS_UNIQUENESS = 0
)(
    input                           clk,
    input                           rst_n,
    input                           pixel_valid,
    input  [PIXEL_BITS-1:0]         left_pixel,
    input  [PIXEL_BITS-1:0]         right_pixel,

    output                          disp_valid,
    output      [10:0]              disp_x_out,
    output      [9:0]               disp_y_out,
    output      [DISP_BITS-1:0]     disp_out,
    output                          unique_pass,

    output      [DISP_BITS-1:0]     raw_disp_out,
    output      [AGG_COST_BITS-1:0] min1_cost_out,
    output      [AGG_COST_BITS-1:0] min2_cost_out
);

// WTA outputs -----------------------------------------------------------------
wire                     wta_valid;
wire [10:0]              wta_x;
wire [9:0]               wta_y;
wire [DISP_BITS-1:0]     wta_disp;
wire [AGG_COST_BITS-1:0] wta_min1;
wire [AGG_COST_BITS-1:0] wta_min2;

top_sgbm_cost_aggr #(
    .IMG_WIDTH         (IMG_WIDTH),
    .IMG_HEIGHT        (IMG_HEIGHT),
    .PIXEL_BITS        (PIXEL_BITS),
    .SINGLE_PATH_BITS  (SINGLE_PATH_BITS),
    .AGG_COST_BITS     (AGG_COST_BITS),
    .DISP_BITS         (DISP_BITS),
    .P1                (P1),
    .P2                (P2)
) u_core (
    .clk               (clk),
    .rst_n             (rst_n),
    .pixel_valid       (pixel_valid),
    .left_pixel        (left_pixel),
    .right_pixel       (right_pixel),
    .disp_valid        (wta_valid),
    .disp_x_out        (wta_x),
    .disp_y_out        (wta_y),
    .disp_out          (wta_disp),
    .min1_cost_out     (wta_min1),
    .min2_cost_out     (wta_min2)
);

// Uniqueness check ------------------------------------------------------------
sgbm_uniqueness_check #(
    .DISP_BITS         (DISP_BITS),
    .COST_BITS         (AGG_COST_BITS),
    .TH_DIFF           (TH_DIFF),
    .BYPASS_UNIQUENESS (BYPASS_UNIQUENESS)
) u_unique (
    .clk               (clk),
    .rst_n             (rst_n),
    .in_valid          (wta_valid),
    .x_in              (wta_x),
    .y_in              (wta_y),
    .disp_in           (wta_disp),
    .min1_cost_in      (wta_min1),
    .min2_cost_in      (wta_min2),
    .out_valid         (disp_valid),
    .x_out             (disp_x_out),
    .y_out             (disp_y_out),
    .disp_out          (disp_out),
    .unique_pass       (unique_pass)
);

// Forward raw WTA info --------------------------------------------------------
assign raw_disp_out  = wta_disp;
assign min1_cost_out = wta_min1;
assign min2_cost_out = wta_min2;

endmodule

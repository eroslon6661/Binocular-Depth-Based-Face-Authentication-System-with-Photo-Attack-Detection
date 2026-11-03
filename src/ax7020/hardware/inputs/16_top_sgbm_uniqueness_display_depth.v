`timescale 1ns / 1ps

module top_sgbm_uniqueness_display_depth #(
    parameter IMG_WIDTH         = 1280,
    parameter IMG_HEIGHT        = 720,
    parameter PIXEL_BITS        = 8,
    parameter SINGLE_PATH_BITS  = 4,
    parameter AGG_COST_BITS     = 6,
    parameter DISP_BITS         = 7,
    parameter DEPTH_BITS        = 16,
    parameter P1                = 4'd2,
    parameter P2                = 4'd8,
    parameter TH_DIFF           = 3,
    parameter BYPASS_UNIQUENESS = 0,
    parameter FB_NUM            = 16'd6000,
    parameter DEPTH_MAX         = 16'hFFFF,
    parameter GRAY_INVERT       = 0
)(
    input                           clk,
    input                           rst_n,
    input                           pixel_valid,
    input      [PIXEL_BITS-1:0]     left_pixel,
    input      [PIXEL_BITS-1:0]     right_pixel,

    output                          disp_valid,
    output      [10:0]              disp_x_out,
    output      [9:0]               disp_y_out,
    output      [DISP_BITS-1:0]     disp_out,
    output                          unique_pass,

    output                          depth_valid,
    output      [10:0]              depth_x_out,
    output      [9:0]               depth_y_out,
    output      [DEPTH_BITS-1:0]    depth_out,
    output                          depth_reliable,

    output                          gray_valid,
    output      [10:0]              gray_x_out,
    output      [9:0]               gray_y_out,
    output      [7:0]               gray_out,
    output                          gray_reliable,

    output      [DISP_BITS-1:0]     raw_disp_out,
    output      [AGG_COST_BITS-1:0] min1_cost_out,
    output      [AGG_COST_BITS-1:0] min2_cost_out
);

wire                     u_valid;
wire [10:0]              u_x;
wire [9:0]               u_y;
wire [DISP_BITS-1:0]     u_disp;
wire                     u_pass;

top_sgbm_uniqueness #(
    .IMG_WIDTH         (IMG_WIDTH),
    .IMG_HEIGHT        (IMG_HEIGHT),
    .PIXEL_BITS        (PIXEL_BITS),
    .SINGLE_PATH_BITS  (SINGLE_PATH_BITS),
    .AGG_COST_BITS     (AGG_COST_BITS),
    .DISP_BITS         (DISP_BITS),
    .P1                (P1),
    .P2                (P2),
    .TH_DIFF           (TH_DIFF),
    .BYPASS_UNIQUENESS (BYPASS_UNIQUENESS)
) u_unique_top (
    .clk               (clk),
    .rst_n             (rst_n),
    .pixel_valid       (pixel_valid),
    .left_pixel        (left_pixel),
    .right_pixel       (right_pixel),
    .disp_valid        (u_valid),
    .disp_x_out        (u_x),
    .disp_y_out        (u_y),
    .disp_out          (u_disp),
    .unique_pass       (u_pass),
    .raw_disp_out      (raw_disp_out),
    .min1_cost_out     (min1_cost_out),
    .min2_cost_out     (min2_cost_out)
);

assign disp_valid  = u_valid;
assign disp_x_out  = u_x;
assign disp_y_out  = u_y;
assign disp_out    = u_disp;
assign unique_pass = u_pass;

sgbm_depth_from_disp_lut #(
    .DISP_BITS        (DISP_BITS),
    .DEPTH_BITS       (DEPTH_BITS),
    .FB_NUM           (FB_NUM),
    .DEPTH_MAX        (DEPTH_MAX)
) u_depth (
    .clk              (clk),
    .rst_n            (rst_n),
    .in_valid         (u_valid),
    .x_in             (u_x),
    .y_in             (u_y),
    .disp_in          (u_disp),
    .unique_pass_in   (u_pass),
    .out_valid        (depth_valid),
    .x_out            (depth_x_out),
    .y_out            (depth_y_out),
    .disp_out         (),
    .depth_out        (depth_out),
    .depth_reliable   (depth_reliable)
);

sgbm_disp_to_gray_lut #(
    .DISP_BITS        (DISP_BITS),
    .GRAY_BITS        (8),
    .GRAY_INVERT      (GRAY_INVERT)
) u_gray (
    .clk              (clk),
    .rst_n            (rst_n),
    .in_valid         (u_valid),
    .x_in             (u_x),
    .y_in             (u_y),
    .disp_in          (u_disp),
    .unique_pass_in   (u_pass),
    .out_valid        (gray_valid),
    .x_out            (gray_x_out),
    .y_out            (gray_y_out),
    .gray_out         (gray_out),
    .gray_reliable    (gray_reliable)
);

endmodule

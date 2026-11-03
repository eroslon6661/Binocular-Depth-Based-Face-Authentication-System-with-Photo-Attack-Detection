`timescale 1ns / 1ps
module wta_merge2 #(
    parameter COST_BITS = 6,
    parameter DISP_BITS = 7
)(
    input  wire [COST_BITS-1:0] a_best_cost,
    input  wire [DISP_BITS-1:0] a_best_disp,
    input  wire [COST_BITS-1:0] a_second_cost,
    input  wire [COST_BITS-1:0] b_best_cost,
    input  wire [DISP_BITS-1:0] b_best_disp,
    input  wire [COST_BITS-1:0] b_second_cost,
    output wire [COST_BITS-1:0] o_best_cost,
    output wire [DISP_BITS-1:0] o_best_disp,
    output wire [COST_BITS-1:0] o_second_cost
);

wire a_better = (a_best_cost < b_best_cost) ||
                ((a_best_cost == b_best_cost) && (a_best_disp <= b_best_disp));

wire [COST_BITS-1:0] losing_best_cost = a_better ? b_best_cost : a_best_cost;
wire [COST_BITS-1:0] min_second_ab    = (a_second_cost < b_second_cost) ? a_second_cost : b_second_cost;

assign o_best_cost   = a_better ? a_best_cost : b_best_cost;
assign o_best_disp   = a_better ? a_best_disp : b_best_disp;
assign o_second_cost = (losing_best_cost < min_second_ab) ? losing_best_cost : min_second_ab;

endmodule

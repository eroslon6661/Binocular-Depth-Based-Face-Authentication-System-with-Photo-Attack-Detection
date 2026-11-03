`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Uniqueness Check after WTA
//
// Rule:
//   if (min2_cost_in <= min1_cost_in + TH_DIFF)
//       reject -> disp_out = 0, unique_pass = 0
//   else
//       keep   -> disp_out = disp_in, unique_pass = 1
//
// Notes:
// - Very low resource usage
// - 1-cycle pipeline
// -----------------------------------------------------------------------------
module sgbm_uniqueness_check #(
    parameter DISP_BITS = 7,
    parameter COST_BITS = 6,
    parameter TH_DIFF   = 3,
    parameter BYPASS_UNIQUENESS = 0
)(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire                     in_valid,
    input  wire [10:0]              x_in,
    input  wire [9:0]               y_in,
    input  wire [DISP_BITS-1:0]     disp_in,
    input  wire [COST_BITS-1:0]     min1_cost_in,
    input  wire [COST_BITS-1:0]     min2_cost_in,

    output reg                      out_valid,
    output reg  [10:0]              x_out,
    output reg  [9:0]               y_out,
    output reg  [DISP_BITS-1:0]     disp_out,
    output reg                      unique_pass
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid    <= 1'b0;
        x_out        <= 11'd0;
        y_out        <= 10'd0;
        disp_out     <= {DISP_BITS{1'b0}};
        unique_pass  <= 1'b0;
    end else begin
        out_valid <= in_valid;
        x_out     <= x_in;
        y_out     <= y_in;

        if (in_valid) begin
            if (BYPASS_UNIQUENESS != 0) begin
                disp_out    <= disp_in;
                unique_pass <= 1'b1;
            end else if ({1'b0, min2_cost_in} <= ({1'b0, min1_cost_in} + TH_DIFF[COST_BITS:0])) begin
                disp_out    <= {DISP_BITS{1'b0}};
                unique_pass <= 1'b0;
            end else begin
                disp_out    <= disp_in;
                unique_pass <= 1'b1;
            end
        end else begin
            disp_out    <= {DISP_BITS{1'b0}};
            unique_pass <= 1'b0;
        end
    end
end

endmodule

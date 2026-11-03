`timescale 1ns / 1ps
module sgbm_disp_to_gray_lut #(
    parameter DISP_BITS   = 7,
    parameter GRAY_BITS   = 8,
    parameter GRAY_INVERT = 0
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     in_valid,
    input  wire [10:0]              x_in,
    input  wire [9:0]               y_in,
    input  wire [DISP_BITS-1:0]     disp_in,
    input  wire                     unique_pass_in,
    output reg                      out_valid,
    output reg  [10:0]              x_out,
    output reg  [9:0]               y_out,
    output reg  [GRAY_BITS-1:0]     gray_out,
    output reg                      gray_reliable
);

reg [GRAY_BITS-1:0] gray_lut;
wire [GRAY_BITS-1:0] gray_sel;
assign gray_sel = (GRAY_INVERT != 0) ? (8'd255 - gray_lut) : gray_lut;

always @* begin
    gray_lut = (disp_in >= 7'd64) ? 8'd255 : {disp_in[5:0], 2'b00};
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid      <= 1'b0;
        x_out          <= 11'd0;
        y_out          <= 10'd0;
        gray_out       <= {GRAY_BITS{1'b0}};
        gray_reliable  <= 1'b0;
    end else begin
        out_valid <= in_valid;
        x_out     <= x_in;
        y_out     <= y_in;

        if (in_valid && unique_pass_in && (disp_in != {DISP_BITS{1'b0}})) begin
            gray_out      <= gray_sel;
            gray_reliable <= 1'b1;
        end else begin
            gray_out      <= {GRAY_BITS{1'b0}};
            gray_reliable <= 1'b0;
        end
    end
end

endmodule

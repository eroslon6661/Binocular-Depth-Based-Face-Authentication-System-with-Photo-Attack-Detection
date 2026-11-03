`timescale 1ns / 1ps

module census_hamming #(
    parameter PIX_WIDTH = 8
)(
    input                       clk,
    input                       rst_n,
    input                       window_valid,
    input  [PIX_WIDTH-1:0]      l_matrix_11,
    input  [PIX_WIDTH-1:0]      l_matrix_12,
    input  [PIX_WIDTH-1:0]      l_matrix_13,
    input  [PIX_WIDTH-1:0]      l_matrix_21,
    input  [PIX_WIDTH-1:0]      l_matrix_22,
    input  [PIX_WIDTH-1:0]      l_matrix_23,
    input  [PIX_WIDTH-1:0]      l_matrix_31,
    input  [PIX_WIDTH-1:0]      l_matrix_32,
    input  [PIX_WIDTH-1:0]      l_matrix_33,
    input  [PIX_WIDTH-1:0]      r_matrix_11,
    input  [PIX_WIDTH-1:0]      r_matrix_12,
    input  [PIX_WIDTH-1:0]      r_matrix_13,
    input  [PIX_WIDTH-1:0]      r_matrix_21,
    input  [PIX_WIDTH-1:0]      r_matrix_22,
    input  [PIX_WIDTH-1:0]      r_matrix_23,
    input  [PIX_WIDTH-1:0]      r_matrix_31,
    input  [PIX_WIDTH-1:0]      r_matrix_32,
    input  [PIX_WIDTH-1:0]      r_matrix_33,
    output reg                  census_valid,
    output reg  [7:0]           left_census_code,
    output reg  [7:0]           right_census_code
);
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        census_valid      <= 1'b0;
        left_census_code  <= 8'd0;
        right_census_code <= 8'd0;
    end else begin
        census_valid <= window_valid;
        if (window_valid) begin
            left_census_code[7]  <= (l_matrix_11 > l_matrix_22);
            left_census_code[6]  <= (l_matrix_12 > l_matrix_22);
            left_census_code[5]  <= (l_matrix_13 > l_matrix_22);
            left_census_code[4]  <= (l_matrix_21 > l_matrix_22);
            left_census_code[3]  <= (l_matrix_23 > l_matrix_22);
            left_census_code[2]  <= (l_matrix_31 > l_matrix_22);
            left_census_code[1]  <= (l_matrix_32 > l_matrix_22);
            left_census_code[0]  <= (l_matrix_33 > l_matrix_22);

            right_census_code[7] <= (r_matrix_11 > r_matrix_22);
            right_census_code[6] <= (r_matrix_12 > r_matrix_22);
            right_census_code[5] <= (r_matrix_13 > r_matrix_22);
            right_census_code[4] <= (r_matrix_21 > r_matrix_22);
            right_census_code[3] <= (r_matrix_23 > r_matrix_22);
            right_census_code[2] <= (r_matrix_31 > r_matrix_22);
            right_census_code[1] <= (r_matrix_32 > r_matrix_22);
            right_census_code[0] <= (r_matrix_33 > r_matrix_22);
        end
    end
end
*/
always @(posedge clk) begin
    if (!rst_n) begin
        census_valid <= 1'b0;
    end else begin
        census_valid <= window_valid;
        if (window_valid) begin
            left_census_code[7]  <= (l_matrix_11 > l_matrix_22);
            left_census_code[6]  <= (l_matrix_12 > l_matrix_22);
            left_census_code[5]  <= (l_matrix_13 > l_matrix_22);
            left_census_code[4]  <= (l_matrix_21 > l_matrix_22);
            left_census_code[3]  <= (l_matrix_23 > l_matrix_22);
            left_census_code[2]  <= (l_matrix_31 > l_matrix_22);
            left_census_code[1]  <= (l_matrix_32 > l_matrix_22);
            left_census_code[0]  <= (l_matrix_33 > l_matrix_22);

            right_census_code[7] <= (r_matrix_11 > r_matrix_22);
            right_census_code[6] <= (r_matrix_12 > r_matrix_22);
            right_census_code[5] <= (r_matrix_13 > r_matrix_22);
            right_census_code[4] <= (r_matrix_21 > r_matrix_22);
            right_census_code[3] <= (r_matrix_23 > r_matrix_22);
            right_census_code[2] <= (r_matrix_31 > r_matrix_22);
            right_census_code[1] <= (r_matrix_32 > r_matrix_22);
            right_census_code[0] <= (r_matrix_33 > r_matrix_22);
        end
    end
end
endmodule

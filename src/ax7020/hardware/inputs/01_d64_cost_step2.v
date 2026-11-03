`timescale 1ns / 1ps

// Keep 65 cost candidates while extending the search to near objects.
// Candidate 0..23: 0..46 in 2-pixel steps (far range).
// Candidate 24..47: 48..140 in 4-pixel steps (middle range).
// Candidate 48..64: 144..352 in 13-pixel steps (near range).
module d64_cost_step2 #(
    parameter IMG_WIDTH = 1278,
    parameter IMG_HEIGHT = 718,
    parameter [3:0] INVALID_COST = 4'hf
)(
    input wire clk,
    input wire rst_n,
    input wire data_en,
    input wire [7:0] left_census,
    input wire [7:0] right_census,
    output wire cost_valid,
    output wire [10:0] x_cnt_d1,
    output wire [9:0] y_cnt_d1,
    output wire [3:0] hamming_raw0_out,
    output wire [3:0] cost0,
    output wire [3:0] cost1,
    output wire [3:0] cost2,
    output wire [3:0] cost3,
    output wire [3:0] cost4,
    output wire [3:0] cost5,
    output wire [3:0] cost6,
    output wire [3:0] cost7,
    output wire [3:0] cost8,
    output wire [3:0] cost9,
    output wire [3:0] cost10,
    output wire [3:0] cost11,
    output wire [3:0] cost12,
    output wire [3:0] cost13,
    output wire [3:0] cost14,
    output wire [3:0] cost15,
    output wire [3:0] cost16,
    output wire [3:0] cost17,
    output wire [3:0] cost18,
    output wire [3:0] cost19,
    output wire [3:0] cost20,
    output wire [3:0] cost21,
    output wire [3:0] cost22,
    output wire [3:0] cost23,
    output wire [3:0] cost24,
    output wire [3:0] cost25,
    output wire [3:0] cost26,
    output wire [3:0] cost27,
    output wire [3:0] cost28,
    output wire [3:0] cost29,
    output wire [3:0] cost30,
    output wire [3:0] cost31,
    output wire [3:0] cost32,
    output wire [3:0] cost33,
    output wire [3:0] cost34,
    output wire [3:0] cost35,
    output wire [3:0] cost36,
    output wire [3:0] cost37,
    output wire [3:0] cost38,
    output wire [3:0] cost39,
    output wire [3:0] cost40,
    output wire [3:0] cost41,
    output wire [3:0] cost42,
    output wire [3:0] cost43,
    output wire [3:0] cost44,
    output wire [3:0] cost45,
    output wire [3:0] cost46,
    output wire [3:0] cost47,
    output wire [3:0] cost48,
    output wire [3:0] cost49,
    output wire [3:0] cost50,
    output wire [3:0] cost51,
    output wire [3:0] cost52,
    output wire [3:0] cost53,
    output wire [3:0] cost54,
    output wire [3:0] cost55,
    output wire [3:0] cost56,
    output wire [3:0] cost57,
    output wire [3:0] cost58,
    output wire [3:0] cost59,
    output wire [3:0] cost60,
    output wire [3:0] cost61,
    output wire [3:0] cost62,
    output wire [3:0] cost63,
    output wire [3:0] cost64
);

reg [10:0] x_cnt;
reg [9:0] y_cnt;
reg [10:0] x_d1;
reg [9:0] y_d1;
reg valid_d1;
reg [7:0] left_census_d1;
// Vivado 2023.2 otherwise infers an incompatible SDP RAMB for this wide,
// tapped shift history (AVAL-88 at bitstream DRC).
(* shreg_extract = "no", ram_style = "registers" *) reg [8*353-1:0] right_history;
wire [4*65-1:0] cost_bus;

function [3:0] popcount8;
    input [7:0] value;
    begin
        popcount8 = value[0] + value[1] + value[2] + value[3] +
                    value[4] + value[5] + value[6] + value[7];
    end
endfunction

always @(posedge clk) begin
    if (!rst_n) begin
        x_cnt <= 11'd0;
        y_cnt <= 10'd0;
        x_d1 <= 11'd0;
        y_d1 <= 10'd0;
        valid_d1 <= 1'b0;
    end else begin
        valid_d1 <= data_en;
        if (data_en) begin
            x_d1 <= x_cnt;
            y_d1 <= y_cnt;
            left_census_d1 <= left_census;
            right_history <= {right_history[8*352-1:0], right_census};
            if (x_cnt == IMG_WIDTH-1) begin
                x_cnt <= 11'd0;
                y_cnt <= (y_cnt == IMG_HEIGHT-1) ? 10'd0 : y_cnt + 10'd1;
            end else begin
                x_cnt <= x_cnt + 11'd1;
            end
        end
    end
end

genvar disparity;
generate
    for (disparity = 0; disparity < 65; disparity = disparity + 1) begin : gen_cost
        localparam integer DISP_PX =
            (disparity < 24) ? 2 * disparity :
            (disparity < 48) ? 48 + 4 * (disparity - 24) :
                               144 + 13 * (disparity - 48);
        assign cost_bus[4*disparity +: 4] =
            (valid_d1 && (x_d1 >= DISP_PX)) ?
            popcount8(left_census_d1 ^ right_history[8*DISP_PX +: 8]) :
            INVALID_COST;
    end
endgenerate

assign cost_valid = valid_d1;
assign x_cnt_d1 = x_d1;
assign y_cnt_d1 = y_d1;
assign hamming_raw0_out = cost0;
assign cost0 = cost_bus[0*4 +: 4];
assign cost1 = cost_bus[1*4 +: 4];
assign cost2 = cost_bus[2*4 +: 4];
assign cost3 = cost_bus[3*4 +: 4];
assign cost4 = cost_bus[4*4 +: 4];
assign cost5 = cost_bus[5*4 +: 4];
assign cost6 = cost_bus[6*4 +: 4];
assign cost7 = cost_bus[7*4 +: 4];
assign cost8 = cost_bus[8*4 +: 4];
assign cost9 = cost_bus[9*4 +: 4];
assign cost10 = cost_bus[10*4 +: 4];
assign cost11 = cost_bus[11*4 +: 4];
assign cost12 = cost_bus[12*4 +: 4];
assign cost13 = cost_bus[13*4 +: 4];
assign cost14 = cost_bus[14*4 +: 4];
assign cost15 = cost_bus[15*4 +: 4];
assign cost16 = cost_bus[16*4 +: 4];
assign cost17 = cost_bus[17*4 +: 4];
assign cost18 = cost_bus[18*4 +: 4];
assign cost19 = cost_bus[19*4 +: 4];
assign cost20 = cost_bus[20*4 +: 4];
assign cost21 = cost_bus[21*4 +: 4];
assign cost22 = cost_bus[22*4 +: 4];
assign cost23 = cost_bus[23*4 +: 4];
assign cost24 = cost_bus[24*4 +: 4];
assign cost25 = cost_bus[25*4 +: 4];
assign cost26 = cost_bus[26*4 +: 4];
assign cost27 = cost_bus[27*4 +: 4];
assign cost28 = cost_bus[28*4 +: 4];
assign cost29 = cost_bus[29*4 +: 4];
assign cost30 = cost_bus[30*4 +: 4];
assign cost31 = cost_bus[31*4 +: 4];
assign cost32 = cost_bus[32*4 +: 4];
assign cost33 = cost_bus[33*4 +: 4];
assign cost34 = cost_bus[34*4 +: 4];
assign cost35 = cost_bus[35*4 +: 4];
assign cost36 = cost_bus[36*4 +: 4];
assign cost37 = cost_bus[37*4 +: 4];
assign cost38 = cost_bus[38*4 +: 4];
assign cost39 = cost_bus[39*4 +: 4];
assign cost40 = cost_bus[40*4 +: 4];
assign cost41 = cost_bus[41*4 +: 4];
assign cost42 = cost_bus[42*4 +: 4];
assign cost43 = cost_bus[43*4 +: 4];
assign cost44 = cost_bus[44*4 +: 4];
assign cost45 = cost_bus[45*4 +: 4];
assign cost46 = cost_bus[46*4 +: 4];
assign cost47 = cost_bus[47*4 +: 4];
assign cost48 = cost_bus[48*4 +: 4];
assign cost49 = cost_bus[49*4 +: 4];
assign cost50 = cost_bus[50*4 +: 4];
assign cost51 = cost_bus[51*4 +: 4];
assign cost52 = cost_bus[52*4 +: 4];
assign cost53 = cost_bus[53*4 +: 4];
assign cost54 = cost_bus[54*4 +: 4];
assign cost55 = cost_bus[55*4 +: 4];
assign cost56 = cost_bus[56*4 +: 4];
assign cost57 = cost_bus[57*4 +: 4];
assign cost58 = cost_bus[58*4 +: 4];
assign cost59 = cost_bus[59*4 +: 4];
assign cost60 = cost_bus[60*4 +: 4];
assign cost61 = cost_bus[61*4 +: 4];
assign cost62 = cost_bus[62*4 +: 4];
assign cost63 = cost_bus[63*4 +: 4];
assign cost64 = cost_bus[64*4 +: 4];

endmodule

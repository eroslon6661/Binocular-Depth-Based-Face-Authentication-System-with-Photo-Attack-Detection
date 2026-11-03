`timescale 1ns / 1ps
module sgbm_agg_lr #(
    parameter DISP_NUM      = 65,
    parameter COST_BITS     = 4,
    parameter AGG_COST_BITS = 4,
    parameter P1            = 4'd2,
    parameter P2            = 4'd8,
    parameter INVALID_COST  = 4'hf
)(
    input                       clk,
    input                       rst_n,
    input                       cost_valid,
    input       [10:0]          x_in,
    input       [9:0]           y_in,
    input [3:0] cost0_in,
    input [3:0] cost1_in,
    input [3:0] cost2_in,
    input [3:0] cost3_in,
    input [3:0] cost4_in,
    input [3:0] cost5_in,
    input [3:0] cost6_in,
    input [3:0] cost7_in,
    input [3:0] cost8_in,
    input [3:0] cost9_in,
    input [3:0] cost10_in,
    input [3:0] cost11_in,
    input [3:0] cost12_in,
    input [3:0] cost13_in,
    input [3:0] cost14_in,
    input [3:0] cost15_in,
    input [3:0] cost16_in,
    input [3:0] cost17_in,
    input [3:0] cost18_in,
    input [3:0] cost19_in,
    input [3:0] cost20_in,
    input [3:0] cost21_in,
    input [3:0] cost22_in,
    input [3:0] cost23_in,
    input [3:0] cost24_in,
    input [3:0] cost25_in,
    input [3:0] cost26_in,
    input [3:0] cost27_in,
    input [3:0] cost28_in,
    input [3:0] cost29_in,
    input [3:0] cost30_in,
    input [3:0] cost31_in,
    input [3:0] cost32_in,
    input [3:0] cost33_in,
    input [3:0] cost34_in,
    input [3:0] cost35_in,
    input [3:0] cost36_in,
    input [3:0] cost37_in,
    input [3:0] cost38_in,
    input [3:0] cost39_in,
    input [3:0] cost40_in,
    input [3:0] cost41_in,
    input [3:0] cost42_in,
    input [3:0] cost43_in,
    input [3:0] cost44_in,
    input [3:0] cost45_in,
    input [3:0] cost46_in,
    input [3:0] cost47_in,
    input [3:0] cost48_in,
    input [3:0] cost49_in,
    input [3:0] cost50_in,
    input [3:0] cost51_in,
    input [3:0] cost52_in,
    input [3:0] cost53_in,
    input [3:0] cost54_in,
    input [3:0] cost55_in,
    input [3:0] cost56_in,
    input [3:0] cost57_in,
    input [3:0] cost58_in,
    input [3:0] cost59_in,
    input [3:0] cost60_in,
    input [3:0] cost61_in,
    input [3:0] cost62_in,
    input [3:0] cost63_in,
    input [3:0] cost64_in,
    output reg                  cost_out_valid,
    output reg  [10:0]          x_out,
    output reg  [9:0]           y_out,
    output [3:0] cost0_out,
    output [3:0] cost1_out,
    output [3:0] cost2_out,
    output [3:0] cost3_out,
    output [3:0] cost4_out,
    output [3:0] cost5_out,
    output [3:0] cost6_out,
    output [3:0] cost7_out,
    output [3:0] cost8_out,
    output [3:0] cost9_out,
    output [3:0] cost10_out,
    output [3:0] cost11_out,
    output [3:0] cost12_out,
    output [3:0] cost13_out,
    output [3:0] cost14_out,
    output [3:0] cost15_out,
    output [3:0] cost16_out,
    output [3:0] cost17_out,
    output [3:0] cost18_out,
    output [3:0] cost19_out,
    output [3:0] cost20_out,
    output [3:0] cost21_out,
    output [3:0] cost22_out,
    output [3:0] cost23_out,
    output [3:0] cost24_out,
    output [3:0] cost25_out,
    output [3:0] cost26_out,
    output [3:0] cost27_out,
    output [3:0] cost28_out,
    output [3:0] cost29_out,
    output [3:0] cost30_out,
    output [3:0] cost31_out,
    output [3:0] cost32_out,
    output [3:0] cost33_out,
    output [3:0] cost34_out,
    output [3:0] cost35_out,
    output [3:0] cost36_out,
    output [3:0] cost37_out,
    output [3:0] cost38_out,
    output [3:0] cost39_out,
    output [3:0] cost40_out,
    output [3:0] cost41_out,
    output [3:0] cost42_out,
    output [3:0] cost43_out,
    output [3:0] cost44_out,
    output [3:0] cost45_out,
    output [3:0] cost46_out,
    output [3:0] cost47_out,
    output [3:0] cost48_out,
    output [3:0] cost49_out,
    output [3:0] cost50_out,
    output [3:0] cost51_out,
    output [3:0] cost52_out,
    output [3:0] cost53_out,
    output [3:0] cost54_out,
    output [3:0] cost55_out,
    output [3:0] cost56_out,
    output [3:0] cost57_out,
    output [3:0] cost58_out,
    output [3:0] cost59_out,
    output [3:0] cost60_out,
    output [3:0] cost61_out,
    output [3:0] cost62_out,
    output [3:0] cost63_out,
    output [3:0] cost64_out
);

localparam BUSW = DISP_NUM*AGG_COST_BITS;

wire [DISP_NUM*COST_BITS-1:0] cost_bus_in;
reg  [DISP_NUM*COST_BITS-1:0] cost_bus_d1;
reg  [10:0] x_d1, x_d2;
reg  [9:0]  y_d1, y_d2;
reg         valid_d1, valid_d2;
reg  [BUSW+AGG_COST_BITS-1:0] prev_state;
reg  [BUSW+AGG_COST_BITS-1:0] curr_state;
reg  [BUSW+AGG_COST_BITS-1:0] curr_state_mid_r;
wire [BUSW+AGG_COST_BITS-1:0] next_state;
wire boundary_d1;

assign cost_bus_in[0*4 +: 4] = cost0_in;
assign cost_bus_in[1*4 +: 4] = cost1_in;
assign cost_bus_in[2*4 +: 4] = cost2_in;
assign cost_bus_in[3*4 +: 4] = cost3_in;
assign cost_bus_in[4*4 +: 4] = cost4_in;
assign cost_bus_in[5*4 +: 4] = cost5_in;
assign cost_bus_in[6*4 +: 4] = cost6_in;
assign cost_bus_in[7*4 +: 4] = cost7_in;
assign cost_bus_in[8*4 +: 4] = cost8_in;
assign cost_bus_in[9*4 +: 4] = cost9_in;
assign cost_bus_in[10*4 +: 4] = cost10_in;
assign cost_bus_in[11*4 +: 4] = cost11_in;
assign cost_bus_in[12*4 +: 4] = cost12_in;
assign cost_bus_in[13*4 +: 4] = cost13_in;
assign cost_bus_in[14*4 +: 4] = cost14_in;
assign cost_bus_in[15*4 +: 4] = cost15_in;
assign cost_bus_in[16*4 +: 4] = cost16_in;
assign cost_bus_in[17*4 +: 4] = cost17_in;
assign cost_bus_in[18*4 +: 4] = cost18_in;
assign cost_bus_in[19*4 +: 4] = cost19_in;
assign cost_bus_in[20*4 +: 4] = cost20_in;
assign cost_bus_in[21*4 +: 4] = cost21_in;
assign cost_bus_in[22*4 +: 4] = cost22_in;
assign cost_bus_in[23*4 +: 4] = cost23_in;
assign cost_bus_in[24*4 +: 4] = cost24_in;
assign cost_bus_in[25*4 +: 4] = cost25_in;
assign cost_bus_in[26*4 +: 4] = cost26_in;
assign cost_bus_in[27*4 +: 4] = cost27_in;
assign cost_bus_in[28*4 +: 4] = cost28_in;
assign cost_bus_in[29*4 +: 4] = cost29_in;
assign cost_bus_in[30*4 +: 4] = cost30_in;
assign cost_bus_in[31*4 +: 4] = cost31_in;
assign cost_bus_in[32*4 +: 4] = cost32_in;
assign cost_bus_in[33*4 +: 4] = cost33_in;
assign cost_bus_in[34*4 +: 4] = cost34_in;
assign cost_bus_in[35*4 +: 4] = cost35_in;
assign cost_bus_in[36*4 +: 4] = cost36_in;
assign cost_bus_in[37*4 +: 4] = cost37_in;
assign cost_bus_in[38*4 +: 4] = cost38_in;
assign cost_bus_in[39*4 +: 4] = cost39_in;
assign cost_bus_in[40*4 +: 4] = cost40_in;
assign cost_bus_in[41*4 +: 4] = cost41_in;
assign cost_bus_in[42*4 +: 4] = cost42_in;
assign cost_bus_in[43*4 +: 4] = cost43_in;
assign cost_bus_in[44*4 +: 4] = cost44_in;
assign cost_bus_in[45*4 +: 4] = cost45_in;
assign cost_bus_in[46*4 +: 4] = cost46_in;
assign cost_bus_in[47*4 +: 4] = cost47_in;
assign cost_bus_in[48*4 +: 4] = cost48_in;
assign cost_bus_in[49*4 +: 4] = cost49_in;
assign cost_bus_in[50*4 +: 4] = cost50_in;
assign cost_bus_in[51*4 +: 4] = cost51_in;
assign cost_bus_in[52*4 +: 4] = cost52_in;
assign cost_bus_in[53*4 +: 4] = cost53_in;
assign cost_bus_in[54*4 +: 4] = cost54_in;
assign cost_bus_in[55*4 +: 4] = cost55_in;
assign cost_bus_in[56*4 +: 4] = cost56_in;
assign cost_bus_in[57*4 +: 4] = cost57_in;
assign cost_bus_in[58*4 +: 4] = cost58_in;
assign cost_bus_in[59*4 +: 4] = cost59_in;
assign cost_bus_in[60*4 +: 4] = cost60_in;
assign cost_bus_in[61*4 +: 4] = cost61_in;
assign cost_bus_in[62*4 +: 4] = cost62_in;
assign cost_bus_in[63*4 +: 4] = cost63_in;
assign cost_bus_in[64*4 +: 4] = cost64_in;

assign cost0_out  = curr_state[0*4 +: 4];
assign cost1_out  = curr_state[1*4 +: 4];
assign cost2_out  = curr_state[2*4 +: 4];
assign cost3_out  = curr_state[3*4 +: 4];
assign cost4_out  = curr_state[4*4 +: 4];
assign cost5_out  = curr_state[5*4 +: 4];
assign cost6_out  = curr_state[6*4 +: 4];
assign cost7_out  = curr_state[7*4 +: 4];
assign cost8_out  = curr_state[8*4 +: 4];
assign cost9_out  = curr_state[9*4 +: 4];
assign cost10_out = curr_state[10*4 +: 4];
assign cost11_out = curr_state[11*4 +: 4];
assign cost12_out = curr_state[12*4 +: 4];
assign cost13_out = curr_state[13*4 +: 4];
assign cost14_out = curr_state[14*4 +: 4];
assign cost15_out = curr_state[15*4 +: 4];
assign cost16_out = curr_state[16*4 +: 4];
assign cost17_out = curr_state[17*4 +: 4];
assign cost18_out = curr_state[18*4 +: 4];
assign cost19_out = curr_state[19*4 +: 4];
assign cost20_out = curr_state[20*4 +: 4];
assign cost21_out = curr_state[21*4 +: 4];
assign cost22_out = curr_state[22*4 +: 4];
assign cost23_out = curr_state[23*4 +: 4];
assign cost24_out = curr_state[24*4 +: 4];
assign cost25_out = curr_state[25*4 +: 4];
assign cost26_out = curr_state[26*4 +: 4];
assign cost27_out = curr_state[27*4 +: 4];
assign cost28_out = curr_state[28*4 +: 4];
assign cost29_out = curr_state[29*4 +: 4];
assign cost30_out = curr_state[30*4 +: 4];
assign cost31_out = curr_state[31*4 +: 4];
assign cost32_out = curr_state[32*4 +: 4];
assign cost33_out = curr_state[33*4 +: 4];
assign cost34_out = curr_state[34*4 +: 4];
assign cost35_out = curr_state[35*4 +: 4];
assign cost36_out = curr_state[36*4 +: 4];
assign cost37_out = curr_state[37*4 +: 4];
assign cost38_out = curr_state[38*4 +: 4];
assign cost39_out = curr_state[39*4 +: 4];
assign cost40_out = curr_state[40*4 +: 4];
assign cost41_out = curr_state[41*4 +: 4];
assign cost42_out = curr_state[42*4 +: 4];
assign cost43_out = curr_state[43*4 +: 4];
assign cost44_out = curr_state[44*4 +: 4];
assign cost45_out = curr_state[45*4 +: 4];
assign cost46_out = curr_state[46*4 +: 4];
assign cost47_out = curr_state[47*4 +: 4];
assign cost48_out = curr_state[48*4 +: 4];
assign cost49_out = curr_state[49*4 +: 4];
assign cost50_out = curr_state[50*4 +: 4];
assign cost51_out = curr_state[51*4 +: 4];
assign cost52_out = curr_state[52*4 +: 4];
assign cost53_out = curr_state[53*4 +: 4];
assign cost54_out = curr_state[54*4 +: 4];
assign cost55_out = curr_state[55*4 +: 4];
assign cost56_out = curr_state[56*4 +: 4];
assign cost57_out = curr_state[57*4 +: 4];
assign cost58_out = curr_state[58*4 +: 4];
assign cost59_out = curr_state[59*4 +: 4];
assign cost60_out = curr_state[60*4 +: 4];
assign cost61_out = curr_state[61*4 +: 4];
assign cost62_out = curr_state[62*4 +: 4];
assign cost63_out = curr_state[63*4 +: 4];
assign cost64_out = curr_state[64*4 +: 4];

assign boundary_d1 = (x_d1 == 11'd0);

sgbm_path_core_bus #(
    .DISP_NUM(DISP_NUM),
    .COST_BITS(COST_BITS),
    .AGG_BITS(AGG_COST_BITS),
    .P1(P1),
    .P2(P2),
    .INVALID_COST(INVALID_COST)
) u_core (
    .cost_bus   (cost_bus_d1),
    .prev_state (prev_state),
    .boundary   (boundary_d1),
    .next_state (next_state)
);

always @(posedge clk) begin
    if (!rst_n) begin
        valid_d1        <= 1'b0;
        valid_d2        <= 1'b0;
        cost_out_valid  <= 1'b0;
        x_d1            <= 11'd0;
        x_d2            <= 11'd0;
        y_d1            <= 10'd0;
        y_d2            <= 10'd0;
        x_out           <= 11'd0;
        y_out           <= 10'd0;
        prev_state      <= {(BUSW+AGG_COST_BITS){1'b0}};
        curr_state_mid_r<= {(BUSW+AGG_COST_BITS){1'b0}};
        curr_state      <= {(BUSW+AGG_COST_BITS){1'b0}};
    end else begin
        cost_out_valid <= valid_d2;
        x_out          <= x_d2;
        y_out          <= y_d2;
        curr_state     <= curr_state_mid_r;

        x_d2           <= x_d1;
        y_d2           <= y_d1;
        valid_d2       <= valid_d1;
        curr_state_mid_r <= next_state;

        if (cost_valid) begin
            cost_bus_d1 <= cost_bus_in;
            x_d1        <= x_in;
            y_d1        <= y_in;
            valid_d1    <= 1'b1;
            prev_state  <= (x_in == 11'd0) ? {(BUSW+AGG_COST_BITS){1'b0}} : next_state;
        end else begin
            valid_d1    <= 1'b0;
        end
    end
end

endmodule
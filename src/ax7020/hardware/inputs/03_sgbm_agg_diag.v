`timescale 1ns / 1ps
module sgbm_agg_diag #(
    parameter IMG_WIDTH     = 1280,
    parameter DISP_NUM      = 65,
    parameter COST_BITS     = 4,
    parameter AGG_COST_BITS = 4,
    parameter P1            = 4'd2,
    parameter P2            = 4'd8,
    parameter INVALID_COST  = 4'hf,
    parameter DIAG_MODE     = 0
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     cost_valid,
    input  wire [10:0]              x_in,
    input  wire [9:0]               y_in,
    input  wire [COST_BITS-1:0] cost0_in,
    input  wire [COST_BITS-1:0] cost1_in,
    input  wire [COST_BITS-1:0] cost2_in,
    input  wire [COST_BITS-1:0] cost3_in,
    input  wire [COST_BITS-1:0] cost4_in,
    input  wire [COST_BITS-1:0] cost5_in,
    input  wire [COST_BITS-1:0] cost6_in,
    input  wire [COST_BITS-1:0] cost7_in,
    input  wire [COST_BITS-1:0] cost8_in,
    input  wire [COST_BITS-1:0] cost9_in,
    input  wire [COST_BITS-1:0] cost10_in,
    input  wire [COST_BITS-1:0] cost11_in,
    input  wire [COST_BITS-1:0] cost12_in,
    input  wire [COST_BITS-1:0] cost13_in,
    input  wire [COST_BITS-1:0] cost14_in,
    input  wire [COST_BITS-1:0] cost15_in,
    input  wire [COST_BITS-1:0] cost16_in,
    input  wire [COST_BITS-1:0] cost17_in,
    input  wire [COST_BITS-1:0] cost18_in,
    input  wire [COST_BITS-1:0] cost19_in,
    input  wire [COST_BITS-1:0] cost20_in,
    input  wire [COST_BITS-1:0] cost21_in,
    input  wire [COST_BITS-1:0] cost22_in,
    input  wire [COST_BITS-1:0] cost23_in,
    input  wire [COST_BITS-1:0] cost24_in,
    input  wire [COST_BITS-1:0] cost25_in,
    input  wire [COST_BITS-1:0] cost26_in,
    input  wire [COST_BITS-1:0] cost27_in,
    input  wire [COST_BITS-1:0] cost28_in,
    input  wire [COST_BITS-1:0] cost29_in,
    input  wire [COST_BITS-1:0] cost30_in,
    input  wire [COST_BITS-1:0] cost31_in,
    input  wire [COST_BITS-1:0] cost32_in,
    input  wire [COST_BITS-1:0] cost33_in,
    input  wire [COST_BITS-1:0] cost34_in,
    input  wire [COST_BITS-1:0] cost35_in,
    input  wire [COST_BITS-1:0] cost36_in,
    input  wire [COST_BITS-1:0] cost37_in,
    input  wire [COST_BITS-1:0] cost38_in,
    input  wire [COST_BITS-1:0] cost39_in,
    input  wire [COST_BITS-1:0] cost40_in,
    input  wire [COST_BITS-1:0] cost41_in,
    input  wire [COST_BITS-1:0] cost42_in,
    input  wire [COST_BITS-1:0] cost43_in,
    input  wire [COST_BITS-1:0] cost44_in,
    input  wire [COST_BITS-1:0] cost45_in,
    input  wire [COST_BITS-1:0] cost46_in,
    input  wire [COST_BITS-1:0] cost47_in,
    input  wire [COST_BITS-1:0] cost48_in,
    input  wire [COST_BITS-1:0] cost49_in,
    input  wire [COST_BITS-1:0] cost50_in,
    input  wire [COST_BITS-1:0] cost51_in,
    input  wire [COST_BITS-1:0] cost52_in,
    input  wire [COST_BITS-1:0] cost53_in,
    input  wire [COST_BITS-1:0] cost54_in,
    input  wire [COST_BITS-1:0] cost55_in,
    input  wire [COST_BITS-1:0] cost56_in,
    input  wire [COST_BITS-1:0] cost57_in,
    input  wire [COST_BITS-1:0] cost58_in,
    input  wire [COST_BITS-1:0] cost59_in,
    input  wire [COST_BITS-1:0] cost60_in,
    input  wire [COST_BITS-1:0] cost61_in,
    input  wire [COST_BITS-1:0] cost62_in,
    input  wire [COST_BITS-1:0] cost63_in,
    input  wire [COST_BITS-1:0] cost64_in,
    output reg                      cost_out_valid,
    output reg  [10:0]              x_out,
    output reg  [9:0]               y_out,
    output wire [AGG_COST_BITS-1:0] cost0_out,
    output wire [AGG_COST_BITS-1:0] cost1_out,
    output wire [AGG_COST_BITS-1:0] cost2_out,
    output wire [AGG_COST_BITS-1:0] cost3_out,
    output wire [AGG_COST_BITS-1:0] cost4_out,
    output wire [AGG_COST_BITS-1:0] cost5_out,
    output wire [AGG_COST_BITS-1:0] cost6_out,
    output wire [AGG_COST_BITS-1:0] cost7_out,
    output wire [AGG_COST_BITS-1:0] cost8_out,
    output wire [AGG_COST_BITS-1:0] cost9_out,
    output wire [AGG_COST_BITS-1:0] cost10_out,
    output wire [AGG_COST_BITS-1:0] cost11_out,
    output wire [AGG_COST_BITS-1:0] cost12_out,
    output wire [AGG_COST_BITS-1:0] cost13_out,
    output wire [AGG_COST_BITS-1:0] cost14_out,
    output wire [AGG_COST_BITS-1:0] cost15_out,
    output wire [AGG_COST_BITS-1:0] cost16_out,
    output wire [AGG_COST_BITS-1:0] cost17_out,
    output wire [AGG_COST_BITS-1:0] cost18_out,
    output wire [AGG_COST_BITS-1:0] cost19_out,
    output wire [AGG_COST_BITS-1:0] cost20_out,
    output wire [AGG_COST_BITS-1:0] cost21_out,
    output wire [AGG_COST_BITS-1:0] cost22_out,
    output wire [AGG_COST_BITS-1:0] cost23_out,
    output wire [AGG_COST_BITS-1:0] cost24_out,
    output wire [AGG_COST_BITS-1:0] cost25_out,
    output wire [AGG_COST_BITS-1:0] cost26_out,
    output wire [AGG_COST_BITS-1:0] cost27_out,
    output wire [AGG_COST_BITS-1:0] cost28_out,
    output wire [AGG_COST_BITS-1:0] cost29_out,
    output wire [AGG_COST_BITS-1:0] cost30_out,
    output wire [AGG_COST_BITS-1:0] cost31_out,
    output wire [AGG_COST_BITS-1:0] cost32_out,
    output wire [AGG_COST_BITS-1:0] cost33_out,
    output wire [AGG_COST_BITS-1:0] cost34_out,
    output wire [AGG_COST_BITS-1:0] cost35_out,
    output wire [AGG_COST_BITS-1:0] cost36_out,
    output wire [AGG_COST_BITS-1:0] cost37_out,
    output wire [AGG_COST_BITS-1:0] cost38_out,
    output wire [AGG_COST_BITS-1:0] cost39_out,
    output wire [AGG_COST_BITS-1:0] cost40_out,
    output wire [AGG_COST_BITS-1:0] cost41_out,
    output wire [AGG_COST_BITS-1:0] cost42_out,
    output wire [AGG_COST_BITS-1:0] cost43_out,
    output wire [AGG_COST_BITS-1:0] cost44_out,
    output wire [AGG_COST_BITS-1:0] cost45_out,
    output wire [AGG_COST_BITS-1:0] cost46_out,
    output wire [AGG_COST_BITS-1:0] cost47_out,
    output wire [AGG_COST_BITS-1:0] cost48_out,
    output wire [AGG_COST_BITS-1:0] cost49_out,
    output wire [AGG_COST_BITS-1:0] cost50_out,
    output wire [AGG_COST_BITS-1:0] cost51_out,
    output wire [AGG_COST_BITS-1:0] cost52_out,
    output wire [AGG_COST_BITS-1:0] cost53_out,
    output wire [AGG_COST_BITS-1:0] cost54_out,
    output wire [AGG_COST_BITS-1:0] cost55_out,
    output wire [AGG_COST_BITS-1:0] cost56_out,
    output wire [AGG_COST_BITS-1:0] cost57_out,
    output wire [AGG_COST_BITS-1:0] cost58_out,
    output wire [AGG_COST_BITS-1:0] cost59_out,
    output wire [AGG_COST_BITS-1:0] cost60_out,
    output wire [AGG_COST_BITS-1:0] cost61_out,
    output wire [AGG_COST_BITS-1:0] cost62_out,
    output wire [AGG_COST_BITS-1:0] cost63_out,
    output wire [AGG_COST_BITS-1:0] cost64_out
);

localparam STATE_BITS = 264;
localparam BRAM_BITS = 288;


wire [DISP_NUM*COST_BITS-1:0] cost_bus_in;
assign cost_bus_in[0*COST_BITS +: COST_BITS] = cost0_in;
assign cost_bus_in[1*COST_BITS +: COST_BITS] = cost1_in;
assign cost_bus_in[2*COST_BITS +: COST_BITS] = cost2_in;
assign cost_bus_in[3*COST_BITS +: COST_BITS] = cost3_in;
assign cost_bus_in[4*COST_BITS +: COST_BITS] = cost4_in;
assign cost_bus_in[5*COST_BITS +: COST_BITS] = cost5_in;
assign cost_bus_in[6*COST_BITS +: COST_BITS] = cost6_in;
assign cost_bus_in[7*COST_BITS +: COST_BITS] = cost7_in;
assign cost_bus_in[8*COST_BITS +: COST_BITS] = cost8_in;
assign cost_bus_in[9*COST_BITS +: COST_BITS] = cost9_in;
assign cost_bus_in[10*COST_BITS +: COST_BITS] = cost10_in;
assign cost_bus_in[11*COST_BITS +: COST_BITS] = cost11_in;
assign cost_bus_in[12*COST_BITS +: COST_BITS] = cost12_in;
assign cost_bus_in[13*COST_BITS +: COST_BITS] = cost13_in;
assign cost_bus_in[14*COST_BITS +: COST_BITS] = cost14_in;
assign cost_bus_in[15*COST_BITS +: COST_BITS] = cost15_in;
assign cost_bus_in[16*COST_BITS +: COST_BITS] = cost16_in;
assign cost_bus_in[17*COST_BITS +: COST_BITS] = cost17_in;
assign cost_bus_in[18*COST_BITS +: COST_BITS] = cost18_in;
assign cost_bus_in[19*COST_BITS +: COST_BITS] = cost19_in;
assign cost_bus_in[20*COST_BITS +: COST_BITS] = cost20_in;
assign cost_bus_in[21*COST_BITS +: COST_BITS] = cost21_in;
assign cost_bus_in[22*COST_BITS +: COST_BITS] = cost22_in;
assign cost_bus_in[23*COST_BITS +: COST_BITS] = cost23_in;
assign cost_bus_in[24*COST_BITS +: COST_BITS] = cost24_in;
assign cost_bus_in[25*COST_BITS +: COST_BITS] = cost25_in;
assign cost_bus_in[26*COST_BITS +: COST_BITS] = cost26_in;
assign cost_bus_in[27*COST_BITS +: COST_BITS] = cost27_in;
assign cost_bus_in[28*COST_BITS +: COST_BITS] = cost28_in;
assign cost_bus_in[29*COST_BITS +: COST_BITS] = cost29_in;
assign cost_bus_in[30*COST_BITS +: COST_BITS] = cost30_in;
assign cost_bus_in[31*COST_BITS +: COST_BITS] = cost31_in;
assign cost_bus_in[32*COST_BITS +: COST_BITS] = cost32_in;
assign cost_bus_in[33*COST_BITS +: COST_BITS] = cost33_in;
assign cost_bus_in[34*COST_BITS +: COST_BITS] = cost34_in;
assign cost_bus_in[35*COST_BITS +: COST_BITS] = cost35_in;
assign cost_bus_in[36*COST_BITS +: COST_BITS] = cost36_in;
assign cost_bus_in[37*COST_BITS +: COST_BITS] = cost37_in;
assign cost_bus_in[38*COST_BITS +: COST_BITS] = cost38_in;
assign cost_bus_in[39*COST_BITS +: COST_BITS] = cost39_in;
assign cost_bus_in[40*COST_BITS +: COST_BITS] = cost40_in;
assign cost_bus_in[41*COST_BITS +: COST_BITS] = cost41_in;
assign cost_bus_in[42*COST_BITS +: COST_BITS] = cost42_in;
assign cost_bus_in[43*COST_BITS +: COST_BITS] = cost43_in;
assign cost_bus_in[44*COST_BITS +: COST_BITS] = cost44_in;
assign cost_bus_in[45*COST_BITS +: COST_BITS] = cost45_in;
assign cost_bus_in[46*COST_BITS +: COST_BITS] = cost46_in;
assign cost_bus_in[47*COST_BITS +: COST_BITS] = cost47_in;
assign cost_bus_in[48*COST_BITS +: COST_BITS] = cost48_in;
assign cost_bus_in[49*COST_BITS +: COST_BITS] = cost49_in;
assign cost_bus_in[50*COST_BITS +: COST_BITS] = cost50_in;
assign cost_bus_in[51*COST_BITS +: COST_BITS] = cost51_in;
assign cost_bus_in[52*COST_BITS +: COST_BITS] = cost52_in;
assign cost_bus_in[53*COST_BITS +: COST_BITS] = cost53_in;
assign cost_bus_in[54*COST_BITS +: COST_BITS] = cost54_in;
assign cost_bus_in[55*COST_BITS +: COST_BITS] = cost55_in;
assign cost_bus_in[56*COST_BITS +: COST_BITS] = cost56_in;
assign cost_bus_in[57*COST_BITS +: COST_BITS] = cost57_in;
assign cost_bus_in[58*COST_BITS +: COST_BITS] = cost58_in;
assign cost_bus_in[59*COST_BITS +: COST_BITS] = cost59_in;
assign cost_bus_in[60*COST_BITS +: COST_BITS] = cost60_in;
assign cost_bus_in[61*COST_BITS +: COST_BITS] = cost61_in;
assign cost_bus_in[62*COST_BITS +: COST_BITS] = cost62_in;
assign cost_bus_in[63*COST_BITS +: COST_BITS] = cost63_in;
assign cost_bus_in[64*COST_BITS +: COST_BITS] = cost64_in;

wire left_boundary  = (x_in == 11'd0);
wire right_boundary = (x_in == IMG_WIDTH-1);

wire [10:0] rd_addr_w =
    (DIAG_MODE == 0) ? (left_boundary  ? 11'd0 : (x_in - 11'd1)) :
                       (right_boundary ? 11'd0 : (x_in + 11'd1));

//reg bank_sel_d1, bank_sel_d2; // 1: read even bank, 0: read odd bank

wire diag_boundary_in =
    (y_in == 10'd0) |
    ((DIAG_MODE == 0) ? left_boundary : right_boundary);
/*
reg  [DISP_NUM*COST_BITS-1:0] cost_bus_d1, cost_bus_d2, cost_bus_d3;
reg  [10:0] x_d1, x_d2, x_d3;
reg  [9:0]  y_d1, y_d2, y_d3;
reg         valid_d1, valid_d2, valid_d3;
reg         boundary_d1, boundary_d2, boundary_d3;
*/

reg  [DISP_NUM*COST_BITS-1:0] cost_bus_d1, cost_bus_d2, cost_bus_d3;
reg  [10:0] x_d1, x_d2, x_d3, x_d4;
reg  [9:0]  y_d1, y_d2, y_d3, y_d4;
reg         valid_d1, valid_d2, valid_d3, valid_d4;
reg         boundary_d1, boundary_d2, boundary_d3;
reg         bank_sel_d1, bank_sel_d2, bank_sel_d3, bank_sel_d4;

reg  [STATE_BITS-1:0] prev_state_r;
reg  [STATE_BITS-1:0] curr_state_r;
reg  [STATE_BITS-1:0] next_state_mid_r;
wire [STATE_BITS-1:0] next_state_w;

/*
wire [STATE_BITS-1:0] ram_even_q;
wire [STATE_BITS-1:0] ram_odd_q;
wire [STATE_BITS-1:0] prev_state_q_sel = bank_sel_d2 ? ram_even_q : ram_odd_q;

reg  [STATE_BITS-1:0] prev_state_r;
reg  [STATE_BITS-1:0] curr_state_r;
wire [STATE_BITS-1:0] next_state_w;
*/

wire [BRAM_BITS-1:0] ram_even_q_full;
wire [BRAM_BITS-1:0] ram_odd_q_full;

wire [STATE_BITS-1:0] ram_even_q = ram_even_q_full[STATE_BITS-1:0];
wire [STATE_BITS-1:0] ram_odd_q  = ram_odd_q_full [STATE_BITS-1:0];

wire [STATE_BITS-1:0] prev_state_q_sel = bank_sel_d2 ? ram_even_q : ram_odd_q;

//reg  [STATE_BITS-1:0] prev_state_r;
//reg  [STATE_BITS-1:0] curr_state_r;
//wire [STATE_BITS-1:0] next_state_w;
/*
wire [BRAM_BITS-1:0] next_state_w_pad = {{(BRAM_BITS-STATE_BITS){1'b0}}, next_state_w};


wire wr_even = valid_d3 & (~y_d3[0]);
wire wr_odd  = valid_d3 & ( y_d3[0]);

bram_1280x288 u_ram_even (
    .clock     (clk),
    .data      (next_state_w_pad),
    .rdaddress (rd_addr_w),
    .wraddress (x_d3),
    .wren      (wr_even),
    .q         (ram_even_q_full)
);

bram_1280x288 u_ram_odd (
    .clock    (clk),
    .wren     (wr_odd),
    .wraddress(x_d3),
    .rdaddress(rd_addr_w),
    .data    (next_state_w_pad),
    .q   (ram_odd_q_full)
);
*/

wire [BRAM_BITS-1:0] next_state_mid_pad_w =
    {{(BRAM_BITS-STATE_BITS){1'b0}}, next_state_mid_r};

wire wr_even = valid_d4 & (~bank_sel_d4);
wire wr_odd  = valid_d4 & ( bank_sel_d4);

bram_1280x288 u_ram_even (
    .clock     (clk),
    .data      (next_state_mid_pad_w),
    .rdaddress (rd_addr_w),
    .wraddress (x_d4),
    .wren      (wr_even),
    .q         (ram_even_q_full)
);

bram_1280x288 u_ram_odd (
    .clock     (clk),
    .data      (next_state_mid_pad_w),
    .rdaddress (rd_addr_w),
    .wraddress (x_d4),
    .wren      (wr_odd),
    .q         (ram_odd_q_full)
);

sgbm_path_core_bus #(
    .DISP_NUM    (DISP_NUM),
    .COST_BITS   (COST_BITS),
    .AGG_BITS    (AGG_COST_BITS),
    .P1          (P1),
    .P2          (P2),
    .INVALID_COST(INVALID_COST)
) u_core (
    .cost_bus   (cost_bus_d3),
    .prev_state (prev_state_r),
    .boundary   (boundary_d3),
    .next_state (next_state_w)
);
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bank_sel_d1 <= 1'b1;
        bank_sel_d2 <= 1'b1;

        cost_bus_d1 <= {(DISP_NUM*COST_BITS){1'b0}};
        cost_bus_d2 <= {(DISP_NUM*COST_BITS){1'b0}};
        cost_bus_d3 <= {(DISP_NUM*COST_BITS){1'b0}};
        x_d1 <= 11'd0; x_d2 <= 11'd0; x_d3 <= 11'd0;
        y_d1 <= 10'd0; y_d2 <= 10'd0; y_d3 <= 10'd0;
        valid_d1 <= 1'b0; valid_d2 <= 1'b0; valid_d3 <= 1'b0;
        boundary_d1 <= 1'b1; boundary_d2 <= 1'b1; boundary_d3 <= 1'b1;

        prev_state_r   <= {STATE_BITS{1'b0}};
        curr_state_r   <= {STATE_BITS{1'b0}};
        cost_out_valid <= 1'b0;
        x_out          <= 11'd0;
        y_out          <= 10'd0;
    end else begin
        bank_sel_d1 <= y_in[0];
        bank_sel_d2 <= bank_sel_d1;

        cost_bus_d1 <= cost_bus_in;
        cost_bus_d2 <= cost_bus_d1;
        cost_bus_d3 <= cost_bus_d2;

        x_d1 <= x_in; x_d2 <= x_d1; x_d3 <= x_d2;
        y_d1 <= y_in; y_d2 <= y_d1; y_d3 <= y_d2;

        valid_d1 <= cost_valid;
        valid_d2 <= valid_d1;
        valid_d3 <= valid_d2;

        boundary_d1 <= diag_boundary_in;
        boundary_d2 <= boundary_d1;
        boundary_d3 <= boundary_d2;

        if (valid_d2)
            prev_state_r <= prev_state_q_sel;
        else
            prev_state_r <= {STATE_BITS{1'b0}};

        curr_state_r   <= next_state_w;
        cost_out_valid <= valid_d3;
        x_out          <= x_d3;
        y_out          <= y_d3;
    end
end
*/
/*
always @(posedge clk) begin
    if (!rst_n) begin
        bank_sel_d1 <= 1'b1;
        bank_sel_d2 <= 1'b1;

        x_d1 <= 11'd0; x_d2 <= 11'd0; x_d3 <= 11'd0;
        y_d1 <= 10'd0; y_d2 <= 10'd0; y_d3 <= 10'd0;
        valid_d1 <= 1'b0; valid_d2 <= 1'b0; valid_d3 <= 1'b0;
        boundary_d1 <= 1'b1; boundary_d2 <= 1'b1; boundary_d3 <= 1'b1;

        prev_state_r   <= {STATE_BITS{1'b0}};
        cost_out_valid <= 1'b0;
        x_out          <= 11'd0;
        y_out          <= 10'd0;
    end else begin
        bank_sel_d1 <= y_in[0];
        bank_sel_d2 <= bank_sel_d1;

        cost_bus_d1 <= cost_bus_in;
        cost_bus_d2 <= cost_bus_d1;
        cost_bus_d3 <= cost_bus_d2;

        x_d1 <= x_in; x_d2 <= x_d1; x_d3 <= x_d2;
        y_d1 <= y_in; y_d2 <= y_d1; y_d3 <= y_d2;

        valid_d1 <= cost_valid;
        valid_d2 <= valid_d1;
        valid_d3 <= valid_d2;

        boundary_d1 <= diag_boundary_in;
        boundary_d2 <= boundary_d1;
        boundary_d3 <= boundary_d2;

        if (valid_d2)
            prev_state_r <= prev_state_q_sel;
        else
            prev_state_r <= {STATE_BITS{1'b0}};

        curr_state_r   <= next_state_w;
        cost_out_valid <= valid_d3;
        x_out          <= x_d3;
        y_out          <= y_d3;
    end
end
*/


always @(posedge clk) begin
    if (!rst_n) begin
        bank_sel_d1 <= 1'b1;
        bank_sel_d2 <= 1'b1;
        bank_sel_d3 <= 1'b1;
        bank_sel_d4 <= 1'b1;

        x_d1 <= 11'd0; x_d2 <= 11'd0; x_d3 <= 11'd0; x_d4 <= 11'd0;
        y_d1 <= 10'd0; y_d2 <= 10'd0; y_d3 <= 10'd0; y_d4 <= 10'd0;

        valid_d1 <= 1'b0;
        valid_d2 <= 1'b0;
        valid_d3 <= 1'b0;
        valid_d4 <= 1'b0;

        boundary_d1 <= 1'b1;
        boundary_d2 <= 1'b1;
        boundary_d3 <= 1'b1;

        prev_state_r     <= {STATE_BITS{1'b0}};
        next_state_mid_r <= {STATE_BITS{1'b0}};
        curr_state_r     <= {STATE_BITS{1'b0}};

        cost_out_valid   <= 1'b0;
        x_out            <= 11'd0;
        y_out            <= 10'd0;
    end else begin
        bank_sel_d1 <= y_in[0];
        bank_sel_d2 <= bank_sel_d1;
        bank_sel_d3 <= bank_sel_d2;
        bank_sel_d4 <= bank_sel_d3;

        cost_bus_d1 <= cost_bus_in;
        cost_bus_d2 <= cost_bus_d1;
        cost_bus_d3 <= cost_bus_d2;

        x_d1 <= x_in;
        x_d2 <= x_d1;
        x_d3 <= x_d2;
        x_d4 <= x_d3;

        y_d1 <= y_in;
        y_d2 <= y_d1;
        y_d3 <= y_d2;
        y_d4 <= y_d3;

        valid_d1 <= cost_valid;
        valid_d2 <= valid_d1;
        valid_d3 <= valid_d2;
        valid_d4 <= valid_d3;

        boundary_d1 <= diag_boundary_in;
        boundary_d2 <= boundary_d1;
        boundary_d3 <= boundary_d2;

        if (valid_d2)
            prev_state_r <= prev_state_q_sel;
        else
            prev_state_r <= {STATE_BITS{1'b0}};

        if (valid_d3)
            next_state_mid_r <= next_state_w;
        else
            next_state_mid_r <= {STATE_BITS{1'b0}};

        curr_state_r   <= next_state_mid_r;
        cost_out_valid <= valid_d4;
        x_out          <= x_d4;
        y_out          <= y_d4;
    end
end


assign cost0_out = curr_state_r[0*AGG_COST_BITS +: AGG_COST_BITS];
assign cost1_out = curr_state_r[1*AGG_COST_BITS +: AGG_COST_BITS];
assign cost2_out = curr_state_r[2*AGG_COST_BITS +: AGG_COST_BITS];
assign cost3_out = curr_state_r[3*AGG_COST_BITS +: AGG_COST_BITS];
assign cost4_out = curr_state_r[4*AGG_COST_BITS +: AGG_COST_BITS];
assign cost5_out = curr_state_r[5*AGG_COST_BITS +: AGG_COST_BITS];
assign cost6_out = curr_state_r[6*AGG_COST_BITS +: AGG_COST_BITS];
assign cost7_out = curr_state_r[7*AGG_COST_BITS +: AGG_COST_BITS];
assign cost8_out = curr_state_r[8*AGG_COST_BITS +: AGG_COST_BITS];
assign cost9_out = curr_state_r[9*AGG_COST_BITS +: AGG_COST_BITS];
assign cost10_out = curr_state_r[10*AGG_COST_BITS +: AGG_COST_BITS];
assign cost11_out = curr_state_r[11*AGG_COST_BITS +: AGG_COST_BITS];
assign cost12_out = curr_state_r[12*AGG_COST_BITS +: AGG_COST_BITS];
assign cost13_out = curr_state_r[13*AGG_COST_BITS +: AGG_COST_BITS];
assign cost14_out = curr_state_r[14*AGG_COST_BITS +: AGG_COST_BITS];
assign cost15_out = curr_state_r[15*AGG_COST_BITS +: AGG_COST_BITS];
assign cost16_out = curr_state_r[16*AGG_COST_BITS +: AGG_COST_BITS];
assign cost17_out = curr_state_r[17*AGG_COST_BITS +: AGG_COST_BITS];
assign cost18_out = curr_state_r[18*AGG_COST_BITS +: AGG_COST_BITS];
assign cost19_out = curr_state_r[19*AGG_COST_BITS +: AGG_COST_BITS];
assign cost20_out = curr_state_r[20*AGG_COST_BITS +: AGG_COST_BITS];
assign cost21_out = curr_state_r[21*AGG_COST_BITS +: AGG_COST_BITS];
assign cost22_out = curr_state_r[22*AGG_COST_BITS +: AGG_COST_BITS];
assign cost23_out = curr_state_r[23*AGG_COST_BITS +: AGG_COST_BITS];
assign cost24_out = curr_state_r[24*AGG_COST_BITS +: AGG_COST_BITS];
assign cost25_out = curr_state_r[25*AGG_COST_BITS +: AGG_COST_BITS];
assign cost26_out = curr_state_r[26*AGG_COST_BITS +: AGG_COST_BITS];
assign cost27_out = curr_state_r[27*AGG_COST_BITS +: AGG_COST_BITS];
assign cost28_out = curr_state_r[28*AGG_COST_BITS +: AGG_COST_BITS];
assign cost29_out = curr_state_r[29*AGG_COST_BITS +: AGG_COST_BITS];
assign cost30_out = curr_state_r[30*AGG_COST_BITS +: AGG_COST_BITS];
assign cost31_out = curr_state_r[31*AGG_COST_BITS +: AGG_COST_BITS];
assign cost32_out = curr_state_r[32*AGG_COST_BITS +: AGG_COST_BITS];
assign cost33_out = curr_state_r[33*AGG_COST_BITS +: AGG_COST_BITS];
assign cost34_out = curr_state_r[34*AGG_COST_BITS +: AGG_COST_BITS];
assign cost35_out = curr_state_r[35*AGG_COST_BITS +: AGG_COST_BITS];
assign cost36_out = curr_state_r[36*AGG_COST_BITS +: AGG_COST_BITS];
assign cost37_out = curr_state_r[37*AGG_COST_BITS +: AGG_COST_BITS];
assign cost38_out = curr_state_r[38*AGG_COST_BITS +: AGG_COST_BITS];
assign cost39_out = curr_state_r[39*AGG_COST_BITS +: AGG_COST_BITS];
assign cost40_out = curr_state_r[40*AGG_COST_BITS +: AGG_COST_BITS];
assign cost41_out = curr_state_r[41*AGG_COST_BITS +: AGG_COST_BITS];
assign cost42_out = curr_state_r[42*AGG_COST_BITS +: AGG_COST_BITS];
assign cost43_out = curr_state_r[43*AGG_COST_BITS +: AGG_COST_BITS];
assign cost44_out = curr_state_r[44*AGG_COST_BITS +: AGG_COST_BITS];
assign cost45_out = curr_state_r[45*AGG_COST_BITS +: AGG_COST_BITS];
assign cost46_out = curr_state_r[46*AGG_COST_BITS +: AGG_COST_BITS];
assign cost47_out = curr_state_r[47*AGG_COST_BITS +: AGG_COST_BITS];
assign cost48_out = curr_state_r[48*AGG_COST_BITS +: AGG_COST_BITS];
assign cost49_out = curr_state_r[49*AGG_COST_BITS +: AGG_COST_BITS];
assign cost50_out = curr_state_r[50*AGG_COST_BITS +: AGG_COST_BITS];
assign cost51_out = curr_state_r[51*AGG_COST_BITS +: AGG_COST_BITS];
assign cost52_out = curr_state_r[52*AGG_COST_BITS +: AGG_COST_BITS];
assign cost53_out = curr_state_r[53*AGG_COST_BITS +: AGG_COST_BITS];
assign cost54_out = curr_state_r[54*AGG_COST_BITS +: AGG_COST_BITS];
assign cost55_out = curr_state_r[55*AGG_COST_BITS +: AGG_COST_BITS];
assign cost56_out = curr_state_r[56*AGG_COST_BITS +: AGG_COST_BITS];
assign cost57_out = curr_state_r[57*AGG_COST_BITS +: AGG_COST_BITS];
assign cost58_out = curr_state_r[58*AGG_COST_BITS +: AGG_COST_BITS];
assign cost59_out = curr_state_r[59*AGG_COST_BITS +: AGG_COST_BITS];
assign cost60_out = curr_state_r[60*AGG_COST_BITS +: AGG_COST_BITS];
assign cost61_out = curr_state_r[61*AGG_COST_BITS +: AGG_COST_BITS];
assign cost62_out = curr_state_r[62*AGG_COST_BITS +: AGG_COST_BITS];
assign cost63_out = curr_state_r[63*AGG_COST_BITS +: AGG_COST_BITS];
assign cost64_out = curr_state_r[64*AGG_COST_BITS +: AGG_COST_BITS];

endmodule

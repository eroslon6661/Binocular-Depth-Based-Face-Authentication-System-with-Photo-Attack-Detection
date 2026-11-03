`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// line_buffer_3x3 : BRAM drop-in replacement for the original top_sgbm_cost
//
// FIXED VERSION:
// - removed .rden() port connections because your BRAM IP does not expose rden
// - keeps old top_sgbm_cost interface unchanged
// -----------------------------------------------------------------------------
module line_buffer_3x3 #(
    parameter IMG_WIDTH         = 1280,
    parameter IMG_HEIGHT        = 720,
    parameter PIXEL_BITS        = 8,
    parameter LINE_BUFFER_DEPTH = 11
) (
    input                         clk,
    input                         rst_n,
    input                         pixel_valid,
    input  [PIXEL_BITS-1:0]       pixel_in,
    output [PIXEL_BITS-1:0]       matrix_11,
    output [PIXEL_BITS-1:0]       matrix_12,
    output [PIXEL_BITS-1:0]       matrix_13,
    output [PIXEL_BITS-1:0]       matrix_21,
    output [PIXEL_BITS-1:0]       matrix_22,
    output [PIXEL_BITS-1:0]       matrix_23,
    output [PIXEL_BITS-1:0]       matrix_31,
    output [PIXEL_BITS-1:0]       matrix_32,
    output [PIXEL_BITS-1:0]       matrix_33,
    output reg                    window_valid
);

wire reset = ~rst_n;

// ---------------------- 1. input / counter alignment -------------------------
reg [PIXEL_BITS-1:0] data_in_d1, data_in_d2;
reg                  data_valid_d1, data_valid_d2;
reg [10:0]           col_cnt_d1, col_cnt_d2;
reg [9:0]            row_cnt_d1, row_cnt_d2;
reg                  line_end_flag;
reg                  line_end_flag_d1, line_end_flag_d2;
reg                  window_valid_1;

reg [10:0] col_cnt;
reg [9:0]  row_cnt;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        col_cnt        <= 11'd0;
        row_cnt        <= 10'd0;
        line_end_flag  <= 1'b0;
    end else if (pixel_valid) begin
        line_end_flag <= 1'b0;
        if (col_cnt == IMG_WIDTH - 1) begin
            col_cnt <= 11'd0;
            row_cnt <= (row_cnt == IMG_HEIGHT - 1) ? 10'd0 : (row_cnt + 10'd1);
            line_end_flag <= 1'b1;
        end else begin
            col_cnt <= col_cnt + 11'd1;
        end
    end else begin
        line_end_flag <= 1'b0;
    end
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_in_d1        <= {PIXEL_BITS{1'b0}};
        data_in_d2        <= {PIXEL_BITS{1'b0}};
        data_valid_d1     <= 1'b0;
        data_valid_d2     <= 1'b0;
        col_cnt_d1        <= 11'd0;
        col_cnt_d2        <= 11'd0;
        row_cnt_d1        <= 10'd0;
        row_cnt_d2        <= 10'd0;
        line_end_flag_d1  <= 1'b0;
        line_end_flag_d2  <= 1'b0;
    end else begin
        // align to BRAM internal read pipeline
        data_valid_d1    <= pixel_valid;
        data_in_d1       <= pixel_in;
        col_cnt_d1       <= col_cnt;
        row_cnt_d1       <= row_cnt;
        line_end_flag_d1 <= line_end_flag;

        data_valid_d2    <= data_valid_d1;
        data_in_d2       <= data_in_d1;
        col_cnt_d2       <= col_cnt_d1;
        row_cnt_d2       <= row_cnt_d1;
        line_end_flag_d2 <= line_end_flag_d1;
    end
end

// ---------------------- 2. BRAM interface -----------------------------------
wire [7:0] bram0_dout;
wire [7:0] bram1_dout;

reg  [10:0] bram0_rdaddr;
reg  [10:0] bram0_wraddr;
reg         bram0_wren;
reg  [7:0]  bram0_din;

reg  [10:0] bram1_rdaddr;
reg  [10:0] bram1_wraddr;
reg         bram1_wren;
reg  [7:0]  bram1_din;

always @(*) begin
    bram0_rdaddr = 11'd0;
    bram0_wraddr = 11'd0;
    bram0_wren   = 1'b0;
    bram0_din    = 8'd0;

    bram1_rdaddr = 11'd0;
    bram1_wraddr = 11'd0;
    bram1_wren   = 1'b0;
    bram1_din    = 8'd0;

    // write current line into BRAM1
    if (pixel_valid) begin
        bram1_wraddr = col_cnt;
        bram1_wren   = 1'b1;
        bram1_din    = pixel_in;

        // no rden port on this IP, so read address is driven continuously
        bram1_rdaddr = col_cnt;
        bram0_rdaddr = col_cnt;
    end

    // roll BRAM1 data into BRAM0 after 2-cycle alignment
    if (data_valid_d2 && (row_cnt_d2 >= 10'd1)) begin
        bram0_wraddr = col_cnt_d2;
        bram0_wren   = 1'b1;
        bram0_din    = bram1_dout;
    end
end

// NOTE: this IP name is the user's BRAM line buffer IP.
// This version assumes the IP ports are:
//   clock, data, rdaddress, wraddress, wren, q
bram_line_8x1280 bram0_inst (
    .clock     (clk),
    .data      (bram0_din),
    .rdaddress (bram0_rdaddr),
    .wraddress (bram0_wraddr),
    .wren      (bram0_wren),
    .q         (bram0_dout)
);

bram_line_8x1280 bram1_inst (
    .clock     (clk),
    .data      (bram1_din),
    .rdaddress (bram1_rdaddr),
    .wraddress (bram1_wraddr),
    .wren      (bram1_wren),
    .q         (bram1_dout)
);

// ---------------------- 3. 3x3 shift registers ------------------------------
reg [7:0] row0_d0, row0_d1, row0_d2; // oldest row
reg [7:0] row1_d0, row1_d1, row1_d2; // middle row
reg [7:0] row2_d0, row2_d1, row2_d2; // newest row

always @(posedge clk or posedge reset) begin
    if (reset) begin
        row0_d0 <= 8'd0; row0_d1 <= 8'd0; row0_d2 <= 8'd0;
        row1_d0 <= 8'd0; row1_d1 <= 8'd0; row1_d2 <= 8'd0;
        row2_d0 <= 8'd0; row2_d1 <= 8'd0; row2_d2 <= 8'd0;
   // end else if (line_end_flag_d2) begin
      //  row0_d0 <= 8'd0; row0_d1 <= 8'd0; row0_d2 <= 8'd0;
     //   row1_d0 <= 8'd0; row1_d1 <= 8'd0; row1_d2 <= 8'd0;
     //   row2_d0 <= 8'd0; row2_d1 <= 8'd0; row2_d2 <= 8'd0;
    end else if (data_valid_d2) begin
        // three inputs are column-aligned here
        row0_d0 <= bram0_dout;
        row0_d1 <= row0_d0;
        row0_d2 <= row0_d1;

        row1_d0 <= bram1_dout;
        row1_d1 <= row1_d0;
        row1_d2 <= row1_d1;

        row2_d0 <= data_in_d2;
        row2_d1 <= row2_d0;
        row2_d2 <= row2_d1;
    end
end

// ---------------------- 4. output register / valid alignment ----------------
reg [7:0] p00, p01, p02;
reg [7:0] p10, p11, p12;
reg [7:0] p20, p21, p22;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        p00 <= 8'd0; p01 <= 8'd0; p02 <= 8'd0;
        p10 <= 8'd0; p11 <= 8'd0; p12 <= 8'd0;
        p20 <= 8'd0; p21 <= 8'd0; p22 <= 8'd0;
        window_valid_1 <= 1'b0;
        window_valid   <= 1'b0;
    end else begin
        p00 <= row0_d0; p01 <= row0_d1; p02 <= row0_d2;
        p10 <= row1_d0; p11 <= row1_d1; p12 <= row1_d2;
        p20 <= row2_d0; p21 <= row2_d1; p22 <= row2_d2;

        window_valid_1 <= data_valid_d2 && (row_cnt_d2 >= 10'd2) && (col_cnt_d2 >= 11'd2);
        window_valid   <= window_valid_1;
    end
end

// ---------------------- 5. map to old interface naming ----------------------
assign matrix_11 = p02;
assign matrix_12 = p01;
assign matrix_13 = p00;

assign matrix_21 = p12;
assign matrix_22 = p11;
assign matrix_23 = p10;

assign matrix_31 = p22;
assign matrix_32 = p21;
assign matrix_33 = p20;

endmodule

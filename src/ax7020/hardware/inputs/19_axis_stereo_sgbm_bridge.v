`timescale 1ns / 1ps

// Two synchronized RGB888 AXI4-Stream frames -> 1280x720 disparity image.
//
// The two input streams are read from independent DDR frame buffers at the
// same clock.  A pair is accepted only when both streams have a pixel ready,
// so the SGBM core always sees matching (x,y) samples.  The 3x3 census stage
// produces a 1278x718 interior image.  This wrapper adds a one-pixel black
// border and sends a full 1280x720 RGB888 frame to the result VDMA.
module axis_stereo_sgbm_bridge #(
    parameter IMG_WIDTH  = 1280,
    parameter IMG_HEIGHT = 720
)(
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF s0_axis:s1_axis:m_axis, ASSOCIATED_RESET aresetn" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
    input  wire          aclk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    input  wire          aresetn,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s0_axis TDATA" *)
    input  wire [23:0]   s0_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s0_axis TKEEP" *)
    input  wire [2:0]    s0_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s0_axis TVALID" *)
    input  wire          s0_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s0_axis TREADY" *)
    output wire          s0_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s0_axis TUSER" *)
    input  wire          s0_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s0_axis TLAST" *)
    input  wire          s0_axis_tlast,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s1_axis TDATA" *)
    input  wire [23:0]   s1_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s1_axis TKEEP" *)
    input  wire [2:0]    s1_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s1_axis TVALID" *)
    input  wire          s1_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s1_axis TREADY" *)
    output wire          s1_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s1_axis TUSER" *)
    input  wire          s1_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s1_axis TLAST" *)
    input  wire          s1_axis_tlast,

    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
    output wire [23:0]   m_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *)
    output wire [2:0]    m_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
    output wire          m_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *)
    input  wire          m_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TUSER" *)
    output wire          m_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *)
    output wire          m_axis_tlast
);

localparam INTERIOR_WIDTH  = IMG_WIDTH  - 2;
localparam INTERIOR_HEIGHT = IMG_HEIGHT - 2;

// Synchronize reset release into the 30 MHz SGBM clock domain.
(* ASYNC_REG = "TRUE" *) reg [1:0] rst_sync;
always @(posedge aclk or negedge aresetn) begin
    if (!aresetn)
        rst_sync <= 2'b00;
    else
        rst_sync <= {rst_sync[0], 1'b1};
end
wire core_rst_n = rst_sync[1];

// Use an inexpensive luminance approximation.  The byte order is irrelevant
// to synchronization; if the RGB/BGR order differs, only the color weights
// change slightly.
wire [9:0] gray0_sum = {2'b00, s0_axis_tdata[7:0]} +
                       ({2'b00, s0_axis_tdata[15:8]} << 1) +
                       {2'b00, s0_axis_tdata[23:16]};
wire [9:0] gray1_sum = {2'b00, s1_axis_tdata[7:0]} +
                       ({2'b00, s1_axis_tdata[15:8]} << 1) +
                       {2'b00, s1_axis_tdata[23:16]};
wire [7:0] left_gray  = gray0_sum[9:2];
wire [7:0] right_gray = gray1_sum[9:2];

wire fifo_full;
wire fifo_prog_full;
wire fifo_empty;
wire fifo_wr_rst_busy;
wire fifo_rd_rst_busy;
wire [7:0] fifo_dout;
wire fifo_rd_en;

wire accept_pair = core_rst_n && !fifo_prog_full && !fifo_wr_rst_busy;
assign s0_axis_tready = accept_pair && s1_axis_tvalid;
assign s1_axis_tready = accept_pair && s0_axis_tvalid;
wire pair_fire = s0_axis_tvalid && s1_axis_tvalid && accept_pair;
wire input_sof = pair_fire && s0_axis_tuser && s1_axis_tuser;

wire        gray_valid;
wire [10:0] gray_x;
wire [9:0]  gray_y;
wire [7:0]  gray_pixel;
wire        median_valid;
wire [7:0]  median_pixel;

top_sgbm_uniqueness_display_depth #(
    .IMG_WIDTH         (IMG_WIDTH),
    .IMG_HEIGHT        (IMG_HEIGHT),
    .PIXEL_BITS        (8),
    .SINGLE_PATH_BITS  (4),
    .AGG_COST_BITS     (6),
    .DISP_BITS         (7),
    .P1                (4'd2),
    .P2                (4'd8),
    .TH_DIFF           (3),
    .BYPASS_UNIQUENESS (0),
    .FB_NUM            (16'd6000),
    .DEPTH_MAX         (16'hFFFF),
    .GRAY_INVERT       (0)
) u_sgbm (
    .clk               (aclk),
    .rst_n             (core_rst_n),
    .pixel_valid       (pair_fire),
    .left_pixel        (left_gray),
    .right_pixel       (right_gray),
    .disp_valid        (),
    .disp_x_out        (),
    .disp_y_out        (),
    .disp_out          (),
    .unique_pass       (),
    .depth_valid       (),
    .depth_x_out       (),
    .depth_y_out       (),
    .depth_out         (),
    .depth_reliable    (),
    .gray_valid        (gray_valid),
    .gray_x_out        (gray_x),
    .gray_y_out        (gray_y),
    .gray_out          (gray_pixel),
    .gray_reliable     (),
    .raw_disp_out      (),
    .min1_cost_out     (),
    .min2_cost_out     ()
);

sgbm_median3x3 #(.IMG_WIDTH(INTERIOR_WIDTH)) u_disparity_median (
    .clk(aclk), .rst_n(core_rst_n),
    .in_valid(gray_valid), .x_in(gray_x), .y_in(gray_y),
    .pixel_in(gray_pixel),
    .out_valid(median_valid), .pixel_out(median_pixel)
);

// The FIFO absorbs VDMA burst back-pressure and the two border cycles added
// to every output line.  prog_full leaves room for pixels already in flight
// inside the SGBM pipeline.
wire fifo_wr_en = median_valid && !fifo_full && !fifo_wr_rst_busy;
xpm_fifo_sync #(
    .DOUT_RESET_VALUE    ("0"),
    .ECC_MODE            ("no_ecc"),
    .FIFO_MEMORY_TYPE    ("block"),
    .FIFO_READ_LATENCY   (0),
    .FIFO_WRITE_DEPTH    (4096),
    .FULL_RESET_VALUE    (0),
    .PROG_EMPTY_THRESH   (10),
    .PROG_FULL_THRESH    (3800),
    .RD_DATA_COUNT_WIDTH (13),
    .READ_DATA_WIDTH     (8),
    .READ_MODE           ("fwft"),
    .SIM_ASSERT_CHK      (0),
    .USE_ADV_FEATURES    ("0002"),
    .WAKEUP_TIME         (0),
    .WR_DATA_COUNT_WIDTH (13),
    .WRITE_DATA_WIDTH    (8)
) u_result_fifo (
    .almost_empty  (),
    .almost_full   (),
    .data_valid    (),
    .dbiterr       (),
    .dout          (fifo_dout),
    .empty         (fifo_empty),
    .full          (fifo_full),
    .overflow      (),
    .prog_empty    (),
    .prog_full     (fifo_prog_full),
    .rd_data_count (),
    .rd_rst_busy   (fifo_rd_rst_busy),
    .sbiterr       (),
    .underflow     (),
    .wr_ack        (),
    .wr_data_count (),
    .wr_rst_busy   (fifo_wr_rst_busy),
    .din           (median_pixel),
    .injectdbiterr (1'b0),
    .injectsbiterr (1'b0),
    .rd_en         (fifo_rd_en),
    .rst           (~core_rst_n),
    .sleep         (1'b0),
    .wr_clk        (aclk),
    .wr_en         (fifo_wr_en)
);

localparam ST_IDLE   = 3'd0;
localparam ST_TOP    = 3'd1;
localparam ST_LEFT   = 3'd2;
localparam ST_DATA   = 3'd3;
localparam ST_RIGHT  = 3'd4;
localparam ST_BOTTOM = 3'd5;

reg [2:0]  state;
reg [10:0] border_x;
reg [10:0] data_x;
reg [9:0]  interior_y;
reg [2:0]  pending_frames;

wire start_frame = (state == 3'd0) && (pending_frames != 0) && core_rst_n;
wire out_fire = m_axis_tvalid && m_axis_tready;

always @(posedge aclk or negedge core_rst_n) begin
    if (!core_rst_n) begin
        pending_frames <= 3'd0;
    end else begin
        case ({input_sof, start_frame})
            2'b10: if (pending_frames != 3'd7)
                       pending_frames <= pending_frames + 3'd1;
            2'b01: pending_frames <= pending_frames - 3'd1;
            default: pending_frames <= pending_frames;
        endcase
    end
end

always @(posedge aclk or negedge core_rst_n) begin
    if (!core_rst_n) begin
        state      <= ST_IDLE;
        border_x   <= 11'd0;
        data_x     <= 11'd0;
        interior_y <= 10'd0;
    end else begin
        case (state)
            ST_IDLE: begin
                border_x <= 11'd0;
                if (start_frame)
                    state <= ST_TOP;
            end

            ST_TOP: if (out_fire) begin
                if (border_x == IMG_WIDTH-1) begin
                    border_x   <= 11'd0;
                    data_x     <= 11'd0;
                    interior_y <= 10'd0;
                    state      <= ST_LEFT;
                end else begin
                    border_x <= border_x + 11'd1;
                end
            end

            ST_LEFT: if (out_fire) begin
                data_x <= 11'd0;
                state  <= ST_DATA;
            end

            ST_DATA: if (out_fire) begin
                if (data_x == INTERIOR_WIDTH-1) begin
                    data_x <= 11'd0;
                    state  <= ST_RIGHT;
                end else begin
                    data_x <= data_x + 11'd1;
                end
            end

            ST_RIGHT: if (out_fire) begin
                if (interior_y == INTERIOR_HEIGHT-1) begin
                    border_x <= 11'd0;
                    state    <= ST_BOTTOM;
                end else begin
                    interior_y <= interior_y + 10'd1;
                    state      <= ST_LEFT;
                end
            end

            ST_BOTTOM: if (out_fire) begin
                if (border_x == IMG_WIDTH-1) begin
                    border_x <= 11'd0;
                    state    <= ST_IDLE;
                end else begin
                    border_x <= border_x + 11'd1;
                end
            end

            default: state <= ST_IDLE;
        endcase
    end
end

assign m_axis_tkeep  = 3'b111;
assign m_axis_tdata  = (state == ST_DATA) ? {fifo_dout, fifo_dout, fifo_dout} : 24'h000000;
assign m_axis_tvalid = (state == ST_TOP)   ? 1'b1 :
                       (state == ST_LEFT)  ? 1'b1 :
                       (state == ST_DATA)  ? (!fifo_empty && !fifo_rd_rst_busy) :
                       (state == ST_RIGHT) ? 1'b1 :
                       (state == ST_BOTTOM)? 1'b1 : 1'b0;
assign m_axis_tuser  = (state == ST_TOP) && (border_x == 0);
assign m_axis_tlast  = ((state == ST_TOP) || (state == ST_BOTTOM)) ?
                       (border_x == IMG_WIDTH-1) : (state == ST_RIGHT);
assign fifo_rd_en    = (state == ST_DATA) && out_fire;

// Keep optional input side-band signals visible to lint/synthesis without
// changing the one-pixel-per-beat datapath.
wire unused_sideband = &{1'b0, s0_axis_tkeep, s1_axis_tkeep,
                         s0_axis_tlast, s1_axis_tlast, gray_x, gray_y};

endmodule

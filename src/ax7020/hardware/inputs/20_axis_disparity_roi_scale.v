`timescale 1ns / 1ps

// Preserve RGB channels while expanding the 1024x640 source region to the 1280x720 HDMI raster.
// Horizontal samples are interpolated; input VDMA back-pressure allows a
// single line to be buffered before it is displayed.
module axis_disparity_roi_scale (
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF s_axis:m_axis, ASSOCIATED_RESET aresetn" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
    input  wire        aclk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    input  wire        aresetn,
    // Written by the PS through AXI GPIO channel 2: {distance_cm[9:0],
    // enable, y[9:0], x[10:0]}. The measurement result stays visible until
    // the cursor moves; zero distance means no measurement yet.
    input  wire [31:0] cursor_control,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *)
    input  wire [23:0] s_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *)
    input  wire [2:0]  s_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *)
    input  wire        s_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *)
    output wire        s_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TUSER" *)
    input  wire        s_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *)
    input  wire        s_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
    output wire [23:0] m_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *)
    output wire [2:0]  m_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
    output wire        m_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *)
    input  wire        m_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TUSER" *)
    output wire        m_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *)
    output wire        m_axis_tlast
);

localparam WAIT_SOF = 2'd0;
localparam FILL     = 2'd1;
localparam OUTPUT   = 2'd2;

(* ram_style = "block" *) reg [23:0] line_buffer_a [0:1023];
(* ram_style = "block" *) reg [23:0] line_buffer_b [0:1023];
reg [1:0] state;
reg [9:0] input_x;
reg [9:0] input_y;
reg [10:0] output_x;
reg [9:0] output_y;
reg [9:0] source_x;
reg [2:0] horizontal_phase;
reg duplicate_line;
reg [23:0] pixel_a;
reg [23:0] pixel_b;
reg [10:0] weighted_sum [0:2];
reg [10:0] interp_sum [0:2];
reg [23:0] interp_copy;
reg interp_is_copy;
reg interp_valid;
reg interp_user;
reg interp_last;
reg [23:0] pipe_data;
reg pipe_valid;
reg pipe_user;
reg pipe_last;
(* ASYNC_REG = "TRUE" *) reg [31:0] cursor_meta;
(* ASYNC_REG = "TRUE" *) reg [31:0] cursor_sync;
reg [31:0] cursor_frame;
reg interp_cross_inner;
reg interp_cross_outer;
reg interp_measured;
wire [10:0] cursor_x = cursor_frame[10:0];
wire [9:0] cursor_y = cursor_frame[20:11];
wire near_vertical = (output_x >= cursor_x - 11'd16) &&
                     (output_x <= cursor_x + 11'd16) &&
                     (output_y >= cursor_y - 10'd2) &&
                     (output_y <= cursor_y + 10'd2);
wire near_horizontal = (output_y >= cursor_y - 10'd16) &&
                       (output_y <= cursor_y + 10'd16) &&
                       (output_x >= cursor_x - 11'd2) &&
                       (output_x <= cursor_x + 11'd2);
wire core_vertical = (output_x >= cursor_x - 11'd14) &&
                     (output_x <= cursor_x + 11'd14) &&
                     (output_y == cursor_y);
wire core_horizontal = (output_y >= cursor_y - 10'd14) &&
                       (output_y <= cursor_y + 10'd14) &&
                       (output_x == cursor_x);

wire input_fire = s_axis_tvalid && s_axis_tready;
wire pipe_ready = !pipe_valid || m_axis_tready;
wire interp_ready = !interp_valid || pipe_ready;
wire generate_fire = (state == OUTPUT) && interp_ready;
wire [9:0] next_source_x = source_x + (horizontal_phase != 3'd0);
wire read_first_pixel = (state == FILL && input_fire &&
                         input_x == 10'd1023) ||
                        (state == OUTPUT && generate_fire &&
                         output_x == 11'd1279);
wire read_enable = read_first_pixel || generate_fire;
wire [9:0] read_address = read_first_pixel ? 10'd0 : next_source_x;
wire [9:0] read_address_next = read_first_pixel ? 10'd1 :
                                ((next_source_x == 10'd1023) ? 10'd1023 :
                                 next_source_x + 10'd1);
wire [23:0] output_rgb;
genvar channel;
generate for(channel=0;channel<3;channel=channel+1) begin: rgb_channels
    wire [10:0] a = {3'b000,pixel_a[channel*8 +: 8]};
    wire [10:0] b = {3'b000,pixel_b[channel*8 +: 8]};
    always @(*) begin
        case(horizontal_phase)
            3'd1: weighted_sum[channel] = a + (b << 2);
            3'd2: weighted_sum[channel] = (a << 1) + b + (b << 1);
            3'd3: weighted_sum[channel] = a + (a << 1) + (b << 1);
            3'd4: weighted_sum[channel] = (a << 2) + b;
            default: weighted_sum[channel] = 11'd0;
        endcase
    end
    always @(posedge aclk) begin
        if(!aresetn) interp_sum[channel] <= 11'd0;
        else if(interp_ready && state==OUTPUT)
            interp_sum[channel] <= weighted_sum[channel];
    end
    assign output_rgb[channel*8 +: 8] = interp_is_copy ?
        interp_copy[channel*8 +: 8] : (interp_sum[channel]+11'd2)/5;
end endgenerate

assign s_axis_tready = (state == WAIT_SOF) || (state == FILL);
assign m_axis_tdata = pipe_data;
assign m_axis_tkeep = 3'b111;
assign m_axis_tvalid = pipe_valid;
assign m_axis_tuser = pipe_user;
assign m_axis_tlast = pipe_last;

always @(posedge aclk) begin
    if (!aresetn) begin
        cursor_meta <= 32'd0;
        cursor_sync <= 32'd0;
        cursor_frame <= 32'd0;
        interp_valid <= 1'b0;
        interp_copy <= 24'd0;
        interp_is_copy <= 1'b0;
        interp_user <= 1'b0;
        interp_last <= 1'b0;
        pipe_valid <= 1'b0;
        pipe_data <= 24'd0;
        pipe_user <= 1'b0;
        pipe_last <= 1'b0;
        interp_cross_inner <= 1'b0;
        interp_cross_outer <= 1'b0;
        interp_measured <= 1'b0;
    end else begin
        cursor_meta <= cursor_control;
        cursor_sync <= cursor_meta;
        if (input_fire && s_axis_tuser)
            cursor_frame <= cursor_sync;
        if (interp_ready) begin
            interp_valid <= (state == OUTPUT);
            if (state == OUTPUT) begin
                interp_copy <= pixel_a;
                interp_is_copy <= (horizontal_phase == 0);
                interp_user <= (output_x == 0) && (output_y == 0);
                interp_last <= (output_x == 11'd1279);
                interp_cross_inner <= cursor_frame[21] &&
                                      (core_vertical || core_horizontal);
                interp_cross_outer <= cursor_frame[21] &&
                                      (near_vertical || near_horizontal);
                interp_measured <= (cursor_frame[31:22] != 10'd0);
            end
        end
        if (pipe_ready) begin
            pipe_valid <= interp_valid;
            if (interp_valid) begin
                pipe_data <= interp_cross_inner ?
                             (interp_measured ? 24'h00FF00 : 24'hFFFF00) :
                             interp_cross_outer ? 24'h000000 :
                             output_rgb;
                pipe_user <= interp_user;
                pipe_last <= interp_last;
            end
        end
    end
end

always @(posedge aclk) begin
    if (input_fire && ((state == FILL) || s_axis_tuser))
        line_buffer_a[input_x] <= s_axis_tdata;
    if (read_enable)
        pixel_a <= line_buffer_a[read_address];
end

always @(posedge aclk) begin
    if (input_fire && ((state == FILL) || s_axis_tuser))
        line_buffer_b[input_x] <= s_axis_tdata;
    if (read_enable)
        pixel_b <= line_buffer_b[read_address_next];
end

always @(posedge aclk) begin
    if (!aresetn) begin
        state <= WAIT_SOF;
        input_x <= 0;
        input_y <= 0;
        output_x <= 0;
        output_y <= 0;
        source_x <= 0;
        horizontal_phase <= 0;
        duplicate_line <= 0;
    end else begin
        case (state)
            WAIT_SOF: if (input_fire && s_axis_tuser) begin
                input_x <= 10'd1;
                input_y <= 0;
                output_y <= 0;
                duplicate_line <= 0;
                state <= FILL;
            end
            FILL: if (input_fire) begin
                if (input_x == 10'd1023) begin
                    input_x <= 0;
                    output_x <= 0;
                    source_x <= 0;
                    horizontal_phase <= 0;
                    state <= OUTPUT;
                end else begin
                    input_x <= input_x + 10'd1;
                end
            end
            OUTPUT: if (generate_fire) begin
                if (output_x == 11'd1279) begin
                    output_x <= 0;
                    source_x <= 0;
                    horizontal_phase <= 0;
                    if (output_y == 10'd719) begin
                        state <= WAIT_SOF;
                    end else begin
                        output_y <= output_y + 10'd1;
                        if (input_y[2:0] == 3'd7 && !duplicate_line) begin
                            duplicate_line <= 1'b1;
                        end else begin
                            duplicate_line <= 1'b0;
                            input_y <= input_y + 10'd1;
                            state <= FILL;
                        end
                    end
                end else begin
                    output_x <= output_x + 11'd1;
                    source_x <= next_source_x;
                    horizontal_phase <= (horizontal_phase == 3'd4) ? 0 :
                                        horizontal_phase + 3'd1;
                end
            end
            default: state <= WAIT_SOF;
        endcase
    end
end

wire unused_sideband = &{1'b0, s_axis_tkeep, s_axis_tlast};
endmodule

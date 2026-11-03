`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Disparity -> Depth LUT module
//
// Depth model:
//     Z = FB_NUM / d
//
// Design choice:
// - NO runtime divider is inferred for variable disparity.
// - For d = 1..64, the output is implemented as a compile-time LUT (case table).
// - Much lighter and more timing-friendly than a generic divider.
//
// Notes:
// - disp_in = 0 => depth_out = 0, depth_reliable = 0
// - unique_pass_in = 0 => depth_out = 0, depth_reliable = 0
// - out_valid keeps raster timing for downstream display/depth pipeline
// - 1-cycle pipeline
// -----------------------------------------------------------------------------
module sgbm_depth_from_disp_lut #(
    parameter DISP_BITS   = 7,
    parameter DEPTH_BITS  = 16,
    parameter FB_NUM      = 16'd6000,   // f * B * scale
    parameter DEPTH_MAX   = 16'hFFFF
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
    output reg  [DISP_BITS-1:0]     disp_out,
    output reg  [DEPTH_BITS-1:0]    depth_out,
    output reg                      depth_reliable
);

reg [DEPTH_BITS-1:0] depth_lut;

always @(*) begin
    depth_lut = {DEPTH_BITS{1'b0}};
    case (disp_in)
                7'd1: depth_lut = (FB_NUM / 1 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 1);
                7'd2: depth_lut = (FB_NUM / 2 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 2);
                7'd3: depth_lut = (FB_NUM / 3 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 3);
                7'd4: depth_lut = (FB_NUM / 4 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 4);
                7'd5: depth_lut = (FB_NUM / 5 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 5);
                7'd6: depth_lut = (FB_NUM / 6 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 6);
                7'd7: depth_lut = (FB_NUM / 7 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 7);
                7'd8: depth_lut = (FB_NUM / 8 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 8);
                7'd9: depth_lut = (FB_NUM / 9 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 9);
                7'd10: depth_lut = (FB_NUM / 10 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 10);
                7'd11: depth_lut = (FB_NUM / 11 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 11);
                7'd12: depth_lut = (FB_NUM / 12 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 12);
                7'd13: depth_lut = (FB_NUM / 13 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 13);
                7'd14: depth_lut = (FB_NUM / 14 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 14);
                7'd15: depth_lut = (FB_NUM / 15 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 15);
                7'd16: depth_lut = (FB_NUM / 16 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 16);
                7'd17: depth_lut = (FB_NUM / 17 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 17);
                7'd18: depth_lut = (FB_NUM / 18 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 18);
                7'd19: depth_lut = (FB_NUM / 19 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 19);
                7'd20: depth_lut = (FB_NUM / 20 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 20);
                7'd21: depth_lut = (FB_NUM / 21 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 21);
                7'd22: depth_lut = (FB_NUM / 22 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 22);
                7'd23: depth_lut = (FB_NUM / 23 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 23);
                7'd24: depth_lut = (FB_NUM / 24 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 24);
                7'd25: depth_lut = (FB_NUM / 25 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 25);
                7'd26: depth_lut = (FB_NUM / 26 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 26);
                7'd27: depth_lut = (FB_NUM / 27 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 27);
                7'd28: depth_lut = (FB_NUM / 28 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 28);
                7'd29: depth_lut = (FB_NUM / 29 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 29);
                7'd30: depth_lut = (FB_NUM / 30 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 30);
                7'd31: depth_lut = (FB_NUM / 31 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 31);
                7'd32: depth_lut = (FB_NUM / 32 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 32);
                7'd33: depth_lut = (FB_NUM / 33 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 33);
                7'd34: depth_lut = (FB_NUM / 34 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 34);
                7'd35: depth_lut = (FB_NUM / 35 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 35);
                7'd36: depth_lut = (FB_NUM / 36 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 36);
                7'd37: depth_lut = (FB_NUM / 37 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 37);
                7'd38: depth_lut = (FB_NUM / 38 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 38);
                7'd39: depth_lut = (FB_NUM / 39 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 39);
                7'd40: depth_lut = (FB_NUM / 40 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 40);
                7'd41: depth_lut = (FB_NUM / 41 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 41);
                7'd42: depth_lut = (FB_NUM / 42 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 42);
                7'd43: depth_lut = (FB_NUM / 43 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 43);
                7'd44: depth_lut = (FB_NUM / 44 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 44);
                7'd45: depth_lut = (FB_NUM / 45 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 45);
                7'd46: depth_lut = (FB_NUM / 46 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 46);
                7'd47: depth_lut = (FB_NUM / 47 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 47);
                7'd48: depth_lut = (FB_NUM / 48 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 48);
                7'd49: depth_lut = (FB_NUM / 49 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 49);
                7'd50: depth_lut = (FB_NUM / 50 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 50);
                7'd51: depth_lut = (FB_NUM / 51 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 51);
                7'd52: depth_lut = (FB_NUM / 52 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 52);
                7'd53: depth_lut = (FB_NUM / 53 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 53);
                7'd54: depth_lut = (FB_NUM / 54 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 54);
                7'd55: depth_lut = (FB_NUM / 55 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 55);
                7'd56: depth_lut = (FB_NUM / 56 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 56);
                7'd57: depth_lut = (FB_NUM / 57 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 57);
                7'd58: depth_lut = (FB_NUM / 58 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 58);
                7'd59: depth_lut = (FB_NUM / 59 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 59);
                7'd60: depth_lut = (FB_NUM / 60 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 60);
                7'd61: depth_lut = (FB_NUM / 61 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 61);
                7'd62: depth_lut = (FB_NUM / 62 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 62);
                7'd63: depth_lut = (FB_NUM / 63 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 63);
                7'd64: depth_lut = (FB_NUM / 64 > DEPTH_MAX) ? DEPTH_MAX : (FB_NUM / 64);
        default: depth_lut = {DEPTH_BITS{1'b0}};
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid       <= 1'b0;
        x_out           <= 11'd0;
        y_out           <= 10'd0;
        disp_out        <= {DISP_BITS{1'b0}};
        depth_out       <= {DEPTH_BITS{1'b0}};
        depth_reliable  <= 1'b0;
    end else begin
        out_valid <= in_valid;
        x_out     <= x_in;
        y_out     <= y_in;
        disp_out  <= disp_in;

        if (in_valid && unique_pass_in && (disp_in != {DISP_BITS{1'b0}})) begin
            depth_out      <= depth_lut;
            depth_reliable <= 1'b1;
        end else begin
            depth_out      <= {DEPTH_BITS{1'b0}};
            depth_reliable <= 1'b0;
        end
    end
end

endmodule

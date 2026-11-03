`timescale 1ns/1ps
// Handshake-preserving GREEN8 conversion. Both instances share the same
// 150 MHz clock/reset so capture timestamps are directly comparable.
module axis_rgb_to_green_oneway #(
    parameter CLOCK_HZ=150000000, parameter HEIGHT=720
)(
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF s_axis:m_axis, ASSOCIATED_RESET aresetn" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *)
    input wire aclk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
    input wire aresetn,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *)
    input wire [23:0] s_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *)
    input wire [2:0] s_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *)
    input wire s_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *)
    output wire s_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TUSER" *)
    input wire s_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *)
    input wire s_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
    output wire [7:0] m_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *)
    output wire m_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
    output wire m_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *)
    input wire m_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TUSER" *)
    output wire m_axis_tuser,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *)
    output wire m_axis_tlast,
    output reg [31:0] safe_sequence,
    output reg [31:0] safe_capture_us, output wire [31:0] capture_clock_us
);
    reg [31:0] sequence, capture_us, previous_sequence, previous_capture_us;
    reg [31:0] clock_us; assign capture_clock_us=clock_us;
    reg [31:0] divider;
    reg [9:0] row;
    reg frame_started;
    wire fire=s_axis_tvalid && m_axis_tready && aresetn;
    assign s_axis_tready=m_axis_tready && aresetn;
    assign m_axis_tdata=s_axis_tdata[15:8];
    // Video In always produces complete RGB pixels and has no TKEEP port.
    assign m_axis_tkeep=1'b1;
    assign m_axis_tvalid=s_axis_tvalid && aresetn;
    assign m_axis_tuser=s_axis_tuser;
    assign m_axis_tlast=s_axis_tlast;
    always @(posedge aclk) begin
        if(!aresetn) begin
            divider<=0; clock_us<=0; sequence<=0; capture_us<=0; row<=0;
            previous_sequence<=0; previous_capture_us<=0;
            safe_sequence<=0; safe_capture_us<=0; frame_started<=0;
        end else begin
            // Fractional divider also handles PS clocks such as 142.857 MHz.
            if(divider+1000000>=CLOCK_HZ) begin
                divider<=divider+1000000-CLOCK_HZ; clock_us<=clock_us+1;
            end else divider<=divider+1000000;
            if(fire) begin
                if(s_axis_tuser) begin
                    sequence<=sequence+1; capture_us<=clock_us; row<=0; frame_started<=1;
                end
                if(s_axis_tlast && frame_started) begin
                    if(row==HEIGHT-1) begin
                        // Publish the preceding complete frame. This gives
                        // S2MM outstanding writes a full frame to finish.
                        safe_sequence<=previous_sequence;
                        safe_capture_us<=previous_capture_us;
                        previous_sequence<=sequence;
                        previous_capture_us<=capture_us;
                        frame_started<=0; row<=0;
                    end else row<=row+1;
                end
            end
        end
    end
endmodule



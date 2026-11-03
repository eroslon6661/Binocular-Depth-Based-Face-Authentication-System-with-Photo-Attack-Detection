`timescale 1ns/1ps
// Preserve the AXI VDMA external genlock Gray encoding (AMD PG020).
module vdma_frame_pointer_cdc (
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dest_clk, ASSOCIATED_RESET dest_resetn" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 dest_clk CLK" *)
    input wire dest_clk,
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME dest_resetn, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 dest_resetn RST" *)
    input wire dest_resetn,
    input wire [5:0] source_gray,
    output wire [5:0] dest_gray
);
    (* ASYNC_REG = "TRUE" *) reg [5:0] gray_meta=0,gray_sync=0;
    always @(posedge dest_clk) begin
        if(!dest_resetn) begin gray_meta<=0;gray_sync<=0;end
        else begin gray_meta<=source_gray;gray_sync<=gray_meta;end
    end
    assign dest_gray=gray_sync;
endmodule

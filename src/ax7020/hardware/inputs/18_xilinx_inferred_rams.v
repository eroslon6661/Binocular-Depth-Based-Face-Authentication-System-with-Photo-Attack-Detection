`timescale 1ns / 1ps

// Xilinx-compatible replacements for the two Altera altsyncram wrappers used
// by the original SGBM RTL.  Both memories keep the original module names and
// port lists so the algorithm sources do not need to be edited.
//
// The original altsyncram instances register both the read address and the
// output.  The RTL below preserves that two-register synchronous read path.

module bram_line_8x1280 (
    input              clock,
    input      [7:0]   data,
    input      [10:0]  rdaddress,
    input      [10:0]  wraddress,
    input              wren,
    output     [7:0]   q
);

    (* ram_style = "block" *) reg [7:0] mem [0:2047];
    reg [10:0] rdaddress_r;
    reg [7:0]  q_r;

    always @(posedge clock) begin
        if (wren)
            mem[wraddress] <= data;

        rdaddress_r <= rdaddress;
        q_r          <= mem[rdaddress_r];
    end

    assign q = q_r;

endmodule


module bram_1280x288 (
    input               clock,
    input      [287:0]  data,
    input      [10:0]   rdaddress,
    input      [10:0]   wraddress,
    input               wren,
    output     [287:0]  q
);

    (* ram_style = "block" *) reg [287:0] mem [0:2047];
    reg [10:0]  rdaddress_r;
    reg [287:0] q_r;

    always @(posedge clock) begin
        if (wren)
            mem[wraddress] <= data;

        rdaddress_r <= rdaddress;
        q_r          <= mem[rdaddress_r];
    end

    assign q = q_r;

endmodule

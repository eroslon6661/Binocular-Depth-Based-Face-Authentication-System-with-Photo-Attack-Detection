// RGB/DE panel pins. Clock is forwarded through an ODDR, not fabric logic.
module rgb_lcd_pins (
    input wire pclk, input wire [23:0] data, input wire active,
    input wire [1:0] control,
    output wire [23:0] lcd_rgb, output wire lcd_de,
    output wire lcd_hs, output wire lcd_vs, output wire lcd_clk,
    output wire lcd_rst, output wire lcd_bl
);
    assign lcd_rgb = active ? data : 24'b0;
    assign lcd_de = active;
    // ATK 7016 reference uses DE mode. These pins are inactive high.
    assign lcd_hs=1'b1;
    assign lcd_vs=1'b1;
    assign lcd_rst=control[0];
    assign lcd_bl=control[1];
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),.INIT(1'b0),.SRTYPE("SYNC"))
      pixel_clock (.C(pclk),.CE(1'b1),.D1(1'b1),.D2(1'b0),
                   .R(1'b0),.S(1'b0),.Q(lcd_clk));
endmodule

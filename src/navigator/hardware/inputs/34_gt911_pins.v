// GPIO bit 0/1: open-drain SCL/SDA pull-low; bit 2: RESET level;
// bit 3: INT pull-low during address selection, released during normal use.
module gt911_pins (
    input wire [3:0] drive, output wire [3:0] sense,
    inout wire touch_scl, inout wire touch_sda, inout wire touch_int,
    output wire touch_rst
);
    IOBUF scl (.I(1'b0),.T(~drive[0]),.O(sense[0]),.IO(touch_scl));
    IOBUF sda (.I(1'b0),.T(~drive[1]),.O(sense[1]),.IO(touch_sda));
    IOBUF irq (.I(1'b0),.T(~drive[3]),.O(sense[2]),.IO(touch_int));
    assign sense[3]=1'b0;
    assign touch_rst=drive[2];
endmodule

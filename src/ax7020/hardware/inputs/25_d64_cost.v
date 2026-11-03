`timescale 1ns / 1ps

module d64_cost #(
    parameter IMG_WIDTH    = 1278,
    parameter IMG_HEIGHT   = 718,
    parameter INVALID_COST = 4'hf
)(
    input               clk,
    input               rst_n,
    input               data_en,
    input       [7:0]   left_census,
    input       [7:0]   right_census,
    output              cost_valid,
    output      [10:0]  x_cnt_d1,
    output      [9:0]   y_cnt_d1,
    output      [3:0]   hamming_raw0_out,
    output [3:0] cost0,
    output [3:0] cost1,
    output [3:0] cost2,
    output [3:0] cost3,
    output [3:0] cost4,
    output [3:0] cost5,
    output [3:0] cost6,
    output [3:0] cost7,
    output [3:0] cost8,
    output [3:0] cost9,
    output [3:0] cost10,
    output [3:0] cost11,
    output [3:0] cost12,
    output [3:0] cost13,
    output [3:0] cost14,
    output [3:0] cost15,
    output [3:0] cost16,
    output [3:0] cost17,
    output [3:0] cost18,
    output [3:0] cost19,
    output [3:0] cost20,
    output [3:0] cost21,
    output [3:0] cost22,
    output [3:0] cost23,
    output [3:0] cost24,
    output [3:0] cost25,
    output [3:0] cost26,
    output [3:0] cost27,
    output [3:0] cost28,
    output [3:0] cost29,
    output [3:0] cost30,
    output [3:0] cost31,
    output [3:0] cost32,
    output [3:0] cost33,
    output [3:0] cost34,
    output [3:0] cost35,
    output [3:0] cost36,
    output [3:0] cost37,
    output [3:0] cost38,
    output [3:0] cost39,
    output [3:0] cost40,
    output [3:0] cost41,
    output [3:0] cost42,
    output [3:0] cost43,
    output [3:0] cost44,
    output [3:0] cost45,
    output [3:0] cost46,
    output [3:0] cost47,
    output [3:0] cost48,
    output [3:0] cost49,
    output [3:0] cost50,
    output [3:0] cost51,
    output [3:0] cost52,
    output [3:0] cost53,
    output [3:0] cost54,
    output [3:0] cost55,
    output [3:0] cost56,
    output [3:0] cost57,
    output [3:0] cost58,
    output [3:0] cost59,
    output [3:0] cost60,
    output [3:0] cost61,
    output [3:0] cost62,
    output [3:0] cost63,
    output [3:0] cost64
);

reg [10:0] x_cnt;
reg [9:0]  y_cnt;
reg [10:0] x_d1;
reg [9:0]  y_d1;
reg [7:0]  left_census_d1;
reg        valid_d1;
reg [7:0] right_shift0;
reg [7:0] right_shift1;
reg [7:0] right_shift2;
reg [7:0] right_shift3;
reg [7:0] right_shift4;
reg [7:0] right_shift5;
reg [7:0] right_shift6;
reg [7:0] right_shift7;
reg [7:0] right_shift8;
reg [7:0] right_shift9;
reg [7:0] right_shift10;
reg [7:0] right_shift11;
reg [7:0] right_shift12;
reg [7:0] right_shift13;
reg [7:0] right_shift14;
reg [7:0] right_shift15;
reg [7:0] right_shift16;
reg [7:0] right_shift17;
reg [7:0] right_shift18;
reg [7:0] right_shift19;
reg [7:0] right_shift20;
reg [7:0] right_shift21;
reg [7:0] right_shift22;
reg [7:0] right_shift23;
reg [7:0] right_shift24;
reg [7:0] right_shift25;
reg [7:0] right_shift26;
reg [7:0] right_shift27;
reg [7:0] right_shift28;
reg [7:0] right_shift29;
reg [7:0] right_shift30;
reg [7:0] right_shift31;
reg [7:0] right_shift32;
reg [7:0] right_shift33;
reg [7:0] right_shift34;
reg [7:0] right_shift35;
reg [7:0] right_shift36;
reg [7:0] right_shift37;
reg [7:0] right_shift38;
reg [7:0] right_shift39;
reg [7:0] right_shift40;
reg [7:0] right_shift41;
reg [7:0] right_shift42;
reg [7:0] right_shift43;
reg [7:0] right_shift44;
reg [7:0] right_shift45;
reg [7:0] right_shift46;
reg [7:0] right_shift47;
reg [7:0] right_shift48;
reg [7:0] right_shift49;
reg [7:0] right_shift50;
reg [7:0] right_shift51;
reg [7:0] right_shift52;
reg [7:0] right_shift53;
reg [7:0] right_shift54;
reg [7:0] right_shift55;
reg [7:0] right_shift56;
reg [7:0] right_shift57;
reg [7:0] right_shift58;
reg [7:0] right_shift59;
reg [7:0] right_shift60;
reg [7:0] right_shift61;
reg [7:0] right_shift62;
reg [7:0] right_shift63;
reg [7:0] right_shift64;

function [3:0] popcount8;
    input [7:0] v;
    begin
        popcount8 = v[0] + v[1] + v[2] + v[3] + v[4] + v[5] + v[6] + v[7];
    end
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_cnt <= 11'd0;
        y_cnt <= 10'd0;
    end else if (data_en) begin
        if (x_cnt == IMG_WIDTH-1) begin
            x_cnt <= 11'd0;
            if (y_cnt == IMG_HEIGHT-1)
                y_cnt <= 10'd0;
            else
                y_cnt <= y_cnt + 10'd1;
        end else begin
            x_cnt <= x_cnt + 11'd1;
        end
    end
end
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        left_census_d1 <= 8'd0;
        x_d1           <= 11'd0;
        y_d1           <= 10'd0;
        valid_d1       <= 1'b0;
            right_shift0 <= 8'd0;
            right_shift1 <= 8'd0;
            right_shift2 <= 8'd0;
            right_shift3 <= 8'd0;
            right_shift4 <= 8'd0;
            right_shift5 <= 8'd0;
            right_shift6 <= 8'd0;
            right_shift7 <= 8'd0;
            right_shift8 <= 8'd0;
            right_shift9 <= 8'd0;
            right_shift10 <= 8'd0;
            right_shift11 <= 8'd0;
            right_shift12 <= 8'd0;
            right_shift13 <= 8'd0;
            right_shift14 <= 8'd0;
            right_shift15 <= 8'd0;
            right_shift16 <= 8'd0;
            right_shift17 <= 8'd0;
            right_shift18 <= 8'd0;
            right_shift19 <= 8'd0;
            right_shift20 <= 8'd0;
            right_shift21 <= 8'd0;
            right_shift22 <= 8'd0;
            right_shift23 <= 8'd0;
            right_shift24 <= 8'd0;
            right_shift25 <= 8'd0;
            right_shift26 <= 8'd0;
            right_shift27 <= 8'd0;
            right_shift28 <= 8'd0;
            right_shift29 <= 8'd0;
            right_shift30 <= 8'd0;
            right_shift31 <= 8'd0;
            right_shift32 <= 8'd0;
            right_shift33 <= 8'd0;
            right_shift34 <= 8'd0;
            right_shift35 <= 8'd0;
            right_shift36 <= 8'd0;
            right_shift37 <= 8'd0;
            right_shift38 <= 8'd0;
            right_shift39 <= 8'd0;
            right_shift40 <= 8'd0;
            right_shift41 <= 8'd0;
            right_shift42 <= 8'd0;
            right_shift43 <= 8'd0;
            right_shift44 <= 8'd0;
            right_shift45 <= 8'd0;
            right_shift46 <= 8'd0;
            right_shift47 <= 8'd0;
            right_shift48 <= 8'd0;
            right_shift49 <= 8'd0;
            right_shift50 <= 8'd0;
            right_shift51 <= 8'd0;
            right_shift52 <= 8'd0;
            right_shift53 <= 8'd0;
            right_shift54 <= 8'd0;
            right_shift55 <= 8'd0;
            right_shift56 <= 8'd0;
            right_shift57 <= 8'd0;
            right_shift58 <= 8'd0;
            right_shift59 <= 8'd0;
            right_shift60 <= 8'd0;
            right_shift61 <= 8'd0;
            right_shift62 <= 8'd0;
            right_shift63 <= 8'd0;
            right_shift64 <= 8'd0;
    end else begin
        valid_d1 <= 1'b0;
        if (data_en) begin
            left_census_d1 <= left_census;
            x_d1 <= x_cnt;
            y_d1 <= y_cnt;
            valid_d1 <= 1'b1;
            right_shift0 <= right_census;
            right_shift1 <= right_shift0;
            right_shift2 <= right_shift1;
            right_shift3 <= right_shift2;
            right_shift4 <= right_shift3;
            right_shift5 <= right_shift4;
            right_shift6 <= right_shift5;
            right_shift7 <= right_shift6;
            right_shift8 <= right_shift7;
            right_shift9 <= right_shift8;
            right_shift10 <= right_shift9;
            right_shift11 <= right_shift10;
            right_shift12 <= right_shift11;
            right_shift13 <= right_shift12;
            right_shift14 <= right_shift13;
            right_shift15 <= right_shift14;
            right_shift16 <= right_shift15;
            right_shift17 <= right_shift16;
            right_shift18 <= right_shift17;
            right_shift19 <= right_shift18;
            right_shift20 <= right_shift19;
            right_shift21 <= right_shift20;
            right_shift22 <= right_shift21;
            right_shift23 <= right_shift22;
            right_shift24 <= right_shift23;
            right_shift25 <= right_shift24;
            right_shift26 <= right_shift25;
            right_shift27 <= right_shift26;
            right_shift28 <= right_shift27;
            right_shift29 <= right_shift28;
            right_shift30 <= right_shift29;
            right_shift31 <= right_shift30;
            right_shift32 <= right_shift31;
            right_shift33 <= right_shift32;
            right_shift34 <= right_shift33;
            right_shift35 <= right_shift34;
            right_shift36 <= right_shift35;
            right_shift37 <= right_shift36;
            right_shift38 <= right_shift37;
            right_shift39 <= right_shift38;
            right_shift40 <= right_shift39;
            right_shift41 <= right_shift40;
            right_shift42 <= right_shift41;
            right_shift43 <= right_shift42;
            right_shift44 <= right_shift43;
            right_shift45 <= right_shift44;
            right_shift46 <= right_shift45;
            right_shift47 <= right_shift46;
            right_shift48 <= right_shift47;
            right_shift49 <= right_shift48;
            right_shift50 <= right_shift49;
            right_shift51 <= right_shift50;
            right_shift52 <= right_shift51;
            right_shift53 <= right_shift52;
            right_shift54 <= right_shift53;
            right_shift55 <= right_shift54;
            right_shift56 <= right_shift55;
            right_shift57 <= right_shift56;
            right_shift58 <= right_shift57;
            right_shift59 <= right_shift58;
            right_shift60 <= right_shift59;
            right_shift61 <= right_shift60;
            right_shift62 <= right_shift61;
            right_shift63 <= right_shift62;
            right_shift64 <= right_shift63;
        end
    end
end
*/
always @(posedge clk) begin
    if (!rst_n) begin
        x_d1     <= 11'd0;
        y_d1     <= 10'd0;
        valid_d1 <= 1'b0;
    end else begin
        valid_d1 <= 1'b0;
        if (data_en) begin
            left_census_d1 <= left_census;
            x_d1 <= x_cnt;
            y_d1 <= y_cnt;
            valid_d1 <= 1'b1;

            right_shift0  <= right_census;
            right_shift1  <= right_shift0;
            right_shift2  <= right_shift1;
            right_shift3  <= right_shift2;
            right_shift4  <= right_shift3;
            right_shift5  <= right_shift4;
            right_shift6  <= right_shift5;
            right_shift7  <= right_shift6;
            right_shift8  <= right_shift7;
            right_shift9  <= right_shift8;
            right_shift10 <= right_shift9;
            right_shift11 <= right_shift10;
            right_shift12 <= right_shift11;
            right_shift13 <= right_shift12;
            right_shift14 <= right_shift13;
            right_shift15 <= right_shift14;
            right_shift16 <= right_shift15;
            right_shift17 <= right_shift16;
            right_shift18 <= right_shift17;
            right_shift19 <= right_shift18;
            right_shift20 <= right_shift19;
            right_shift21 <= right_shift20;
            right_shift22 <= right_shift21;
            right_shift23 <= right_shift22;
            right_shift24 <= right_shift23;
            right_shift25 <= right_shift24;
            right_shift26 <= right_shift25;
            right_shift27 <= right_shift26;
            right_shift28 <= right_shift27;
            right_shift29 <= right_shift28;
            right_shift30 <= right_shift29;
            right_shift31 <= right_shift30;
            right_shift32 <= right_shift31;
            right_shift33 <= right_shift32;
            right_shift34 <= right_shift33;
            right_shift35 <= right_shift34;
            right_shift36 <= right_shift35;
            right_shift37 <= right_shift36;
            right_shift38 <= right_shift37;
            right_shift39 <= right_shift38;
            right_shift40 <= right_shift39;
            right_shift41 <= right_shift40;
            right_shift42 <= right_shift41;
            right_shift43 <= right_shift42;
            right_shift44 <= right_shift43;
            right_shift45 <= right_shift44;
            right_shift46 <= right_shift45;
            right_shift47 <= right_shift46;
            right_shift48 <= right_shift47;
            right_shift49 <= right_shift48;
            right_shift50 <= right_shift49;
            right_shift51 <= right_shift50;
            right_shift52 <= right_shift51;
            right_shift53 <= right_shift52;
            right_shift54 <= right_shift53;
            right_shift55 <= right_shift54;
            right_shift56 <= right_shift55;
            right_shift57 <= right_shift56;
            right_shift58 <= right_shift57;
            right_shift59 <= right_shift58;
            right_shift60 <= right_shift59;
            right_shift61 <= right_shift60;
            right_shift62 <= right_shift61;
            right_shift63 <= right_shift62;
            right_shift64 <= right_shift63;
        end
    end
end

assign cost_valid = valid_d1;
assign x_cnt_d1 = x_d1;
assign y_cnt_d1 = y_d1;
assign hamming_raw0_out = cost0;
assign cost0 = (valid_d1 && 1'b1) ? popcount8(left_census_d1 ^ right_shift0) : INVALID_COST;
assign cost1 = (valid_d1 && (x_d1 >= 11'd1)) ? popcount8(left_census_d1 ^ right_shift1) : INVALID_COST;
assign cost2 = (valid_d1 && (x_d1 >= 11'd2)) ? popcount8(left_census_d1 ^ right_shift2) : INVALID_COST;
assign cost3 = (valid_d1 && (x_d1 >= 11'd3)) ? popcount8(left_census_d1 ^ right_shift3) : INVALID_COST;
assign cost4 = (valid_d1 && (x_d1 >= 11'd4)) ? popcount8(left_census_d1 ^ right_shift4) : INVALID_COST;
assign cost5 = (valid_d1 && (x_d1 >= 11'd5)) ? popcount8(left_census_d1 ^ right_shift5) : INVALID_COST;
assign cost6 = (valid_d1 && (x_d1 >= 11'd6)) ? popcount8(left_census_d1 ^ right_shift6) : INVALID_COST;
assign cost7 = (valid_d1 && (x_d1 >= 11'd7)) ? popcount8(left_census_d1 ^ right_shift7) : INVALID_COST;
assign cost8 = (valid_d1 && (x_d1 >= 11'd8)) ? popcount8(left_census_d1 ^ right_shift8) : INVALID_COST;
assign cost9 = (valid_d1 && (x_d1 >= 11'd9)) ? popcount8(left_census_d1 ^ right_shift9) : INVALID_COST;
assign cost10 = (valid_d1 && (x_d1 >= 11'd10)) ? popcount8(left_census_d1 ^ right_shift10) : INVALID_COST;
assign cost11 = (valid_d1 && (x_d1 >= 11'd11)) ? popcount8(left_census_d1 ^ right_shift11) : INVALID_COST;
assign cost12 = (valid_d1 && (x_d1 >= 11'd12)) ? popcount8(left_census_d1 ^ right_shift12) : INVALID_COST;
assign cost13 = (valid_d1 && (x_d1 >= 11'd13)) ? popcount8(left_census_d1 ^ right_shift13) : INVALID_COST;
assign cost14 = (valid_d1 && (x_d1 >= 11'd14)) ? popcount8(left_census_d1 ^ right_shift14) : INVALID_COST;
assign cost15 = (valid_d1 && (x_d1 >= 11'd15)) ? popcount8(left_census_d1 ^ right_shift15) : INVALID_COST;
assign cost16 = (valid_d1 && (x_d1 >= 11'd16)) ? popcount8(left_census_d1 ^ right_shift16) : INVALID_COST;
assign cost17 = (valid_d1 && (x_d1 >= 11'd17)) ? popcount8(left_census_d1 ^ right_shift17) : INVALID_COST;
assign cost18 = (valid_d1 && (x_d1 >= 11'd18)) ? popcount8(left_census_d1 ^ right_shift18) : INVALID_COST;
assign cost19 = (valid_d1 && (x_d1 >= 11'd19)) ? popcount8(left_census_d1 ^ right_shift19) : INVALID_COST;
assign cost20 = (valid_d1 && (x_d1 >= 11'd20)) ? popcount8(left_census_d1 ^ right_shift20) : INVALID_COST;
assign cost21 = (valid_d1 && (x_d1 >= 11'd21)) ? popcount8(left_census_d1 ^ right_shift21) : INVALID_COST;
assign cost22 = (valid_d1 && (x_d1 >= 11'd22)) ? popcount8(left_census_d1 ^ right_shift22) : INVALID_COST;
assign cost23 = (valid_d1 && (x_d1 >= 11'd23)) ? popcount8(left_census_d1 ^ right_shift23) : INVALID_COST;
assign cost24 = (valid_d1 && (x_d1 >= 11'd24)) ? popcount8(left_census_d1 ^ right_shift24) : INVALID_COST;
assign cost25 = (valid_d1 && (x_d1 >= 11'd25)) ? popcount8(left_census_d1 ^ right_shift25) : INVALID_COST;
assign cost26 = (valid_d1 && (x_d1 >= 11'd26)) ? popcount8(left_census_d1 ^ right_shift26) : INVALID_COST;
assign cost27 = (valid_d1 && (x_d1 >= 11'd27)) ? popcount8(left_census_d1 ^ right_shift27) : INVALID_COST;
assign cost28 = (valid_d1 && (x_d1 >= 11'd28)) ? popcount8(left_census_d1 ^ right_shift28) : INVALID_COST;
assign cost29 = (valid_d1 && (x_d1 >= 11'd29)) ? popcount8(left_census_d1 ^ right_shift29) : INVALID_COST;
assign cost30 = (valid_d1 && (x_d1 >= 11'd30)) ? popcount8(left_census_d1 ^ right_shift30) : INVALID_COST;
assign cost31 = (valid_d1 && (x_d1 >= 11'd31)) ? popcount8(left_census_d1 ^ right_shift31) : INVALID_COST;
assign cost32 = (valid_d1 && (x_d1 >= 11'd32)) ? popcount8(left_census_d1 ^ right_shift32) : INVALID_COST;
assign cost33 = (valid_d1 && (x_d1 >= 11'd33)) ? popcount8(left_census_d1 ^ right_shift33) : INVALID_COST;
assign cost34 = (valid_d1 && (x_d1 >= 11'd34)) ? popcount8(left_census_d1 ^ right_shift34) : INVALID_COST;
assign cost35 = (valid_d1 && (x_d1 >= 11'd35)) ? popcount8(left_census_d1 ^ right_shift35) : INVALID_COST;
assign cost36 = (valid_d1 && (x_d1 >= 11'd36)) ? popcount8(left_census_d1 ^ right_shift36) : INVALID_COST;
assign cost37 = (valid_d1 && (x_d1 >= 11'd37)) ? popcount8(left_census_d1 ^ right_shift37) : INVALID_COST;
assign cost38 = (valid_d1 && (x_d1 >= 11'd38)) ? popcount8(left_census_d1 ^ right_shift38) : INVALID_COST;
assign cost39 = (valid_d1 && (x_d1 >= 11'd39)) ? popcount8(left_census_d1 ^ right_shift39) : INVALID_COST;
assign cost40 = (valid_d1 && (x_d1 >= 11'd40)) ? popcount8(left_census_d1 ^ right_shift40) : INVALID_COST;
assign cost41 = (valid_d1 && (x_d1 >= 11'd41)) ? popcount8(left_census_d1 ^ right_shift41) : INVALID_COST;
assign cost42 = (valid_d1 && (x_d1 >= 11'd42)) ? popcount8(left_census_d1 ^ right_shift42) : INVALID_COST;
assign cost43 = (valid_d1 && (x_d1 >= 11'd43)) ? popcount8(left_census_d1 ^ right_shift43) : INVALID_COST;
assign cost44 = (valid_d1 && (x_d1 >= 11'd44)) ? popcount8(left_census_d1 ^ right_shift44) : INVALID_COST;
assign cost45 = (valid_d1 && (x_d1 >= 11'd45)) ? popcount8(left_census_d1 ^ right_shift45) : INVALID_COST;
assign cost46 = (valid_d1 && (x_d1 >= 11'd46)) ? popcount8(left_census_d1 ^ right_shift46) : INVALID_COST;
assign cost47 = (valid_d1 && (x_d1 >= 11'd47)) ? popcount8(left_census_d1 ^ right_shift47) : INVALID_COST;
assign cost48 = (valid_d1 && (x_d1 >= 11'd48)) ? popcount8(left_census_d1 ^ right_shift48) : INVALID_COST;
assign cost49 = (valid_d1 && (x_d1 >= 11'd49)) ? popcount8(left_census_d1 ^ right_shift49) : INVALID_COST;
assign cost50 = (valid_d1 && (x_d1 >= 11'd50)) ? popcount8(left_census_d1 ^ right_shift50) : INVALID_COST;
assign cost51 = (valid_d1 && (x_d1 >= 11'd51)) ? popcount8(left_census_d1 ^ right_shift51) : INVALID_COST;
assign cost52 = (valid_d1 && (x_d1 >= 11'd52)) ? popcount8(left_census_d1 ^ right_shift52) : INVALID_COST;
assign cost53 = (valid_d1 && (x_d1 >= 11'd53)) ? popcount8(left_census_d1 ^ right_shift53) : INVALID_COST;
assign cost54 = (valid_d1 && (x_d1 >= 11'd54)) ? popcount8(left_census_d1 ^ right_shift54) : INVALID_COST;
assign cost55 = (valid_d1 && (x_d1 >= 11'd55)) ? popcount8(left_census_d1 ^ right_shift55) : INVALID_COST;
assign cost56 = (valid_d1 && (x_d1 >= 11'd56)) ? popcount8(left_census_d1 ^ right_shift56) : INVALID_COST;
assign cost57 = (valid_d1 && (x_d1 >= 11'd57)) ? popcount8(left_census_d1 ^ right_shift57) : INVALID_COST;
assign cost58 = (valid_d1 && (x_d1 >= 11'd58)) ? popcount8(left_census_d1 ^ right_shift58) : INVALID_COST;
assign cost59 = (valid_d1 && (x_d1 >= 11'd59)) ? popcount8(left_census_d1 ^ right_shift59) : INVALID_COST;
assign cost60 = (valid_d1 && (x_d1 >= 11'd60)) ? popcount8(left_census_d1 ^ right_shift60) : INVALID_COST;
assign cost61 = (valid_d1 && (x_d1 >= 11'd61)) ? popcount8(left_census_d1 ^ right_shift61) : INVALID_COST;
assign cost62 = (valid_d1 && (x_d1 >= 11'd62)) ? popcount8(left_census_d1 ^ right_shift62) : INVALID_COST;
assign cost63 = (valid_d1 && (x_d1 >= 11'd63)) ? popcount8(left_census_d1 ^ right_shift63) : INVALID_COST;
assign cost64 = (valid_d1 && (x_d1 >= 11'd64)) ? popcount8(left_census_d1 ^ right_shift64) : INVALID_COST;

endmodule

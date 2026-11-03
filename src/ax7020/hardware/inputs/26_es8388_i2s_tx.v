`timescale 1ns / 1ps

// A 16 kHz mono sample is repeated for three 48 kHz stereo I2S frames.
// gpio_word is held until gpio_ack matches its toggle bit.
module es8388_i2s_tx (
    input  wire        control_clk,
    input  wire        audio_clk,
    input  wire        resetn,
    input  wire        audio_locked,
    input  wire [16:0] gpio_word,
    output wire [0:0]  gpio_ack,
    output wire        aud_bclk,
    output wire        aud_lrc,
    output reg         aud_dacdat
);
    reg [7:0] phase = 8'd0;
    reg [1:0] repeat_count = 2'd0;
    reg [15:0] sample = 16'd0;
    reg toggle_meta = 1'b0;
    reg toggle_sync = 1'b0;
    reg accepted_toggle = 1'b0;
    reg ack_meta = 1'b0;
    reg ack_sync = 1'b0;

    assign aud_bclk = phase[1];
    assign aud_lrc = phase[7];
    assign gpio_ack[0] = ack_sync;

    always @(posedge control_clk or negedge resetn) begin
        if (!resetn) begin
            ack_meta <= 1'b0;
            ack_sync <= 1'b0;
        end else begin
            ack_meta <= accepted_toggle;
            ack_sync <= ack_meta;
        end
    end

    always @(posedge audio_clk or negedge resetn) begin
        if (!resetn) begin
            phase <= 8'd0;
            repeat_count <= 2'd0;
            sample <= 16'd0;
            toggle_meta <= 1'b0;
            toggle_sync <= 1'b0;
            accepted_toggle <= 1'b0;
            aud_dacdat <= 1'b0;
        end else if (!audio_locked) begin
            phase <= 8'd0;
            repeat_count <= 2'd0;
            sample <= 16'd0;
            toggle_meta <= 1'b0;
            toggle_sync <= 1'b0;
            accepted_toggle <= 1'b0;
            aud_dacdat <= 1'b0;
        end else begin
            toggle_meta <= gpio_word[16];
            toggle_sync <= toggle_meta;
            phase <= phase + 8'd1;

            if (phase == 8'd0) begin
                if (repeat_count == 2'd0) begin
                    repeat_count <= 2'd2;
                    if (toggle_sync != accepted_toggle) begin
                        sample <= gpio_word[15:0];
                        accepted_toggle <= toggle_sync;
                    end else begin
                        sample <= 16'd0;
                    end
                end else begin
                    repeat_count <= repeat_count - 2'd1;
                end
            end

            // Data changes on BCLK falling edges. I2S inserts one bit clock
            // between each LRCK edge and the sample MSB.
            if (phase[1:0] == 2'b00) begin
                case (phase[6:2])
                    5'd0: aud_dacdat <= 1'b0;
                    5'd1, 5'd2, 5'd3, 5'd4,
                    5'd5, 5'd6, 5'd7, 5'd8,
                    5'd9, 5'd10, 5'd11, 5'd12,
                    5'd13, 5'd14, 5'd15, 5'd16:
                        aud_dacdat <= sample[16 - phase[6:2]];
                    default: aud_dacdat <= 1'b0;
                endcase
            end
        end
    end
endmodule

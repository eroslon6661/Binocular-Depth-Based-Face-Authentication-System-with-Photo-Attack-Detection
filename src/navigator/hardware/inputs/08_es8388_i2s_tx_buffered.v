`timescale 1ns/1ps
// Same GPIO toggle protocol and 16 kHz PCM format as the original transmitter.
// ACK means queued. A 512-sample asynchronous FIFO buffers 32 ms of audio.
module es8388_i2s_tx_buffered (
    input wire control_clk, input wire audio_clk,
    input wire resetn, input wire audio_locked,
    input wire [16:0] gpio_word, output wire [0:0] gpio_ack,
    output wire aud_bclk, output wire aud_lrc, output reg aud_dacdat
);
    (* ram_style="block" *) reg [15:0] fifo[0:511];
    reg [9:0] write_binary=0,write_gray=0,read_binary=0,read_gray=0;
    (* ASYNC_REG="TRUE" *) reg [9:0] read_meta=0,read_sync=0,write_meta=0,write_sync=0;
    (* ASYNC_REG="TRUE" *) reg locked_meta=0,locked_sync=0;
    reg accepted_toggle=0;
    reg [7:0] phase=0;
    reg [1:0] repeat_count=0;
    reg [15:0] sample=0;
    wire full=write_gray=={~read_sync[9:8],read_sync[7:0]};
    wire empty=read_gray==write_sync;
    wire [9:0] next_write=write_binary+1'b1;
    wire [9:0] next_read=read_binary+1'b1;
    wire pop=audio_locked && phase==0 && repeat_count==0 && !empty;
    assign gpio_ack[0]=accepted_toggle;
    assign aud_bclk=phase[1];
    assign aud_lrc=phase[7];
    always @(posedge control_clk or negedge resetn) begin
        if(!resetn) begin
            write_binary<=0;write_gray<=0;read_meta<=0;read_sync<=0;
            accepted_toggle<=0;locked_meta<=0;locked_sync<=0;
        end else begin
            read_meta<=read_gray;read_sync<=read_meta;
            locked_meta<=audio_locked;locked_sync<=locked_meta;
            if(locked_sync && gpio_word[16]!=accepted_toggle && !full) begin
                write_binary<=next_write;write_gray<=(next_write>>1)^next_write;
                accepted_toggle<=gpio_word[16];
            end
        end
    end
    // Separate clocked RAM ports allow inference of true dual-port block RAM.
    always @(posedge control_clk) begin
        if(resetn && locked_sync && gpio_word[16]!=accepted_toggle && !full)
            fifo[write_binary[8:0]]<=gpio_word[15:0];
    end
    always @(posedge audio_clk or negedge resetn) begin
        if(!resetn) begin
            read_binary<=0;read_gray<=0;write_meta<=0;write_sync<=0;
            phase<=0;repeat_count<=0;sample<=0;aud_dacdat<=0;
        end else begin
            write_meta<=write_gray;write_sync<=write_meta;
            if(!audio_locked) begin
                phase<=0;repeat_count<=0;sample<=0;aud_dacdat<=0;
            end else begin
                phase<=phase+1'b1;
                if(phase==0) begin
                    if(repeat_count==0) begin
                        repeat_count<=2;
                        if(pop) begin
                            sample<=fifo[read_binary[8:0]];
                            read_binary<=next_read;read_gray<=(next_read>>1)^next_read;
                        end else sample<=0;
                    end else repeat_count<=repeat_count-1'b1;
                end
                if(phase[1:0]==0) begin
                    case(phase[6:2])
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16:
                            aud_dacdat<=sample[16-phase[6:2]];
                        default:aud_dacdat<=0;
                    endcase
                end
            end
        end
    end
endmodule

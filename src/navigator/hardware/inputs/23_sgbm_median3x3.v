`timescale 1ns / 1ps
// Valid-disparity 3x3 median for the display stream.  Zero means the
// matcher has no result, so zeros are omitted from the median.  Only
// neighbors within three disparity-index levels of the center participate.
// A valid center needs at least one agreeing neighbor in the causal window.
// The first two image rows/columns pass through unchanged.  There is one
// output sample for each input sample, including all frame borders.
module sgbm_median3x3 #(
    parameter IMG_WIDTH = 1278
)(
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    input wire [10:0] x_in,
    input wire [9:0] y_in,
    input wire [7:0] pixel_in,
    output reg out_valid,
    output reg [7:0] pixel_out
);
(* ram_style = "block" *) reg [7:0] previous_line [0:IMG_WIDTH-1];
(* ram_style = "block" *) reg [7:0] older_line [0:IMG_WIDTH-1];
reg [7:0] previous_read, older_read;
reg [7:0] current_d;
reg [10:0] x_d;
reg [9:0] y_d;
reg valid_d;
always @(posedge clk) begin
    valid_d <= rst_n && in_valid;
    if (rst_n && in_valid) begin
        previous_read <= previous_line[x_in];
        older_read <= older_line[x_in];
        older_line[x_in] <= previous_line[x_in];
        previous_line[x_in] <= pixel_in;
        current_d <= pixel_in;
        x_d <= x_in;
        y_d <= y_in;
    end
end

reg [7:0] old_x1,old_x2,prev_x1,prev_x2,cur_x1,cur_x2;
always @(posedge clk) begin
    if (valid_d) begin
        old_x2 <= old_x1;
        old_x1 <= older_read;
        prev_x2 <= prev_x1;
        prev_x1 <= previous_read;
        cur_x2 <= cur_x1;
        cur_x1 <= current_d;
    end
end
wire [7:0] sample [0:8];
assign sample[0]=old_x2;
assign sample[1]=old_x1;
assign sample[2]=older_read;
assign sample[3]=prev_x2;
assign sample[4]=prev_x1;
assign sample[5]=previous_read;
assign sample[6]=cur_x2;
assign sample[7]=cur_x1;
assign sample[8]=current_d;
wire [8:0] agrees;
wire [3:0] support_count =
    {3'd0,agrees[0]}+{3'd0,agrees[1]}+
    {3'd0,agrees[2]}+{3'd0,agrees[3]}+
    {3'd0,agrees[4]}+{3'd0,agrees[5]}+
    {3'd0,agrees[6]}+{3'd0,agrees[7]}+
    {3'd0,agrees[8]};

wire [71:0] stage_data [0:9];
genvar k,s;
generate for(k=0;k<9;k=k+1) begin: input_map
    wire [7:0] difference = (sample[k] >= current_d) ?
        (sample[k]-current_d) : (current_d-sample[k]);
    assign agrees[k] = (sample[k]!=8'd0) &&
                       (current_d!=8'd0) && (difference<=8'd12);
    assign stage_data[0][8*k +: 8] =
        agrees[k] ? sample[k] : 8'hff;
end endgenerate
reg [8:0] valid_pipe;
reg [8:0] filter_pipe;
reg [7:0] original_pipe [0:8];
reg [3:0] support_pipe [0:8];
generate for(s=0;s<9;s=s+1) begin: sort_stage
    wire [71:0] ordered;
    reg [71:0] result_reg;
    for(k=0;k<9;k=k+1) begin: compare
        if (((k%2)==(s%2)) && k<8) begin: lower
            assign ordered[8*k +:8] =
                (stage_data[s][8*k +:8] <= stage_data[s][8*(k+1) +:8]) ?
                stage_data[s][8*k +:8] : stage_data[s][8*(k+1) +:8];
        end else if (k>0 && (((k-1)%2)==(s%2))) begin: upper
            assign ordered[8*k +:8] =
                (stage_data[s][8*(k-1) +:8] <= stage_data[s][8*k +:8]) ?
                stage_data[s][8*k +:8] : stage_data[s][8*(k-1) +:8];
        end else begin: unchanged
            assign ordered[8*k +:8] = stage_data[s][8*k +:8];
        end
    end
    always @(posedge clk)
        result_reg <= ordered;
    assign stage_data[s+1] = result_reg;
    if (s==0) begin: first
        always @(posedge clk) begin
            valid_pipe[s] <= rst_n && valid_d;
            filter_pipe[s] <= (x_d>=11'd2 && y_d>=10'd2);
            original_pipe[s] <= current_d;
            support_pipe[s] <= support_count;
        end
    end else begin: later
        always @(posedge clk) begin
            valid_pipe[s] <= rst_n && valid_pipe[s-1];
            filter_pipe[s] <= filter_pipe[s-1];
            original_pipe[s] <= original_pipe[s-1];
            support_pipe[s] <= support_pipe[s-1];
        end
    end
end endgenerate
wire [3:0] median_index = (support_pipe[8]-4'd1)>>1;
wire [7:0] valid_median = stage_data[9][8*median_index +:8];
always @(posedge clk) begin
    if (!rst_n) begin
        out_valid <= 1'b0;
        pixel_out <= 8'd0;
    end else begin
        out_valid <= valid_pipe[8];
        if (!filter_pipe[8])
            pixel_out <= original_pipe[8];
        else if (original_pipe[8]!=8'd0 && support_pipe[8]>=4'd2)
            pixel_out <= valid_median;
        else
            pixel_out <= 8'd0;
    end
end
endmodule


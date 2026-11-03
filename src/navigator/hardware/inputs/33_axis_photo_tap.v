`timescale 1ns/1ps
// Passive one-shot RGB tap. Photo congestion NEVER stalls the existing path.
// A FIFO overflow/shape error invalidates the whole photo until the next arm.
module axis_photo_tap #(
    parameter WIDTH=1280, HEIGHT=720, FIFO_BITS=10
)(
    (* X_INTERFACE_PARAMETER="XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF s_axis:m_axis:photo_axis, ASSOCIATED_RESET aresetn" *)
    (* X_INTERFACE_INFO="xilinx.com:signal:clock:1.0 aclk CLK" *) input wire aclk,
    (* X_INTERFACE_PARAMETER="XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW" *)
    (* X_INTERFACE_INFO="xilinx.com:signal:reset:1.0 aresetn RST" *) input wire aresetn,
    input wire arm_toggle,input wire [31:0] clock_us,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 s_axis TDATA" *) input wire [23:0] s_axis_tdata,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 s_axis TVALID" *) input wire s_axis_tvalid,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 s_axis TREADY" *) output wire s_axis_tready,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 s_axis TUSER" *) input wire s_axis_tuser,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 s_axis TLAST" *) input wire s_axis_tlast,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 m_axis TDATA" *) output wire [23:0] m_axis_tdata,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 m_axis TVALID" *) output wire m_axis_tvalid,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 m_axis TREADY" *) input wire m_axis_tready,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 m_axis TUSER" *) output wire m_axis_tuser,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 m_axis TLAST" *) output wire m_axis_tlast,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 photo_axis TDATA" *) output wire [23:0] photo_axis_tdata,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 photo_axis TVALID" *) output wire photo_axis_tvalid,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 photo_axis TREADY" *) input wire photo_axis_tready,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 photo_axis TUSER" *) output wire photo_axis_tuser,
    (* X_INTERFACE_INFO="xilinx.com:interface:axis:1.0 photo_axis TLAST" *) output wire photo_axis_tlast,
    output wire [31:0] status,output reg [31:0] capture_us
);
    localparam DEPTH=(1<<FIFO_BITS);
    (* ram_style="block" *) reg [25:0] fifo[0:DEPTH-1];
    reg [FIFO_BITS-1:0] wr,rd;
    reg [FIFO_BITS:0] count;
    reg seen_arm,waiting,collecting,draining,done,error;
    reg [15:0] col,row;
    reg [25:0] head;
    reg head_valid;
    wire fire=s_axis_tvalid && s_axis_tready;
    wire start=waiting && fire && s_axis_tuser;
    wire push=fire && (collecting || start) && !error;
    wire pop=(!head_valid || photo_axis_tready) && count!=0;
    wire bad_shape=push && ((!start && s_axis_tuser) ||
        (s_axis_tlast != (col==WIDTH-1)));
    assign s_axis_tready=m_axis_tready && aresetn;
    assign m_axis_tdata=s_axis_tdata;
    assign m_axis_tvalid=s_axis_tvalid && aresetn;
    assign m_axis_tuser=s_axis_tuser;assign m_axis_tlast=s_axis_tlast;
    assign photo_axis_tdata=head[23:0];assign photo_axis_tuser=head[24];assign photo_axis_tlast=head[25];
    assign photo_axis_tvalid=head_valid && !error && aresetn;
    assign status={29'd0,(waiting|collecting|draining),error,done};
    always @(posedge aclk) begin
        if(!aresetn) begin
            wr<=0;rd<=0;count<=0;head<=0;head_valid<=0;seen_arm<=0;
            waiting<=0;collecting<=0;draining<=0;done<=0;error<=0;col<=0;row<=0;capture_us<=0;
        end else if(arm_toggle!=seen_arm) begin
            seen_arm<=arm_toggle;waiting<=1;collecting<=0;draining<=0;done<=0;error<=0;
            wr<=0;rd<=0;count<=0;head_valid<=0;col<=0;row<=0;
        end else if(!error) begin
            if(head_valid && photo_axis_tready)head_valid<=0;
            if(pop) begin head<=fifo[rd];rd<=rd+1'b1;head_valid<=1;end
            case({push,pop})
                2'b10:count<=count+1'b1;
                2'b01:count<=count-1'b1;
                default:count<=count;
            endcase
            if(push) begin
                if((count==DEPTH && !pop) || bad_shape) begin
                    error<=1;waiting<=0;collecting<=0;draining<=0;done<=0;head_valid<=0;
                end else begin
                    fifo[wr]<={s_axis_tlast,s_axis_tuser,s_axis_tdata};wr<=wr+1'b1;
                    if(start) begin waiting<=0;collecting<=1;capture_us<=clock_us;end
                    if(s_axis_tlast) begin
                        col<=0;
                        if(row==HEIGHT-1)begin collecting<=0;draining<=1;end
                        else row<=row+1'b1;
                    end else col<=col+1'b1;
                end
            end
            if(draining && count==0 && !head_valid)begin draining<=0;done<=1;end
        end
    end
endmodule

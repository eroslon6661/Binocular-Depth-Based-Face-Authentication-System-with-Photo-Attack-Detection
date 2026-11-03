`timescale 1ns/1ps
module tb;
reg [259:0] cost; reg [263:0] previous; reg boundary;
wire [263:0] actual; reg [524:0] inputs[0:4243]; reg [263:0] expected[0:4243];
integer i; integer errors=0;
sgbm_path_core_bus dut(.cost_bus(cost),.prev_state(previous),.boundary(boundary),.next_state(actual));
initial begin
 $readmemb("input.mem",inputs); $readmemh("expected.mem",expected);
 for(i=0;i<4244;i=i+1) begin
   {boundary,cost,previous}=inputs[i]; #1;
   if(actual !== expected[i]) begin
     $display("MISMATCH case=%0d actual=%h expected=%h",i,actual,expected[i]); errors=errors+1;
     if(errors>=10) $fatal(1,"TOO_MANY_ERRORS");
   end
 end
 if(errors==0) $display("SGM_PATH_PASS cases=4244 candidate_outputs=275860 minimum_outputs=4244");
 else $fatal(1,"FAIL errors=%0d",errors);
 $finish;
end
endmodule

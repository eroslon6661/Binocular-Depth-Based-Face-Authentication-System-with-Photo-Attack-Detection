"""Independent integer reference versus the packaged, unchanged SGM path RTL."""
from pathlib import Path
import random, hashlib, json, subprocess, os, shutil
import argparse
p=argparse.ArgumentParser();p.add_argument('--vivado-bin',type=Path,required=True);p.add_argument('--output',type=Path,required=True);args=p.parse_args()
W=Path(__file__).parent;S=args.output.resolve();S.mkdir(parents=True,exist_ok=False)
RTL=W/'path_core.v'
source_hash=hashlib.sha256(RTL.read_bytes()).hexdigest()
shutil.copyfile(RTL,S/'path_core.v')
rng=random.Random(20261028);cases=[]
def add(label,c,p,b=0):
 assert len(c)==len(p)==65 and all(0<=v<=15 for v in c+p)
 m=min(p); out=[]
 for j in range(65):
  trans=[p[j]-m,8]
  if j>0:trans.append(p[j-1]-m+2)
  if j<64:trans.append(p[j+1]-m+2)
  out.append(c[j] if b else min(15,c[j]+min(trans)))
 pv=sum(v<<(4*j) for j,v in enumerate(p))+(m<<260)
 cv=sum(v<<(4*j) for j,v in enumerate(c))
 ov=sum(v<<(4*j) for j,v in enumerate(out))+(min(out)<<260)
 cases.append({'label':label,'input':(b<<524)|(cv<<264)|pv,'expected':ov,'saturated':sum(v==15 for v in out)})
for b in [0,1]:
 for c0 in [0,8,15]:
  for p0 in [0,7,15]:add('uniform_boundary' if b else 'uniform',[c0]*65,[p0]*65,b)
for j in range(65):
 p=[15]*65;p[j]=0
 add('isolated_minimum',[8]*65,p)
 add('boundary_reset',[15 if k%2 else 0 for k in range(65)],p,1)
for i in range(4096):
 add('random_full4' if i%2 else 'random_hamming',[rng.randrange(16 if i%2 else 9) for _ in range(65)],[rng.randrange(16) for _ in range(65)],int(i%17==0))
N=len(cases)
(S/'input.mem').write_text('\n'.join(format(c['input'],'0525b') for c in cases)+'\n')
(S/'expected.mem').write_text('\n'.join(format(c['expected'],'066x') for c in cases)+'\n')
tb=f'''`timescale 1ns/1ps
module tb;
reg [259:0] cost; reg [263:0] previous; reg boundary;
wire [263:0] actual; reg [524:0] inputs[0:{N-1}]; reg [263:0] expected[0:{N-1}];
integer i; integer errors=0;
sgbm_path_core_bus dut(.cost_bus(cost),.prev_state(previous),.boundary(boundary),.next_state(actual));
initial begin
 $readmemb("input.mem",inputs); $readmemh("expected.mem",expected);
 for(i=0;i<{N};i=i+1) begin
   {{boundary,cost,previous}}=inputs[i]; #1;
   if(actual !== expected[i]) begin
     $display("MISMATCH case=%0d actual=%h expected=%h",i,actual,expected[i]); errors=errors+1;
     if(errors>=10) $fatal(1,"TOO_MANY_ERRORS");
   end
 end
 if(errors==0) $display("SGM_PATH_PASS cases={N} candidate_outputs={N*65} minimum_outputs={N}");
 else $fatal(1,"FAIL errors=%0d",errors);
 $finish;
end
endmodule
'''
(S/'tb.sv').write_text(tb)
binp=args.vivado_bin.resolve()
commands=[['xvlog.bat','-sv','path_core.v','tb.sv'],['xelab.bat','tb','-s','path_check','-debug','off'],['xsim.bat','path_check','-runall']]
log=[]
for cmd in commands:
 cp=subprocess.run([str(binp/cmd[0])]+cmd[1:],cwd=S,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,encoding='utf-8',errors='replace')
 log.append({'command':cmd,'returncode':cp.returncode,'stdout':cp.stdout})
 (S/(cmd[0]+'.log')).write_text(cp.stdout,encoding='utf-8')
 if cp.returncode:break
passed=len(log)==3 and all(c['returncode']==0 for c in log) and 'SGM_PATH_PASS' in log[-1]['stdout']
assert hashlib.sha256(RTL.read_bytes()).hexdigest()==source_hash
result={'passed':passed,'scope':'One combinational SGM path core, 65 candidates, four-bit saturated state, P1=2 P2=8. No row RAM, full-image timing or real-camera accuracy assertion.','cases':N,'candidate_outputs':N*65,'minimum_outputs':N,'boundary_cases':sum((c['input']>>524)&1 for c in cases),'saturated_outputs':sum(c['saturated'] for c in cases),'rng_seed':20261028,'rtl_source':str(RTL),'rtl_sha256':source_hash,'reference':'Independent Python normalized recurrence, then saturation to 15; consistent predecessor minimum.','tool':'See raw xvlog/xelab/xsim logs for actual tool version','tool_bin':str(binp),'testbench_sha256':hashlib.sha256((S/'tb.sv').read_bytes()).hexdigest(),'commands':[{k:v for k,v in x.items() if k!='stdout'} for x in log]}
(S/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2),flush=True)
if not passed:raise SystemExit(1)

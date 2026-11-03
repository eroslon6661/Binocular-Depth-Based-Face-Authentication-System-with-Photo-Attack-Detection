from pathlib import Path
import argparse,os,subprocess
p=argparse.ArgumentParser();p.add_argument('--vitis-run',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--mode',choices=['csim','export'],default='csim');a=p.parse_args()
if a.out.exists():raise SystemExit('Use a new output directory')
a.out.parent.mkdir(parents=True,exist_ok=True)
env=os.environ.copy();env['DELIVERY_HLS_OUTPUT']=str(a.out.resolve());env['DELIVERY_HLS_MODE']=a.mode
raise SystemExit(subprocess.run([str(a.vitis_run),'--mode','hls','--tcl',str(Path(__file__).with_name('build_hls.tcl'))],env=env,cwd=a.out.parent).returncode)

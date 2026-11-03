"""Run preserved decision/timer regression against current PS source on host GCC."""
import argparse,hashlib,json,os,subprocess
from pathlib import Path
def main():
    p=argparse.ArgumentParser();p.add_argument('--gcc',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    root=Path(__file__).resolve().parents[2];src=root/'src/navigator/software';out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    test=Path(__file__).with_name('test_access.c');env=os.environ.copy();env['PATH']=str(a.gcc.parent)+os.pathsep+env['PATH']
    exe=out/'access_check.exe'
    cmd=[str(a.gcc),'-O2','-Wall','-Wextra','-I'+str(src),str(test),str(src/'db_access.c'),'-o',str(exe)]
    build=subprocess.run(cmd,env=env,capture_output=True,text=True);(out/'build.log').write_text(build.stdout+build.stderr)
    build.check_returncode();run=subprocess.run([str(exe)],env=env,capture_output=True,text=True);(out/'run.log').write_text(run.stdout+run.stderr)
    result={'passed':run.returncode==0,'scope':'Host decision truth table, 5-second auto-close and uint32 timer wraparound; not live accuracy or physical lock actuation.',
      'test_origin':'Preserved test_access.c from dual_fpga_verified_20261012/05_validation/shared_tests; linked with current release PS code.',
      'source_sha256':{f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in [test,src/'db_access.c',src/'db_access.h']}}
    (out/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));run.check_returncode()
if __name__=='__main__':main()

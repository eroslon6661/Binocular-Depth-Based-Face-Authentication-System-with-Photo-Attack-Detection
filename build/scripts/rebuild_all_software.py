"""Rebuild both boards' BSP, CPU1, CPU0, FSBL and candidate BOOT with AMD 2026.1.
Never programs hardware or SD. PL inputs are the verified packaged bitstreams/XSAs.
"""
from pathlib import Path
import argparse,subprocess,sys,os,json,hashlib
HERE=Path(__file__).resolve().parent
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--tool-root',type=Path,default=Path(os.environ.get('AMD_2026_1','E:/vivado2026.1/2026.1')));a=p.parse_args()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);root=a.tool_root.resolve();cmds=[]
    def run(name,cmd):
        cmd=list(map(str,cmd));cmds.append({'step':name,'argv':cmd})
        (out/'commands.json').write_text(json.dumps(cmds,indent=2))
        print('BUILD_STEP '+name,flush=True)
        with (out/(name+'.log')).open('w') as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True)
    tools=root/'gnu/aarch32/nt/gcc-arm-none-eabi/bin'
    for role,short in [('navigator','nav'),('ax7020','ax')]:
        dep=out/(role+'_deps');app=out/(role+'_app')
        run(role+'_dependencies',[sys.executable,HERE/'rebuild_legacy_dependencies.py',role,'--out',dep,'--tools',tools,'--make',root/'Vitis/gnuwin/bin/make.exe'])
        run(role+'_application',[sys.executable,HERE/'build_software.py',short,'--out',app,'--compiler',tools/'arm-none-eabi-gcc.exe','--bsp',dep/'bsp','--cpu1',dep/'crc_core1/crc_core1.bin'])
    run('fsbl',[root/'Vitis/bin/vitis.bat','-s',HERE/'rebuild_fsbl_2026.py','--workspace',out/'fsbl_workspace'])
    for role,short in [('navigator','nav'),('ax7020','ax')]:
        run(role+'_boot',[sys.executable,HERE/'build_sd.py',short,'--out',out/role/'BOOT.BIN','--tool-root',root,'--elf',out/(role+'_app')/'application.elf','--fsbl',out/'fsbl_workspace'/(role+'_source')/'zynq_fsbl/build/fsbl.elf'])
    files=[x for x in out.rglob('*') if x.is_file() and x.suffix in ('.elf','.a','.bin','.BIN')]
    result={'toolchain':'AMD 2026.1','driver_source':'packaged compatible vendor API sources; not silently upgraded','pl_reimplemented':False,'board_tested':False,'sd_written':False,'outputs':{x.relative_to(out).as_posix():hashlib.sha256(x.read_bytes()).hexdigest() for x in files}}
    (out/'result.json').write_text(json.dumps(result,indent=2));print('ALL_SOFTWARE_SOURCE_BUILD_PASS')
if __name__=='__main__':main()

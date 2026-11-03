"""Recompile retained BSP sources and CPU1 with 2026.1 GCC into a new directory.
This preserves legacy driver/API configuration; it does not relabel vendor sources.
No prebuilt .a/.o/.elf/.bin files are used as build inputs.
"""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,os,shutil,subprocess
ROOT=Path(__file__).resolve().parents[2]
FLAGS=['-mcpu=cortex-a9','-mfpu=vfpv3','-mfloat-abi=hard','-O2','-g','-Wall','-Wextra','-ffunction-sections','-fdata-sections']
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('role',choices=['navigator','ax7020']);p.add_argument('--out',type=Path,required=True);p.add_argument('--tools',type=Path,default=Path('E:/vivado2026.1/2026.1/gnu/aarch32/nt/gcc-arm-none-eabi/bin'));p.add_argument('--make',type=Path,default=Path('E:/vivado2026.1/2026.1/Vitis/gnuwin/bin/make.exe'));a=p.parse_args()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);bsp=out/'bsp';dep=ROOT/f'src/{a.role}/deps'
    shutil.copytree(dep/'bsp/include',bsp/'include');shutil.copytree(dep/'bsp/libsrc',bsp/'libsrc',ignore=shutil.ignore_patterns('*.o','*.a','*.d','*.elf','*.bin'))
    (bsp/'lib').mkdir();obj=out/'obj';obj.mkdir();cc=a.tools/'arm-none-eabi-gcc.exe';ar=a.tools/'arm-none-eabi-ar.exe';env=os.environ.copy();env['PATH']=str(a.tools)+os.pathsep+env['PATH']
    commands=[]
    def run(cmd,cwd=None):
        commands.append({'argv':list(map(str,cmd)),'cwd':str(cwd or out)})
        r=subprocess.run(list(map(str,cmd)),cwd=cwd or out,env=env,capture_output=True,text=True)
        if r.returncode:(out/'last_failure.log').write_text(str(cmd)+'\n'+r.stdout+r.stderr,encoding='utf-8')
        return r
    jobs=[]
    for driver in sorted((bsp/'libsrc').iterdir()):
        if driver.name.startswith('lwip'):continue
        for s in sorted((driver/'src').glob('*')):
            if s.suffix in ('.c','.S'):jobs.append((s,obj/(driver.name+'_'+s.name+'.o')))
    def compile_one(pair):
        s,o=pair;r=run([cc,*FLAGS,'-I'+str(s.parent),'-I'+str(bsp/'include'),'-c',s,'-o',o]);return s,r
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:results=list(pool.map(compile_one,jobs))
    log=''.join(f'\nSOURCE {s}\n{r.stdout}{r.stderr}' for s,r in results);(out/'bsp_build.log').write_text(log,encoding='utf-8')
    failed=[str(s) for s,r in results if r.returncode]
    if failed:raise RuntimeError('BSP compilation failed: '+str(failed))
    rsp=out/'archive.rsp';rsp.write_text('\n'.join('"'+o.as_posix()+'"' for s,o in jobs))
    r=run([ar,'rcs',bsp/'lib/libxil.a','@'+str(rsp)]);r.check_returncode()
    lwip=next((bsp/'libsrc').glob('lwip*/src'))
    r=run([a.make,'-j4','libs','COMPILER='+str(cc),'GCC_COMPILER='+str(cc),'ARCHIVER='+str(ar),
           'COMPILER_FLAGS='+' '.join(FLAGS),'EXTRA_COMPILER_FLAGS=-DLWIP_ALLOW_MEM_FREE_FROM_OTHER_CONTEXT=1'],cwd=lwip)
    (out/'lwip_build.log').write_text(r.stdout+r.stderr,encoding='utf-8');r.check_returncode()
    core=out/'crc_core1';shutil.copytree(dep/'crc_core1/src',core/'src');shutil.copy2(dep/'crc_core1/lscript.ld',core/'lscript.ld');(core/'obj').mkdir()
    old=json.loads((dep/'crc_core1/build_options.json').read_text());flags=[f for f in old['flags'] if not f.startswith('-I')]+['-I'+str(core/'src'),'-I'+str(bsp/'include')]
    objects=[];logs=[]
    for s in sorted((core/'src').iterdir()):
        if s.suffix not in ('.c','.S'):continue
        o=core/'obj'/(s.name+'.o');r=run([cc,*flags,'-c',s,'-o',o]);logs.append(r.stdout+r.stderr);r.check_returncode();objects.append(o)
    runtime={n:subprocess.check_output([str(cc),*flags,'-print-file-name='+n],env=env,text=True).strip() for n in ['crti.o','crtbegin.o','crtend.o','crtn.o']}
    r=run([cc,*flags,'-nostartfiles',runtime['crti.o'],runtime['crtbegin.o'],*objects,'-Wl,-T,'+str(core/'lscript.ld'),'-Wl,--gc-sections','-Wl,-Map,'+str(core/'application.map'),'-L'+str(bsp/'lib'),'-Wl,--start-group','-lxil','-lm','-lc','-lgcc','-Wl,--end-group',runtime['crtend.o'],runtime['crtn.o'],'-o',core/'crc_core1.elf']);logs.append(r.stdout+r.stderr);(out/'cpu1_build.log').write_text(''.join(logs));r.check_returncode()
    run([a.tools/'arm-none-eabi-objcopy.exe','-O','binary',core/'crc_core1.elf',core/'crc_core1.bin']).check_returncode()
    def sha(x):return hashlib.sha256(x.read_bytes()).hexdigest()
    result={'role':a.role,'compiler':subprocess.check_output([str(cc),'--version'],text=True).splitlines()[0],
        'vendor_api':'retained legacy BSP configuration','prebuilt_libraries_used':False,'board_tested':False,
        'objects_compiled_libxil':len(jobs),'outputs':{str(x.relative_to(out)):sha(x) for x in [bsp/'lib/libxil.a',bsp/'lib/liblwip4.a',core/'crc_core1.elf',core/'crc_core1.bin']}}
    (out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n');(out/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()

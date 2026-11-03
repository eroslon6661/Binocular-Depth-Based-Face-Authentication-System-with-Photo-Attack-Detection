"""Read-only release audit. Does not access boards or claim a new hardware run."""
from pathlib import Path
import json,hashlib,sys,os
R=Path(__file__).resolve().parents[1]
if os.name=='nt' and not str(R).startswith('\\\\?\\'):
    R=Path('\\\\?\\'+str(R))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks=[]
def check(name,ok):checks.append({'name':name,'passed':bool(ok)})
for role,key in [('navigator','NAVIGATOR'),('ax7020','AX7020')]:
    m=json.loads((R/f'reports/software/{role}/build_manifest.json').read_text(encoding='utf-8'))
    check(role+'_source_binding',all((R/f'src/{role}/software'/n).is_file() and sha(R/f'src/{role}/software'/n)==h for n,h in m['source_sha256'].items()))
    check(role+'_elf_binding',sha(R/f'board/{role}/jtag/application.elf')==m['sha256'])
    sd=json.loads((R/f'board/{role}/sd/{key}_BUILD.json').read_text(encoding='utf-8'))
    paths={'BOOT.BIN':f'board/{role}/sd/BOOT.BIN','fsbl.elf':f'board/{role}/boot_sources/fsbl.elf','system.bit':f'board/{role}/jtag/system.bit','application.elf':f'board/{role}/jtag/application.elf'}
    check(role+'_boot_inputs',all(sha(R/paths[n])==h.lower() for n,h in sd['sha256'].items()))
    check(role+'_report_bit_binding',sha(R/f'reports/implementation/{role}/system.bit')==sha(R/f'board/{role}/jtag/system.bit'))
    check(role+'_2026_1_report','Vivado v.2026.1' in (R/f'reports/implementation/{role}/utilization.rpt').read_text(errors='replace'))
    hw=R/f'src/{role}/hardware'
    import re
    inputs=re.findall(r'\[file join \$here \{([^}]+)\}\]',(hw/'recreate.tcl').read_text())
    check(role+'_recreate_inputs',all((hw/x).exists() for x in inputs))
m=json.loads((R/'manifest.json').read_text(encoding='utf-8'))
check('manifest_hashes',all((R/x['path']).is_file() and sha(R/x['path'])==x['sha256'] for x in m['files']))
actual={p.relative_to(R).as_posix() for p in R.rglob('*') if p.is_file() and '__pycache__' not in p.parts and p.name!='manifest.json'}
check('manifest_complete',actual=={x['path'] for x in m['files']})
print(json.dumps({'passed':all(x['passed'] for x in checks),'checks':checks,'board_accessed':False},indent=2))
sys.exit(0 if all(x['passed'] for x in checks) else 1)

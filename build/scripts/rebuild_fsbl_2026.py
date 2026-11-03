"""Run with Vitis 2026.1: vitis -s this.py --workspace <new ASCII folder>.
Generate platform BSP and FSBL from each packaged XSA with installed 2026.1 sources.
"""
from pathlib import Path
import argparse,json,hashlib
import vitis
p=argparse.ArgumentParser();p.add_argument('--workspace',type=Path,required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[2];workspace=a.workspace.resolve()
if workspace.exists():raise RuntimeError('Use a new workspace')
client=vitis.create_client();client.set_workspace(str(workspace))
records=[]
try:
    for role in ['navigator','ax7020']:
        xsa=root/f'reports/implementation/{role}/system.xsa'
        platform=client.create_platform_component(name=role+'_source',hw_design=str(xsa),os='standalone',cpu='ps7_cortexa9_0',domain_name='standalone_cpu0',no_boot_bsp=False)
        platform.build()
        elfs=list((workspace/(role+'_source')).rglob('fsbl.elf'))
        if not elfs:raise RuntimeError('FSBL output missing for '+role)
        records.append({'role':role,'xsa_sha256':hashlib.sha256(xsa.read_bytes()).hexdigest(),'fsbl':[{'path':str(f.relative_to(workspace)),'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in elfs],'board_tested':False})
    (workspace/'source_build_result.json').write_text(json.dumps(records,indent=2)+'\n')
finally:
    vitis.dispose()

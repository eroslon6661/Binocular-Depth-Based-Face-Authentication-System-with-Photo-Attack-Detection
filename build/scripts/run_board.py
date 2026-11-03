"""Print a JTAG plan by default. Programming requires explicit physical-role confirmation."""
from pathlib import Path
import argparse,subprocess,json
R=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('role',choices=['navigator','ax7020']);p.add_argument('--serial',required=True)
p.add_argument('--xsdb',type=Path);p.add_argument('--execute',action='store_true')
p.add_argument('--confirmed-role',choices=['navigator','ax7020']);p.add_argument('--log',type=Path)
a=p.parse_args()
cmd=[str(a.xsdb or 'xsdb.bat'),str(R/'build/scripts/program_jtag.tcl'),a.role,str(R),a.serial]
print(json.dumps({'role':a.role,'command':cmd,'execute':a.execute},indent=2))
if a.execute:
    if a.confirmed_role!=a.role or not a.xsdb or not a.xsdb.is_file() or not a.log:raise SystemExit('Supply XSDB, a log path, and confirm physical board role')
    if a.log.exists():raise SystemExit('Log must be a new file')
    a.log.parent.mkdir(parents=True,exist_ok=True)
    with a.log.open('w',encoding='utf-8') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
    raise SystemExit(r.returncode)

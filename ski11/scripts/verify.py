"""Read-only checks for Vivado 7-series reports, exact data and manifests."""
import argparse, hashlib, json, math, re, sys
from pathlib import Path

def sha(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for b in iter(lambda:f.read(1048576), b""): h.update(b)
    return h.hexdigest()

def contained(root, name):
    root=Path(root).resolve()
    p=Path(name)
    if p.is_absolute(): raise ValueError("absolute manifest path")
    p=(root/p).resolve()
    if not p.is_relative_to(root): raise ValueError("path outside root")
    return p

def compare(a,b):
    a,b=Path(a),Path(b)
    if not a.stat().st_size or not b.stat().st_size:
        return {"status":"FAIL","reason":"empty data"},1
    mismatch=0; first=None; offset=0
    with a.open("rb") as x,b.open("rb") as y:
        while True:
            u,v=x.read(1048576),y.read(1048576)
            if not u and not v: break
            for k in range(max(len(u),len(v))):
                if k>=len(u) or k>=len(v) or u[k]!=v[k]:
                    mismatch+=1
                    if first is None:first=offset+k
            offset+=max(len(u),len(v))
    return {"status":"FAIL" if mismatch else "PASS","different_bytes":mismatch,
            "first_difference":first,"golden_bytes":a.stat().st_size,
            "candidate_bytes":b.stat().st_size},int(bool(mismatch))

def reports(util,timing,limit=90):
    if not 0<limit<=100: raise ValueError("limit must be in (0,100]")
    u=Path(util).read_text(encoding="utf-8-sig",errors="replace")
    t=Path(timing).read_text(encoding="utf-8-sig",errors="replace")
    rows={}; errors=[]; review=[]
    for line in u.splitlines():
        if not line.startswith("|"):continue
        cells=[c.strip() for c in line.split("|")[1:-1]]
        if len(cells)!=6:continue
        try:
            used=float(cells[1].replace(",",""))
            available=float(cells[4].replace(",",""))
            if available<=0:continue
            if not math.isfinite(used) or used<0:raise ValueError()
        except ValueError:continue
        name=cells[0]
        row={"used":used,"available":available,"percent":round(100*used/available,4)}
        if name in rows and rows[name]!=row:review.append("conflicting row: "+name)
        rows[name]=row
    for name in ["Slice","Slice LUTs","Slice Registers","Block RAM Tile","DSPs"]:
        if name not in rows: review.append("missing resource: "+name)
    for name,r in rows.items():
        if r["percent"]>limit:errors.append(name+" exceeds "+str(limit)+"%")
    header=re.search(r"WNS\(ns\).*TNS\(ns\).*WHS\(ns\).*WPWS\(ns\)[^\n]*\n",t)
    values=None
    if header:
        for line in t[header.end():].splitlines()[:8]:
            parts=line.split()
            if len(parts)==12:
                try:values=[float(x) for x in parts];break
                except ValueError:pass
    metrics={}
    if values is None or not all(math.isfinite(x) for x in values):
        review.append("missing/invalid 12-column timing summary")
    else:
        keys=["WNS","TNS","setup_failing","setup_total","WHS","THS",
              "hold_failing","hold_total","WPWS","TPWS","pulse_failing","pulse_total"]
        metrics=dict(zip(keys,values))
        for k in ["WNS","TNS","WHS","THS","WPWS","TPWS"]:
            if metrics[k]<0:errors.append(k+" violation")
        for k in ["setup_failing","hold_failing","pulse_failing"]:
            if metrics[k]!=0:errors.append(k+" not zero")
        if metrics["setup_total"]<=0:review.append("no analyzed setup endpoints")
    for k in ["no_clock","unconstrained_internal_endpoints","no_input_delay","no_output_delay",
              "partial_input_delay","partial_output_delay","multiple_clock","loops"]:
        m=re.search(r"checking "+re.escape(k)+r" \((\d+)\)",t)
        if not m:review.append("missing check_timing: "+k)
        elif int(m[1]):review.append(k+"="+m[1])
    if not re.search(r"Design State\s*:\s*(Routed|Physopt postRoute)",u):
        review.append("utilization is not proven routed")
    code=1 if errors else 2 if review else 0
    return {"status":["PASS","FAIL","REVIEW"][code],"scope":"resource and reported timing checks; not complete electrical signoff",
            "resources":rows,"timing":metrics,"failures":errors,"review":review},code

def manifest(root,path):
    d=json.loads(Path(path).read_text(encoding="utf-8-sig"))
    entries=d.get("files")
    if not isinstance(entries,list) or not entries:raise ValueError("empty/invalid manifest")
    errors=[];seen=set()
    for e in entries:
        name=e["path"];p=contained(root,name)
        if str(p) in seen:raise ValueError("duplicate entry")
        seen.add(str(p))
        expected=e["sha256"]
        if not re.fullmatch("[0-9a-fA-F]{64}",expected):raise ValueError("invalid hash")
        if not p.is_file():errors.append(name+": missing")
        elif sha(p)!=expected.lower():errors.append(name+": hash mismatch")
    return {"status":"FAIL" if errors else "PASS","files":len(entries),"failures":errors},int(bool(errors))

def main():
    p=argparse.ArgumentParser(description=__doc__);s=p.add_subparsers(dest="cmd",required=True)
    q=s.add_parser("compare");q.add_argument("golden");q.add_argument("candidate")
    q=s.add_parser("reports");q.add_argument("util");q.add_argument("timing");q.add_argument("--limit",type=float,default=90)
    q=s.add_parser("manifest");q.add_argument("root");q.add_argument("manifest")
    q=s.add_parser("make-manifest");q.add_argument("root");q.add_argument("name");q.add_argument("files",nargs="+")
    a=p.parse_args()
    try:
        if a.cmd=="compare":result,code=compare(a.golden,a.candidate)
        elif a.cmd=="reports":result,code=reports(a.util,a.timing,a.limit)
        elif a.cmd=="manifest":result,code=manifest(a.root,a.manifest)
        else:
            result={"name":a.name,"files":[{"path":n,"sha256":sha(contained(a.root,n))} for n in a.files]};code=0
    except (OSError,ValueError,KeyError,TypeError) as e:result,code={"status":"UNKNOWN","error":str(e)},2
    print(json.dumps(result,ensure_ascii=False,indent=2));return code
if __name__=="__main__":sys.exit(main())


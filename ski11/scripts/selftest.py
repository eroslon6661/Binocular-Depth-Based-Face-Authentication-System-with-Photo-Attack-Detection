import json,tempfile
from pathlib import Path
from verify import compare,manifest,sha,reports,contained
with tempfile.TemporaryDirectory() as d:
    p=Path(d);a=p/"a.bin";b=p/"b.bin"
    a.write_bytes(bytes(range(256)));b.write_bytes(a.read_bytes())
    assert compare(a,b)[1]==0
    b.write_bytes(bytes([9])+a.read_bytes()[1:]);assert compare(a,b)[0]["first_difference"]==0
    b.write_bytes(a.read_bytes()+b"x");assert compare(a,b)[0]["different_bytes"]==1
    b.write_bytes(b"");assert compare(a,b)[1]==1
    m=p/"manifest.json";m.write_text(json.dumps({"files":[{"path":"a.bin","sha256":sha(a)}]}))
    assert manifest(p,m)[1]==0
    a.write_bytes(b"changed");assert manifest(p,m)[1]==1
    a.unlink();assert manifest(p,m)[1]==1
    try:contained(p,"../outside");raise AssertionError("escape accepted")
    except ValueError:pass
    u=p/"u.rpt";t=p/"t.rpt"
    u.write_text("| Design State : Routed\n"+"\n".join("| "+n+" | 1 | 0 | 0 | 100 | 1 |" for n in ["Slice","Slice LUTs","Slice Registers","Block RAM Tile","DSPs"]))
    text="WNS(ns) TNS(ns) WHS(ns) WPWS(ns)\n------\n0.1 0 0 10 0.1 0 0 10 0.1 0 0 10\n"
    text+="\n".join("checking "+n+" (0)" for n in ["no_clock","unconstrained_internal_endpoints","no_input_delay","no_output_delay","partial_input_delay","partial_output_delay","multiple_clock","loops"])
    t.write_text(text);assert reports(u,t)[1]==0
    t.write_text(text.replace("no_input_delay (0)","no_input_delay (2)"));assert reports(u,t)[1]==2
    t.write_text(text.replace("0.1 0 0 10","-0.1 -1 1 10",1));assert reports(u,t)[1]==1
    t.write_text("not a report");assert reports(u,t)[1]==2
print("PASS: exact comparison, length/empty data, hash tamper/missing, path escape, timing violation and missing constraint cases")


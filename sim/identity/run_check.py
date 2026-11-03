"""Compare unchanged PS identity C code with an independent integer Python oracle.
This is host verification of matching, not a camera/FPGA or recognition-accuracy test.
"""
from pathlib import Path
import argparse,csv,hashlib,json,math,os,random,re,struct,subprocess
ROOT=Path(__file__).resolve().parents[2]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def array(path,name):
    s=path.read_text();m=re.search(r'\b'+name+r'\s*\[[^\]]+\][^=]*=\s*\{([^}]+)\}',s,re.S)
    if not m:raise ValueError(name)
    x=[int(v) for v in re.findall(r'-?\d+',m[1])];assert len(x)==512;return x
def cosine(q,t):
    denominator=math.isqrt(sum(x*x for x in q)*sum(x*x for x in t))
    if not denominator:return -2147483648
    numerator=sum(a*b for a,b in zip(q,t))*32768
    rounded=(abs(numerator)+denominator//2)//denominator
    return max(-32768,min(32768,rounded if numerator>=0 else -rounded))
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--gcc',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);src=ROOT/'src/navigator/software'
    ts=[array(src/'db_face_identity_template.c','db_face_person01_template_i8'),array(src/'db_face_gallery.c','db_face_person02_template_i8'),array(src/'db_face_gallery.c','db_face_person02_camera_template_i8')]
    header=(src/'db_face_identity_template.h').read_text();threshold=int(re.search(r'DB_FACE_MATCH_THRESHOLD_Q15\s+(\d+)',header)[1])
    rng=random.Random(20261101);vectors=[('zero',[0]*512)]
    for i,t in enumerate(ts):vectors += [(f'template_{i}',t),(f'negative_{i}',[-x for x in t])]
    for i in range(1000):
        v=[rng.gauss(0,1) for _ in range(512)];n=math.sqrt(sum(x*x for x in v))
        vectors.append(('random_normalized', [max(-127,min(127,round(x*127/n))) for x in v]))
    for t in ts:
        for magnitude in range(1,21):vectors.append(('template_noise',[max(-127,min(127,x+rng.randint(-magnitude,magnitude))) for x in t]))
    with (out/'input_i8.bin').open('wb') as f:
        for _,v in vectors:f.write(struct.pack('512b',*v))
    harness=out/'identity_harness.c'
    harness.write_text('''#include <stdio.h>
#include <stdint.h>
#include "db_face_identity.h"
int main(int argc,char **argv){
 if(argc!=2)return 2;FILE *f=fopen(argv[1],"rb");if(!f)return 3;
 int8_t v[512];unsigned i=0,p;int32_t score;size_t n;
 puts("case,score1,score2,identified,person,score");
 while((n=fread(v,1,512,f))==512){int ok=db_face_identify_i8(v,&p,&score);
 printf("%u,%ld,%ld,%d,%u,%ld\\n",i++,(long)db_face_person_similarity_i8_q15(v,1),(long)db_face_person_similarity_i8_q15(v,2),ok,p,(long)score);}
 fclose(f);return n?4:0;}
''')
    names=['db_face_identity.c','db_face_identity_template.c','db_face_gallery.c']
    env=os.environ.copy();env['PATH']=str(a.gcc.parent)+os.pathsep+env['PATH']
    cmd=[str(a.gcc),'-O2','-std=c99','-I'+str(src),str(harness),*[str(src/n) for n in names],'-lm','-o',str(out/'identity_check.exe')]
    build=subprocess.run(cmd,env=env,text=True,capture_output=True);(out/'build.log').write_text(build.stdout+build.stderr);build.check_returncode()
    run=subprocess.run([str(out/'identity_check.exe'),str(out/'input_i8.bin')],env=env,text=True,capture_output=True);run.check_returncode();(out/'actual.csv').write_text(run.stdout)
    rows=list(csv.DictReader(run.stdout.splitlines()));expected=[]
    for i,(label,v) in enumerate(vectors):
        s1=cosine(v,ts[0]);s2=max(cosine(v,ts[1]),cosine(v,ts[2]));best=max(s1,s2)
        person=0 if s1==s2 or best<threshold else 1 if s1>s2 else 2
        expected.append(dict(case=i,score1=s1,score2=s2,identified=int(person!=0),person=person,score=best,label=label))
    fields=list(expected[0])
    with (out/'expected.csv').open('w',newline='') as f:w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(expected)
    mismatches=[i for i,(e,r) in enumerate(zip(expected,rows)) if any(e[k]!=int(r[k]) for k in r)]
    result={'passed':len(rows)==len(expected) and not mismatches,'cases':len(expected),'seed':20261101,'mismatches':mismatches,'scope':'Host-compiled unchanged PS identity matching vs independent Python integer cosine/rounding/threshold oracle. Not whole-model, board or accuracy verification. No firmware changes.','source_sha256':{n:digest(src/n) for n in names},'input_sha256':digest(out/'input_i8.bin'),'compiler':subprocess.check_output([str(a.gcc),'--version'],env=env,text=True).splitlines()[0]}
    (out/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2));return 0 if result['passed'] else 1
if __name__=='__main__':raise SystemExit(main())

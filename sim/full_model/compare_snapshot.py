"""Compare a flushed board capture with the submitted QDQ ONNX models.
CPU ONNX Runtime is independent of the FPGA convolution implementation.
No tolerances are used to turn mismatches into a pass; one frame is not accuracy validation.
"""
from pathlib import Path
import argparse, json, hashlib, re, csv, math
import numpy as np
import onnx
import onnxruntime as ort
from generate_face_runtime import generate

ROOT=Path(__file__).resolve().parents[2]
F=np.float32
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def sat(x):
    x=np.asarray(x,np.float32)
    return np.clip(np.trunc(x+np.where(x>=0,F(.5),F(-.5))),-128,127).astype(np.int8)
def metric(a,b):
    a=np.asarray(a);b=np.asarray(b);d=np.abs(a.astype(np.float64)-b.astype(np.float64))
    return dict(elements=int(d.size),different=int(np.count_nonzero(d)),max_abs=float(d.max()),mean_abs=float(d.mean()),rmse=float(np.sqrt(np.mean(d*d))))
def tensor(arena,t):
    off,n,h,w,c,s=t
    return arena[off:off+n].reshape(h,w,c)
def decode(arrays,ts,meta,sw,sh):
    best=None;scale=F(min(320/sw,320/sh));x0=(320-int(F(sw)*scale+F(.5)))//2;y0=(320-int(F(sh)*scale+F(.5)))//2
    for stride in (8,16,32):
        def head(name):
            i=meta['heads'][f'{name}_{stride}'];return arrays[i].astype(np.float32)*F(ts[i][5])
        cls,obj,box,kps=[head(n) for n in ('cls','obj','bbox','kps')]
        scores=np.sqrt((1/(1+np.exp(-cls)))*(1/(1+np.exp(-obj))))[:,:,0]
        y,x=np.unravel_index(np.argmax(scores),scores.shape);s=scores[y,x]
        if best is None or s>best[0]:
            b=box[y,x];w=F(np.exp(b[2])*stride);h=F(np.exp(b[3])*stride)
            cx=F((F(x)+b[0])*stride);cy=F((F(y)+b[1])*stride)
            lm=kps[y,x].reshape(5,2).copy();lm[:,0]=(lm[:,0]+x)*stride;lm[:,1]=(lm[:,1]+y)*stride
            lm[:,0]=(lm[:,0]-x0)/scale;lm[:,1]=(lm[:,1]-y0)/scale
            best=np.array([s,(cx-w/F(2)-x0)/scale,(cy-h/F(2)-y0)/scale,w/scale,h/scale,*lm.reshape(-1)],np.float32)
    return best
def align(raw,det):
    # Independent least squares geometry and bilinear sampler, float64 arithmetic.
    src=np.asarray(det[5:],float).reshape(5,2)
    dst=np.array([[38.2946,51.6963],[73.5318,51.5014],[56.0252,71.7366],[41.5493,92.3655],[70.7299,92.2041]])
    sc=src.mean(0);dc=dst.mean(0);s=src-sc;d=dst-dc
    den=np.sum(s*s);a=np.sum(s*d)/den;b=np.sum(s[:,0]*d[:,1]-s[:,1]*d[:,0])/den
    matrix=np.array([[a,-b],[b,a]]);trans=dc-matrix@sc
    y,x=np.mgrid[:112,:112];p=(np.stack((x,y),-1)-trans)@np.linalg.inv(matrix).T
    ix=np.floor(p[...,0]).astype(int);iy=np.floor(p[...,1]).astype(int);fx=p[...,0]-ix;fy=p[...,1]-iy
    mask=(ix>=0)&(iy>=0)&(ix+1<raw.shape[1])&(iy+1<raw.shape[0]);out=np.zeros((112,112,3),np.uint8)
    vx=ix[mask];vy=iy[mask];ax=fx[mask,None];ay=fy[mask,None]
    top=raw[vy,vx].astype(float)*(1-ax)+raw[vy,vx+1]*ax
    bot=raw[vy+1,vx].astype(float)*(1-ax)+raw[vy+1,vx+1]*ax
    out[mask]=np.clip(np.floor(top*(1-ay)+bot*ay+.5),0,255).astype(np.uint8)
    return out[:,:,::-1].copy()
def normalized_embedding(v):
    v=np.asarray(v,np.float32).reshape(-1);return sat(v/F(np.sqrt(np.sum(v*v,dtype=np.float32)))*F(127))
def bn_embedding(q,ts,meta):
    gamma,beta,mean,var=[np.asarray(a,np.float32) for a in meta['bn']]
    x=q.reshape(-1).astype(np.float32)*F(ts[meta['final_tensor']][5])
    return normalized_embedding(gamma*(x-mean)/np.sqrt(var+F(meta['bn_epsilon']))+beta)
def cosine(a,b):
    a=a.astype(float);b=b.astype(float);return float(np.dot(a,b)/np.sqrt(np.dot(a,a)*np.dot(b,b)))
def identity(v):
    src=ROOT/'src/navigator/software'
    def arr(file,name):
        text=(src/file).read_text();m=re.search(r'\b'+name+r'\s*\[[^\]]+\][^=]*=\s*\{([^}]+)\}',text,re.S)
        a=[int(x) for x in re.findall(r'-?\d+',m[1])];assert len(a)==512;return a
    templates=[arr('db_face_identity_template.c','db_face_person01_template_i8'),arr('db_face_gallery.c','db_face_person02_template_i8'),arr('db_face_gallery.c','db_face_person02_camera_template_i8')]
    def score(t):
        q=[int(x) for x in v];den=math.isqrt(sum(x*x for x in q)*sum(x*x for x in t));num=sum(x*y for x,y in zip(q,t))*32768
        return max(-32768,min(32768,((abs(num)+den//2)//den)*(1 if num>=0 else -1))) if den else -2147483648
    scores=[score(templates[0]),max(score(templates[1]),score(templates[2]))]
    threshold=int(re.search(r'DB_FACE_MATCH_THRESHOLD_Q15\s+(\d+)',(src/'db_face_identity_template.h').read_text())[1])
    best=max(scores);person=0 if best<threshold or scores[0]==scores[1] else scores.index(best)+1
    return {'scores_q15':scores,'threshold_q15':threshold,'score_q15':best,'person_id':person,'matched':int(person!=0)}
def run_model(path,names,inp):
    m=onnx.shape_inference.infer_shapes(onnx.load(path))
    outputs=[o.name for o in m.graph.output];infos={v.name:v for v in [*m.graph.value_info,*m.graph.output]}
    for name in names:
        if name not in outputs:m.graph.output.append(infos[name]);outputs.append(name)
    opts=ort.SessionOptions();opts.graph_optimization_level=ort.GraphOptimizationLevel.ORT_DISABLE_ALL;opts.intra_op_num_threads=2
    sess=ort.InferenceSession(m.SerializeToString(),opts,providers=['CPUExecutionProvider'])
    values=dict(zip(outputs,sess.run(None,{sess.get_inputs()[0].name:inp.astype(np.float32)})))
    def hwc(v):
        return v[0].transpose(1,2,0) if v.ndim==4 else v.reshape(1,1,-1)
    return [hwc(values[n]) for n in names],values
def main():
    p=argparse.ArgumentParser();p.add_argument('--capture',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    md=[int(x) for x in (a.capture/'metadata.txt').read_text().split()]
    assert md[0]==0x56455231
    _,frame,ybytes,mbytes,sw,sh,stride,psize=md[:8]
    raw=np.fromfile(a.capture/'raw_bgr.bin',np.uint8).reshape(sh,stride)[:,:sw*3].reshape(sh,sw,3)
    pipe=(a.capture/'pipeline.bin').read_bytes();assert len(pipe)==psize and int.from_bytes(pipe[4:8],'little')==frame
    board_detection=np.frombuffer(pipe,np.float32,count=15,offset=28).copy()
    aligned=np.frombuffer(pipe,np.uint8,count=112*112*3,offset=112).reshape(112,112,3).copy()
    embedding=np.frombuffer(pipe,np.int8,count=512,offset=37744).copy()
    modeldir=ROOT/'src/common/models_and_gallery/models/calibrated_int8_20261015';packdir=ROOT/'src/navigator/deps/face_models_int8'
    desc=(ROOT/'src/navigator/software/db_face_model_generated.c').read_text()
    report={'frame':frame,'scope':'single captured frame; layer comparison and end-to-end QDQ reference; no dataset accuracy claim','onnxruntime':ort.__version__,'onnx':onnx.__version__,'graph_optimization':'disabled','provider':'CPUExecutionProvider','files':{f.name:sha(f) for f in a.capture.iterdir() if f.is_file()},'models':{},'checks':{}}
    data={};rows=[]
    for role,base,arena_size in [('yunet','yunet_320',ybytes),('mobile','mobilefacenet_112',mbytes)]:
        path=modeldir/(base+'_qdq_int8.onnx');manifest=packdir/(base+'_hls_int8.json')
        ts,ops,layers,meta,names=generate(path,manifest,role)
        assert meta['arena_bytes']==arena_size
        match=re.search(r'db_'+role+r'_tensors\[\d+\]=\{(.*?)\n\};',desc,re.S)
        actual=[]
        for row in re.findall(r'\{([^}]+)\}',match.group(1)):
            vals=row.split(',');actual.append([int(x.rstrip('U')) for x in vals[:5]]+[float(vals[5].rstrip('f'))])
        assert len(ts)==len(actual)
        for t,c in zip(ts,actual):assert t[:5]==c[:5] and F(t[5])==F(c[5]),'Descriptor mismatch'
        arena=np.fromfile(a.capture/(role+'.bin'),np.int8);assert len(arena)==arena_size
        board=[tensor(arena,t) for t in ts]
        if role=='yunet':
            inp=np.zeros((320,320,3),np.float32);scale=F(min(320/sw,320/sh));rw=int(F(sw)*scale+F(.5));rh=int(F(sh)*scale+F(.5));x0=(320-rw)//2;y0=(320-rh)//2
            sx=np.minimum((np.arange(rw,dtype=np.float32)/scale).astype(int),sw-1);sy=np.minimum((np.arange(rh,dtype=np.float32)/scale).astype(int),sh-1)
            inp[y0:y0+rh,x0:x0+rw]=raw[sy[:,None],sx[None,:]]
        else:inp=(aligned.astype(np.float32)-F(127.5))/F(127.5)
        check=sat(inp/F(ts[meta['input']][5]));report['checks'][role+'_preprocess']=metric(board[meta['input']],check)
        ref,outputs=run_model(path,names,inp.transpose(2,0,1)[None])
        for i,(b,r) in enumerate(zip(board,ref)):
            z=metric(b,r);rows.append({'network':role,'tensor_id':i,'name':names[i],**z})
            r.astype(np.int8).tofile(a.out/f'{role}_tensor_{i:02d}_reference.bin')
        report['models'][role]={'onnx_sha256':sha(path),'pack_sha256':sha(packdir/(base+'_hls_int8.pack')),'tensors':len(ts),'operations':len(ops),'descriptor_verified':True,'exact_tensors':sum(np.array_equal(b,r) for b,r in zip(board,ref))}
        data[role]=(ts,meta,board,ref,outputs)
        print(role,report['models'][role],flush=True)
    ts,meta,b,r,_=data['yunet'];refdet=decode(r,ts,meta,sw,sh);boarddecode=decode(b,ts,meta,sw,sh)
    report['checks']['board_head_decode']=metric(board_detection,boarddecode)
    report['checks']['qdq_detection']=metric(board_detection,refdet)
    report['checks']['qdq_box_pixels']=metric(board_detection[1:5],refdet[1:5])
    report['checks']['qdq_landmarks_pixels']=metric(board_detection[5:],refdet[5:])
    report['board_detection']=board_detection.tolist();report['qdq_detection']=refdet.tolist()
    aligned_from_board=align(raw,board_detection);refaligned=align(raw,refdet)
    report['checks']['alignment_from_board_landmarks']=metric(aligned,aligned_from_board)
    report['checks']['end_to_end_alignment']=metric(aligned,refaligned)
    aligned.tofile(a.out/'board_aligned_rgb.bin');embedding.tofile(a.out/'board_embedding.bin');refaligned.tofile(a.out/'reference_aligned_rgb.bin')
    ts,meta,b,r,outputs=data['mobile'];boardbn=bn_embedding(b[meta['final_tensor']],ts,meta);refembed=bn_embedding(r[meta['final_tensor']],ts,meta)
    report['checks']['board_bn_l2']=metric(embedding,boardbn)
    report['checks']['mobile_stage_embedding']=dict(**metric(embedding,refembed),cosine=cosine(embedding,refembed))
    refembed.tofile(a.out/'reference_stage_embedding.bin')
    end_ref,_=run_model(modeldir/'mobilefacenet_112_qdq_int8.onnx',generate(modeldir/'mobilefacenet_112_qdq_int8.onnx',packdir/'mobilefacenet_112_hls_int8.json','mobile')[4],((refaligned.astype(np.float32)-F(127.5))/F(127.5)).transpose(2,0,1)[None])
    end_embedding=bn_embedding(end_ref[meta['final_tensor']],ts,meta);end_embedding.tofile(a.out/'reference_end_to_end_embedding.bin')
    report['checks']['end_to_end_embedding']=dict(**metric(embedding,end_embedding),cosine=cosine(embedding,end_embedding))
    report['board_identity_result']={'frame':int.from_bytes(pipe[92:96],'little'),'score_q15':int.from_bytes(pipe[96:100],'little',signed=True),'matched':int.from_bytes(pipe[100:104],'little'),'valid':int.from_bytes(pipe[104:108],'little'),'person_id':int.from_bytes(pipe[108:112],'little')}
    report['identity_reference']={name:identity(v) for name,v in [('board_embedding',embedding),('qdq_stage_embedding',refembed),('qdq_end_to_end_embedding',end_embedding)]}
    report['identity_board_matches_independent']=all(report['board_identity_result'][k]==report['identity_reference']['board_embedding'][k] for k in ('score_q15','person_id','matched'))
    report['qdq_identity_decision_agrees']=all(report['board_identity_result'][k]==report['identity_reference']['qdq_end_to_end_embedding'][k] for k in ('person_id','matched'))
    with (a.out/'layers.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    (a.out/'result.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report['checks'],indent=2))
if __name__=='__main__':main()

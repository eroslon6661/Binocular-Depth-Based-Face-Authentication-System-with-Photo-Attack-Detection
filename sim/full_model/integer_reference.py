"""Independent NumPy integer deployment reference; no HLS/C function is called.
Convolution accumulators, Q31 rescaling and Q15 PReLU implement the pack contract.
PS-only operators retain float32 and half-away rounding used by this deployment.
"""
from pathlib import Path
import argparse,json,csv
import numpy as np
from compare_snapshot import ROOT,generate,tensor,sat,metric,bn_embedding

def requant(v,m,s,extra=0):
    v=np.asarray(v,np.int64);out=np.empty_like(v)
    for c in range(v.shape[-1]):
        x=v[...,c]*int(m[c]);right=31+extra-int(s[c])
        if right>0:
            mag=np.abs(x);q=mag>>right;r=mag- (q<<right);half=1<<(right-1)
            q=q+((r>half)|((r==half)&((q&1)==1)))
            out[...,c]=np.where(x<0,-q,q)
        else:out[...,c]=x<<(-right)
    return out
def conv(inp,layer,pack,shape):
    oh,ow,oc=shape;ic=inp.shape[2];g=layer['groups'];ipg=ic//g;opg=oc//g;k=layer['kernel'];st=layer['stride'];pd=layer['pad']
    def read(key,dtype,count):return np.frombuffer(pack,dtype=dtype,count=count,offset=layer[key])
    w=read('weights_offset',np.int8,oc*k*k*ipg).reshape(oc,k*k*ipg).astype(np.int64)
    bias=read('bias_offset','<i4',oc).astype(np.int64)
    m=read('multiplier_q31_offset','<i4',layer['multiplier_q31_bytes']//4)
    s=read('scale_shift_offset',np.int8,layer['scale_shift_bytes'])
    slope=read('prelu_slope_q15_offset','<i2',oc).astype(np.int64)
    padded=np.pad(inp,((pd,pd),(pd,pd),(0,0)))
    win=np.lib.stride_tricks.sliding_window_view(padded,(k,k),axis=(0,1))[::st,::st].transpose(0,1,3,4,2)
    acc=np.empty((oh,ow,oc),np.int64)
    for group in range(g):
        x=win[:oh,:ow,:,:,group*ipg:(group+1)*ipg].reshape(oh*ow,-1).astype(np.int64)
        lo=group*opg;hi=lo+opg
        acc[:,:,lo:hi]=(x@w[lo:hi].T+bias[lo:hi]).reshape(oh,ow,opg)
    # The hardware accumulator is signed 32 bits, including overflow semantics.
    acc=acc.astype(np.int32).astype(np.int64)
    q=np.clip(requant(acc,m[:oc],s[:oc]),-128,127)
    if layer['activation']==1:q=requant(np.maximum(q,0),m[oc:oc*2],s[oc:oc*2])
    elif layer['activation']==2:
        neg=requant(q*slope,m[oc:oc*2],s[oc:oc*2],15)
        pos=requant(q,m[oc:oc*2],s[oc:oc*2]);q=np.where(q<0,neg,pos)
    return np.clip(q,-128,127).astype(np.int8)
def execute(role,op,vals,ts,layers,pack,meta):
    typ,ai,bi,oi,li,k,st,pd=op;a=vals[ai];t=ts[ai];o=ts[oi];sa=np.float32(t[5]);so=np.float32(o[5]);h,w,c=o[2:5]
    if typ==1:return conv(a,layers[li],pack,(h,w,c))
    if typ==2:return sat((a.astype(np.float32)*sa+vals[bi].astype(np.float32)*np.float32(ts[bi][5]))/so)
    if typ==3:
        p=np.pad(a,((pd,pd),(pd,pd),(0,0)),constant_values=-128)
        v=np.lib.stride_tricks.sliding_window_view(p,(k,k),axis=(0,1))[::st,::st].max(axis=(-2,-1))[:h,:w]
        if li:v=np.maximum(v,0)
        return sat(v.astype(np.float32)*sa/so)
    if typ==4:
        v=a[(np.arange(h)*a.shape[0]//h)[:,None],(np.arange(w)*a.shape[1]//w)[None,:]]
        return sat(v.astype(np.float32)*sa/so)
    if typ==5:
        if t[2]>1 and t[3]>1 and h==w==1 and c==a.size:
            v=a.astype(np.float32)*sa
            if li:v=np.where(v<0,v*np.asarray(meta['flat_prelu'],np.float32),v)
            return sat(v.transpose(2,0,1).reshape(h,w,c)/so)
        return sat(a.astype(np.float32)*np.float32(sa/so)).reshape(h,w,c)
    raise ValueError(typ)
def main():
    p=argparse.ArgumentParser();p.add_argument('--capture',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    md=[int(v) for v in (a.capture/'metadata.txt').read_text().split()];rows=[];summary={'frame':md[1],'scope':'whole graph fixed-point deployment reference; separate from QDQ float operator equivalence','networks':{}}
    models=ROOT/'src/common/models_and_gallery/models/calibrated_int8_20261015';packs=ROOT/'src/navigator/deps/face_models_int8'
    for role,base in [('yunet','yunet_320'),('mobile','mobilefacenet_112')]:
        ts,ops,layers,meta,names=generate(models/(base+'_qdq_int8.onnx'),packs/(base+'_hls_int8.json'),role)
        pack=(packs/(base+'_hls_int8.pack')).read_bytes();arena=np.fromfile(a.capture/(role+'.bin'),np.int8);board=[tensor(arena,t) for t in ts]
        vals={meta['input']:board[meta['input']].copy()};local_bad=0
        for n,op in enumerate(ops):
            ref=execute(role,op,vals,ts,layers,pack,meta);vals[op[3]]=ref;z=metric(board[op[3]],ref)
            # Local replay removes propagated errors and pinpoints operator defects.
            local=ref if z['different']==0 else execute(role,op,dict(enumerate(board)),ts,layers,pack,meta)
            lz=metric(board[op[3]],local);local_bad+=lz['different']!=0
            rows.append({'network':role,'op':n,'type':op[0],'tensor':op[3],**z,'local_different':lz['different'],'local_max_abs':lz['max_abs']})
            print(role,n,z['different'],lz['different'],flush=True)
        summary['networks'][role]={'operations':len(ops),'exact_cumulative_operations':sum(r['different']==0 for r in rows if r['network']==role),'local_mismatching_operations':local_bad}
        if role=='mobile':
            emb=bn_embedding(vals[meta['final_tensor']],ts,meta);emb.tofile(a.out/'integer_embedding.bin')
            actual=np.frombuffer((a.capture/'pipeline.bin').read_bytes(),np.int8,count=512,offset=37744)
            summary['embedding']=metric(actual,emb)
    summary['passed']=all(n['local_mismatching_operations']==0 and n['exact_cumulative_operations']==n['operations'] for n in summary['networks'].values()) and summary['embedding']['different']==0
    with (a.out/'operators.csv').open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    (a.out/'result.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
if __name__=='__main__':main()

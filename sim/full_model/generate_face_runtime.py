#!/usr/bin/env python3
"""Generate compact static runtime descriptors for the calibrated face graphs."""
from __future__ import annotations
import argparse,json,math
from pathlib import Path
import numpy as np, onnx
from onnx import numpy_helper

OP_CONV,OP_ADD,OP_MAXPOOL,OP_RESIZE,OP_REQUANT=1,2,3,4,5

def generate(model_path:Path,manifest_path:Path,prefix:str):
    m=onnx.shape_inference.infer_shapes(onnx.load(model_path)); manifest=json.loads(manifest_path.read_text())
    init={x.name:numpy_helper.to_array(x) for x in m.graph.initializer}; prod={o:n for n in m.graph.node for o in n.output}
    cons={}
    for n in m.graph.node:
        for x in n.input: cons.setdefault(x,[]).append(n)
    shapes={}
    for v in [*m.graph.input,*m.graph.value_info,*m.graph.output]:
        d=[x.dim_value for x in v.type.tensor_type.shape.dim]
        if d and all(d[1:]): shapes[v.name]=[1 if i==0 and x==0 else x for i,x in enumerate(d)]
    def attrs(n):
        return {a.name:(list(a.ints) if a.ints else (list(a.floats) if a.floats else (a.i if a.type==2 else a.f))) for a in n.attribute}
    def qsrc(value):
        n=prod.get(value)
        if n and n.op_type=="DequantizeLinear": return n.input[0]
        if n and n.op_type in {"Flatten","Reshape","Transpose","Relu","PRelu"}: return qsrc(n.input[0])
        return value
    def downstream_q(value,max_depth=5):
        frontier=[value]; seen=set()
        for _ in range(max_depth):
            nxt=[]
            for x in frontier:
                for n in cons.get(x,[]):
                    if n.op_type=="QuantizeLinear":
                        q_users=cons.get(n.output[0],[])
                        if len(q_users)==1 and q_users[0].op_type=="DequantizeLinear":
                            act_users=cons.get(q_users[0].output[0],[])
                            if len(act_users)==1 and act_users[0].op_type in {"Relu","PRelu"}:
                                tail=cons.get(act_users[0].output[0],[])
                                if len(tail)==1 and tail[0].op_type=="QuantizeLinear": return tail[0].output[0]
                        return n.output[0]
                    if n.op_type in {"Relu","PRelu","Flatten","Reshape","Transpose"} and id(n) not in seen:
                        seen.add(id(n)); nxt+=list(n.output)
            frontier=nxt
        return None
    def scale(q):
        n=prod.get(q)
        if n is None or n.op_type!="QuantizeLinear":
            raise ValueError(f"{prefix}:{q} is not a quantized tensor ({getattr(n,'op_type',None)})")
        return float(np.asarray(init[n.input[1]]).reshape(-1)[0])
    qtensors=set()
    rawops=[]; conv_i=0
    for n in m.graph.node:
        if n.op_type in {"Conv","Gemm"}:
            i=qsrc(n.input[0]); o=downstream_q(n.output[0]);
            if not o: raise ValueError(f"{prefix}:{n.name} no output Q")
            rawops.append([OP_CONV,i,"",o,conv_i,0,0,0]); conv_i+=1; qtensors|={i,o}
        elif n.op_type=="Add":
            i0,i1=qsrc(n.input[0]),qsrc(n.input[1]); o=downstream_q(n.output[0],2)
            if not o: raise ValueError(f"{prefix}:{n.name} no output Q")
            rawops.append([OP_ADD,i0,i1,o,0,0,0,0]); qtensors|={i0,i1,o}
        elif n.op_type=="MaxPool":
            i=qsrc(n.input[0]); o=downstream_q(n.output[0],2); a=attrs(n)
            # Some YuNet pools consume a Relu of the preceding quantized tensor
            # without another QuantizeLinear node. Preserve that activation.
            relu_input=int(prod[n.input[0]].op_type=="Relu")
            rawops.append([OP_MAXPOOL,i,"",o,relu_input,int(a['kernel_shape'][0]),int(a.get('strides',[1])[0]),int(a.get('pads',[0])[0])]); qtensors|={i,o}
        elif n.op_type=="Resize":
            i=qsrc(n.input[0]); o=downstream_q(n.output[0],2)
            rawops.append([OP_RESIZE,i,"",o,0,0,0,0]); qtensors|={i,o}
        elif n.op_type=="QuantizeLinear":
            p=prod.get(n.input[0])
            if p and p.op_type in {"Flatten","Reshape","Transpose"}:
                i=qsrc(p.input[0]); o=n.output[0]
                pre=prod.get(p.input[0])
                prelu_before_flatten=int(p.op_type=="Flatten" and pre is not None and pre.op_type=="PRelu")
                if i!=o: rawops.append([OP_REQUANT,i,"",o,prelu_before_flatten,0,0,0]); qtensors|={i,o}
    if conv_i!=len(manifest['layers']): raise ValueError((prefix,conv_i,len(manifest['layers'])))
    # Only activation tensors, never quantized weight/bias initializers.
    qtensors={q for q in qtensors if q not in init}
    ordered=sorted(qtensors); ids={q:i for i,q in enumerate(ordered)}; tensors=[]; off=0
    for q in ordered:
        s=shapes.get(q)
        if not s:
            # Q output has same shape as its source.
            s=shapes.get(prod[q].input[0])
        if not s: raise ValueError(f"{prefix}:{q} no shape")
        if len(s)==4: _,c,h,w=s
        elif len(s)==2: _,c=s; h=w=1
        else: raise ValueError((q,s))
        off=(off+63)&~63; size=int(c*h*w); tensors.append([off,size,int(h),int(w),int(c),scale(q)]); off+=size
    ops=[]
    for typ,i0,i1,o,layer,kernel,stride,pad in rawops:
        if i0 not in ids or o not in ids or (i1 and i1 not in ids): continue
        ops.append([typ,ids[i0],ids[i1] if i1 else 65535,ids[o],layer,kernel,stride,pad])
    # Network input: first Q node fed by graph input.
    inp=next(n.output[0] for n in m.graph.node if n.op_type=="QuantizeLinear" and n.input[0]==m.graph.input[0].name)
    available={ids[inp]}
    for number,op in enumerate(ops):
        if op[1] not in available or (op[2]!=65535 and op[2] not in available):
            raise ValueError(f"{prefix}: op {number} consumes an unavailable tensor: {op}")
        available.add(op[3])
    meta={"arena_bytes":off,"input":ids[inp]}
    if prefix=="yunet":
        heads={}
        for out in m.graph.output:
            x=out.name
            while x not in ids:
                n=prod[x]; x=qsrc(n.input[0])
            heads[out.name]=ids[x]
        meta["heads"]=heads
        if any(value not in available for value in heads.values()): raise ValueError(f"{prefix}: unavailable output head")
    else:
        bn=next(n for n in m.graph.node if n.op_type=="BatchNormalization")
        meta["final_tensor"]=ids[qsrc(bn.input[0])]
        if meta["final_tensor"] not in available: raise ValueError(f"{prefix}: unavailable final tensor")
        a=attrs(bn); meta["bn_epsilon"]=float(a.get("epsilon",1e-5))
        meta["bn"]=[np.asarray(init[x],np.float32).reshape(-1).tolist() for x in bn.input[1:5]]
        flat_prelu=[]
        for n in m.graph.node:
            if n.op_type=="Flatten":
                p=prod.get(n.input[0])
                if p is not None and p.op_type=="PRelu":
                    flat_prelu=np.asarray(init[p.input[1]],np.float32).reshape(-1).tolist()
        if not flat_prelu: raise ValueError(f"{prefix}: missing pre-Flatten PRelu slopes")
        meta["flat_prelu"]=flat_prelu
    return tensors,ops,manifest['layers'],meta,ordered

def c_array(name,rows,fmt):
    return f"const {fmt[0]} {name}[{len(rows)}]={{\n"+"\n".join("    {"+fmt[1](r)+"}," for r in rows)+"\n};\n"

def cf(value):
    s=f'{value:.9g}'
    if '.' not in s and 'e' not in s: s+='.'
    return s+'f'

def main():
    p=argparse.ArgumentParser(); p.add_argument('--models',type=Path,required=True);p.add_argument('--packs',type=Path,required=True);p.add_argument('--src',type=Path,required=True);a=p.parse_args()
    y=generate(a.models/'yunet_320_qdq_int8.onnx',a.packs/'yunet_320_hls_int8.json','yunet')
    f=generate(a.models/'mobilefacenet_112_qdq_int8.onnx',a.packs/'mobilefacenet_112_hls_int8.json','mobile')
    h='''#ifndef DB_FACE_MODEL_GENERATED_H\n#define DB_FACE_MODEL_GENERATED_H\n#include <stdint.h>\ntypedef struct {uint32_t offset,bytes;uint16_t h,w,c;float scale;} DbFaceTensorDesc;\ntypedef struct {uint16_t type,in0,in1,out,layer,kernel,stride,pad;} DbFaceOpDesc;\ntypedef struct {uint32_t weights_offset,bias_offset,multiplier_offset,shift_offset,slope_offset;uint16_t in_h,in_w,in_c,out_h,out_w,out_c,kernel,stride,pad,groups,activation;} DbFaceConvDesc;\nextern const unsigned char db_yunet_pack_start[],db_yunet_pack_end[],db_mobile_pack_start[],db_mobile_pack_end[];\nextern const DbFaceTensorDesc db_yunet_tensors[],db_mobile_tensors[];extern const DbFaceOpDesc db_yunet_ops[],db_mobile_ops[];extern const DbFaceConvDesc db_yunet_convs[],db_mobile_convs[];\nextern const unsigned db_yunet_tensor_count,db_yunet_op_count,db_yunet_conv_count,db_yunet_input_tensor,db_yunet_arena_bytes;\nextern const unsigned db_mobile_tensor_count,db_mobile_op_count,db_mobile_conv_count,db_mobile_input_tensor,db_mobile_final_tensor,db_mobile_arena_bytes;\nextern const uint16_t db_yunet_heads[12];extern const float db_mobile_bn_gamma[512],db_mobile_bn_beta[512],db_mobile_bn_mean[512],db_mobile_bn_var[512],db_mobile_bn_epsilon;\nextern const float db_mobile_flatten_prelu_slope[64];\n#endif\n'''
    def emit(prefix,data):
        ts,ops,layers,meta,*_=data
        s=c_array(f'db_{prefix}_tensors',ts,('DbFaceTensorDesc',lambda r:f'{r[0]}U,{r[1]}U,{r[2]}U,{r[3]}U,{r[4]}U,{cf(r[5])}'))
        s+=c_array(f'db_{prefix}_ops',ops,('DbFaceOpDesc',lambda r:','.join(str(x)+'U' for x in r)))
        cr=[]
        for x in layers:
            if x['op']=='Conv' and len(x['input_shape_nchw'])!=4:
                raise ValueError(f"{prefix}: missing Conv input shape for {x['name']}")
            if len(x['input_shape_nchw'])>=4:
                _,ic,ih,iw=x['input_shape_nchw']
            else:
                ih=iw=1; ic=x['weights_bytes']//max(1,x['bias_bytes']) * 4 if x['op']=='Gemm' else 0
            if len(x['output_shape_nchw'])>=4:
                _,oc,oh,ow=x['output_shape_nchw']
            elif len(x['output_shape_nchw'])==2:
                _,oc=x['output_shape_nchw'];oh=ow=1
            else:
                oc=x['bias_bytes']//4;oh=ow=1
            cr.append([x['weights_offset'],x['bias_offset'],x['multiplier_q31_offset'],x['scale_shift_offset'],x['prelu_slope_q15_offset'],ih,iw,ic,oh,ow,oc,x['kernel'],x['stride'],x['pad'],x['groups'],x['activation']])
        s+=c_array(f'db_{prefix}_convs',cr,('DbFaceConvDesc',lambda r:','.join(str(x)+'U' for x in r)))
        s+=f'const unsigned db_{prefix}_tensor_count={len(ts)}U,db_{prefix}_op_count={len(ops)}U,db_{prefix}_conv_count={len(cr)}U,db_{prefix}_input_tensor={meta["input"]}U,db_{prefix}_arena_bytes={meta["arena_bytes"]}U;\n'
        return s
    source='#include "db_face_model_generated.h"\n'+emit('yunet',y)+emit('mobile',f)
    order=['cls_8','cls_16','cls_32','obj_8','obj_16','obj_32','bbox_8','bbox_16','bbox_32','kps_8','kps_16','kps_32']
    source+='const uint16_t db_yunet_heads[12]={'+','.join(str(y[3]['heads'][x])+'U' for x in order)+'};\n'
    bn=f[3]['bn']; labels=['gamma','beta','mean','var']
    for label,vals in zip(labels,bn): source+=f'const float db_mobile_bn_{label}[512]={{'+','.join(cf(v) for v in vals)+'};\n'
    if len(f[3]['flat_prelu'])!=64: raise ValueError('mobile: expected 64 pre-Flatten PRelu slopes')
    source+='const float db_mobile_flatten_prelu_slope[64]={'+','.join(cf(v) for v in f[3]['flat_prelu'])+'};\n'
    source+=f'const float db_mobile_bn_epsilon={cf(f[3]["bn_epsilon"])};\nconst unsigned db_mobile_final_tensor={f[3]["final_tensor"]}U;\n'
    asm='''.section .db_face_models,"a"\n.balign 64\n.global db_yunet_pack_start\ndb_yunet_pack_start:\n.incbin "yunet_320_hls_int8.pack"\n.global db_yunet_pack_end\ndb_yunet_pack_end:\n.balign 64\n.global db_mobile_pack_start\ndb_mobile_pack_start:\n.incbin "mobilefacenet_112_hls_int8.pack"\n.global db_mobile_pack_end\ndb_mobile_pack_end:\n'''
    a.src.mkdir(parents=True,exist_ok=True);(a.src/'db_face_model_generated.h').write_text(h);(a.src/'db_face_model_generated.c').write_text(source);(a.src/'db_face_model_data.S').write_text(asm)
    print(json.dumps({'yunet':{'tensors':len(y[0]),'ops':len(y[1]),'arena':y[3]['arena_bytes']},'mobile':{'tensors':len(f[0]),'ops':len(f[1]),'arena':f[3]['arena_bytes']}},indent=2))
if __name__=='__main__':main()

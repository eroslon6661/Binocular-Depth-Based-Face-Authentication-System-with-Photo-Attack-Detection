#include "db_face_pipeline.h"
#include "db_face_box.h"
#include "db_face_profile.h"
#include "db_net.h"
#include "db_face_model_generated.h"
#include "xil_cache.h"
#include "xil_io.h"
#include <math.h>
#include <stdint.h>
#include <string.h>

#define FACE_REG_BASE 0x40090000U
#define FACE_ARENA_BASE 0x14000000U
#define R_AP 0x00U
#define R_INPUT 0x10U
#define R_WEIGHTS 0x1CU
#define R_BIAS 0x28U
#define R_MULT 0x34U
#define R_SHIFT 0x40U
#define R_SLOPE 0x4CU
#define R_RESIDUAL 0x58U
#define R_OUTPUT 0x64U
#define R_IN_H 0x70U
#define R_IN_W 0x78U
#define R_IN_C 0x80U
#define R_OUT_C 0x88U
#define R_KERNEL 0x90U
#define R_STRIDE 0x98U
#define R_PAD 0xA0U
#define R_GROUPS 0xA8U
#define R_IN_PG 0xB0U
#define R_OUT_PG 0xB8U
#define R_OUT_H 0xC0U
#define R_OUT_W 0xC8U
#define R_ACT 0xD0U
#define R_RES_EN 0xD8U
#define OP_CONV 1U
#define OP_ADD 2U
#define OP_MAXPOOL 3U
#define OP_RESIZE 4U
#define OP_REQUANT 5U

typedef struct {
    const DbFaceTensorDesc *tensor; const DbFaceOpDesc *op; const DbFaceConvDesc *conv;
    const unsigned char *pack; unsigned tensor_count,op_count,op_index;
    unsigned running,kind; float letter_scale,letter_x,letter_y;
} Runtime;
static Runtime rt;
static uint32_t perf_run,perf_wait_started;
static DbFacePerfEvent perf_event;

static int8_t *tp(unsigned id){return (int8_t *)(uintptr_t)(FACE_ARENA_BASE+rt.tensor[id].offset);}
static int sat(float x){int v=(int)(x+(x>=0.0f?0.5f:-0.5f));return v>127?127:(v<-128?-128:v);}
static float deq(int8_t q,float s){return (float)q*s;}

static void cpu_requant(const DbFaceOpDesc *x)
{
    unsigned in=x->in0,out=x->out;
    const DbFaceTensorDesc *a=&rt.tensor[in],*o=&rt.tensor[out];unsigned i,n=o->bytes<a->bytes?o->bytes:a->bytes;
    int8_t *src=tp(in),*dst=tp(out);float k=a->scale/o->scale;
    if(a->h>1U && a->w>1U && o->h==1U && o->w==1U &&
       o->c==a->bytes && o->bytes==a->bytes) {
        /* ONNX Flatten follows NCHW order, while accelerator activations are
         * stored HWC. MobileFaceNet also applies PRelu just before Flatten,
         * without an intervening QuantizeLinear node. */
        unsigned c,y,px;
        for(c=0;c<a->c;++c)for(y=0;y<a->h;++y)for(px=0;px<a->w;++px) {
            float value=(float)src[(y*a->w+px)*a->c+c]*a->scale;
            if(x->layer && value<0.0f)value*=db_mobile_flatten_prelu_slope[c];
            dst[c*a->h*a->w+y*a->w+px]=(int8_t)sat(value/o->scale);
        }
    } else {
        for(i=0;i<n;++i)dst[i]=(int8_t)sat((float)src[i]*k);
    }
    Xil_DCacheFlushRange((UINTPTR)dst,o->bytes);
}
static void cpu_add(unsigned ai,unsigned bi,unsigned oi)
{
    const DbFaceTensorDesc *a=&rt.tensor[ai],*b=&rt.tensor[bi],*o=&rt.tensor[oi];unsigned i;
    int8_t *ap=tp(ai),*bp=tp(bi),*op=tp(oi);
    for(i=0;i<o->bytes;++i)op[i]=(int8_t)sat(((float)ap[i]*a->scale+(float)bp[i]*b->scale)/o->scale);
    Xil_DCacheFlushRange((UINTPTR)op,o->bytes);
}
static void cpu_pool(const DbFaceOpDesc *x)
{
    const DbFaceTensorDesc *a=&rt.tensor[x->in0],*o=&rt.tensor[x->out];int8_t *ap=tp(x->in0),*op=tp(x->out);
    unsigned y,z,c,ky,kx;
    for(y=0;y<o->h;++y)for(z=0;z<o->w;++z)for(c=0;c<o->c;++c){
        int best=-128;
        for(ky=0;ky<x->kernel;++ky)for(kx=0;kx<x->kernel;++kx){
            int iy=(int)(y*x->stride+ky)-(int)x->pad,ix=(int)(z*x->stride+kx)-(int)x->pad;
            if(iy>=0&&ix>=0&&iy<a->h&&ix<a->w){int v=ap[((unsigned)iy*a->w+(unsigned)ix)*a->c+c];if(v>best)best=v;}
        }
        if(x->layer && best<0)best=0; /* Relu before MaxPool; max(ReLU(x)) == ReLU(max(x)). */
        op[(y*o->w+z)*o->c+c]=(int8_t)sat((float)best*a->scale/o->scale);
    }
    Xil_DCacheFlushRange((UINTPTR)op,o->bytes);
}
static void cpu_resize(const DbFaceOpDesc *x)
{
    const DbFaceTensorDesc *a=&rt.tensor[x->in0],*o=&rt.tensor[x->out];int8_t *ap=tp(x->in0),*op=tp(x->out);unsigned y,z,c;
    for(y=0;y<o->h;++y)for(z=0;z<o->w;++z){unsigned iy=(y*a->h)/o->h,ix=(z*a->w)/o->w;
        for(c=0;c<o->c;++c)op[(y*o->w+z)*o->c+c]=(int8_t)sat((float)ap[(iy*a->w+ix)*a->c+c]*a->scale/o->scale);
    }
    Xil_DCacheFlushRange((UINTPTR)op,o->bytes);
}
static void wr(unsigned off,uint32_t value){Xil_Out32(FACE_REG_BASE+off,value);}
static void launch_conv(const DbFaceOpDesc *op)
{
    const DbFaceConvDesc *c=&rt.conv[op->layer];const DbFaceTensorDesc *in=&rt.tensor[op->in0],*out=&rt.tensor[op->out];
    uintptr_t p=(uintptr_t)rt.pack;uint32_t begin=db_time_us(),cached;
    memset(&perf_event,0,sizeof(perf_event));perf_event.run=perf_run;
    perf_event.net=(uint16_t)rt.kind;perf_event.op=(uint16_t)rt.op_index;
    perf_event.type=OP_CONV;perf_event.layer=op->layer;perf_event.bytes=out->bytes;
    Xil_DCacheFlushRange((UINTPTR)tp(op->in0),in->bytes);Xil_DCacheFlushRange((UINTPTR)tp(op->out),out->bytes);
    cached=db_time_us();perf_event.cache_us=(uint32_t)(cached-begin);
    wr(R_INPUT,(uint32_t)(uintptr_t)tp(op->in0));wr(R_WEIGHTS,(uint32_t)(p+c->weights_offset));wr(R_BIAS,(uint32_t)(p+c->bias_offset));
    wr(R_MULT,(uint32_t)(p+c->multiplier_offset));wr(R_SHIFT,(uint32_t)(p+c->shift_offset));wr(R_SLOPE,(uint32_t)(p+c->slope_offset));
    wr(R_RESIDUAL,0U);wr(R_OUTPUT,(uint32_t)(uintptr_t)tp(op->out));wr(R_IN_H,c->in_h);wr(R_IN_W,c->in_w);wr(R_IN_C,c->in_c);
    wr(R_OUT_C,c->out_c);wr(R_KERNEL,c->kernel);wr(R_STRIDE,c->stride);wr(R_PAD,c->pad);wr(R_GROUPS,c->groups);
    wr(R_IN_PG,c->in_c/c->groups);wr(R_OUT_PG,c->out_c/c->groups);wr(R_OUT_H,c->out_h);wr(R_OUT_W,c->out_w);
    wr(R_ACT,c->activation);wr(R_RES_EN,0U);wr(R_AP,1U);rt.running=1U;
    perf_wait_started=db_time_us();perf_event.submit_us=(uint32_t)(perf_wait_started-cached);
}
static int run_poll(void)
{
    if(rt.running){
        if((Xil_In32(FACE_REG_BASE+R_AP)&2U)==0U)return 0;
        uint32_t done=db_time_us();perf_event.wait_us=(uint32_t)(done-perf_wait_started);
        Xil_DCacheInvalidateRange((UINTPTR)tp(rt.op[rt.op_index].out),rt.tensor[rt.op[rt.op_index].out].bytes);
        perf_event.cache_us+=(uint32_t)(db_time_us()-done);db_face_profile_push(&perf_event);
        rt.running=0U;++rt.op_index;
    }
    while(rt.op_index<rt.op_count){const DbFaceOpDesc *o=&rt.op[rt.op_index];
        if(o->type==OP_CONV){launch_conv(o);return 0;}
        uint32_t begin=db_time_us();
        if(o->type==OP_ADD)cpu_add(o->in0,o->in1,o->out);
        else if(o->type==OP_MAXPOOL)cpu_pool(o);
        else if(o->type==OP_RESIZE)cpu_resize(o);
        else if(o->type==OP_REQUANT)cpu_requant(o);
        else return -1;
        DbFacePerfEvent e;memset(&e,0,sizeof(e));e.run=perf_run;e.net=(uint16_t)rt.kind;
        e.op=(uint16_t)rt.op_index;e.type=o->type;e.layer=o->layer;
        e.cpu_us=(uint32_t)(db_time_us()-begin);e.bytes=rt.tensor[o->out].bytes;db_face_profile_push(&e);
        ++rt.op_index;
    }
    return 1;
}
static void setup_yunet(void){rt.tensor=db_yunet_tensors;rt.op=db_yunet_ops;rt.conv=db_yunet_convs;rt.pack=db_yunet_pack_start;rt.tensor_count=db_yunet_tensor_count;rt.op_count=db_yunet_op_count;rt.op_index=rt.running=0;rt.kind=1;}
static void setup_mobile(void){rt.tensor=db_mobile_tensors;rt.op=db_mobile_ops;rt.conv=db_mobile_convs;rt.pack=db_mobile_pack_start;rt.tensor_count=db_mobile_tensor_count;rt.op_count=db_mobile_op_count;rt.op_index=rt.running=0;rt.kind=2;}

int db_face_nn_backend_init(void)
{
    if(memcmp(db_yunet_pack_start,"DBF8PK01",8)!=0||memcmp(db_mobile_pack_start,"DBF8PK01",8)!=0)return 0;
    Xil_DCacheFlushRange((UINTPTR)db_yunet_pack_start,(unsigned)(db_yunet_pack_end-db_yunet_pack_start));
    Xil_DCacheFlushRange((UINTPTR)db_mobile_pack_start,(unsigned)(db_mobile_pack_end-db_mobile_pack_start));
    return (Xil_In32(FACE_REG_BASE+R_AP)&4U)!=0U;
}
int db_face_yunet_begin(const uint8_t *src,unsigned sw,unsigned sh,unsigned stride)
{
    uint32_t begin=db_time_us();DbFacePerfEvent e;
    if(++perf_run==0U)++perf_run;
    unsigned x,y,c;setup_yunet();const DbFaceTensorDesc *t=&rt.tensor[db_yunet_input_tensor];int8_t *dst=tp(db_yunet_input_tensor);
    float scale=fminf((float)t->w/(float)sw,(float)t->h/(float)sh);unsigned rw=(unsigned)((float)sw*scale+0.5f),rh=(unsigned)((float)sh*scale+0.5f);
    unsigned x0=(t->w-rw)/2U,y0=(t->h-rh)/2U;memset(dst,0,t->bytes);rt.letter_scale=scale;rt.letter_x=(float)x0;rt.letter_y=(float)y0;
    for(y=0;y<rh;++y)for(x=0;x<rw;++x){unsigned sy=(unsigned)((float)y/scale),sx=(unsigned)((float)x/scale);if(sy>=sh)sy=sh-1;if(sx>=sw)sx=sw-1;
        for(c=0;c<3;++c)dst[((y+y0)*t->w+x+x0)*3U+c]=(int8_t)sat((float)src[sy*stride+sx*3U+c]/t->scale);
    }
    Xil_DCacheFlushRange((UINTPTR)dst,t->bytes);
    memset(&e,0,sizeof(e));e.run=perf_run;e.net=1;e.type=6;e.bytes=t->bytes;
    e.cpu_us=(uint32_t)(db_time_us()-begin);db_face_profile_push(&e);return 1;
}
static float sigmoidf_fast(float x){if(x>16.0f)return 1.0f;if(x<-16.0f)return 0.0f;return 1.0f/(1.0f+expf(-x));}
static int decode_yunet(DbFaceDetection *d)
{
    float best=0.0f;unsigned level,y,x,k;memset(d,0,sizeof(*d));
    for(level=0;level<3;++level){const DbFaceTensorDesc *tc=&rt.tensor[db_yunet_heads[level]],*to=&rt.tensor[db_yunet_heads[3+level]],*tb=&rt.tensor[db_yunet_heads[6+level]],*tk=&rt.tensor[db_yunet_heads[9+level]];
        int8_t *pc=tp(db_yunet_heads[level]),*po=tp(db_yunet_heads[3+level]),*pb=tp(db_yunet_heads[6+level]),*pk=tp(db_yunet_heads[9+level]);float st=(float)(8U<<level);
        for(y=0;y<tc->h;++y)for(x=0;x<tc->w;++x){unsigned i=y*tc->w+x;float s=sqrtf(sigmoidf_fast(deq(pc[i],tc->scale))*sigmoidf_fast(deq(po[i],to->scale)));
            if(s>best){float b[4],box[4];unsigned j;
                for(j=0;j<4;++j)b[j]=deq(pb[i*4+j],tb->scale);
                if(!db_face_decode_box(x,y,st,b,box))continue;
                best=s;d->score=s;d->x=box[0];d->y=box[1];d->width=box[2];d->height=box[3];
                for(k=0;k<5;++k){d->landmark[k][0]=((float)x+deq(pk[i*10+k*2],tk->scale))*st;d->landmark[k][1]=((float)y+deq(pk[i*10+k*2+1],tk->scale))*st;}
            }
        }
    }
    d->x=(d->x-rt.letter_x)/rt.letter_scale;d->y=(d->y-rt.letter_y)/rt.letter_scale;d->width/=rt.letter_scale;d->height/=rt.letter_scale;
    for(k=0;k<5;++k){d->landmark[k][0]=(d->landmark[k][0]-rt.letter_x)/rt.letter_scale;d->landmark[k][1]=(d->landmark[k][1]-rt.letter_y)/rt.letter_scale;}
    return best>0.0f;
}
int db_face_yunet_poll(DbFaceDetection *d){
    int status=run_poll(),decoded;uint32_t begin;DbFacePerfEvent e;if(status<=0)return status;
    begin=db_time_us();decoded=decode_yunet(d);memset(&e,0,sizeof(e));
    e.run=perf_run;e.net=1;e.type=7;e.cpu_us=(uint32_t)(db_time_us()-begin);db_face_profile_push(&e);
    return decoded?1:-1;
}
int db_face_mobilefacenet_begin(const uint8_t rgb[DB_FACE_ALIGN_SIZE*DB_FACE_ALIGN_SIZE*3U])
{
    uint32_t begin=db_time_us();DbFacePerfEvent e;
    unsigned i;setup_mobile();const DbFaceTensorDesc *t=&rt.tensor[db_mobile_input_tensor];int8_t *dst=tp(db_mobile_input_tensor);
    for(i=0;i<t->bytes;++i)dst[i]=(int8_t)sat((((float)rgb[i]-127.5f)/127.5f)/t->scale);
    Xil_DCacheFlushRange((UINTPTR)dst,t->bytes);
    memset(&e,0,sizeof(e));e.run=perf_run;e.net=2;e.type=6;e.bytes=t->bytes;
    e.cpu_us=(uint32_t)(db_time_us()-begin);db_face_profile_push(&e);return 1;
}
int db_face_mobilefacenet_poll(int8_t embedding[DB_FACE_IDENTITY_DIM])
{
    int s=run_poll();unsigned i;float norm=0.0f,temp[DB_FACE_IDENTITY_DIM];if(s<=0)return s;
    uint32_t begin=db_time_us();DbFacePerfEvent e;
    const DbFaceTensorDesc *t=&rt.tensor[db_mobile_final_tensor];int8_t *q=tp(db_mobile_final_tensor);
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i){float x=deq(q[i],t->scale);temp[i]=db_mobile_bn_gamma[i]*(x-db_mobile_bn_mean[i])/sqrtf(db_mobile_bn_var[i]+db_mobile_bn_epsilon)+db_mobile_bn_beta[i];norm+=temp[i]*temp[i];}
    if(!(norm>0.0f))return -1;
    norm=1.0f/sqrtf(norm);
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i)embedding[i]=(int8_t)sat(temp[i]*norm*127.0f);
    memset(&e,0,sizeof(e));e.run=perf_run;e.net=2;e.type=8;e.bytes=DB_FACE_IDENTITY_DIM;
    e.cpu_us=(uint32_t)(db_time_us()-begin);db_face_profile_push(&e);return 1;
}

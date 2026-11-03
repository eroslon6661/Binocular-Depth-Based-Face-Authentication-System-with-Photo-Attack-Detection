#include "db_face_pipeline.h"

#include "db_face_model_generated.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "db_log.h"
#include <string.h>
#if XPAR_PS7_DDR_0_S_AXI_HIGHADDR < 0x1D600000U
#error Snapshot DDR region outside installed memory
#endif
/* Diagnostic-only reservation: Yunet 0x1c000000..1c7fffff,
 * Mobile 0x1c800000..1cffffff, raw 0x1d000000..1d3fffff,
 * pipeline 0x1d400000, metadata 0x1d500000.
 * Release fixed buffers/model pack end below these reservations. */
static void db_verify_detection(DbFacePipeline *p){
    volatile uint32_t *m=(volatile uint32_t *)0x1d500000U;
    m[0]=0;m[1]=p->frame;m[2]=db_yunet_arena_bytes;m[3]=db_mobile_arena_bytes;
    m[4]=p->source_width;m[5]=p->source_height;m[6]=p->source_stride;m[7]=sizeof(*p);
    if(db_yunet_arena_bytes>0x800000U || db_mobile_arena_bytes>0x800000U ||
       p->source_stride*p->source_height>0x400000U || sizeof(*p)>0x100000U)return;
    memcpy((void *)0x1c000000U,(const void *)0x14000000U,db_yunet_arena_bytes);
    memcpy((void *)0x1d000000U,p->source_bgr,p->source_stride*p->source_height);
    Xil_DCacheFlushRange(0x1c000000U,db_yunet_arena_bytes);
    Xil_DCacheFlushRange(0x1d000000U,p->source_stride*p->source_height);
    m[0]=0x594e4554U;Xil_DCacheFlushRange(0x1d500000U,64U);
}
static void db_verify_complete(DbFacePipeline *p){
    volatile uint32_t *m=(volatile uint32_t *)0x1d500000U;
    if(m[0]!=0x594e4554U || m[1]!=p->frame)return;
    memcpy((void *)0x1c800000U,(const void *)0x14000000U,db_mobile_arena_bytes);
    memcpy((void *)0x1d400000U,p,sizeof(*p));
    Xil_DCacheFlushRange(0x1c800000U,db_mobile_arena_bytes);
    Xil_DCacheFlushRange(0x1d400000U,sizeof(*p));
    m[0]=0x56455231U;Xil_DCacheFlushRange(0x1d500000U,64U);
    db_log("VERIFY SNAPSHOT frame=%lu ready=1\r\n",(unsigned long)p->frame);
}

#include "db_face_pipeline.h"
#include <math.h>
#include <string.h>

/* ArcFace 112x112 canonical five-point geometry used by enrollment. */
static const float db_arcface_template[DB_FACE_LANDMARKS][2]={
    {38.2946f,51.6963f},{73.5318f,51.5014f},{56.0252f,71.7366f},
    {41.5493f,92.3655f},{70.7299f,92.2041f}
};

/* Least-squares similarity transform: destination = s*R*source+t.  This is
 * deterministic and uses all five YuNet landmarks. */
static int similarity(const float source[DB_FACE_LANDMARKS][2],float m[6])
{
    float sx=0.0f,sy=0.0f,dx=0.0f,dy=0.0f,a=0.0f,b=0.0f,den=0.0f;
    unsigned i;
    for(i=0;i<DB_FACE_LANDMARKS;++i) {
        sx+=source[i][0];sy+=source[i][1];
        dx+=db_arcface_template[i][0];dy+=db_arcface_template[i][1];
    }
    sx/=DB_FACE_LANDMARKS;sy/=DB_FACE_LANDMARKS;
    dx/=DB_FACE_LANDMARKS;dy/=DB_FACE_LANDMARKS;
    for(i=0;i<DB_FACE_LANDMARKS;++i) {
        float x=source[i][0]-sx,y=source[i][1]-sy;
        float u=db_arcface_template[i][0]-dx,v=db_arcface_template[i][1]-dy;
        a+=x*u+y*v;b+=x*v-y*u;den+=x*x+y*y;
    }
    if(!(den>1.0f) || !isfinite(den))return 0;
    a/=den;b/=den;
    if(!isfinite(a) || !isfinite(b) || a*a+b*b<0.000001f)return 0;
    m[0]=a;m[1]=-b;m[2]=dx-a*sx+b*sy;
    m[3]=b;m[4]= a;m[5]=dy-b*sx-a*sy;
    return 1;
}

static uint8_t sample(const uint8_t *image,unsigned width,unsigned height,
    unsigned stride,float x,float y,unsigned channel)
{
    int x0=(int)floorf(x),y0=(int)floorf(y),x1=x0+1,y1=y0+1;
    float fx=x-(float)x0,fy=y-(float)y0;
    float p00,p01,p10,p11,value;
    if(x0<0 || y0<0 || x1>=(int)width || y1>=(int)height)return 0;
    p00=image[(unsigned)y0*stride+(unsigned)x0*3U+channel];
    p01=image[(unsigned)y0*stride+(unsigned)x1*3U+channel];
    p10=image[(unsigned)y1*stride+(unsigned)x0*3U+channel];
    p11=image[(unsigned)y1*stride+(unsigned)x1*3U+channel];
    value=(p00+(p01-p00)*fx)+(p10+(p11-p10)*fx-p00-(p01-p00)*fx)*fy;
    if(value<0.0f)value=0.0f;
    if(value>255.0f)value=255.0f;
    return (uint8_t)(value+0.5f);
}

static int align112(DbFacePipeline *p)
{
    float m[6],det,ia,ib,itx;
    unsigned x,y;
    if(!similarity(p->detection.landmark,m))return 0;
    det=m[0]*m[4]-m[1]*m[3];
    if(fabsf(det)<0.000001f)return 0;
    ia=m[4]/det;ib=-m[1]/det;itx=-(ia*m[2]+ib*m[5]);
    /* inverse second row is [-m3/det,m0/det] */
    for(y=0;y<DB_FACE_ALIGN_SIZE;++y)for(x=0;x<DB_FACE_ALIGN_SIZE;++x) {
        float source_x=ia*(float)x+ib*(float)y+itx;
        float source_y=(-m[3]/det)*(float)x+(m[0]/det)*(float)y+
            (m[3]*m[2]-m[0]*m[5])/det;
        size_t o=((size_t)y*DB_FACE_ALIGN_SIZE+x)*3U;
        /* Camera storage is BGR888; MobileFaceNet contract is RGB. */
        p->aligned_rgb[o+0]=sample(p->source_bgr,p->source_width,p->source_height,
            p->source_stride,source_x,source_y,2U);
        p->aligned_rgb[o+1]=sample(p->source_bgr,p->source_width,p->source_height,
            p->source_stride,source_x,source_y,1U);
        p->aligned_rgb[o+2]=sample(p->source_bgr,p->source_width,p->source_height,
            p->source_stride,source_x,source_y,0U);
    }
    return 1;
}

#if defined(__GNUC__)
#define DB_WEAK __attribute__((weak))
#else
#define DB_WEAK
#endif
DB_WEAK int db_face_nn_backend_init(void){return 0;}
DB_WEAK int db_face_yunet_begin(const uint8_t *p,unsigned w,unsigned h,unsigned s)
{(void)p;(void)w;(void)h;(void)s;return 0;}
DB_WEAK int db_face_yunet_poll(DbFaceDetection *d){(void)d;return -1;}
DB_WEAK int db_face_mobilefacenet_begin(
    const uint8_t p[DB_FACE_ALIGN_SIZE*DB_FACE_ALIGN_SIZE*3U]){(void)p;return 0;}
DB_WEAK int db_face_mobilefacenet_poll(int8_t p[DB_FACE_IDENTITY_DIM]){(void)p;return -1;}

int db_face_pipeline_init(DbFacePipeline *p)
{
    if(!p)return 0;
    memset(p,0,sizeof(*p));
    p->state=db_face_nn_backend_init()?DB_FACE_PIPELINE_IDLE:DB_FACE_PIPELINE_DISABLED;
    return p->state==DB_FACE_PIPELINE_IDLE;
}
int db_face_pipeline_available(const DbFacePipeline *p)
{return p && p->state!=DB_FACE_PIPELINE_DISABLED;}
int db_face_pipeline_begin(DbFacePipeline *p,uint32_t frame,const uint8_t *image,
    unsigned width,unsigned height,unsigned stride,uint32_t now_us)
{
    if(!p || p->state!=DB_FACE_PIPELINE_IDLE || !frame || !image ||
       width<2U || height<2U || stride<width*3U)return 0;
    p->frame=frame;p->started_us=now_us;p->stage_started_us=now_us;
    p->detected_us=0U;p->completed_us=0U;
    p->detection_pending=0U;
    p->source_bgr=image;p->source_width=width;
    p->source_height=height;p->source_stride=stride;
    memset(&p->result,0,sizeof(p->result));
    if(!db_face_yunet_begin(image,width,height,stride))return 0;
    p->state=DB_FACE_PIPELINE_DETECTING;return 1;
}
int db_face_pipeline_poll(DbFacePipeline *p,uint32_t now_us)
{
    int status;
    if(!p)return -1;
    if((p->state==DB_FACE_PIPELINE_DETECTING || p->state==DB_FACE_PIPELINE_EMBEDDING) &&
       (uint32_t)(now_us-p->stage_started_us)>DB_FACE_PIPELINE_TIMEOUT_US) {
        p->completed_us=now_us;p->state=DB_FACE_PIPELINE_IDLE;return -1;
    }
    if(p->state==DB_FACE_PIPELINE_DETECTING) {
        status=db_face_yunet_poll(&p->detection);
        if(status<0 || (status>0 && (p->detection.score<0.6f || !align112(p) ||
           !(db_verify_detection(p),db_face_mobilefacenet_begin(p->aligned_rgb))))) {
            p->completed_us=now_us;p->state=DB_FACE_PIPELINE_IDLE;return -1;
        }
        if(status>0){p->detected_us=now_us;p->stage_started_us=now_us;p->detection_pending=1U;
            p->state=DB_FACE_PIPELINE_EMBEDDING;}
        return 0;
    }
    if(p->state==DB_FACE_PIPELINE_EMBEDDING) {
        status=db_face_mobilefacenet_poll(p->embedding);
        if(status<0){p->completed_us=now_us;p->state=DB_FACE_PIPELINE_IDLE;return -1;}
        if(status>0) {
            p->result.frame=p->frame;
            p->result.matched=(unsigned)db_face_identify_i8(p->embedding,&p->result.person_id,&p->result.score_q15);
            p->result.valid=1;p->completed_us=now_us;p->state=DB_FACE_PIPELINE_DONE;db_verify_complete(p);return 1;
        }
        return 0;
    }
    return p->state==DB_FACE_PIPELINE_DONE?1:(p->state==DB_FACE_PIPELINE_FAILED?-1:0);
}
int db_face_pipeline_take_result(DbFacePipeline *p,DbFaceResult *r)
{
    if(!p || !r || p->state!=DB_FACE_PIPELINE_DONE || !p->result.valid)return 0;
    *r=p->result;p->result.valid=0;p->state=DB_FACE_PIPELINE_IDLE;return 1;
}
int db_face_pipeline_take_detection(DbFacePipeline *p,DbFaceDetection *d)
{
    if(!p || !d || !p->detection_pending)return 0;
    *d=p->detection;p->detection_pending=0U;return 1;
}

"""Create a diagnostic PS source copy; never edit release source files.
Extra DDR snapshots change timing only. Use solely with this Zynq DDR layout.
"""
from pathlib import Path
import argparse,shutil,json,hashlib
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
shutil.copytree(ROOT/'src/navigator/software',out)
f=out/'db_face_pipeline.c';s=f.read_text()
marker='!db_face_mobilefacenet_begin(p->aligned_rgb)'
assert s.count(marker)==1
s=s.replace(marker,'!(db_verify_detection(p),db_face_mobilefacenet_begin(p->aligned_rgb))')
marker='p->result.valid=1;p->completed_us=now_us;p->state=DB_FACE_PIPELINE_DONE;return 1;'
assert s.count(marker)==1
s=s.replace(marker,'p->result.valid=1;p->completed_us=now_us;p->state=DB_FACE_PIPELINE_DONE;db_verify_complete(p);return 1;')
helpers='''
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
    db_log("VERIFY SNAPSHOT frame=%lu ready=1\\r\\n",(unsigned long)p->frame);
}
'''
s='#include "db_face_pipeline.h"\n'+helpers+'\n'+s;f.write_text(s,encoding='utf-8')
(out.parent/'snapshot_source.json').write_text(json.dumps({'diagnostic_only':True,'modified_file':'db_face_pipeline.c',
 'baseline_sha256':hashlib.sha256((ROOT/'src/navigator/software/db_face_pipeline.c').read_bytes()).hexdigest(),
 'diagnostic_sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'timing_valid':False},indent=2))
print(out)

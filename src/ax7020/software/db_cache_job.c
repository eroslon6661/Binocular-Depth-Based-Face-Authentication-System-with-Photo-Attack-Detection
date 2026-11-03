#include "db_cache_job.h"
#include "db_perf.h"
#include "xil_cache.h"
#include "xil_cache_l.h"
#include "db_image_memory.h"
void db_cache_begin(DbCacheJob *job,uint8_t *left,uint8_t *right,unsigned invalidate)
{
    job->image[0]=left;job->image[1]=right;
    job->camera=job->offset=0;job->invalidate=invalidate;
}
int db_cache_poll(DbCacheJob *job)
{
    DbPerfStamp diagnostic=db_perf_begin(DB_PERF_CACHE);
    unsigned budget=DB_CACHE_STEP_BYTES;
    while(job->camera<2 && budget) {
        unsigned bytes=DB_IMAGE_BYTES-job->offset;
        if(bytes>DB_CACHE_IRQ_SLICE_BYTES)bytes=DB_CACHE_IRQ_SLICE_BYTES;
        if(bytes>budget)bytes=budget;
        uintptr_t address=(uintptr_t)(job->image[job->camera]+job->offset);
        if(db_image_range_l1(address,bytes)) {
            /* The streaming regions never allocate in L2. Keep complete L1
             * maintenance and DSB, avoiding global L2 fill-disable/sync. */
            if(job->invalidate)Xil_L1DCacheInvalidateRange((uint32_t)address,bytes);
            else Xil_L1DCacheFlushRange((uint32_t)address,bytes);
        } else if(job->invalidate)
            Xil_DCacheInvalidateRange((INTPTR)(job->image[job->camera]+job->offset),bytes);
        else Xil_DCacheFlushRange((INTPTR)(job->image[job->camera]+job->offset),bytes);
        job->offset+=bytes;budget-=bytes;
        if(job->offset==DB_IMAGE_BYTES){job->offset=0;++job->camera;}
    }
    db_perf_end(DB_PERF_CACHE,diagnostic);
    return job->camera==2;
}

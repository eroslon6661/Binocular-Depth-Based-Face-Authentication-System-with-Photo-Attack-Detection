#ifndef DB_CAPTURE_JOB_H
#define DB_CAPTURE_JOB_H
#include "xaxivdma.h"
#include "xgpio.h"
#include "db_cache_job.h"
typedef struct {
    XAxiVdma camera[2];XGpio tag[2],clock_reader;DbCacheJob cache;
    const uint8_t *source[2];uint8_t *destination[2];
    uint32_t sequence[2],stamp[2],previous[2];
    unsigned store[2],active,phase,dma,verified,row;
    uint32_t resync_sequence[2],recoveries;
    unsigned resyncing;
} DbCaptureJob;
int db_capture_init(DbCaptureJob *capture);
uint32_t db_capture_time_us(DbCaptureJob *capture);
/* 1: started, 0: wait/new-frame resync, -2: hardware fault, do not recycle. */
int db_capture_begin(DbCaptureJob *capture,uint8_t *left,uint8_t *right);
/* -2 is fatal: retain all outstanding DMA-owned memory until board reset. */
int db_capture_poll(DbCaptureJob *capture);
#endif

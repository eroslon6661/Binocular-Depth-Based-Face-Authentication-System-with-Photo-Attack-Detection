#ifndef DB_CACHE_JOB_H
#define DB_CACHE_JOB_H
#include <stdint.h>
#include "db_wire.h"
/* Return to network/audio service between bounded cache operations.
 * Default to the measured fusedrx range size. Repeated 2 KiB SDK calls
 * add global L2 cache synchronization work even with AMP disabled.
 * Images remain cache-line aligned and caller-owned until completion. */
#define DB_CACHE_STEP_BYTES 32768U
#ifndef DB_CACHE_IRQ_SLICE_BYTES
#define DB_CACHE_IRQ_SLICE_BYTES 32768U
#endif
#if DB_CACHE_IRQ_SLICE_BYTES % 32U || DB_CACHE_STEP_BYTES % DB_CACHE_IRQ_SLICE_BYTES
#error Cache slices must preserve cache-line alignment and the poll budget.
#endif
typedef struct {
    uint8_t *image[2];
    unsigned camera,offset,invalidate;
} DbCacheJob;
void db_cache_begin(DbCacheJob *job,uint8_t *left,uint8_t *right,unsigned invalidate);
int db_cache_poll(DbCacheJob *job);
#endif

#ifndef DB_LIVE_SEQUENCE_H
#define DB_LIVE_SEQUENCE_H
#include "db_liveness.h"
#define DB_LIVE_USABLE_SAMPLES 3U
#define DB_LIVE_MAX_ATTEMPTS 5U
typedef struct {
    unsigned attempts,usable,passes,dense,lr,votes;
    int32_t rms_q8,nose_q8,ne_q8,nc_q8;
    uint32_t sum_mm,min_mm,max_mm,last_frame;
} DbLiveSequence;
void db_live_sequence_reset(DbLiveSequence *);
int db_live_sample_usable(const DbLiveness *);
/* Returns true only after three usable samples or the bounded attempt limit.
 * An unusable surface is neither positive nor negative evidence. */
int db_live_sequence_add(DbLiveSequence *,const DbLiveness *);
void db_live_sequence_result(const DbLiveSequence *,DbControl *);
#endif

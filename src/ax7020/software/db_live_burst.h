#ifndef DB_LIVE_BURST_H
#define DB_LIVE_BURST_H
#include "db_control.h"
#include "db_wire.h"
#define DB_LIVE_BURST_SLOTS 5U
#define DB_LIVE_BURST_CAPTURE_US 250000U
#define DB_LIVE_BURST_LOCAL_US 500000U
typedef struct {
    uint8_t *left,*right,*disparity;
    uint32_t frame,stamp[2];
    unsigned image_ready,disparity_ready;
} DbLiveBurstSlot;
typedef struct {
    DbLiveBurstSlot slot[DB_LIVE_BURST_SLOTS];
    uint32_t session,id,photo_frame,photo_stamp,started_us;
    unsigned active,count,next;
} DbLiveBurst;
int db_live_burst_init(DbLiveBurst *,uint8_t *memory,unsigned step);
void db_live_burst_clear(DbLiveBurst *);
int db_live_burst_start(DbLiveBurst *,const DbControl *photo,uint32_t now);
int db_live_burst_open(const DbLiveBurst *,uint32_t now);
/* Copy only frames adjacent to the named photograph, before the neural
 * detector finishes. Return a one-based result tag, or zero if not retained. */
unsigned db_live_burst_capture(DbLiveBurst *,uint32_t frame,uint32_t left_us,
    uint32_t right_us,const uint8_t *left,const uint8_t *right,uint32_t now);
int db_live_burst_disparity(DbLiveBurst *,unsigned tag,uint32_t frame,const uint8_t *rgb);
int db_live_burst_matches(const DbLiveBurst *,const DbControl *);
const DbLiveBurstSlot *db_live_burst_take(DbLiveBurst *);
int db_live_burst_pending(const DbLiveBurst *,uint32_t now);
#endif

#ifndef DB_PHOTO_H
#define DB_PHOTO_H
#include "db_control.h"
#include "db_wire.h"
enum {DB_PHOTO_IDLE,DB_PHOTO_CAPTURING,DB_PHOTO_READY,DB_PHOTO_MEASURING,DB_PHOTO_DONE,DB_PHOTO_FAILED};
typedef struct {
    uint32_t frame,request_id,stamp[2],trigger_us,distance_mm,status;
    unsigned state,x,y,pressed;
} DbPhoto;
/* One event per press. A release must follow even a rejected/busy press. */
int db_photo_button(DbPhoto *photo,unsigned down,unsigned inside_button,unsigned contacts);
/* Raw BGR888 -> RGB565 preview; full originals remain unchanged. offset and
 * count are pixels, output is RGB565 in the requested byte order. */
size_t db_photo_rgb565(const uint8_t *raw,unsigned preview_w,unsigned preview_h,
    size_t offset,size_t count,uint8_t *out,unsigned big_endian);
int db_photo_begin(DbPhoto *photo,unsigned x,unsigned y,uint32_t trigger_us);
int db_photo_ready(DbPhoto *photo,uint32_t frame,uint32_t left_us,uint32_t right_us,uint32_t max_skew_us);
int db_photo_bind(DbPhoto *photo,const DbControl *request);
int db_photo_result(DbPhoto *photo,const DbControl *result);
void db_photo_fail(DbPhoto *photo);
/* Free older unowned slots while a named frame is awaited. CRC/DMA-owned
 * slots are retained. Set acquire=0 while a previous matcher is still busy. */
DbSlot *db_photo_acquire(DbReceiver *receiver,uint32_t frame,unsigned acquire);
#endif

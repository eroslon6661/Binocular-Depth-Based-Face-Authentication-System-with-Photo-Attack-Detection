#ifndef DB_SCREEN_H
#define DB_SCREEN_H
#include "db_photo.h"
#include <stddef.h>
/* Local RGB screen adapter contract.
 * Each callback must return promptly; never wait for a whole image transfer.
 * poll returns DB_SCREEN_EVENT_CAPTURE or DB_SCREEN_EVENT_MODE,
 * 0 for no event, -1 on failure (event constants are in db_mode.h).
 * notify receives immutable raw RGB photos plus their matching distance state. */
typedef struct {
    int (*poll)(void *context);
    void (*notify)(void *context,const DbPhoto *photo);
    void *context;
} DbScreenAdapter;
int db_screen_init(void);
int db_screen_attach(const DbScreenAdapter *adapter);
void db_screen_poll(uint32_t now);
int db_screen_take_capture(void);
int db_screen_take_hdmi_switch(void);
int db_screen_preview_start(uint32_t now,uint32_t clock);
int db_screen_preview_busy(void);
int db_screen_preview_acquire(const uint8_t *images[2],uint32_t stamps[2]);
void db_screen_preview_release(void);
void db_screen_preview_cancel(void);
int db_screen_take_mode_switch(void);
int db_screen_set_mode(unsigned mode);
int db_screen_begin(unsigned x,unsigned y,uint32_t now,uint32_t capture_clock);
int db_screen_raw_ready(uint8_t *images[2],uint32_t stamps[2]);
int db_screen_set_frame(uint32_t frame);
int db_screen_bind(const DbControl *request);
void db_screen_result(const DbControl *result);
/* Accepted physical-key results also update the LCD. Keep the last measurement
 * separate from the photographed frame so an old photo is not relabelled. */
void db_screen_measurement(const DbControl *result,unsigned from_photo);
const DbControl *db_screen_last_measurement(unsigned *from_photo);
void db_screen_fail(void);
int db_screen_busy(void);
const DbPhoto *db_screen_photo(void);
/* Native, unrectified, full-size BGR888 (little-endian RGB bus bytes).
 * Valid only until the next accepted capture. Read in bounded chunks.
 * No HDMI/disparity buffers are exposed through this API. */
const uint8_t *db_screen_image(unsigned camera,size_t *bytes);
/* Hold while copying both original photos into display thumbnails. */
int db_screen_image_lock(uint32_t frame);
void db_screen_image_release(void);
size_t db_screen_preview(uint32_t frame,unsigned camera,unsigned w,unsigned h,
    size_t pixel_offset,size_t pixel_count,uint8_t *out,unsigned big_endian);
#endif

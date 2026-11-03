#ifndef DB_PREVIEW_PROTOCOL_H
#define DB_PREVIEW_PROTOCOL_H
#include <stdint.h>
#include <stddef.h>
/* Transport resampling compensates the existing 1024x640 -> 1280x720
 * HDMI scaler: each 512x320 tile becomes 640x360, with 16:9 geometry. */
#define DB_PREVIEW_W 512U
#define DB_PREVIEW_H 320U
#define DB_PREVIEW_ROWS (2U*DB_PREVIEW_H)
#define DB_PREVIEW_HEADER 32U
#define DB_PREVIEW_PACKET (DB_PREVIEW_HEADER+DB_PREVIEW_W*2U)
#define DB_PREVIEW_PORT 5003U
#define DB_HDMI_DEPTH 0U
#define DB_HDMI_COLOR 1U
typedef struct {uint32_t session,frame,stamp[2];unsigned camera,row;} DbPreviewRow;
int db_preview_pixels_init(void);
int db_preview_shading_init(void);
void db_preview_shading_set(unsigned enabled);
void db_preview_shading_pixels(uint8_t *out,const uint8_t *src,unsigned camera,unsigned row);
void db_preview_pixels(uint8_t *out,const uint8_t *src);
int db_preview_encode(uint8_t *,const DbPreviewRow *,const uint8_t *bgr);
int db_preview_decode(DbPreviewRow *,const uint8_t *,size_t);
void db_preview_expand(uint8_t *bgr,const uint8_t *rgb565);
typedef struct {uint32_t frame,stamp[2],started;unsigned count;uint8_t seen[80];} DbPreviewAssembly;
/* 1: new row, 2: final row, 0: duplicate/invalid/old. No partial publication. */
int db_preview_accept(DbPreviewAssembly *,const DbPreviewRow *,uint32_t now);
#endif

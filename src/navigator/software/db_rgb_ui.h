#ifndef DB_RGB_UI_H
#define DB_RGB_UI_H
#include "db_photo.h"
#include "db_mode.h"
#include "db_face_pipeline.h"
#define DB_LCD_W 1024U
#define DB_LCD_H 600U
#define DB_THUMB_W 480U
#define DB_THUMB_H 270U
typedef struct {
 DbPhoto photo,button;
 unsigned mode,controls_busy,hdmi_mode,hdmi_pending;
 DbControl measurement;
 unsigned have_measurement,measurement_is_photo,touch_ready;
 uint32_t thumb_frame;
 unsigned have_thumbs;
 uint32_t face_frame;
 unsigned have_box,identity_state,person_id,reference_person,have_live,live_status;
 unsigned box_x0,box_y0,box_x1,box_y1;
 int32_t identity_score_q15;
 uint8_t thumb[2][DB_THUMB_W*DB_THUMB_H*3U];
} DbRgbUi;
/* Coordinates are scaled from the controller's reported native resolution.
 * One capture event only for a single contact starting inside the button. */
int db_rgb_ui_touch(DbRgbUi *,unsigned down,unsigned contacts,unsigned x,unsigned y,unsigned width,unsigned height);
int db_rgb_ui_set_mode(DbRgbUi *,unsigned mode);
void db_rgb_ui_copy(DbRgbUi *,const uint8_t *left,const uint8_t *right,unsigned offset,unsigned count);
void db_rgb_ui_row(const DbRgbUi *,unsigned row,uint8_t *bgr);
enum {DB_UI_ID_PENDING=0,DB_UI_ID_MATCHED,DB_UI_ID_UNKNOWN,DB_UI_ID_ERROR};
void db_rgb_ui_face_reset(DbRgbUi *);
int db_rgb_ui_detection(DbRgbUi *,uint32_t frame,const DbFaceDetection *);
int db_rgb_ui_identity(DbRgbUi *,uint32_t frame,unsigned person,int32_t score,unsigned valid);
int db_rgb_ui_liveness(DbRgbUi *,uint32_t frame,unsigned status);
#endif

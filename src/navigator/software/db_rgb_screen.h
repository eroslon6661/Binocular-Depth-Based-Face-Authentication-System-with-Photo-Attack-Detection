#ifndef DB_RGB_SCREEN_H
#define DB_RGB_SCREEN_H
#include "db_face_pipeline.h"
int db_rgb_screen_attach(void);
void db_rgb_screen_hdmi(unsigned mode,unsigned pending);
void db_rgb_screen_controls_busy(unsigned busy);
int db_rgb_screen_set_mode(unsigned mode);
void db_rgb_screen_detection(uint32_t frame,const DbFaceDetection *);
void db_rgb_screen_identity(uint32_t frame,unsigned person,int32_t score,unsigned valid);
void db_rgb_screen_liveness(uint32_t frame,unsigned status);
#endif

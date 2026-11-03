#ifndef DB_FACE_LIVE_POINTS_H
#define DB_FACE_LIVE_POINTS_H
#include "db_face_pipeline.h"
#include <stdint.h>
/* Convert YuNet landmarks from the raw left camera into the rectified-left
 * geometry consumed by the AX7020 liveness matcher. */
int db_face_live_points(const DbFaceDetection *d,uint16_t point_xy[10],
                        uint16_t *center_x,uint16_t *center_y);
#endif

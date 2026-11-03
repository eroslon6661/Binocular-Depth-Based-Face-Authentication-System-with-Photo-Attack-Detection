#ifndef DB_CAMERA_H
#define DB_CAMERA_H
/* Preserve the sensor sequence that has produced live frames on the board.
 * Capture currently measures ~28.6 fps; 30 fps is not yet validated. */
#ifndef DB_CAMERA_HTS
#define DB_CAMERA_HTS 2570U
#endif
#ifndef DB_CAMERA_VTS
#define DB_CAMERA_VTS 980U
#endif
int db_camera_init_pair(void);
#endif

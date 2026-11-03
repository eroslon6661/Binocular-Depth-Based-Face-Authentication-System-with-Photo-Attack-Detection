#ifndef DB_LIVENESS_H
#define DB_LIVENESS_H
#include "db_control.h"
#include "db_face_geometry.h"
#include <stdint.h>
#define DB_LIVE_POINTS 9U
#define DB_LIVE_D_MIN 45U
#define DB_LIVE_D_MAX 160U
typedef struct {
    const uint8_t *left,*right,*left_mask,*right_mask,*disp_rgb;
    float px[DB_LIVE_POINTS],py[DB_LIVE_POINTS],disp[DB_LIVE_POINTS];
    float score[DB_LIVE_D_MAX+1U],best_score[DB_LIVE_POINTS];
    float uniqueness[DB_LIVE_POINTS],lr_error[DB_LIVE_POINTS];
    int8_t best_dy[DB_LIVE_D_MAX+1U];
    int64_t ref_sum,ref_sum2;
    unsigned point,d,dy,valid,active,phase,search_min,search_max;
    unsigned lr_consistent,dense_valid,dense_total,regional_votes,live;
    DbFaceGeometry geometry;
    unsigned surface_valid;
    uint32_t frame,distance_mm;
    float plane_rms_px,nose_relief_px,nose_eye_px,nose_cheek_px;
} DbLiveness;
/* disp_rgb is the FPGA SGBM RGB888 result before HDMI scaling/overlay. Its
 * gray byte carries the uniqueness-filtered disparity-index image.  Dense
 * face disparity seeds distance/shape; local ZNCC anchors cross-check it. */
int db_liveness_begin(DbLiveness *job,const uint8_t *left,const uint8_t *right,
    const uint8_t *left_mask,const uint8_t *right_mask,const uint8_t *disp_rgb,
    const DbControl *request);
/* Bounded patch matching; returns 1 when all result fields are ready. */
int db_liveness_poll(DbLiveness *job,unsigned candidate_budget);
#endif

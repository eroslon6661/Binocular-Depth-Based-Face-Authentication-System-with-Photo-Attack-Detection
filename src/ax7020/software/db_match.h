#ifndef DB_MATCH_H
#define DB_MATCH_H
#include "db_wire.h"
#define DB_ROI 32U
#define DB_SEARCH_MAX 512U
typedef struct {
    uint8_t reference[DB_ROI][DB_ROI];
    uint8_t search[DB_ROI][DB_ROI+DB_SEARCH_MAX];
    uint8_t valid[DB_ROI][DB_ROI+DB_SEARCH_MAX];
    uint32_t cost[DB_SEARCH_MAX+1U];
    unsigned cx, cy, max_d, next_d;
    uint32_t frame, distance_mm, disparity_x16;
    unsigned reliable, active;
} DbMatch;
/* Physical right camera is the reference, left is searched at x-d.
 * Invalid map pixels never become black matching candidates. */
int db_match_begin(DbMatch *m,const uint8_t *left,const uint8_t *right,
                   const uint8_t *left_mask,const uint8_t *right_mask,
                   unsigned cx,unsigned cy,uint32_t frame);
/* Q is OpenCV's left-reference Q. Right-reference d is converted to -d,
 * and x_left=x_right-d before reprojection. Returns 1 on job completion. */
int db_match_poll(DbMatch *m,unsigned disparities_per_call,const double q[16],
                  unsigned max_distance_mm);
#endif

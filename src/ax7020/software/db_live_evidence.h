#ifndef DB_LIVE_EVIDENCE_H
#define DB_LIVE_EVIDENCE_H
#include "db_control.h"
#include "db_face_geometry.h"
/* Identity belongs to the shutter frame. A later person/background must
 * never repair unknown geometry in that frame, or give it a photo label. */
static inline unsigned db_live_evidence_status(unsigned first_geometry,
    unsigned valid,unsigned live,unsigned flat,unsigned distance_span)
{
    if(first_geometry==DB_GEOM_FLAT)return DB_CTRL_SPOOF;
    if(first_geometry==DB_GEOM_FACE&&flat==0U&&valid>=2U&&live>=2U&&distance_span<=200U)return DB_CTRL_OK;
    return DB_CTRL_INVALID;
}
#endif

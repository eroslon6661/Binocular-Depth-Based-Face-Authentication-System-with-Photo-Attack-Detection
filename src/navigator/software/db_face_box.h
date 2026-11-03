#ifndef DB_FACE_BOX_H
#define DB_FACE_BOX_H
#include <math.h>
/* YuNet bbox is centre offset + log(width,height), not L/T/R/B distances.
 * Reference: OpenCV modules/objdetect/src/face_detect.cpp postProcess(). */
static inline int db_face_decode_box(unsigned x,unsigned y,unsigned stride,const float b[4],float out[4])
{
    float w,h,cx,cy;unsigned i;
    if(!b || !out || !stride)return 0;
    for(i=0;i<4;++i)if(!isfinite(b[i]))return 0;
    w=expf(b[2])*stride;h=expf(b[3])*stride;
    cx=((float)x+b[0])*stride;cy=((float)y+b[1])*stride;
    if(!isfinite(w) || !isfinite(h) || !isfinite(cx) || !isfinite(cy) || w<=0 || h<=0)return 0;
    out[0]=cx-w*.5f;out[1]=cy-h*.5f;out[2]=w;out[3]=h;
    return isfinite(out[0]) && isfinite(out[1]);
}
#endif

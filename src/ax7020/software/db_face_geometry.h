#ifndef DB_FACE_GEOMETRY_H
#define DB_FACE_GEOMETRY_H
#include <stdint.h>
enum { DB_GEOM_UNKNOWN=0,DB_GEOM_FLAT=1,DB_GEOM_FACE=2 };
typedef struct {
    const uint8_t *left,*right,*lm,*rm;
    float x[5],y[5],disp[2][5],quality[2][5],gap[2][5],relief[2],ref_rms[2],relief_mm[2];
    int vertical[2][5];
    float score[116][25],best,reverse_best,reverse_gap;
    int lo,hi,vlo,vhi,d,v,bd,bv,reverse_d,reverse_v;
    unsigned point,scale,phase,active,result,valid,mm,complete,reason;
    unsigned retry,first_reason,first_valid,first_complete,work;
    int initial_lo,initial_hi;
} DbFaceGeometry;
int db_face_geometry_begin(DbFaceGeometry *g,const uint8_t *left,const uint8_t *right,
    const uint8_t *lm,const uint8_t *rm,const float *x,const float *y,float seed);
int db_face_geometry_poll(DbFaceGeometry *g,unsigned budget);
#endif

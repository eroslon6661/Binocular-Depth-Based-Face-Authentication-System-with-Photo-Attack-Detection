#include "db_face_live_points.h"
#include "db_wire.h"
#include <math.h>

static int rectify_left(float u,float v,float *ou,float *ov)
{
    const double fx=2188.73978669,fy=1568.38961023,cx=447.73530392,cy=317.347134227;
    const double k1=-0.453717768812,k2=0.0489903157287,p1=-0.00431300372032,p2=0.0113367235439;
    const double r[9]={0.99986464,-0.00902144,0.01375932,
                       0.00903974,0.99995834,-0.00126865,
                      -0.01374730,0.00139286,0.99990453};
    const double nf=2408.0871660136345,ncx=471.2801170349121,ncy=337.3220901489258;
    double xd=((double)u-cx)/fx,yd=((double)v-cy)/fy,x=xd,y=yd,X,Y,Z;
    unsigned i;
    if(!isfinite(u)||!isfinite(v))return 0;
    for(i=0;i<7U;++i){
        double r2=x*x+y*y,rad=1.0+k1*r2+k2*r2*r2;
        double dx=2.0*p1*x*y+p2*(r2+2.0*x*x);
        double dy=p1*(r2+2.0*y*y)+2.0*p2*x*y;
        if(fabs(rad)<1e-9)return 0;
        x=(xd-dx)/rad;y=(yd-dy)/rad;
    }
    X=r[0]*x+r[1]*y+r[2];Y=r[3]*x+r[4]*y+r[5];Z=r[6]*x+r[7]*y+r[8];
    if(fabs(Z)<1e-9)return 0;
    *ou=(float)(nf*X/Z+ncx);*ov=(float)(nf*Y/Z+ncy);
    return *ou>=0.0f && *ov>=0.0f && *ou<(float)DB_WIDTH && *ov<(float)DB_HEIGHT;
}

int db_face_live_points(const DbFaceDetection *d,uint16_t out[10],uint16_t *cx,uint16_t *cy)
{
    float sx=0.0f,sy=0.0f,x,y;unsigned i;
    if(!d||!out||!cx||!cy)return 0;
    for(i=0;i<DB_FACE_LANDMARKS;++i){
        if(!rectify_left(d->landmark[i][0],d->landmark[i][1],&x,&y))return 0;
        out[i*2U]=(uint16_t)(x+0.5f);out[i*2U+1U]=(uint16_t)(y+0.5f);sx+=x;sy+=y;
    }
    *cx=(uint16_t)(sx/DB_FACE_LANDMARKS+0.5f);
    *cy=(uint16_t)(sy/DB_FACE_LANDMARKS+0.5f);
    return 1;
}

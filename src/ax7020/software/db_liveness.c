#include "db_liveness.h"
#include "db_wire.h"
#include <math.h>
#include <string.h>
#define FB_MM_PX 73981.90437621115
#define DENSE_STEP 5U

static int solve3(double a[3][4],double out[3])
{
    unsigned c,r,k,p;for(c=0;c<3U;++c){double best=fabs(a[c][c]);p=c;
        for(r=c+1U;r<3U;++r)if(fabs(a[r][c])>best){best=fabs(a[r][c]);p=r;}
        if(best<1e-9)return 0;
        if(p!=c)for(k=c;k<4U;++k){double t=a[c][k];a[c][k]=a[p][k];a[p][k]=t;}
        {double q=a[c][c];for(k=c;k<4U;++k)a[c][k]/=q;}
        for(r=0;r<3U;++r)if(r!=c){double q=a[r][c];for(k=c;k<4U;++k)a[r][k]-=q*a[c][k];}
    }for(c=0;c<3U;++c)out[c]=a[c][3];return 1;
}

static float gray_to_disp(uint8_t gray)
{
    unsigned i;if(!gray)return 0.0f;i=gray==255U?64U:(unsigned)(gray+2U)/4U;
    if(i<24U)return (float)(2U*i);
    if(i<48U)return (float)(48U+4U*(i-24U));
    return (float)(144U+13U*(i-48U));
}

static unsigned gray_to_index(uint8_t gray)
{return !gray?0U:(gray==255U?64U:(unsigned)(gray+2U)/4U);}

static float plane_at(const double c[3],float x,float y,float cx,float cy,float sx,float sy)
{return (float)(c[0]*(x-cx)/sx+c[1]*(y-cy)/sy+c[2]);}

static float zone_median(const DbLiveness *j,float lx,float y,float median,float rx,float ry)
{
    unsigned hist[65]={0},target,k;int x0=(int)(lx+median-rx),x1=(int)(lx+median+rx);
    int y0=(int)(y-ry),y1=(int)(y+ry),x,yy;unsigned count=0;
    if(x0<1)x0=1;
    if(y0<1)y0=1;
    if(x1>=(int)DB_WIDTH-1)x1=DB_WIDTH-2;
    if(y1>=(int)DB_HEIGHT-1)y1=DB_HEIGHT-2;
    for(yy=y0;yy<=y1;yy+=2)for(x=x0;x<=x1;x+=2){
        uint8_t g=j->disp_rgb[((unsigned)yy*DB_WIDTH+(unsigned)x)*3U];
        unsigned idx=g==255U?64U:(unsigned)(g+2U)/4U;float d=gray_to_disp(g);
        if(idx&&fabsf(d-median)<=18.0f){++hist[idx];++count;}
    }
    if(count<8U)return 0.0f;
    target=(count+1U)/2U;
    for(k=1;k<=64U;++k){if(hist[k]>=target)return gray_to_disp(k==64U?255U:(uint8_t)(k*4U));target-=hist[k];}
    return 0.0f;
}

static void plane_add(double a[3][4],float x,float y,float d)
{
    a[0][0]+=x*x;a[0][1]+=x*y;a[0][2]+=x;a[0][3]+=x*d;
    a[1][0]+=x*y;a[1][1]+=y*y;a[1][2]+=y;a[1][3]+=y*d;
    a[2][0]+=x;a[2][1]+=y;a[2][2]+=1.0;a[2][3]+=d;
}

static void finish_surface(DbLiveness *j)
{
    float median,ex,ey,mx,my,ed,fh,cx,cy,sx,sy;
    unsigned hist[65]={0},i,k,n=0,seed=0,target,kept=0;
    double a[3][4]={{0}},coef[3],sum2=0,a2[3][4]={{0}};
    float nose,eyes[2],cheeks[2],nr,er=0,cr=0;unsigned en=0,cn=0;
    j->valid=j->dense_valid=j->dense_total=j->regional_votes=j->live=0;
    j->distance_mm=0;j->plane_rms_px=j->nose_relief_px=j->nose_eye_px=j->nose_cheek_px=0.0f;
    if(!j->disp_rgb)return;
    ex=(j->px[0]+j->px[1])*0.5f;ey=(j->py[0]+j->py[1])*0.5f;
    mx=(j->px[3]+j->px[4])*0.5f;my=(j->py[3]+j->py[4])*0.5f;
    ed=hypotf(j->px[1]-j->px[0],j->py[1]-j->py[0]);fh=hypotf(mx-ex,my-ey);
    if(ed<20.0f||fh<20.0f)return;
    /* The FPGA disparity image is right-reference geometry.  Map each valid
     * right-image sample back to its left-image coordinate (x-d), then retain
     * samples that land inside the landmark-defined face ellipse.  This gives
     * a dense distance seed even when smooth skin leaves too few local ZNCC
     * anchors; anchors are applied later as an independent consistency check. */
    cx=ex;cy=ey+0.324f*fh;sx=1.02f*ed;sy=0.72f*fh;
    for(k=DENSE_STEP/2U;k<DB_HEIGHT;k+=DENSE_STEP)for(i=DENSE_STEP/2U;i<DB_WIDTH;i+=DENSE_STEP){
        uint8_t g=j->disp_rgb[(k*DB_WIDTH+i)*3U];unsigned idx=gray_to_index(g);
        float d=gray_to_disp(g),nx,ny=((float)k-cy)/sy;
        if(!idx||d<(float)DB_LIVE_D_MIN||d>(float)DB_LIVE_D_MAX)continue;
        nx=((float)i-d-cx)/sx;
        if(nx*nx+ny*ny>1.0f)continue;
        ++hist[idx];++seed;
    }
    if(seed<40U)return;
    target=(seed+1U)/2U;median=0.0f;
    for(i=1;i<=64U;++i){
        if(hist[i]>=target){median=gray_to_disp(i==64U?255U:(uint8_t)(i*4U));break;}
        target-=hist[i];
    }
    if(median<(float)DB_LIVE_D_MIN||median>(float)DB_LIVE_D_MAX)return;
    j->distance_mm=(uint32_t)(FB_MM_PX/(double)median+0.5);
    /* Only anchors agreeing with the dense seed count as the final local
     * cross-check.  One good independent anchor is sufficient; it no longer
     * prevents the dense estimator itself from running. */
    for(i=0;i<DB_LIVE_POINTS;++i)if(j->disp[i]>0.0f&&fabsf(j->disp[i]-median)<=18.0f)++n;
    j->valid=j->lr_consistent=n;
    for(k=DENSE_STEP/2U;k<DB_HEIGHT;k+=DENSE_STEP)for(i=DENSE_STEP/2U;i<DB_WIDTH;i+=DENSE_STEP){
        float nx=((float)i-(cx+median))/sx,ny=((float)k-cy)/sy,d;uint8_t g;
        if(nx*nx+ny*ny>1.0f)continue;
        ++j->dense_total;g=j->disp_rgb[(k*DB_WIDTH+i)*3U];d=gray_to_disp(g);
        if(d<=0.0f||fabsf(d-median)>18.0f)continue;
        nx=((float)i-d-cx)/sx;if(nx*nx+ny*ny>1.0f)continue;
        ++j->dense_valid;plane_add(a,nx,ny,d);
    }
    if(j->dense_valid<40U||!solve3(a,coef))return;
    for(k=DENSE_STEP/2U;k<DB_HEIGHT;k+=DENSE_STEP)for(i=DENSE_STEP/2U;i<DB_WIDTH;i+=DENSE_STEP){
        float nx,ny=((float)k-cy)/sy,d,e;uint8_t g;
        g=j->disp_rgb[(k*DB_WIDTH+i)*3U];d=gray_to_disp(g);
        if(d<=0.0f||fabsf(d-median)>18.0f)continue;
        nx=((float)i-d-cx)/sx;if(nx*nx+ny*ny>1.0f)continue;
        e=d-(float)(coef[0]*nx+coef[1]*ny+coef[2]);
        if(fabsf(e)>6.0f)continue;
        ++kept;plane_add(a2,nx,ny,d);
    }
    if(kept<40U||!solve3(a2,coef))return;
    sum2=0;kept=0;
    for(k=DENSE_STEP/2U;k<DB_HEIGHT;k+=DENSE_STEP)for(i=DENSE_STEP/2U;i<DB_WIDTH;i+=DENSE_STEP){
        float nx,ny=((float)k-cy)/sy,d,e;uint8_t g;
        g=j->disp_rgb[(k*DB_WIDTH+i)*3U];d=gray_to_disp(g);
        if(d<=0.0f||fabsf(d-median)>18.0f)continue;
        nx=((float)i-d-cx)/sx;if(nx*nx+ny*ny>1.0f)continue;
        e=d-(float)(coef[0]*nx+coef[1]*ny+coef[2]);
        if(fabsf(e)<=6.0f){sum2+=(double)e*e;++kept;}
    }
    if(kept<40U)return;
    j->dense_valid=kept;j->plane_rms_px=(float)sqrt(sum2/kept);
    nose=zone_median(j,j->px[2],j->py[2],median,0.13f*ed,0.16f*fh);
    for(i=0;i<2U;++i)eyes[i]=zone_median(j,j->px[i],j->py[i],median,0.14f*ed,0.12f*fh);
    cheeks[0]=zone_median(j,(j->px[0]+j->px[3])*0.5f,(j->py[0]+j->py[3])*0.5f,median,0.16f*ed,0.16f*fh);
    cheeks[1]=zone_median(j,(j->px[1]+j->px[4])*0.5f,(j->py[1]+j->py[4])*0.5f,median,0.16f*ed,0.16f*fh);
    nr=nose?nose-plane_at(coef,j->px[2],j->py[2],cx,cy,sx,sy):0.0f;
    for(i=0;i<2U;++i)if(eyes[i]){er+=eyes[i]-plane_at(coef,j->px[i],j->py[i],cx,cy,sx,sy);++en;}
    for(i=0;i<2U;++i)if(cheeks[i]){float x=(j->px[i]+j->px[i+3U])*0.5f+median;
        float y=(j->py[i]+j->py[i+3U])*0.5f;cr+=cheeks[i]-plane_at(coef,x-median,y,cx,cy,sx,sy);++cn;}
    if(en)er/=en;
    if(cn)cr/=cn;
    j->nose_relief_px=nr;j->nose_eye_px=nose&&en?nr-er:0.0f;j->nose_cheek_px=nose&&cn?nr-cr:0.0f;
    if(nose&&en&&j->nose_eye_px>=0.25f)++j->regional_votes;
    if(nose&&cn&&j->nose_cheek_px>=0.25f)++j->regional_votes;
    if(nose&&nr>=0.25f)++j->regional_votes;
    /* Dense quantized shape is diagnostic/seed only; it cannot authorize. */
}

int db_liveness_begin(DbLiveness *j,const uint8_t *left,const uint8_t *right,
    const uint8_t *lm,const uint8_t *rm,const uint8_t *disp_rgb,const DbControl *r)
{
    unsigned i;float seed;
    if(!j||!left||!right||!lm||!rm||!disp_rgb||!r||r->type!=DB_CTRL_LIVE_REQUEST||!r->frame)return 0;
    memset(j,0,sizeof(*j));j->left=left;j->right=right;j->left_mask=lm;j->right_mask=rm;j->disp_rgb=disp_rgb;j->frame=r->frame;
    for(i=0;i<5U;++i){j->px[i]=r->data[i*2U];j->py[i]=r->data[i*2U+1U];}
    finish_surface(j);seed=j->distance_mm?(float)(FB_MM_PX/j->distance_mm):0;
    j->live=0;j->active=1;
    db_face_geometry_begin(&j->geometry,left,right,lm,rm,j->px,j->py,seed);
    return 1;
}
int db_liveness_poll(DbLiveness *j,unsigned budget)
{
    unsigned i;
    if(!j||!j->active)return 0;
    if(j->geometry.active&&!db_face_geometry_poll(&j->geometry,budget))return 0;
    j->active=0;j->surface_valid=j->geometry.complete;
    j->live=j->geometry.result==DB_GEOM_FACE;
    j->valid=j->lr_consistent=j->geometry.valid/2U;
    if(j->geometry.mm)j->distance_mm=j->geometry.mm;
    for(i=0;i<5;++i)j->disp[i]=(j->geometry.disp[0][i]+j->geometry.disp[1][i])*.5f;
    j->nose_relief_px=(j->geometry.relief[0]+j->geometry.relief[1])*.5f;
    return 1;
}

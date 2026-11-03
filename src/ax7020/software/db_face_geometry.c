#include "db_face_geometry.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#define W 1280
#define H 720
#define FB 73981.90437621115
/* One optional wider-window check on the SAME immutable stereo pair. A face
 * must be large enough to keep the 91-pixel window below 40% of eye spacing.
 * The first conclusive result is retained; all decision thresholds stay fixed. */
static int radius(const DbFaceGeometry *g)
{return g->retry?(g->scale?45:30):(g->scale?30:20);}
static int patch(const uint8_t *m,int x,int y,int r)
{
    int a,b;if(x<r||y<r||x>=W-r||y>=H-r)return 0;
    for(b=-r;b<=r;++b)for(a=-r;a<=r;++a)if(!m[(y+b)*W+x+a])return 0;
    return 1;
}
static float corr(const uint8_t *a,const uint8_t *b,int x,int y,int xx,int yy,int r)
{
    int i,j,n=(2*r+1)*(2*r+1);int64_t sa=0,sb=0,aa=0,bb=0,ab=0;double va,vb;
    for(j=-r;j<=r;++j)for(i=-r;i<=r;++i){int u=a[(y+j)*W+x+i],v=b[(yy+j)*W+xx+i];sa+=u;sb+=v;aa+=u*u;bb+=v*v;ab+=u*v;}
    va=(double)(n*aa-sa*sa);vb=(double)(n*bb-sb*sb);
    if(va<4.0*n*n||vb<4.0*n*n)return -2;
    return (float)((n*ab-sa*sb)/sqrt(va*vb));
}
static void prepare(DbFaceGeometry *g)
{
    unsigned d,v;int i=(int)g->point,r=radius(g);
    /* The first eye locates the residual vertical offset. Later patches still
     * search seven rows, rather than assuming perfect rectification. */
    if(g->disp[0][0]>0){int vs=g->vertical[0][0];g->vlo=vs-3;g->vhi=vs+3;
        if(g->vlo< -12)g->vlo=-12;
        if(g->vhi>12)g->vhi=12;}
    else {g->vlo=-12;g->vhi=12;}
    for(d=0;d<116;++d)for(v=0;v<25;++v)g->score[d][v]=-2;
    g->phase=0;g->best=-2;g->d=g->lo;g->v=g->vlo;
    if(!patch(g->lm,(int)(g->x[i]+.5f),(int)(g->y[i]+.5f),r)){g->active=0;g->result=DB_GEOM_UNKNOWN;g->reason=3;}
}
int db_face_geometry_begin(DbFaceGeometry *g,const uint8_t *l,const uint8_t *r,
    const uint8_t *lm,const uint8_t *rm,const float *x,const float *y,float seed)
{
    unsigned i;float ex,ey,mx,my,ed,fh;
    memset(g,0,sizeof(*g));if(!l||!r||!lm||!rm||!x||!y)return 0;
    for(i=0;i<5;++i){if(!isfinite(x[i])||!isfinite(y[i])||x[i]<0||x[i]>=W||y[i]<0||y[i]>=H)return 0;g->x[i]=x[i];g->y[i]=y[i];}
    ex=(x[0]+x[1])*.5f;ey=(y[0]+y[1])*.5f;mx=(x[3]+x[4])*.5f;my=(y[3]+y[4])*.5f;
    ed=hypotf(x[1]-x[0],y[1]-y[0]);fh=hypotf(mx-ex,my-ey);
    if(ed<20||fh<20||my<=ey||y[2]<=ey||y[2]>=my)return 0;
    g->left=l;g->right=r;g->lm=lm;g->rm=rm;g->lo=45;g->hi=160;
    if(isfinite(seed)&&seed>=45&&seed<=160){g->lo=(int)seed-16;g->hi=(int)seed+16;if(g->lo<45)g->lo=45;if(g->hi>160)g->hi=160;}
    g->initial_lo=g->lo;g->initial_hi=g->hi;
    g->active=1;prepare(g);return (int)g->active;
}
static int solve(double a[3][4],double c[3])
{
    unsigned i,j,k,p;for(i=0;i<3;++i){p=i;for(j=i+1;j<3;++j)if(fabs(a[j][i])>fabs(a[p][i]))p=j;
        if(fabs(a[p][i])<1e-8)return 0;
        for(k=i;k<4;++k){double t=a[i][k];a[i][k]=a[p][k];a[p][k]=t;}
        {double q=a[i][i];for(k=i;k<4;++k)a[i][k]/=q;}
        for(j=0;j<3;++j)if(j!=i){double q=a[j][i];for(k=i;k<4;++k)a[j][k]-=q*a[i][k];}
    }for(i=0;i<3;++i)c[i]=a[i][3];return 1;
}
static void finish(DbFaceGeometry *g)
{
    unsigned use[5],refs=0,common=0;
    unsigned s,i,j,k;float med[5],minq=1,scale_error=0;int vmin=99,vmax=-99;
    for(i=0;i<5;++i){use[i]=g->disp[0][i]>0&&g->disp[1][i]>0;if(use[i]){++common;if(i!=2)++refs;}}
    if(!use[2]||refs<3U){g->reason=4;return;}
    for(s=0;s<2;++s){double a[3][4]={{0}},c[3],sum=0;float ex=(g->x[0]+g->x[1])*.5f,ey=(g->y[0]+g->y[1])*.5f;
        for(i=0;i<5;++i){double p[3]={(g->x[i]-ex)/200.0,(g->y[i]-ey)/200.0,1};
            if(!use[i])continue;
            if(g->quality[s][i]<minq)minq=g->quality[s][i];
            if(g->vertical[s][i]<vmin)vmin=g->vertical[s][i];
            if(g->vertical[s][i]>vmax)vmax=g->vertical[s][i];
            if(i==2)continue; /* Never fit away the nose protrusion itself. */
            for(j=0;j<3;++j){for(k=0;k<3;++k)a[j][k]+=p[j]*p[k];a[j][3]+=p[j]*g->disp[s][i];}
        }
        if(!solve(a,c)){g->reason=5;return;}
        for(i=0;i<5;++i){float e;if(!use[i])continue;e=g->disp[s][i]-(float)(c[0]*(g->x[i]-ex)/200.0+c[1]*(g->y[i]-ey)/200.0+c[2]);
            if(i==2){float base=g->disp[s][i]-e;
                if(base<=0||g->disp[s][i]<=0){g->reason=5;return;}
                g->relief[s]=e;g->relief_mm[s]=(float)(FB/base-FB/g->disp[s][i]);
            }else sum+=e*e;}
        g->ref_rms[s]=(float)sqrt(sum/refs);
    }
    k=0;for(i=0;i<5;++i)if(use[i]){float e=fabsf(g->disp[0][i]-g->disp[1][i]);if(e>scale_error)scale_error=e;med[k++]=(g->disp[0][i]+g->disp[1][i])*.5f;}
    for(i=1;i<common;++i){float d=med[i];j=i;while(j&&med[j-1]>d){med[j]=med[j-1];--j;}med[j]=d;}
    g->mm=(unsigned)(FB/med[common/2]+.5);g->complete=1;
    /* A broad correlation peak or inconsistent windows is unknown, never
     * positive photo evidence. These are provisional calibrated depth tolerances (4 mm flat, 6 mm relief);
     * preserve diagnostic values for independent board validation. */
    if(vmax-vmin>4||scale_error>4.0f||g->ref_rms[0]>1.5f||g->ref_rms[1]>1.5f){g->reason=6;return;}
    if(refs==4U&&minq>=.90f&&g->ref_rms[0]<=.75f&&g->ref_rms[1]<=.75f&&
       fabsf(g->relief_mm[0])<=4.0f&&fabsf(g->relief_mm[1])<=4.0f)g->result=DB_GEOM_FLAT;
    else if(g->relief_mm[0]>=6.0f&&g->relief_mm[1]>=6.0f&&g->relief_mm[0]<=80.0f&&g->relief_mm[1]<=80.0f)g->result=DB_GEOM_FACE;
    g->reason=g->result==DB_GEOM_UNKNOWN?7U:0U;
}
static int retry_same_pair(DbFaceGeometry *g)
{
    unsigned i;
    if(g->retry||g->result!=DB_GEOM_UNKNOWN||g->valid<4U||
       hypotf(g->x[1]-g->x[0],g->y[1]-g->y[0])<112.5f)return 0;
    /* Do not retry invalid-border or fully textureless captures. */
    for(i=0;i<5;++i)if(!patch(g->lm,(int)(g->x[i]+.5f),(int)(g->y[i]+.5f),45))return 0;
    g->first_reason=g->reason;g->first_valid=g->valid;g->first_complete=g->complete;
    g->retry=1;g->valid=g->complete=g->mm=g->reason=0;
    memset(g->disp,0,sizeof(g->disp));memset(g->quality,0,sizeof(g->quality));
    memset(g->gap,0,sizeof(g->gap));memset(g->vertical,0,sizeof(g->vertical));
    memset(g->relief,0,sizeof(g->relief));memset(g->relief_mm,0,sizeof(g->relief_mm));memset(g->ref_rms,0,sizeof(g->ref_rms));
    g->point=g->scale=0;g->lo=g->initial_lo;g->hi=g->initial_hi;
    prepare(g);return 1;
}
static void advance(DbFaceGeometry *g)
{
    if(++g->point==5U){g->point=0;if(++g->scale==2U){finish(g);if(!retry_same_pair(g))g->active=0;return;}}
    prepare(g);
}
int db_face_geometry_poll(DbFaceGeometry *g,unsigned budget)
{
    if(!g||!g->active)return 0;
    while(budget--&&g->active){int x=(int)(g->x[g->point]+.5f),y=(int)(g->y[g->point]+.5f),r=radius(g);float s=-2;
        /* Independent of CPU frequency; caller still yields after its budget. */
        if(++g->work>80000U){g->reason=8;g->result=DB_GEOM_UNKNOWN;g->active=0;return 1;}
        if(!g->phase){if(patch(g->rm,x+g->d,y+g->v,r))s=corr(g->left,g->right,x,y,x+g->d,y+g->v,r);
            g->score[g->d-45][g->v+12]=s;if(s>g->best){g->best=s;g->bd=g->d;g->bv=g->v;}}
        else if(patch(g->lm,x+g->bd-g->d,y+g->bv-g->v,r)){
            s=corr(g->right,g->left,x+g->bd,y+g->bv,x+g->bd-g->d,y+g->bv-g->v,r);
            if(s>g->reverse_best){g->reverse_best=s;g->reverse_d=g->d;g->reverse_v=g->v;}
        }
        if(++g->v<=g->vhi)continue;
        g->v=g->vlo;
        if(++g->d<=g->hi)continue;
        if(!g->phase){int d,v;float second=-2;
            for(d=g->lo;d<=g->hi;++d)for(v=g->vlo;v<=g->vhi;++v)if(d<g->bd-5||d>g->bd+5||v<g->bv-2||v>g->bv+2){s=g->score[d-45][v+12];if(s>second)second=s;}
            g->quality[g->scale][g->point]=g->best;g->gap[g->scale][g->point]=g->best-second;
            if(g->best<.80f||(g->point!=2U&&g->best-second<.002f)||g->bd<=g->lo||g->bd>=g->hi||g->bv<=g->vlo||g->bv>=g->vhi){g->reason=1;advance(g);if(!g->active)return 1;continue;}
            g->phase=1;g->reverse_best=-2;g->d=g->lo;g->v=g->vlo;continue;
        }else {
            float aa=g->score[g->bd-46][g->bv+12],bb=g->score[g->bd-45][g->bv+12],cc=g->score[g->bd-44][g->bv+12];
            float den=aa-2*bb+cc,sub=fabsf(den)>1e-5f?.5f*(aa-cc)/den:0;
            if(g->reverse_best<.80f||abs(g->reverse_d-g->bd)>2||abs(g->reverse_v-g->bv)>2){g->reason=2;advance(g);if(!g->active)return 1;continue;}
            if(sub>.75f)sub=.75f;
            if(sub< -.75f)sub=-.75f;
            g->disp[g->scale][g->point]=g->bd+sub;g->vertical[g->scale][g->point]=g->bv;++g->valid;
            if(g->scale==0U&&g->point==0U&&g->lo==45&&g->hi==160){
                g->lo=g->bd-16;g->hi=g->bd+16;
                if(g->lo<45)g->lo=45;
                if(g->hi>160)g->hi=160;
            }
            advance(g);
        }
    }return !g->active;
}

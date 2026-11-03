#include "db_match.h"
#include <limits.h>
#include <string.h>
int db_match_begin(DbMatch *m,const uint8_t *l,const uint8_t *r,
                   const uint8_t *lm,const uint8_t *rm,unsigned cx,unsigned cy,uint32_t frame)
{
    unsigned x,y,rx,ry;
    if(!m || m->active || !l || !r || !lm || !rm || cx<=DB_ROI/2U+1U ||
        cy<DB_ROI/2U || cx+DB_ROI/2U>DB_WIDTH || cy+DB_ROI/2U>DB_HEIGHT) return 0;
    m->reliable=0; m->distance_mm=0; m->disparity_x16=0;
    m->cx=cx; m->cy=cy; m->frame=frame; m->max_d=cx-DB_ROI/2U;
    if(m->max_d>DB_SEARCH_MAX) m->max_d=DB_SEARCH_MAX;
    rx=cx-DB_ROI/2U; ry=cy-DB_ROI/2U;
    for(y=0;y<DB_ROI;++y) {
        for(x=0;x<DB_ROI;++x) {
            unsigned i=(ry+y)*DB_WIDTH+rx+x;
            if(!rm[i]) return 0;
            m->reference[y][x]=r[i];
        }
        for(x=0;x<DB_ROI+m->max_d;++x) {
            unsigned i=(ry+y)*DB_WIDTH+rx-m->max_d+x;
            m->search[y][x]=l[i]; m->valid[y][x]=lm[i];
        }
    }
    m->next_d=1; m->active=1; return 1;
}
int db_match_poll(DbMatch *m,unsigned budget,const double q[16],unsigned max_mm)
{
    unsigned x,y,d,best=0,radius;
    uint32_t best_cost=UINT_MAX,other=UINT_MAX;
    int sub=0;
    double disparity,v[4],z,w;
    if(!m || !m->active || !q) return 0;
    while(budget-- && m->next_d<=m->max_d) {
        uint32_t sum=0; unsigned offset=m->max_d-m->next_d;
        for(y=0;y<DB_ROI;++y) for(x=0;x<DB_ROI;++x) {
            int delta;
            if(!m->valid[y][offset+x]) { sum=UINT_MAX; goto done_cost; }
            delta=(int)m->reference[y][x]-(int)m->search[y][offset+x];
            sum+=(unsigned)(delta<0?-delta:delta);
        }
done_cost:
        m->cost[m->next_d++]=sum;
    }
    if(m->next_d<=m->max_d) return 0;
    m->active=0;
    for(d=1;d<=m->max_d;++d) if(m->cost[d]<best_cost) { best=d; best_cost=m->cost[d]; }
    if(best<=1 || best>=m->max_d) return 1;
    radius=best/40U+1U;
    for(d=1;d<=m->max_d;++d) if((d+radius<best || d>best+radius) && m->cost[d]<other) other=m->cost[d];
    if(other==UINT_MAX || (uint64_t)best_cost*100U>=(uint64_t)other*95U) return 1;
    if(m->cost[best-1]!=UINT_MAX && m->cost[best+1]!=UINT_MAX) {
        int lc=(int)m->cost[best-1],bc=(int)best_cost,rc=(int)m->cost[best+1];
        int curvature=lc-2*bc+rc;
        if(curvature>0) { sub=8*(lc-rc)/curvature; if(sub>8)sub=8; if(sub< -8)sub=-8; }
    }
    m->disparity_x16=(uint32_t)((int)best*16+sub);
    disparity=m->disparity_x16/16.0;
    v[0]=m->cx-disparity; v[1]=m->cy; v[2]=-disparity; v[3]=1;
    z=0; w=0;
    for(x=0;x<4;++x) { z+=q[8+x]*v[x]; w+=q[12+x]*v[x]; }
    if(w==0) return 1;
    z/=w;
    if(!(z>0 && z<=max_mm)) return 1;
    m->distance_mm=(uint32_t)(z+0.5); m->reliable=1; return 1;
}

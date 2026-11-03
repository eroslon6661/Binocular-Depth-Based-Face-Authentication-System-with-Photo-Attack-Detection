#include "db_live_sequence.h"
#include <math.h>
#include <string.h>
static int32_t q8(float x)
{
    if(x>=32767.0f/256.0f)return 32767;
    if(x<=-128.0f)return -32768;
    return (int32_t)(x*256.0f+(x>=0?0.5f:-0.5f));
}
void db_live_sequence_reset(DbLiveSequence *s)
{memset(s,0,sizeof(*s));s->min_mm=0xffffffffU;}
int db_live_sample_usable(const DbLiveness *j)
{
    return j && j->surface_status==DB_LIVE_SURFACE_READY && j->dense_valid>=40U &&
        j->distance_mm>=450U && j->distance_mm<=1400U &&
        isfinite(j->plane_rms_px) && isfinite(j->nose_relief_px) &&
        isfinite(j->nose_eye_px) && isfinite(j->nose_cheek_px);
}
int db_live_sequence_add(DbLiveSequence *s,const DbLiveness *j)
{
    if(s->usable>=DB_LIVE_USABLE_SAMPLES || s->attempts>=DB_LIVE_MAX_ATTEMPTS)return 1;
    ++s->attempts;
    /* Distinct, increasing source frames are required, including across wrap.
     * A replay or zero tag consumes an attempt but cannot add evidence. */
    if(!j || !j->frame || (s->last_frame && (int32_t)(j->frame-s->last_frame)<=0))
        return s->attempts>=DB_LIVE_MAX_ATTEMPTS;
    s->last_frame=j->frame;
    if(db_live_sample_usable(j)) {
        ++s->usable;if(j->live)++s->passes;
        s->sum_mm+=j->distance_mm;
        if(j->distance_mm<s->min_mm)s->min_mm=j->distance_mm;
        if(j->distance_mm>s->max_mm)s->max_mm=j->distance_mm;
        s->dense+=j->dense_valid;s->lr+=j->lr_consistent;s->votes+=j->regional_votes;
        s->rms_q8+=q8(j->plane_rms_px);s->nose_q8+=q8(j->nose_relief_px);
        s->ne_q8+=q8(j->nose_eye_px);s->nc_q8+=q8(j->nose_cheek_px);
    }
    return s->usable>=DB_LIVE_USABLE_SAMPLES || s->attempts>=DB_LIVE_MAX_ATTEMPTS;
}
void db_live_sequence_result(const DbLiveSequence *s,DbControl *r)
{
    unsigned n=s->usable;
    memset(r->data,0,sizeof(r->data));r->status=DB_CTRL_INVALID;r->distance_mm=0;
    r->data[4]=(uint16_t)n;r->data[5]=(uint16_t)s->passes;
    if(!n)return;
    r->distance_mm=s->sum_mm/n;r->data[0]=(uint16_t)(s->dense/n);
    r->data[1]=(uint16_t)(s->rms_q8/(int)n);
    r->data[2]=(uint16_t)(int16_t)(s->nose_q8/(int)n);
    r->data[3]=(uint16_t)s->lr;
    r->data[6]=(uint16_t)(int16_t)(s->ne_q8/(int)n);
    r->data[7]=(uint16_t)(int16_t)(s->nc_q8/(int)n);
    r->data[8]=(uint16_t)(s->max_mm-s->min_mm);r->data[9]=(uint16_t)s->votes;
    if(n!=DB_LIVE_USABLE_SAMPLES || s->max_mm-s->min_mm>200U || !s->lr)return;
    /* Same 2-of-3 shape threshold. Invalid attempts cannot supply a pass. */
    r->status=s->passes>=2U?DB_CTRL_OK:DB_CTRL_SPOOF;
}

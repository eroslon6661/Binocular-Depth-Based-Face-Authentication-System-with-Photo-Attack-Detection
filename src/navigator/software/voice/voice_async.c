#include "voice.h"
#include "voice_distance_pcm.h"
#include "voice_access_pcm.h"
#include "voice_mode_pcm.h"
#include "xstatus.h"
#include <stddef.h>

extern const s16 voice_startup_pcm[];
extern const u32 voice_startup_count;
typedef struct { const s16 *samples; u32 count; } Segment;
static Segment phrase[8];
static unsigned segments, current;
static u32 position, last_progress;
static int active;

static int append_clip(unsigned clip)
{
    if (segments >= 8U) return 0;
    phrase[segments].samples=voice_distance_clips[clip].samples;
    phrase[segments++].count=voice_distance_clips[clip].count;
    return 1;
}
static void start(u32 now)
{
    current=0; position=0; last_progress=now; active=1;
}
int voice_async_busy(void) { return active; }
int voice_async_startup(u32 now)
{
    if (active || voice_sample_ready()<0) return XST_FAILURE;
    segments=1; phrase[0].samples=voice_startup_pcm; phrase[0].count=voice_startup_count;
    start(now); return XST_SUCCESS;
}
int voice_async_distance_mm(u32 mm,u32 now)
{
    u32 cm=(mm+5U)/10U,meters,rest,tens,ones;
    if(active || !cm || cm>600U || voice_sample_ready()<0) return XST_FAILURE;
    meters=cm/100U; rest=cm%100U; tens=rest/10U; ones=rest%10U;
    segments=0;
    append_clip(VOICE_CLIP_PREFIX);
    if(meters) { append_clip(VOICE_CLIP_ZERO+meters); append_clip(VOICE_CLIP_METER); }
    if(rest) {
        if(meters && rest<10U) append_clip(VOICE_CLIP_ZERO);
        if(rest<10U) append_clip(VOICE_CLIP_ZERO+rest);
        else {
            if(tens>1U) append_clip(VOICE_CLIP_ZERO+tens);
            append_clip(VOICE_CLIP_TEN);
            if(ones) append_clip(VOICE_CLIP_ZERO+ones);
        }
        append_clip(VOICE_CLIP_CENTIMETER);
    }
    start(now); return XST_SUCCESS;
}
int voice_async_access(unsigned clip,u32 now)
{
    if(active || clip>=VOICE_ACCESS_CLIP_COUNT || voice_sample_ready()<0)return XST_FAILURE;
    segments=1;
    phrase[0].samples=voice_access_clips[clip].samples;
    phrase[0].count=voice_access_clips[clip].count;
    start(now);return XST_SUCCESS;
}
int voice_async_notice(unsigned clip,u32 now)
{
    if(active || clip>=VOICE_NOTICE_COUNT || voice_sample_ready()<0)return XST_FAILURE;
    segments=1;phrase[0].samples=voice_mode_clips[clip].samples;
    phrase[0].count=voice_mode_clips[clip].count;start(now);return XST_SUCCESS;
}
/* Refill at most eight samples per call. Return immediately when the FPGA
 * FIFO is full or an acknowledgement is pending; never wait in a spin loop.
 * The bounded refill lets network work coexist with 16 kHz audio. */
int voice_async_poll(u32 now)
{
    int ready; unsigned budget=8;
    if(!active) return XST_SUCCESS;
    if((u32)(now-last_progress)>500000U) { active=0; return XST_FAILURE; }
    while(budget--) {
        ready=voice_sample_ready();
        if(ready<0) { active=0; return XST_FAILURE; }
        if(!ready) return XST_SUCCESS;
        while(current<segments && position>=phrase[current].count) { ++current; position=0; }
        if(current==segments) { active=0; return XST_SUCCESS; }
        if(voice_try_sample(phrase[current].samples[position])==1) { ++position; last_progress=now; }
        else return XST_SUCCESS;
    }
    return XST_SUCCESS;
}

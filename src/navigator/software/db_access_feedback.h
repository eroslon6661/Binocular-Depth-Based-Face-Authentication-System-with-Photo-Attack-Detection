#ifndef DB_ACCESS_FEEDBACK_H
#define DB_ACCESS_FEEDBACK_H
#include "db_control.h"
#include "voice/voice_access_pcm.h"
/* Failed/incomplete depth is not evidence of a photograph. All such results
 * still deny access; this selects truthful feedback, not an unlock policy. */
static inline unsigned db_access_feedback_clip(unsigned identity_ok,unsigned live_status)
{
    if(live_status!=DB_CTRL_OK && live_status!=DB_CTRL_SPOOF)return VOICE_ACCESS_LIVE_RETRY;
    if(live_status==DB_CTRL_OK)return identity_ok?VOICE_ACCESS_GRANTED:VOICE_ACCESS_UNKNOWN_LIVE;
    return identity_ok?VOICE_ACCESS_USER001_SPOOF:VOICE_ACCESS_UNKNOWN_SPOOF;
}
#endif

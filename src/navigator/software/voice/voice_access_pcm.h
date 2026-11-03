#ifndef VOICE_ACCESS_PCM_H
#define VOICE_ACCESS_PCM_H

#include "xil_types.h"

typedef struct {
    const s16 *samples;
    u32 count;
} VoiceAccessClip;

enum {
    VOICE_ACCESS_GRANTED=0,
    VOICE_ACCESS_CLOSED,
    VOICE_ACCESS_UNKNOWN_LIVE,
    VOICE_ACCESS_UNKNOWN_SPOOF,
    VOICE_ACCESS_USER001_SPOOF,
    VOICE_ACCESS_LIVE_RETRY,
    VOICE_ACCESS_CLIP_COUNT
};

extern const VoiceAccessClip voice_access_clips[VOICE_ACCESS_CLIP_COUNT];

#endif

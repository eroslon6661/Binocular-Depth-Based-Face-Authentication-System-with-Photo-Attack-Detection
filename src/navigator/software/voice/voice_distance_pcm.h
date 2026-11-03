#ifndef VOICE_DISTANCE_PCM_H
#define VOICE_DISTANCE_PCM_H

#include "xil_types.h"

typedef struct {
    const s16 *samples;
    u32 count;
} VoiceClip;

enum {
    VOICE_CLIP_PREFIX,
    VOICE_CLIP_ZERO,
    VOICE_CLIP_ONE,
    VOICE_CLIP_TWO,
    VOICE_CLIP_THREE,
    VOICE_CLIP_FOUR,
    VOICE_CLIP_FIVE,
    VOICE_CLIP_SIX,
    VOICE_CLIP_SEVEN,
    VOICE_CLIP_EIGHT,
    VOICE_CLIP_NINE,
    VOICE_CLIP_TEN,
    VOICE_CLIP_METER,
    VOICE_CLIP_CENTIMETER,
    VOICE_CLIP_COUNT
};

extern const VoiceClip voice_distance_clips[VOICE_CLIP_COUNT];

#endif

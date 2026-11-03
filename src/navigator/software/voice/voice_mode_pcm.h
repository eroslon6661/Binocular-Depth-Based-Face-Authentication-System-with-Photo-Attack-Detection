#ifndef VOICE_MODE_PCM_H
#define VOICE_MODE_PCM_H
#include "xil_types.h"
typedef struct {const s16 *samples;u32 count;} VoiceModeClip;
enum {VOICE_NOTICE_DISTANCE_MODE=0,VOICE_NOTICE_FACE_MODE,
      VOICE_NOTICE_RANGE_FAILED,VOICE_NOTICE_FACE_FAILED,VOICE_NOTICE_COUNT};
extern const VoiceModeClip voice_mode_clips[VOICE_NOTICE_COUNT];
#endif

#ifndef VOICE_H
#define VOICE_H

#include "xil_types.h"

int voice_init(void);
int voice_play_startup(void);
int voice_play_pcm16(const s16 *samples, u32 count);
int voice_play_distance_mm(u32 distance_mm);

/* Nonblocking sample handshake, used by voice_async.c. Do not mix blocking
 * playback with an active asynchronous phrase. Return -1 on unavailable codec. */
int voice_sample_ready(void);
int voice_try_sample(s16 sample);
int voice_async_startup(u32 now_us);
int voice_async_distance_mm(u32 distance_mm, u32 now_us);
int voice_async_access(unsigned clip, u32 now_us);
int voice_async_notice(unsigned clip, u32 now_us);
int voice_async_poll(u32 now_us);
int voice_async_busy(void);

/* Uses the same I2C owner as voice_init; never reinitialize a second driver
 * instance to inspect a live codec. A successful read uses repeated START. */
int voice_codec_read_register(u8 reg, u8 *value);
typedef struct {
    u32 accepted_samples, ack_samples;
    u8 error, reg, expected, actual;
} VoiceStatus;
enum { VOICE_ERROR_NONE, VOICE_ERROR_BUS, VOICE_ERROR_REGISTER,
       VOICE_ERROR_ACK };
void voice_get_status(VoiceStatus *status);

#endif

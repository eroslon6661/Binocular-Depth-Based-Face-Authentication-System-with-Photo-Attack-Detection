#include "db_audio_diag.h"
#include "db_log.h"
#include "voice/voice.h"
#include "xil_printf.h"
#include "xstatus.h"
/* Read-only codec diagnostics, called after voice_init before playback.
 * Register selection does not alter the codec's audio configuration. */
int db_audio_readback(void)
{
    static const u8 regs[]={0,1,2,4,8,23,25,26,27,29,39,42,43,46,47,48,49};
    unsigned i;
    for(i=0;i<sizeof(regs);++i) {
        u8 reg=regs[i],value=0;
        if(voice_codec_read_register(reg,&value)!=XST_SUCCESS) {
            xil_printf("AUDIO_READBACK reg=%u failed\r\n",reg);return XST_FAILURE;
        }
        xil_printf("AUDIO_READBACK reg=%u value=%02x\r\n",reg,value);
    }
    return XST_SUCCESS;
}
void db_audio_report(const char *event)
{
    VoiceStatus status;voice_get_status(&status);
    db_log("AUDIO event=%s accepted=%lu ack=%lu busy=%lu error=%u reg=%u expected=%02x actual=%02x\r\n",
        event,(unsigned long)status.accepted_samples,(unsigned long)status.ack_samples,
        (unsigned long)voice_async_busy(),status.error,status.reg,status.expected,status.actual);
}

#include "voice.h"
#include "voice_distance_pcm.h"

#include "sleep.h"
#include "xgpio.h"
#include "xiicps.h"
#include "xparameters.h"
#include "xstatus.h"

extern const s16 voice_startup_pcm[];
extern const u32 voice_startup_count;

#define ES8388_ADDRESS 0x10U
#define AUDIO_GPIO_CHANNEL 1U
#define AUDIO_ACK_CHANNEL 2U
#define AUDIO_SAMPLE_TIMEOUT 200000U

static XIicPs codec_iic;
static XGpio audio_gpio;
static u32 sample_toggle;
static int voice_ready;
static int codec_bus_ready;
static unsigned sample_pending;
static VoiceStatus voice_status;
#ifdef VOICE_CODEC_BOUNDED_IIC
extern int voice_codec_recv_one(XIicPs *bus,u8 *value);
#endif

void voice_get_status(VoiceStatus *status) { if(status)*status=voice_status; }
static int codec_idle(void)
{
    unsigned tries=1000;
    while(XIicPs_BusIsBusy(&codec_iic) && tries--)usleep(10);
    return XIicPs_BusIsBusy(&codec_iic)?XST_FAILURE:XST_SUCCESS;
}
int voice_codec_read_register(u8 reg,u8 *value)
{
    int status;
    if(!codec_bus_ready || !value || codec_idle()!=XST_SUCCESS)return XST_FAILURE;
    XIicPs_SetOptions(&codec_iic,XIICPS_REP_START_OPTION);
    status=XIicPs_MasterSendPolled(&codec_iic,&reg,1,ES8388_ADDRESS);
    /* Clear the software option before RECV, as in the SDK repeated-start
     * example. RECV releases HOLD and generates STOP after the last byte. */
    XIicPs_ClearOptions(&codec_iic,XIICPS_REP_START_OPTION);
    if(status==XST_SUCCESS)
#ifdef VOICE_CODEC_BOUNDED_IIC
        status=voice_codec_recv_one(&codec_iic,value);
#else
        status=XIicPs_MasterRecvPolled(&codec_iic,value,1,ES8388_ADDRESS);
#endif
    if(status==XST_SUCCESS)status=codec_idle();
    if(status!=XST_SUCCESS) {
        XIicPs_Reset(&codec_iic);
        voice_status.error=VOICE_ERROR_BUS;voice_status.reg=reg;
    }
    return status;
}

static int codec_verify(void)
{
    /* Check only documented bits; reserved bits need not read as written.
     * Values preserve the existing codec routing, volume and I2S format. */
    static const u8 expected[][3]={
        {0,0x06,0xff},{1,0x50,0x3f},{2,0x00,0xff},{4,0x3c,0xfc},
        {8,0x00,0xff},{23,0x18,0x3f},{24,0x0c,0x3f},{25,0x00,0x04},
        {26,0x00,0xff},{27,0x00,0xff},{29,0x1c,0x3f},
        {39,0x80,0xc0},{42,0x80,0xc0},{43,0x80,0xff},
        {46,30,0x3f},{47,30,0x3f},{48,30,0x3f},{49,30,0x3f}
    };
    unsigned i;
    for(i=0;i<sizeof(expected)/sizeof(expected[0]);++i) {
        u8 value=0;
        if(voice_codec_read_register(expected[i][0],&value)!=XST_SUCCESS)return XST_FAILURE;
        if((value&expected[i][2])!=(expected[i][1]&expected[i][2])) {
            voice_status.error=VOICE_ERROR_REGISTER;voice_status.reg=expected[i][0];
            voice_status.expected=expected[i][1];voice_status.actual=value;
            return XST_FAILURE;
        }
    }
    return XST_SUCCESS;
}

static int codec_write(u8 reg, u8 value)
{
    u8 data[2] = {reg, value};
    int status=codec_idle();
    if(status==XST_SUCCESS)status=XIicPs_MasterSendPolled(&codec_iic,data,2,ES8388_ADDRESS);
    if(status==XST_SUCCESS)status=codec_idle();
    if(status!=XST_SUCCESS) {voice_status.error=VOICE_ERROR_BUS;voice_status.reg=reg;}
    return status;
}

int voice_init(void)
{
    XIicPs_Config *iic_cfg;
    XGpio_Config *gpio_cfg;
    unsigned int i;
    int status;
    static const u8 codec_settings[][2] = {
        {0, 0x80}, {0, 0x00}, {1, 0x58}, {1, 0x50},
        {2, 0xf3}, {3, 0xfc}, {0, 0x06},
        {4, 0x3c}, {8, 0x00}, {9, 0x66}, {10, 0x50},
        {12, 0x4c}, {13, 0x0c}, {16, 0x00}, {17, 0x00},
        {18, 0xc0}, {23, 0x18}, {24, 0x0c},
        {25, 0x04}, {26, 0x00}, {27, 0x00}, {29, 0x1c},
        {39, 0x80}, {42, 0x80}, {43, 0x80},
        {46, 30}, {47, 30}, {48, 30}, {49, 30},
        /* ES8388 startup sequence: release DEM/STM only after the serial
         * format, clock selection, mixers and output levels are configured.
         * Releasing it before reg 43 changes can leave the slave clock
         * detector running with the reset routing after a warm download. */
        {2, 0x00}
    };

    voice_ready=codec_bus_ready=0;sample_pending=0;
    voice_status=(VoiceStatus){0};

    gpio_cfg = XGpio_LookupConfig(XPAR_AXI_GPIO_AUDIO_DEVICE_ID);
    if (gpio_cfg == NULL) return XST_FAILURE;
    status = XGpio_CfgInitialize(&audio_gpio, gpio_cfg, gpio_cfg->BaseAddress);
    if (status != XST_SUCCESS) return status;
    XGpio_SetDataDirection(&audio_gpio, AUDIO_GPIO_CHANNEL, 0x0U);
    XGpio_SetDataDirection(&audio_gpio, AUDIO_ACK_CHANNEL, 0x1U);
    /* A PS-only warm reset may retain the PL ACK toggle. Synchronize with
     * it instead of inventing a zero toggle and injecting an unwanted edge. */
    sample_toggle=XGpio_DiscreteRead(&audio_gpio,AUDIO_ACK_CHANNEL)&1U;
    XGpio_DiscreteWrite(&audio_gpio,AUDIO_GPIO_CHANNEL,sample_toggle<<16);

    iic_cfg = XIicPs_LookupConfig(XPAR_XIICPS_0_DEVICE_ID);
    if (iic_cfg == NULL) return XST_FAILURE;
    status = XIicPs_CfgInitialize(&codec_iic, iic_cfg, iic_cfg->BaseAddress);
    if (status != XST_SUCCESS) return status;
    status = XIicPs_SetSClk(&codec_iic, 100000U);
    if (status != XST_SUCCESS) return status;
    codec_bus_ready=1;

    usleep(10000);
    for (i = 0; i < sizeof(codec_settings) / sizeof(codec_settings[0]); ++i) {
        status = codec_write(codec_settings[i][0], codec_settings[i][1]);
        if (status != XST_SUCCESS) return status;
        /* Settle reset assertion/release and chip power changes. The old
         * sole delay followed CONTROL2, leaving reset writes back-to-back. */
        if(i<=2U || codec_settings[i][0]==2U)usleep(10000);
    }
    usleep(50000);
    status = codec_write(25, 0x00);
    if (status != XST_SUCCESS) return status;
    if(codec_verify()!=XST_SUCCESS)return XST_FAILURE;
    voice_ready = 1;
    /* Two silent samples prove that the GPIO request/ACK path advances in
     * both directions. ACK proves FIFO acceptance, not audible playback. */
    for(i=0;i<2U;++i) {
        unsigned tries=2000;
        if(voice_try_sample(0)!=1) {voice_ready=0;voice_status.error=VOICE_ERROR_ACK;return XST_FAILURE;}
        while(!voice_sample_ready() && tries--)usleep(10);
        if(!voice_sample_ready()) {voice_ready=0;voice_status.error=VOICE_ERROR_ACK;return XST_FAILURE;}
    }
    return XST_SUCCESS;
}

int voice_play_pcm16(const s16 *samples, u32 count)
{
    u32 i;
    if (!voice_ready || samples == NULL) return XST_FAILURE;
    for (i = 0; i < count; ++i) {
        u32 timeout = AUDIO_SAMPLE_TIMEOUT;
        while(voice_try_sample(samples[i])!=1)if(--timeout==0U)return XST_FAILURE;
        while(!voice_sample_ready())if(--timeout==0U) {voice_status.error=VOICE_ERROR_ACK;return XST_FAILURE;}
    }
    return XST_SUCCESS;
}

int voice_play_startup(void)
{
    return voice_play_pcm16(voice_startup_pcm, voice_startup_count);
}

int voice_sample_ready(void)
{
    if (!voice_ready) return -1;
    if((XGpio_DiscreteRead(&audio_gpio,AUDIO_ACK_CHANNEL)&1U)!=sample_toggle)return 0;
    if(sample_pending) {sample_pending=0;++voice_status.ack_samples;}
    return 1;
}

int voice_try_sample(s16 sample)
{
    int ready = voice_sample_ready();
    if (ready <= 0) return ready;
    sample_toggle ^= 1U;
    sample_pending=1;++voice_status.accepted_samples;
    XGpio_DiscreteWrite(&audio_gpio, AUDIO_GPIO_CHANNEL,
                        (sample_toggle << 16) | (u16)sample);
    return 1;
}

static int play_clip(u32 clip)
{
    return voice_play_pcm16(voice_distance_clips[clip].samples,
                            voice_distance_clips[clip].count);
}

static int play_centimeters(u32 centimeters)
{
    u32 tens = centimeters / 10U;
    u32 ones = centimeters % 10U;

    if (centimeters < 10U) {
        if (play_clip(VOICE_CLIP_ZERO + centimeters) != XST_SUCCESS)
            return XST_FAILURE;
    } else {
        if (tens > 1U && play_clip(VOICE_CLIP_ZERO + tens) != XST_SUCCESS)
            return XST_FAILURE;
        if (play_clip(VOICE_CLIP_TEN) != XST_SUCCESS) return XST_FAILURE;
        if (ones != 0U && play_clip(VOICE_CLIP_ZERO + ones) != XST_SUCCESS)
            return XST_FAILURE;
    }
    return play_clip(VOICE_CLIP_CENTIMETER);
}

int voice_play_distance_mm(u32 distance_mm)
{
    u32 total_cm = (distance_mm + 5U) / 10U;
    u32 meters = total_cm / 100U;
    u32 centimeters = total_cm % 100U;

    if (total_cm == 0U || total_cm > 600U) return XST_FAILURE;
    if (play_clip(VOICE_CLIP_PREFIX) != XST_SUCCESS) return XST_FAILURE;
    if (meters != 0U) {
        if (play_clip(VOICE_CLIP_ZERO + meters) != XST_SUCCESS)
            return XST_FAILURE;
        if (play_clip(VOICE_CLIP_METER) != XST_SUCCESS) return XST_FAILURE;
    }
    if (centimeters != 0U) {
        if (meters != 0U && centimeters < 10U &&
            play_clip(VOICE_CLIP_ZERO) != XST_SUCCESS) return XST_FAILURE;
        return play_centimeters(centimeters);
    }
    return XST_SUCCESS;
}

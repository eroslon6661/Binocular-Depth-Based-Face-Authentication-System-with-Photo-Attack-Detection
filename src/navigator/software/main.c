#include "db_config.h"
#include "db_color_diag.h"
#include "db_net.h"
#include "db_log.h"
#include "db_capture_job.h"
#include "db_screen.h"
#include "db_camera.h"
#include "db_control_net.h"
#include "db_audio_diag.h"
#include "db_flight.h"
#include "db_crc_amp.h"
#include "db_face_identity.h"
#include "db_face_pipeline.h"
#include "db_face_profile.h"
#include "db_face_live_points.h"
#include "db_access.h"
#include "db_rgb_screen.h"
#include "db_face_gallery.h"
#include "xrectify_accel.h"
#include "xgpiops.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xparameters.h"
#include "emio_sccb_cfg/emio_sccb_cfg.h"
#include "voice/voice.h"
#include "voice/voice_access_pcm.h"
#include "db_access_feedback.h"
#include "db_mode.h"
#include "db_hdmi_nav.h"
#include "voice/voice_mode_pcm.h"
#include <string.h>
extern const uint64_t db_map_left[],db_map_right[];
enum {FREE, COPYING, READY, RECTIFYING, INVALIDATING, SENDING};
typedef struct {uint8_t *image[2],*mask[2];uint32_t frame,stamp[2];unsigned state,photo;} Pair;
static Pair raw[3],output[3];
static Pair photo_raw;
static uint32_t photo_command_acked;
static DbCaptureJob capture;
static DbReceiver unused_receiver;
static DbSender sender;
static DbNet network;
static DbControlNet control;
static DbControlClient request;
static DbFlight flight;
static XRectify_accel engine[2];
static XGpio keys;
static XGpioPs ps_keys;
static DbFacePipeline face_pipeline;
static unsigned face_image_locked;
static DbAccess access_state;
volatile uint32_t db_frame_id=1U;
static unsigned cursor_x=640,cursor_y=360;
static uint32_t cursor_sequence=1;
static void audio_poll(int *available)
{
    if(*available && voice_async_busy()) {
        if(voice_async_poll(db_time_us())!=XST_SUCCESS) {
            *available=0;db_audio_report("playback_failed");
        } else if(!voice_async_busy())db_audio_report("phrase_samples_acked");
    }
}
static unsigned key_sample(void)
{
    unsigned pl=XGpio_DiscreteRead(&keys,1),pressed=0;
    if(!(pl&1U))pressed|=1U;
    if(!(pl&2U))pressed|=2U;
    if(!XGpioPs_ReadPin(&ps_keys,12))pressed|=4U;
    if(!XGpioPs_ReadPin(&ps_keys,11))pressed|=8U;
    if(!(pl&4U))pressed|=16U;
    return pressed;
}
static int keys_init(void)
{
    XGpioPs_Config *p=XGpioPs_LookupConfig(XPAR_XGPIOPS_0_DEVICE_ID);
    if(!p || XGpio_Initialize(&keys,XPAR_AXI_GPIO_KEY_DEVICE_ID)!=XST_SUCCESS ||
       XGpioPs_CfgInitialize(&ps_keys,p,p->BaseAddr)!=XST_SUCCESS)return 0;
    XGpio_SetDataDirection(&keys,1,7U);XGpio_SetDataDirection(&keys,2,0);
    XGpioPs_SetDirectionPin(&ps_keys,12,0);XGpioPs_SetDirectionPin(&ps_keys,11,0);return 1;
}
static uint32_t session_start(void)
{
    /* Dedicated record outside images, maps, CRC mailbox and application.
     * Survives a JTAG program reload; clock mixing also separates cold starts. */
    const uintptr_t record=0x09000000U;uint32_t generation=1,session;
    Xil_DCacheInvalidateRange(record,32);
    if(Xil_In32(record)==0x4f575631U && (Xil_In32(record+4)^Xil_In32(record+8))==0xffffffffU)
        generation=Xil_In32(record+4)+1U;
    if(!generation)generation=1;
    Xil_Out32(record,0x4f575631U);Xil_Out32(record+4,generation);Xil_Out32(record+8,~generation);
    Xil_DCacheFlushRange(record,32);
    session=0x20261011U^(generation*0x9e3779b9U)^db_time_us();return session?session:1U;
}
int main(void)
{
    Pair *copying=NULL,*working_raw=NULL,*working_out=NULL,*sending=NULL;
    DbCacheJob invalidate;
    uint8_t *unused_images[DB_RX_SLOTS][2];
    uint32_t session=session_start(),last_key=0,last_report=0,last_hello=0,last_state=0,last_request=0,last_peer=0;
    uint32_t rect_started=0,last_rect_us=0,copied=0,rectified=0,sent=0,aborted=0,dropped=0;
    unsigned i,c,done[2]={0,0},fatal=0,peer_ready=0,voice_pending_mm=0;
    unsigned access_voice_pending=VOICE_ACCESS_CLIP_COUNT;
    unsigned notice_pending=VOICE_NOTICE_COUNT,mode=DB_MODE_FACE,capture_mode=DB_MODE_FACE;
    unsigned capture_active=0,queued_capture=0;
    unsigned stable=0,candidate=0,debounce[5]={0},held[5]={0};
    int keys_available,audio_available=0;
    DbControl message,hello,state;
    DbControl live_command,live_result;
    DbFaceDetection face_detection;
    DbFaceResult identity_result;
    uint32_t last_live_command=0,live_started=0;
    unsigned have_face_detection=0,live_command_active=0,have_live_result=0;
    unsigned have_identity_result=0,access_reported=0;
    db_log("ONE_WAY NAV capture+rectify -> AX SGBM+HDMI\r\n");
    if(!db_face_identity_self_test()) {
        db_log("FATAL: FACE authorized-gallery self-test failed\r\n");
        return XST_FAILURE;
    }
    db_log("FACE person_01 ready dim=%u threshold_q15=%d template_fnv=%08lx\r\n",
        DB_FACE_IDENTITY_DIM,DB_FACE_MATCH_THRESHOLD_Q15,
        (unsigned long)DB_FACE_TEMPLATE_FNV1A32);
    db_log("FACE authorized_users=%u USER01 preserved; USER02 enrolled\r\n",DB_FACE_AUTHORIZED_COUNT);
    /* This role intentionally keeps CRC on CPU0; no audio-clock/AMP changes. */
    db_crc_amp_init();emio_init();
    for(i=0;i<3;++i)for(c=0;c<2;++c) {
        raw[i].image[c]=(uint8_t *)(DB_RAW_TX_BASE+(i*2U+c)*DB_IMAGE_BYTES);
        output[i].image[c]=(uint8_t *)(DB_WORKER_OUTPUT_BASE+(i*2U+c)*DB_IMAGE_BYTES);
        output[i].mask[c]=(uint8_t *)(DB_MASK_BASE+(i*2U+c)*DB_IMAGE_BYTES);
        unused_images[i][c]=(uint8_t *)(DB_NETWORK_RX_BASE+(i*2U+c)*DB_IMAGE_BYTES);
    }
    Xil_DCacheFlushRange((INTPTR)db_map_left,DB_IMAGE_BYTES*8U);
    Xil_DCacheFlushRange((INTPTR)db_map_right,DB_IMAGE_BYTES*8U);
    Xil_DCacheFlushRange(DB_WORKER_OUTPUT_BASE,6U*DB_IMAGE_BYTES);
    Xil_DCacheFlushRange(DB_MASK_BASE,6U*DB_IMAGE_BYTES);
    if(XRectify_accel_Initialize(&engine[0],XPAR_RECTIFY_LEFT_DEVICE_ID)!=XST_SUCCESS ||
       XRectify_accel_Initialize(&engine[1],XPAR_RECTIFY_RIGHT_DEVICE_ID)!=XST_SUCCESS)return XST_FAILURE;
    if(!db_camera_init_pair() || !db_capture_init(&capture))return XST_FAILURE;
    db_color_diag_init();
    keys_available=keys_init();
    db_access_init(&access_state);
    if(keys_available) {
        stable=candidate=key_sample();
        /* Channel 2 bit 0 is the lock command. It is retained as a clean
         * software/hardware boundary even when the current bitstream has no
         * external actuator pin connected: 0=locked, 1=unlocked. */
        XGpio_DiscreteWrite(&keys,2,0U);
    }
    /* Verify the codec before network setup. Do not queue a timed phrase
     * until the blocking PHY initialization has returned. */
    for(i=0;i<2U && !audio_available;++i)if(voice_init()==XST_SUCCESS &&
       db_audio_readback()==XST_SUCCESS)audio_available=1;
    db_rx_init(&unused_receiver,session,DB_CALIBRATION_ID,DB_RAW,DB_TIMEOUT_US,DB_MAX_SKEW_US,unused_images);
    if(!db_net_open(&network,&unused_receiver,0) || !db_control_net_open(&control,&network))
        db_log("WARNING: network unavailable; audio and keys remain active\r\n");
    /* Photo DMA/cache initialization can take longer than an audio FIFO.
     * Complete it before starting the timed startup phrase. */
    db_screen_init();
    if(db_face_pipeline_init(&face_pipeline))
        db_log("FACE pipeline ready: YuNet -> align112 -> MobileFaceNet -> INT8 match\r\n");
    else
        db_log("FACE pipeline disabled: INT8 inference backend is not present in this bitstream\r\n");
    db_hdmi_nav_init(&network,session);
    if(audio_available && voice_async_startup(db_time_us())!=XST_SUCCESS)audio_available=0;
    db_audio_report(audio_available?"initialized_verified":"init_failed");
    network.tx_source_cpu_written=0;
    db_flight_init(&flight,DB_FRESH_US);db_control_client_init(&request,session,DB_CALIBRATION_ID);
    memset(&hello,0,sizeof(hello));hello.type=DB_CTRL_HELLO;hello.session=session;
    hello.calibration=DB_CALIBRATION_ID;hello.id=session;hello.x=640;hello.y=360;
    state=hello;state.type=DB_CTRL_STATE;
    memset(&live_command,0,sizeof(live_command));memset(&live_result,0,sizeof(live_result));
    memset(&identity_result,0,sizeof(identity_result));
    for(;;) {
        uint32_t now=db_time_us();
        unsigned key_capture=0,touch_capture,controls_busy,photo_owned;
        DbAccessEvent access_event=db_access_poll(&access_state,now);
        if(access_event==DB_ACCESS_EVENT_CLOSED) {
            if(keys_available)XGpio_DiscreteWrite(&keys,2,0U);
            access_voice_pending=VOICE_ACCESS_CLOSED;
            db_log("LOCK state=CLOSED automatic=1\r\n");
        }
        db_log_poll(8);audio_poll(&audio_available);db_net_poll(&network,32);audio_poll(&audio_available);
        if(!audio_available){voice_pending_mm=0;access_voice_pending=VOICE_ACCESS_CLIP_COUNT;notice_pending=VOICE_NOTICE_COUNT;}
        photo_owned=photo_raw.state!=FREE;
        for(i=0;i<3;++i)if(output[i].photo && output[i].state!=FREE)photo_owned=1;
        controls_busy=capture_active || photo_owned || request.active || db_screen_busy() ||
            face_image_locked || have_face_detection || live_command_active ||
            (audio_available && (voice_async_busy() || voice_pending_mm ||
             access_voice_pending<VOICE_ACCESS_CLIP_COUNT || notice_pending<VOICE_NOTICE_COUNT));
        db_color_diag_poll(now,controls_busy);
        db_rgb_screen_controls_busy(controls_busy);
        db_screen_poll(now);
        db_face_profile_poll(now);
        if(face_image_locked) {
            int face_status=db_face_pipeline_poll(&face_pipeline,now);
            DbFaceDetection detected;
            if(db_face_pipeline_take_detection(&face_pipeline,&detected)) {
                face_detection=detected;have_face_detection=1;
                db_rgb_screen_detection(face_pipeline.frame,&detected);
                db_log("LIVE YuNet ready frame=%lu score_x1000=%lu; waiting for exact-frame command binding\r\n",
                    (unsigned long)face_pipeline.frame,(unsigned long)(detected.score*1000.0f));
            }
            if(face_status!=0) {
                DbFaceResult face_result;
                if(face_status>0 && db_face_pipeline_take_result(&face_pipeline,&face_result)) {
                    identity_result=face_result;have_identity_result=1;
                    db_rgb_screen_identity(face_result.frame,face_result.person_id,face_result.score_q15,face_result.valid);
                    db_log("FACE result frame=%lu matched=%u person_id=%u score_q15=%ld threshold_q15=%d\r\n",
                        (unsigned long)face_result.frame,face_result.matched,face_result.person_id,
                        (long)face_result.score_q15,DB_FACE_MATCH_THRESHOLD_Q15);
                    db_log("FACE users frame=%lu user01_q15=%ld user02_q15=%ld samples=1,2\r\n",
                        (unsigned long)face_result.frame,
                        (long)db_face_person_similarity_i8_q15(face_pipeline.embedding,1),
                        (long)db_face_person_similarity_i8_q15(face_pipeline.embedding,2));
                } else {
                    db_rgb_screen_identity(face_pipeline.frame,0,0,0);
                    db_log("FACE inference failed frame=%lu; image lock released\r\n",(unsigned long)face_pipeline.frame);
                }
                db_log("FACE timing detect_us=%lu embed_us=%lu total_us=%lu\r\n",
                    (unsigned long)(face_pipeline.detected_us ?
                        face_pipeline.detected_us-face_pipeline.started_us : 0U),
                    (unsigned long)(face_pipeline.detected_us ?
                        face_pipeline.completed_us-face_pipeline.detected_us : 0U),
                    (unsigned long)(face_pipeline.completed_us-face_pipeline.started_us));
                db_screen_image_release();face_image_locked=0;
            }
        }
        if(capture_mode==DB_MODE_FACE && have_face_detection && !live_command_active && !have_live_result) {
            const DbPhoto *p=db_screen_photo();uint16_t cx,cy;
            if(p->frame==face_pipeline.frame && p->request_id) {
                memset(&live_command,0,sizeof(live_command));live_command.type=DB_CTRL_LIVE_REQUEST;
                live_command.session=session;live_command.calibration=DB_CALIBRATION_ID;
                live_command.id=p->request_id;live_command.frame=p->frame;
                live_command.capture_us=(int32_t)(p->stamp[0]-p->stamp[1])<=0?p->stamp[0]:p->stamp[1];
                if(db_face_live_points(&face_detection,live_command.data,&cx,&cy)) {
                    live_command.x=cx;live_command.y=cy;live_command_active=1;live_started=now;last_live_command=0;
                    db_log("LIVE request prepared frame=%lu center=%u,%u\r\n",
                        (unsigned long)live_command.frame,cx,cy);
                } else {
                    live_result=live_command;live_result.type=DB_CTRL_LIVE_RESULT;
                    live_result.frame=p->frame;live_result.status=DB_CTRL_INVALID;
                    have_live_result=1;db_log("LIVE landmark rectification failed frame=%lu\r\n",(unsigned long)p->frame);
                    db_rgb_screen_liveness(p->frame,DB_CTRL_INVALID);
                }
                have_face_detection=0;
            } else if(p->state==DB_PHOTO_FAILED && !request.active) {
                /* No exact-frame request survived to bind the detection.
                 * Finish as invalid, rather than blocking mode changes forever. */
                memset(&live_result,0,sizeof(live_result));
                live_result.frame=face_pipeline.frame;live_result.status=DB_CTRL_INVALID;
                have_live_result=1;have_face_detection=0;
                db_rgb_screen_liveness(face_pipeline.frame,DB_CTRL_INVALID);
            }
        }
        if(live_command_active && (uint32_t)(now-last_live_command)>=DB_CONTROL_RETRY_US)
            if(db_control_net_send(&control,&live_command))last_live_command=now;
        if(live_command_active && (uint32_t)(now-live_started)>10000000U) {
            live_result=live_command;live_result.type=DB_CTRL_LIVE_RESULT;live_result.status=DB_CTRL_TIMEOUT;
            live_command_active=0;have_live_result=1;
            db_rgb_screen_liveness(live_result.frame,DB_CTRL_TIMEOUT);
            db_log("LIVE timeout frame=%lu\r\n",(unsigned long)live_result.frame);
        }
        db_flight_expire(&flight,now);
        if((uint32_t)(now-last_hello)>=250000U) {
            if(db_control_net_send(&control,&hello))last_hello=now;
        }
        if(db_control_net_take(&control,DB_CTRL_HELLO_ACK,&message) &&
           message.session==session && message.calibration==DB_CALIBRATION_ID) {
            peer_ready=1;last_peer=now;
        }
        if(peer_ready && (uint32_t)(now-last_peer)>1500000U)peer_ready=0;
        if(db_control_net_take(&control,DB_CTRL_FRAME_ACK,&message) && message.session==session &&
           message.calibration==DB_CALIBRATION_ID && (int32_t)(db_frame_id-message.frame)>=0)
            db_flight_complete(&flight,message.frame);
        if(db_control_net_take(&control,DB_CTRL_PHOTO_ACK,&message) && request.active &&
           db_control_photo_ack(&request.request,&message))photo_command_acked=message.frame;
        if(db_control_net_take(&control,DB_CTRL_RESULT,&message)) {
            int accepted=db_control_accept(&request,&message,db_capture_time_us(&capture));
            if(accepted) {
                DbControl ack=message;ack.type=DB_CTRL_RESULT_ACK;db_control_net_send(&control,&ack);
                if(accepted==1) {
                    if(request.request.type==DB_CTRL_PHOTO_REQUEST)db_screen_result(&message);
                    db_screen_measurement(&message,request.request.type==DB_CTRL_PHOTO_REQUEST);
                    db_log("MEASURE REMOTE frame=%lu request=%lu status=%lu distance=%lu mm\r\n",
                        (unsigned long)message.frame,(unsigned long)message.id,(unsigned long)message.status,(unsigned long)message.distance_mm);
                    if(audio_available && (capture_mode==DB_MODE_DISTANCE || request.request.type!=DB_CTRL_PHOTO_REQUEST)) {
                        if(message.status==DB_CTRL_OK)voice_pending_mm=message.distance_mm;
                        /* Failed range stays visible on the screen, silently. */
                    }
                }
            }
        }
        if(db_control_net_take(&control,DB_CTRL_LIVE_RESULT,&message) &&
           message.session==session && message.calibration==DB_CALIBRATION_ID &&
           live_command_active && message.id==live_command.id && message.frame==live_command.frame &&
           message.capture_us==live_command.capture_us) {
            DbControl ack=message;ack.type=DB_CTRL_LIVE_ACK;db_control_net_send(&control,&ack);
            live_result=message;have_live_result=1;live_command_active=0;
            db_rgb_screen_liveness(message.frame,message.status);
            db_log("LIVE result frame=%lu status=%lu distance=%lu dense=%u plane_rms_q8=%u nose_relief_q8=%d lr=%u samples=%u pass=%u ne_q8=%d nc_q8=%d span_mm=%u votes=%u\r\n",
                (unsigned long)message.frame,(unsigned long)message.status,
                (unsigned long)message.distance_mm,message.data[0],message.data[1],(int)(int16_t)message.data[2],
                message.data[3],message.data[4],message.data[5],(int)(int16_t)message.data[6],
                (int)(int16_t)message.data[7],message.data[8],message.data[9]);
        }
        if(capture_mode==DB_MODE_FACE && have_identity_result && have_live_result && !access_reported &&
           identity_result.frame==live_result.frame) {
            unsigned live_ok=live_result.status==DB_CTRL_OK;
            unsigned grant=identity_result.matched && live_ok;
            DbAccessEvent decision=db_access_decide(&access_state,identity_result.matched,live_ok,now);
            if(keys_available)XGpio_DiscreteWrite(&keys,2,db_access_unlocked(&access_state)?1U:0U);
            access_voice_pending=db_access_feedback_clip(identity_result.matched,live_result.status);
            db_log("AUTH feedback frame=%lu id_match=%u live_status=%lu clip=%u reason=%s\r\n",
                (unsigned long)identity_result.frame,identity_result.matched,(unsigned long)live_result.status,access_voice_pending,
                live_result.status==DB_CTRL_SPOOF?"PHOTO_ATTACK":live_result.status!=DB_CTRL_OK?"RETRY":identity_result.matched?"GRANTED":"IDENTITY_MISMATCH");
            /* Face mode speaks the final authentication feedback only;
             * range mode owns numeric distance announcements. */
            voice_pending_mm=0U;
            db_log("ACCESS result frame=%lu grant=%u identity=%u live=%u score_q15=%ld plane_rms_q8=%u person_id=%u\r\n",
                (unsigned long)identity_result.frame,grant,identity_result.matched,live_ok,
                (long)identity_result.score_q15,live_result.data[1],identity_result.person_id);
            db_log("LOCK state=%s decision=%u auto_close_us=%lu\r\n",
                db_access_unlocked(&access_state)?"OPEN":"CLOSED",decision,
                (unsigned long)(db_access_unlocked(&access_state)?DB_ACCESS_OPEN_US:0U));
            access_reported=1;
        }
        if(db_control_expire(&request,now)) {
            DbControl timeout=request.request;
            timeout.type=DB_CTRL_RESULT;timeout.status=DB_CTRL_TIMEOUT;
            timeout.frame=timeout.distance_mm=0;
            db_screen_measurement(&timeout,request.request.type==DB_CTRL_PHOTO_REQUEST);
            if(request.request.type==DB_CTRL_PHOTO_REQUEST) {
                db_screen_fail();
                for(i=0;i<3;++i)if(output[i].photo && output[i].state==READY)output[i].state=FREE;
            }
            db_log("MEASURE timeout; no distance spoken\r\n");
        }
        if(capture_active && !db_screen_busy() && !request.active &&
           !face_image_locked && !have_face_detection && !live_command_active) {
            if(capture_mode==DB_MODE_FACE && !access_reported) {
                if(audio_available)notice_pending=VOICE_NOTICE_FACE_FAILED;
                access_reported=1;
            }
            capture_active=0;
        }
        if(audio_available && access_voice_pending<VOICE_ACCESS_CLIP_COUNT && !voice_async_busy()) {
            unsigned clip=access_voice_pending;
            if(voice_async_access(clip,now)!=XST_SUCCESS)audio_available=0;
            else {db_log("AUTH audio clip=%u frame=%lu\r\n",clip,(unsigned long)identity_result.frame);db_audio_report("access_phrase_queued");}
            access_voice_pending=VOICE_ACCESS_CLIP_COUNT;
        }
        if(audio_available && notice_pending<VOICE_NOTICE_COUNT &&
           access_voice_pending==VOICE_ACCESS_CLIP_COUNT && !voice_async_busy()) {
            if(voice_async_notice(notice_pending,now)!=XST_SUCCESS)audio_available=0;
            else db_audio_report("mode_notice_queued");
            notice_pending=VOICE_NOTICE_COUNT;
        }
        if(audio_available && voice_pending_mm &&
           access_voice_pending==VOICE_ACCESS_CLIP_COUNT && notice_pending==VOICE_NOTICE_COUNT && !voice_async_busy()) {
            if(voice_async_distance_mm(voice_pending_mm,now)!=XST_SUCCESS)audio_available=0;
            else db_audio_report("distance_queued");
            voice_pending_mm=0;
        }
        if(keys_available && (uint32_t)(now-last_key)>=10000U) {
            unsigned sample=key_sample(),fired=0,old_x=cursor_x,old_y=cursor_y;last_key=now;
            for(i=0;i<5;++i) {
                unsigned bit=1U<<i;
                if((sample&bit)!=(candidate&bit)){candidate^=bit;debounce[i]=0;}
                else if(debounce[i]<3U)++debounce[i];
                if(debounce[i]==3U && (stable&bit)!=(candidate&bit)) {
                    stable^=bit;held[i]=0;if(stable&bit)fired|=bit;
                }
                if(i<4 && (stable&bit)) {
                    if(held[i]<65535U)++held[i];
                    if(held[i]==80U || (held[i]>80U && held[i]%16U==0))fired|=bit;
                }
            }
            if((fired&1U) && cursor_y>=8U)cursor_y-=8U;
            if((fired&2U) && cursor_y+8U<DB_HEIGHT)cursor_y+=8U;
            if((fired&4U) && cursor_x>=8U)cursor_x-=8U;
            if((fired&8U) && cursor_x+8U<DB_WIDTH)cursor_x+=8U;
            if(old_x!=cursor_x || old_y!=cursor_y){++cursor_sequence;last_state=0;}
            key_capture=(fired&16U)!=0;
        }
        /* Both controls request one fresh stereo exposure and its own range.
         * Consume a simultaneous touch/key once; held keys stay debounced.
         * Preserve physical-key range/voice if the local LCD backend failed. */
        db_hdmi_nav_control(&control,now,(unsigned)db_screen_take_hdmi_switch());
        if(db_screen_take_mode_switch()) {
            if(!controls_busy && !voice_async_busy() && db_screen_set_mode(mode^1U)) {
                mode^=1U;capture_mode=mode;
                have_face_detection=live_command_active=have_live_result=have_identity_result=access_reported=0;
                memset(&identity_result,0,sizeof(identity_result));memset(&live_result,0,sizeof(live_result));
                voice_pending_mm=0;access_voice_pending=VOICE_ACCESS_CLIP_COUNT;
                db_access_init(&access_state);if(keys_available)XGpio_DiscreteWrite(&keys,2,0U);
                if(audio_available)notice_pending=mode==DB_MODE_DISTANCE?VOICE_NOTICE_DISTANCE_MODE:VOICE_NOTICE_FACE_MODE;
                db_log("MODE selected=%s\r\n",mode==DB_MODE_DISTANCE?"distance":"face");
                controls_busy=1;key_capture=0;
            } else db_log("MODE switch rejected: capture/audio busy\r\n");
        }
        touch_capture=(unsigned)db_screen_take_capture();
        /* A preview tap finishes before rearming for the requested photograph.
         * Keep the user event, without falling back to range-only operation. */
        if(!controls_busy && (key_capture || touch_capture) && db_screen_preview_busy()){
            queued_capture=1;key_capture=touch_capture=0;
        }
        if(queued_capture && !db_screen_preview_busy()){
            if(!controls_busy){key_capture=1;queued_capture=0;}
        }
        if(key_capture || touch_capture) {
            unsigned owned=photo_raw.state!=FREE;
            for(i=0;i<3;++i)if(output[i].photo && output[i].state!=FREE)owned=1;
            if(!controls_busy && !fatal && !owned && !request.active && !voice_pending_mm && peer_ready) {
                db_log("SCREEN capture trigger key=%u touch=%u\r\n",key_capture,touch_capture);
                if(!db_screen_begin(cursor_x,cursor_y,now,db_capture_time_us(&capture))) {
                    db_log("SCREEN capture rejected: backend unavailable or image still owned\r\n");
                    if(key_capture && !db_screen_busy() &&
                       db_control_request_at(&request,cursor_x,cursor_y,now,db_capture_time_us(&capture))) {
                        capture_mode=DB_MODE_DISTANCE;last_request=0;db_log("SCREEN physical-key fallback: distance and voice only\r\n");
                    }
                } else {
                    capture_active=1;capture_mode=mode;
                    have_face_detection=live_command_active=have_live_result=have_identity_result=access_reported=0;
                    memset(&identity_result,0,sizeof(identity_result));memset(&live_result,0,sizeof(live_result));
                    db_log("MODE capture=%s\r\n",capture_mode==DB_MODE_DISTANCE?"distance":"face");
                }
            } else db_log("SCREEN capture rejected: fatal=%u owned=%u request=%u voice=%u peer=%u\r\n",
                fatal,owned,request.active,voice_pending_mm!=0,peer_ready);
        }
        if(photo_raw.state==FREE && db_screen_raw_ready(photo_raw.image,photo_raw.stamp)) {
            if(++db_frame_id==0)++db_frame_id;
            photo_raw.frame=db_frame_id;photo_raw.photo=1;
            if(db_screen_set_frame(photo_raw.frame)) {
                size_t rgb_bytes=0;const uint8_t *rgb=db_screen_image(0,&rgb_bytes);
                photo_raw.state=READY;
                if(capture_mode==DB_MODE_FACE && db_face_pipeline_available(&face_pipeline) && !face_image_locked &&
                   rgb && rgb_bytes==DB_IMAGE_BYTES*3U && db_screen_image_lock(photo_raw.frame)) {
                    if(db_face_pipeline_begin(&face_pipeline,photo_raw.frame,rgb,
                       DB_WIDTH,DB_HEIGHT,DB_WIDTH*3U,now)) {
                        face_image_locked=1;have_face_detection=live_command_active=have_live_result=0;
                        have_identity_result=access_reported=0;memset(&identity_result,0,sizeof(identity_result));
                    }
                    else {db_screen_image_release();db_rgb_screen_identity(photo_raw.frame,0,0,0);}
                } else if(capture_mode==DB_MODE_FACE)db_rgb_screen_identity(photo_raw.frame,0,0,0);
            }
            else db_screen_fail();
        }
        db_hdmi_nav_poll(now,db_capture_time_us(&capture),
            peer_ready && !fatal && !controls_busy && !queued_capture && !key_capture && !touch_capture && !capture_active);
        if(peer_ready && (uint32_t)(now-last_state)>=DB_CONTROL_RETRY_US) {
            state.id=cursor_sequence;state.x=(uint16_t)cursor_x;state.y=(uint16_t)cursor_y;
            if(db_control_net_send(&control,&state))last_state=now;
        }
        if(peer_ready && request.active && (uint32_t)(now-last_request)>=DB_CONTROL_RETRY_US)
            if(db_control_net_send(&control,&request.request))last_request=now;
        if(sending) {
            db_tx_poll_chunks(&sender,8,db_net_send_chunk,&network);
            if(!sender.active && db_net_tx_idle(&network)){sending->state=FREE;sending=NULL;++sent;}
        }
        /* Browsing color does not need a second full-rate depth stream. Drain
         * existing DMA/rectifier/transmit ownership normally. Any photo,
         * identity/liveness or voice task retains the original depth service. */
        if(!fatal && !copying && peer_ready && flight.count<DB_FLIGHT_CAPACITY &&
           (!db_hdmi_nav_color_active(now) || controls_busy || capture_active ||
            queued_capture || request.active)) {
            unsigned queued=0;
            for(i=0;i<3;++i)if(raw[i].state==READY)queued=1;
            if(!queued)for(i=0;i<3;++i)if(raw[i].state==FREE) {
                int begun=db_capture_begin(&capture,raw[i].image[0],raw[i].image[1]);
                if(begun<0){fatal=1;db_log("FATAL: capture channel stopped or bus fault; reset required\r\n");}
                else if(begun) {
                    copying=&raw[i];copying->state=COPYING;
                }
                break;
            }
        }
        if(copying && !fatal) {
            int ready=db_capture_poll(&capture);
            if(ready==-2){fatal=1;db_log("FATAL: capture/DMA ownership fault; reset required\r\n");}
            else if(ready<0){copying->state=FREE;copying=NULL;++aborted;}
            else if(ready) {
                if(++db_frame_id==0)++db_frame_id;
                copying->frame=db_frame_id;
                for(c=0;c<2;++c)copying->stamp[c]=capture.stamp[c];
                copying->state=READY;copying=NULL;++copied;
            }
        }
        if(!fatal && !working_raw) {
            Pair *latest=photo_raw.state==READY?&photo_raw:NULL,*free_out=NULL;
            for(i=0;i<3;++i) {
                if(raw[i].state==READY && (!latest || (!latest->photo && (int32_t)(raw[i].frame-latest->frame)>0)))latest=&raw[i];
                if(output[i].state==FREE && !free_out)free_out=&output[i];
            }
            if(latest && free_out) {
                working_raw=latest;working_out=free_out;latest->state=RECTIFYING;free_out->state=RECTIFYING;
                free_out->frame=latest->frame;
                free_out->photo=latest->photo;
                for(c=0;c<2;++c) {
                    free_out->stamp[c]=latest->stamp[c];done[c]=0;
                    XRectify_accel_Set_source(&engine[c],(u32)latest->image[c]);
                    XRectify_accel_Set_map_r(&engine[c],(u32)(c?db_map_right:db_map_left));
                    XRectify_accel_Set_destination(&engine[c],(u32)free_out->image[c]);
                    XRectify_accel_Set_valid_mask(&engine[c],(u32)free_out->mask[c]);
                    XRectify_accel_Start(&engine[c]);
                }
                rect_started=db_time_us();
            }
        }
        if(working_raw && !fatal) {
            if(working_out->state==RECTIFYING) {
                for(c=0;c<2;++c)if(!done[c])done[c]=XRectify_accel_IsDone(&engine[c]);
                if(done[0] && done[1]) {
                    unsigned errors=XRectify_accel_Get_errors(&engine[0])|XRectify_accel_Get_errors(&engine[1]);
                    last_rect_us=(uint32_t)(db_time_us()-rect_started);
                    if(errors){if(working_raw->photo)db_screen_fail();working_raw->state=working_out->state=FREE;working_raw=NULL;working_out=NULL;++aborted;}
                    else {working_out->state=INVALIDATING;db_cache_begin(&invalidate,working_out->image[0],working_out->image[1],1);}
                /* rect_started may be later than the loop-entry 'now'. */
                } else if((uint32_t)(db_time_us()-rect_started)>500000U) {
                    fatal=1;db_log("FATAL: rectifier timeout; AXI-owned buffers retained until reset\r\n");
                }
            } else if(db_cache_poll(&invalidate)) {
                working_raw->state=FREE;working_out->state=READY;working_raw=NULL;working_out=NULL;++rectified;
            }
        }
        if(!fatal && peer_ready && !sending && db_flight_available(&flight,now)) {
            Pair *latest=NULL;
            for(i=0;i<3;++i)if(output[i].state==READY && (!latest ||
                (output[i].photo && !latest->photo) ||
                (output[i].photo==latest->photo && (int32_t)(output[i].frame-latest->frame)>0)))latest=&output[i];
            /* Submit the exact-frame command before its image packets. The AX
             * then reserves that frame instead of matching a later live frame. */
            if(latest && latest->photo) {
                const DbPhoto *p=db_screen_photo();
                uint32_t stamp=(int32_t)(latest->stamp[0]-latest->stamp[1])<=0?latest->stamp[0]:latest->stamp[1];
                if(p->state==DB_PHOTO_READY && !request.active) {
                    if(db_control_request_frame(&request,p->x,p->y,now,latest->frame,stamp)) {
                        db_screen_bind(&request.request);last_request=0;photo_command_acked=0;
                    }
                }
                if(!request.active || request.request.type!=DB_CTRL_PHOTO_REQUEST || request.request.frame!=latest->frame) {
                    latest->state=FREE;latest=NULL;
                } else if(!last_request) {
                    if(db_control_net_send(&control,&request.request))last_request=now;
                    else latest=NULL;
                }
                if(latest && photo_command_acked!=latest->frame)latest=NULL;
            }
            if(latest && db_net_prepare_tx(&network,latest->image[0],latest->image[1]) &&
               db_tx_begin(&sender,DB_RECTIFIED,session,latest->frame,DB_CALIBRATION_ID,
                   latest->image[0],latest->image[1],latest->stamp[0],latest->stamp[1])) {
                for(i=0;i<3;++i)if(output[i].state==READY && &output[i]!=latest && !output[i].photo){output[i].state=FREE;++dropped;}
                db_flight_sent(&flight,latest->frame,now);latest->state=SENDING;sending=latest;
            }
        }
        if((uint32_t)(now-last_report)>=1000000U) {
            last_report=now;
            db_log("ONE_WAY_NAV copied=%lu rectified=%lu sent=%lu rectify_us=%lu aborted=%lu dropped=%lu flight=%lu peer=%lu session=%08lx\r\n",
                (unsigned long)copied,(unsigned long)rectified,(unsigned long)sent,(unsigned long)last_rect_us,
                (unsigned long)aborted,(unsigned long)dropped,(unsigned long)flight.count,(unsigned long)peer_ready,(unsigned long)session);
            db_net_report(&network);audio_poll(&audio_available);
            if(fatal || capture.resyncing)db_log("CAPTURE_STATE fatal=%u resync=%u recoveries=%lu active=%u phase=%u\r\n",
                fatal,capture.resyncing,(unsigned long)capture.recoveries,capture.active,capture.phase);
        }
    }
}

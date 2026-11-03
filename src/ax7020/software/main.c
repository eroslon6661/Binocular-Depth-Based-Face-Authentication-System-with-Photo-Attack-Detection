#include "db_config.h"
#include "db_net.h"
#include "db_log.h"
#include "db_crc_amp.h"
#include "db_cache_job.h"
#include "db_match.h"
#include "db_liveness.h"
#include "db_live_evidence.h"
#include "db_control_net.h"
#include "db_photo.h"
#include "db_hdmi_ax.h"
#include "xaxivdma.h"
#include "xaxivdma_hw.h"
#include "xgpio.h"
#include "xil_cache.h"
#include "xil_io.h"
#include "xparameters.h"
#include "display_ctrl_hdmi/display_ctrl_hdmi.h"
#include "vdma_api/vdma_api.h"
#include <string.h>
extern const uint8_t db_mask_left[],db_mask_right[];
#define RGB_BYTES (DB_IMAGE_BYTES*3U)
#define RGB_STRIDE (DB_WIDTH*3U)
#define ROI_X 128U
#define ROI_Y 16U
#define ROI_W 1024U
#define ROI_H 640U
#define LIVE_LEFT ((uint8_t *)(DB_WORKER_OUTPUT_BASE+4U*DB_IMAGE_BYTES))
#define LIVE_RIGHT ((uint8_t *)(DB_WORKER_OUTPUT_BASE+5U*DB_IMAGE_BYTES))
#define LIVE_DISP_RGB ((uint8_t *)(DB_WORKER_OUTPUT_BASE+8U*DB_IMAGE_BYTES))
#define LIVE_SAMPLES 3U
#define SG_TAGS 8U
/* Canonical XPAR_AXIVDMA_n aliases change when board peripherals are removed.
 * Select the named HDMI instance, and reject a mismatched BSP at compile time. */
#if !XPAR_AXI_VDMA_2_INCLUDE_MM2S || XPAR_AXI_VDMA_2_M_AXIS_MM2S_TDATA_WIDTH != 24U
#error "HDMI requires the named axi_vdma_2 RGB888 read channel"
#endif
#if XPAR_AXI_VDMA_2_DEVICE_ID == XPAR_SGBM_RESULT_VDMA_DEVICE_ID
#error "HDMI reader and SGBM result writer must be distinct instances"
#endif
static XAxiVdma reader[2],result_dma,display;
static XGpio overlay_gpio;
static DisplayCtrl hdmi;
static DbReceiver receiver;
static DbNet network;
static DbControlNet control;
static DbMatch measurement;
static unsigned cursor_x=640,cursor_y=360;
static uint32_t recent[3];static unsigned recent_count,recent_next;
static unsigned smooth(unsigned mm)
{
    uint32_t a,b,c;recent[recent_next]=mm;recent_next=(recent_next+1U)%3U;
    if(recent_count<3)++recent_count;
    if(recent_count<3)return recent[0];
    a=recent[0];b=recent[1];c=recent[2];
    if(a>b){uint32_t t=a;a=b;b=t;}if(b>c){uint32_t t=b;b=c;c=t;}return a>b?a:b;
}
static unsigned overlay_mm,overlay_mode;
static void overlay(unsigned mm)
{
    unsigned cm=(mm+5U)/10U;overlay_mm=mm;
    if(db_hdmi_ax_mode()){XGpio_DiscreteWrite(&overlay_gpio,2,0);return;}
    XGpio_DiscreteWrite(&overlay_gpio,2,cursor_x|(cursor_y<<11)|(1U<<21)|((cm>1022U?1022U:cm)<<22));
}
static unsigned writer_store(XAxiVdma *v)
{return (Xil_In32(v->BaseAddr+XAXIVDMA_PARKPTR_OFFSET)&XAXIVDMA_PARKPTR_WRTSTR_MASK)>>24;}
static unsigned reader_store(XAxiVdma *v)
{return (Xil_In32(v->BaseAddr+XAXIVDMA_PARKPTR_OFFSET)&XAXIVDMA_PARKPTR_READSTR_MASK)>>16;}
static int init_vdma(XAxiVdma *v,unsigned id)
{
    XAxiVdma_Config *c=XAxiVdma_LookupConfig(id);
    return c && XAxiVdma_CfgInitialize(v,c,c->BaseAddress)==XST_SUCCESS;
}
static int read_one(XAxiVdma *v,const uint8_t *pixels)
{
    XAxiVdma_DmaSetup cfg;XAxiVdma_FrameCounter count;unsigned i;
    memset(&cfg,0,sizeof(cfg));memset(&count,0,sizeof(count));
    cfg.VertSizeInput=DB_HEIGHT;cfg.HoriSizeInput=cfg.Stride=DB_WIDTH;
    cfg.EnableFrameCounter=1;cfg.EnableCircularBuf=0;cfg.EnableSync=0;
    for(i=0;i<3;++i)cfg.FrameStoreStartAddr[i]=(UINTPTR)pixels;
    count.ReadFrameCount=count.WriteFrameCount=1;
    return XAxiVdma_SetFrameCounter(v,&count)==XST_SUCCESS &&
       XAxiVdma_DmaConfig(v,XAXIVDMA_READ,&cfg)==XST_SUCCESS &&
       XAxiVdma_DmaSetBufferAddr(v,XAXIVDMA_READ,cfg.FrameStoreStartAddr)==XST_SUCCESS &&
       XAxiVdma_DmaStart(v,XAXIVDMA_READ)==XST_SUCCESS;
}
static int video_init(void)
{
    memset((void *)DB_RESULT_BASE,0,3U*RGB_BYTES);Xil_DCacheFlushRange(DB_RESULT_BASE,3U*RGB_BYTES);
    if(run_vdma_frame_buffer(&result_dma,XPAR_SGBM_RESULT_VDMA_DEVICE_ID,
       DB_WIDTH,DB_HEIGHT,DB_RESULT_BASE,0,0,ONLY_WRITE,RGB_STRIDE,RGB_BYTES,0)!=XST_SUCCESS ||
       run_vdma_frame_buffer(&display,XPAR_AXI_VDMA_2_DEVICE_ID,
       ROI_W,ROI_H,DB_RESULT_BASE,0,0,ONLY_READ,RGB_STRIDE,RGB_BYTES,(ROI_Y*DB_WIDTH+ROI_X)*3U)!=XST_SUCCESS)return 0;
    if(DisplayInitialize(&hdmi,XPAR_VTC_0_DEVICE_ID)!=XST_SUCCESS ||
       DisplaySetMode(&hdmi,&VMODE_1280x720)!=XST_SUCCESS || DisplayStart(&hdmi)!=XST_SUCCESS)return 0;
    if(!init_vdma(&reader[0],XPAR_SGBM_LEFT_VDMA_DEVICE_ID) || !init_vdma(&reader[1],XPAR_SGBM_RIGHT_VDMA_DEVICE_ID) ||
       XGpio_Initialize(&overlay_gpio,XPAR_AXI_GPIO_KEY_DEVICE_ID)!=XST_SUCCESS)return 0;
    XGpio_SetDataDirection(&overlay_gpio,2,0);overlay(0);return 1;
}
static void make_result(DbControl *r,const DbControl *request,uint32_t frame,uint32_t stamp,unsigned status,unsigned mm)
{
    *r=*request;r->type=DB_CTRL_RESULT;r->frame=frame;r->capture_us=stamp;r->status=status;r->distance_mm=mm;
}
static int begin_live_sample(DbLiveness *job,const DbControl *request,uint32_t frame)
{
    DbControl sample=*request;sample.frame=frame;
    return db_liveness_begin(job,LIVE_LEFT,LIVE_RIGHT,db_mask_left,db_mask_right,
        LIVE_DISP_RGB,&sample);
}
int main(void)
{
    uint8_t *images[DB_RX_SLOTS][2];DbSlot *prepared=NULL,*matching=NULL;
    DbCacheJob cache;DbControl msg,hello,active_request,measure_request,response,ack;
    DbControl live_request,live_response;
    static DbLiveness liveness; /* geometry workspace is not on the task stack */
    unsigned sgbm_timeout_latched=0;
    unsigned i,c,fatal=0,have_hello=0,human_pending=0,result_pending=0,measure_human=0;
    unsigned live_photo_ready=0,live_disp_ready=0,live_result_pending=0;
    unsigned live_sequence_active=0,live_wait_next=0,live_candidate_inflight=0;
    unsigned live_samples=0,live_passes=0,live_valid_samples=0;
    unsigned live_photo_evidence=0,live_first_geometry=DB_GEOM_UNKNOWN;
    unsigned live_sum_dense=0,live_sum_lr=0,live_sum_votes=0;
    int32_t live_sum_rms_q8=0,live_sum_nose_q8=0,live_sum_ne_q8=0,live_sum_nc_q8=0;
    uint32_t live_sum_mm=0,live_min_mm=0xffffffffU,live_max_mm=0;
    uint32_t last_state_id=0,last_request_id=0,request_started=0,response_sent=0,response_started=0;
    uint32_t measure_stamp=0,last_ack=0,last_report=0,last_live=0,submitted=0,result_frames=0,hdmi_updates=0;
    uint32_t live_frame=0,live_stamp=0,live_started=0,live_response_sent=0;
    uint32_t live_candidate_frame=0;
    uint32_t sg_frame[SG_TAGS]={0};uint8_t sg_live[SG_TAGS]={0};unsigned sg_head=0,sg_tail=0,sg_count=0;
    uint32_t last_result_store=0,last_display_store=0,acked_frame=0,sg_started=0,last_sg_us=0;
    unsigned measure_x=640,measure_y=360;
    memset(&active_request,0,sizeof(active_request));memset(&response,0,sizeof(response));
    memset(&live_request,0,sizeof(live_request));memset(&live_response,0,sizeof(live_response));memset(&liveness,0,sizeof(liveness));
    db_log("ONE_WAY AX rectified RX -> SGBM -> HDMI; precision measurement local\r\n");
    if(!video_init()){xil_printf("ERROR: video initialization\r\n");return XST_FAILURE;}
    for(i=0;i<DB_RX_SLOTS;++i)for(c=0;c<2;++c)images[i][c]=(uint8_t *)(DB_NETWORK_RX_BASE+(i*2U+c)*DB_IMAGE_BYTES);
    /* Image packets cannot choose a session. Only the explicit control handshake can. */
    db_rx_init(&receiver,0,DB_CALIBRATION_ID,DB_RECTIFIED,DB_TIMEOUT_US,DB_MAX_SKEW_US,images);
    if(!db_crc_amp_init() || !db_net_open(&network,&receiver,1) || !db_control_net_open(&control,&network))return XST_FAILURE;
    db_hdmi_ax_init(&network,&display);
    last_result_store=writer_store(&result_dma);last_display_store=reader_store(&display);
    for(;;) {
        uint32_t now=db_time_us();int crc_done;
        db_log_poll(8);db_net_poll(&network,32);
        db_hdmi_ax_poll(&control,receiver.session,now);
        if(overlay_mode!=db_hdmi_ax_mode()){overlay_mode=db_hdmi_ax_mode();overlay(overlay_mm);}
        crc_done=fatal?0:db_crc_amp_poll();
        if(crc_done<0){fatal=1;db_log("FATAL: receive CRC/AXI fault; buffers reserved until reset\r\n");}
        if(db_control_net_take(&control,DB_CTRL_HELLO,&msg) && msg.calibration==DB_CALIBRATION_ID){hello=msg;have_hello=1;}
        if(matching && !XAxiVdma_IsBusy(&reader[0],XAXIVDMA_READ) && !XAxiVdma_IsBusy(&reader[1],XAXIVDMA_READ)) {
            last_sg_us=(uint32_t)(db_time_us()-sg_started);acked_frame=matching->frame;
            db_rx_release(matching);matching=NULL;last_ack=0;
            /* A debugger/long CPU service gap can latch a timeout before
             * the next completion poll. Only that timeout may recover,
             * after BOTH readers have released ownership and every involved
             * DMA channel reports no hardware error. Keep output tags intact. */
            if(sgbm_timeout_latched &&
               !XAxiVdma_GetDmaChannelErrors(&reader[0],XAXIVDMA_READ) &&
               !XAxiVdma_GetDmaChannelErrors(&reader[1],XAXIVDMA_READ) &&
               !XAxiVdma_GetDmaChannelErrors(&result_dma,XAXIVDMA_WRITE)) {
                sgbm_timeout_latched=0;fatal=0;
                db_log("SGBM recovered: late input DMA completion, no hardware errors\r\n");
            }
        }
        if(have_hello) {
            if(hello.session==receiver.session) {
                msg=hello;msg.type=DB_CTRL_HELLO_ACK;
                if(db_control_net_send(&control,&msg))have_hello=0;
            } else if(!matching && !db_crc_amp_busy() && !fatal) {
                if(prepared){db_rx_release(prepared);prepared=NULL;}
                db_rx_init(&receiver,hello.session,DB_CALIBRATION_ID,DB_RECTIFIED,DB_TIMEOUT_US,DB_MAX_SKEW_US,images);
                receiver.defer_crc=(uint8_t)db_crc_amp_enabled();
                measurement.active=0;human_pending=result_pending=0;
                liveness.active=live_photo_ready=live_disp_ready=live_result_pending=0;
                live_sequence_active=live_wait_next=live_candidate_inflight=0;
                live_samples=live_passes=live_valid_samples=0;live_photo_evidence=0;live_first_geometry=DB_GEOM_UNKNOWN;sg_head=sg_tail=sg_count=0;
                last_state_id=last_request_id=acked_frame=0;recent_count=recent_next=0;overlay(0);
                msg=hello;msg.type=DB_CTRL_HELLO_ACK;
                if(db_control_net_send(&control,&msg))have_hello=0;
            }
        }
        if(db_control_net_take(&control,DB_CTRL_STATE,&msg) && msg.session==receiver.session &&
           msg.calibration==DB_CALIBRATION_ID && (!last_state_id || (int32_t)(msg.id-last_state_id)>=0)) {
            if(cursor_x!=msg.x || cursor_y!=msg.y){cursor_x=msg.x;cursor_y=msg.y;recent_count=recent_next=0;overlay(0);}
            last_state_id=msg.id;
        }
        if((db_control_net_take(&control,DB_CTRL_REQUEST,&msg) ||
            db_control_net_take(&control,DB_CTRL_PHOTO_REQUEST,&msg)) &&
           msg.session==receiver.session && msg.calibration==DB_CALIBRATION_ID) {
            if(!last_request_id || (int32_t)(msg.id-last_request_id)>0) {
                active_request=msg;last_request_id=msg.id;request_started=now;human_pending=1;result_pending=0;
                db_log("MEASURE request=%lu cursor=%lu,%lu\r\n",(unsigned long)msg.id,(unsigned long)msg.x,(unsigned long)msg.y);
            } else if(msg.id==last_request_id && db_control_same_request(&active_request,&msg) && result_pending)response_sent=0;
            if(msg.type==DB_CTRL_PHOTO_REQUEST && db_control_same_request(&active_request,&msg)) {
                DbControl accepted=msg;accepted.type=DB_CTRL_PHOTO_ACK;db_control_net_send(&control,&accepted);
            }
        }
        if(db_control_net_take(&control,DB_CTRL_LIVE_REQUEST,&msg) &&
           msg.session==receiver.session && msg.calibration==DB_CALIBRATION_ID) {
            if(live_result_pending && msg.id==live_response.id && msg.frame==live_response.frame)live_response_sent=0;
            else if(!live_sequence_active&&!liveness.active) {
                if(live_photo_ready && msg.frame==live_frame && msg.capture_us==live_stamp) {
                    live_request=msg;live_result_pending=0;live_sequence_active=1;live_wait_next=0;
                    live_samples=live_passes=live_valid_samples=0;live_photo_evidence=0;live_first_geometry=DB_GEOM_UNKNOWN;live_sum_dense=live_sum_lr=live_sum_votes=0;
                    live_sum_rms_q8=live_sum_nose_q8=live_sum_ne_q8=live_sum_nc_q8=0;
                    live_sum_mm=0;live_min_mm=0xffffffffU;live_max_mm=0;live_started=now;
                    if(live_disp_ready&&begin_live_sample(&liveness,&live_request,live_frame))
                        db_log("LIVE sequence begin frame=%lu center=%u,%u\r\n",(unsigned long)msg.frame,msg.x,msg.y);
                    else db_log("LIVE sequence waiting for exact disparity frame=%lu\r\n",(unsigned long)msg.frame);
                } else {
                    live_response=msg;live_response.type=DB_CTRL_LIVE_RESULT;live_response.status=DB_CTRL_INVALID;
                    live_result_pending=1;live_response_sent=0;
                    db_log("LIVE rejected frame=%lu stored=%lu ready=%u\r\n",
                        (unsigned long)msg.frame,(unsigned long)live_frame,live_photo_ready);
                }
            }
        }
        if(db_control_net_take(&control,DB_CTRL_LIVE_ACK,&msg) && live_result_pending &&
           msg.session==live_response.session && msg.id==live_response.id &&
           msg.frame==live_response.frame && msg.status==live_response.status)live_result_pending=0;
        if(live_result_pending && (uint32_t)(now-live_response_sent)>=DB_CONTROL_RETRY_US)
            if(db_control_net_send(&control,&live_response))live_response_sent=now;
        if(live_sequence_active && (uint32_t)(now-live_started)>9000000U) {
            live_response=live_request;live_response.type=DB_CTRL_LIVE_RESULT;live_response.status=DB_CTRL_TIMEOUT;
            live_response.data[4]=(uint16_t)live_samples;live_response.data[5]=(uint16_t)live_passes;
            live_sequence_active=live_wait_next=live_candidate_inflight=liveness.active=0;
            live_result_pending=1;live_response_sent=0;db_log("LIVE sequence timeout samples=%u pass=%u\r\n",live_samples,live_passes);
        }
        if(db_control_net_take(&control,DB_CTRL_RESULT_ACK,&msg) && result_pending &&
           msg.session==response.session && msg.calibration==response.calibration && msg.id==response.id &&
           msg.frame==response.frame && msg.x==response.x && msg.y==response.y &&
           msg.capture_us==response.capture_us && msg.distance_mm==response.distance_mm && msg.status==response.status)result_pending=0;
        if(result_pending && (uint32_t)(now-response_sent)>=DB_CONTROL_RETRY_US) {
            if(db_control_net_send(&control,&response))response_sent=now;
            if((uint32_t)(now-response_started)>2000000U)result_pending=0;
        }
        if(acked_frame && (uint32_t)(now-last_ack)>=DB_CONTROL_RETRY_US) {
            memset(&ack,0,sizeof(ack));ack.type=DB_CTRL_FRAME_ACK;ack.session=receiver.session;
            ack.calibration=DB_CALIBRATION_ID;ack.id=ack.frame=acked_frame;ack.x=640;ack.y=360;
            if(db_control_net_send(&control,&ack))last_ack=now;
        }
        if(human_pending && (uint32_t)(now-request_started)>=DB_CONTROL_REQUEST_TIMEOUT_US) {
            make_result(&response,&active_request,0,active_request.capture_us,DB_CTRL_TIMEOUT,0);
            human_pending=0;result_pending=1;response_sent=0;response_started=now;
        }
        if(!fatal)db_crc_amp_schedule_rx(&receiver,0);
        if(!fatal && human_pending && active_request.type==DB_CTRL_PHOTO_REQUEST)
            db_photo_acquire(&receiver,active_request.frame,0);
        if(!fatal && !have_hello && !matching && !prepared) {
            DbSlot *pair=NULL;
            /* Do not let newest-frame selection discard the named photo. */
            if(human_pending && active_request.type==DB_CTRL_PHOTO_REQUEST) {
                pair=db_photo_acquire(&receiver,active_request.frame,!measurement.active);
            }
            if(!pair && !(human_pending && active_request.type==DB_CTRL_PHOTO_REQUEST))pair=db_rx_acquire_latest(&receiver);
            if(pair) {
                unsigned fresh=(uint32_t)(now-pair->first_us)<=DB_FRESH_US;
                if(fresh&&live_sequence_active&&live_wait_next&&!liveness.active&&!live_candidate_inflight) {
                    memcpy(LIVE_LEFT,pair->image[0],DB_IMAGE_BYTES);memcpy(LIVE_RIGHT,pair->image[1],DB_IMAGE_BYTES);
                    live_candidate_frame=pair->frame;
                    live_candidate_inflight=1;live_wait_next=0;
                    db_log("LIVE follow-up retained frame=%lu sample=%u\r\n",(unsigned long)pair->frame,live_samples+1U);
                }
                if(!measurement.active && fresh) {
                    unsigned human=human_pending && db_control_pair_eligible(&active_request,pair->frame,pair->capture_us[0],pair->capture_us[1]);
                    if(human || (!human_pending && !result_pending && (uint32_t)(now-last_live)>=150000U)) {
                        unsigned x=human?active_request.x:cursor_x,y=human?active_request.y:cursor_y;
                        unsigned px=ROI_X+x*ROI_W/DB_WIDTH,py=ROI_Y+y*ROI_H/DB_HEIGHT;
                        measure_human=human;measure_x=x;measure_y=y;measure_request=active_request;last_live=now;
                        measure_stamp=(int32_t)(pair->capture_us[0]-pair->capture_us[1])<=0?pair->capture_us[0]:pair->capture_us[1];
                        if(human && active_request.type==DB_CTRL_PHOTO_REQUEST) {
                            memcpy(LIVE_LEFT,pair->image[0],DB_IMAGE_BYTES);memcpy(LIVE_RIGHT,pair->image[1],DB_IMAGE_BYTES);
                            live_frame=pair->frame;live_stamp=measure_stamp;live_photo_ready=1;live_disp_ready=0;
                            live_candidate_frame=pair->frame;live_candidate_inflight=1;
                            db_log("LIVE exact frame retained frame=%lu\r\n",(unsigned long)live_frame);
                        }
                        if(human)human_pending=0;
                        if(!db_match_begin(&measurement,pair->image[0],pair->image[1],db_mask_left,db_mask_right,px,py,pair->frame)) {
                            if(human) {
                                make_result(&response,&active_request,pair->frame,measure_stamp,DB_CTRL_INVALID,0);
                                result_pending=1;response_sent=0;response_started=now;
                            }
                            if(x==cursor_x && y==cursor_y)overlay(0);
                        }
                    }
                }
                prepared=pair;db_cache_begin(&cache,pair->image[0],pair->image[1],0);
            }
        }
        if(!fatal && prepared && (prepared->dma_clean || db_cache_poll(&cache))) {
            /* Preserve the validated hardware stream order and right-reference geometry. */
            if(!read_one(&reader[0],prepared->image[1]) || !read_one(&reader[1],prepared->image[0])) {
                fatal=1;db_log("FATAL: SGBM reader start; partially DMA-owned images retained\r\n");
            } else if(sg_count>=SG_TAGS) {
                fatal=1;db_log("FATAL: SGBM result tag queue overflow\r\n");
            } else {
                sg_frame[sg_tail]=prepared->frame;
                sg_live[sg_tail]=(uint8_t)(live_candidate_inflight&&prepared->frame==live_candidate_frame);
                sg_tail=(sg_tail+1U)%SG_TAGS;++sg_count;
                matching=prepared;prepared=NULL;++submitted;sg_started=db_time_us();
            }
        }
        /* SGBM can start after the loop-entry timestamp was sampled. */
        if(!fatal && matching && (uint32_t)(db_time_us()-sg_started)>500000U) {
            sgbm_timeout_latched=1;fatal=1;db_log("SGBM DMA timeout: hold buffers; await error-free completion\r\n");
        }
        if(measurement.active && db_match_poll(&measurement,1,db_q,DB_MAX_DISTANCE_MM)) {
            unsigned mm=measurement.reliable?measurement.distance_mm:0;
            unsigned x=measure_x,y=measure_y;
            if(measure_human && measure_request.id==active_request.id) {
                make_result(&response,&measure_request,measurement.frame,measure_stamp,mm?DB_CTRL_OK:DB_CTRL_INVALID,mm);
                result_pending=1;response_sent=0;response_started=now;
                db_log("MEASURE FINAL frame=%lu distance=%lu mm disp_x16=%lu\r\n",(unsigned long)measurement.frame,
                    (unsigned long)mm,(unsigned long)measurement.disparity_x16);
            }
            if(x==cursor_x && y==cursor_y)overlay(mm?(measure_human?mm:smooth(mm)):0);
        }
        if(liveness.active && db_liveness_poll(&liveness,8U)) {
            int rms=(int)(liveness.plane_rms_px*256.0f+0.5f);
            int nose=(int)(liveness.nose_relief_px*256.0f+(liveness.nose_relief_px>=0.0f?0.5f:-0.5f));
            int ne=(int)(liveness.nose_eye_px*256.0f+(liveness.nose_eye_px>=0.0f?0.5f:-0.5f));
            int nc=(int)(liveness.nose_cheek_px*256.0f+(liveness.nose_cheek_px>=0.0f?0.5f:-0.5f));
            unsigned sample_valid=liveness.distance_mm>=450U&&liveness.distance_mm<=1400U&&
                liveness.surface_valid&&liveness.geometry.result!=DB_GEOM_UNKNOWN;
            if(!live_samples)live_first_geometry=liveness.geometry.result;
            if(sample_valid&&liveness.geometry.result==DB_GEOM_FLAT)++live_photo_evidence;
            ++live_samples;if(sample_valid){++live_valid_samples;live_sum_mm+=liveness.distance_mm;
                if(liveness.distance_mm<live_min_mm)live_min_mm=liveness.distance_mm;
                if(liveness.distance_mm>live_max_mm)live_max_mm=liveness.distance_mm;}
            if(sample_valid&&liveness.live)++live_passes;
            live_sum_dense+=liveness.dense_valid;live_sum_lr+=liveness.lr_consistent;live_sum_votes+=liveness.regional_votes;
            live_sum_rms_q8+=rms;live_sum_nose_q8+=nose;live_sum_ne_q8+=ne;live_sum_nc_q8+=nc;
            db_log("LIVE sample=%u frame=%lu pass=%u distance=%lu lr=%u dense=%u/%u rms_q8=%d nose_q8=%d ne_q8=%d nc_q8=%d votes=%u\r\n",
                live_samples,(unsigned long)liveness.frame,sample_valid&&liveness.live,
                (unsigned long)liveness.distance_mm,liveness.lr_consistent,liveness.dense_valid,liveness.dense_total,
                rms,nose,ne,nc,liveness.regional_votes);
            db_log("GEOM frame=%lu result=%u matches=%u complete=%u nose20_q8=%d nose30_q8=%d ref20_q8=%u ref30_q8=%u\r\n",
                (unsigned long)liveness.frame,liveness.geometry.result,liveness.geometry.valid,liveness.geometry.complete,
                (int)(liveness.geometry.relief[0]*256),(int)(liveness.geometry.relief[1]*256),
                (unsigned)(liveness.geometry.ref_rms[0]*256),(unsigned)(liveness.geometry.ref_rms[1]*256));
            db_log("GEOM detail frame=%lu retry=%u reason=%u first_reason=%u first_matches=%u work=%u nose_mm_x10=%d,%d\r\n",
                (unsigned long)liveness.frame,liveness.geometry.retry,liveness.geometry.reason,
                liveness.geometry.first_reason,liveness.geometry.first_valid,liveness.geometry.work,
                (int)(liveness.geometry.relief_mm[0]*10),(int)(liveness.geometry.relief_mm[1]*10));
            if(live_samples<LIVE_SAMPLES&&live_first_geometry==DB_GEOM_FACE&&!live_photo_evidence){live_wait_next=1;}
            else {
                unsigned consistent=live_valid_samples>=2U&&live_max_mm>=live_min_mm&&live_max_mm-live_min_mm<=200U;
                live_response=live_request;live_response.type=DB_CTRL_LIVE_RESULT;
                live_response.distance_mm=live_valid_samples?live_sum_mm/live_valid_samples:0;
                live_response.data[0]=(uint16_t)(live_sum_dense/live_samples);
                live_response.data[1]=(uint16_t)(live_sum_rms_q8/live_samples);
                live_response.data[2]=(uint16_t)(int16_t)(live_sum_nose_q8/(int)LIVE_SAMPLES);
                /* Sequence-wide local cross-check count.  Dense shape is
                 * evaluated per frame, while texture anchors may occur in any
                 * one of the three frames. */
                live_response.data[3]=(uint16_t)live_sum_lr;
                live_response.data[4]=(uint16_t)live_samples;live_response.data[5]=(uint16_t)live_passes;
                live_response.data[6]=(uint16_t)(int16_t)(live_sum_ne_q8/(int)LIVE_SAMPLES);
                live_response.data[7]=(uint16_t)(int16_t)(live_sum_nc_q8/(int)LIVE_SAMPLES);
                live_response.data[8]=(uint16_t)(live_valid_samples?live_max_mm-live_min_mm:0U);
                live_response.data[9]=(uint16_t)live_sum_votes;
                /* Noisy or insufficient depth is not a spoof label. Only independently
                 * matched flat geometry may produce the photo-attack status. */
                live_response.status=db_live_evidence_status(live_first_geometry,live_valid_samples,
                    live_passes,live_photo_evidence,consistent?live_max_mm-live_min_mm:0xffffffffU);
                live_result_pending=1;live_response_sent=0;live_sequence_active=live_wait_next=0;
                db_log("LIVE FINAL frame=%lu status=%lu samples=%u pass=%u consistent=%u distance=%lu time_us=%lu\r\n",
                    (unsigned long)live_response.frame,(unsigned long)live_response.status,live_samples,live_passes,consistent,
                    (unsigned long)live_response.distance_mm,(unsigned long)(db_time_us()-live_started));
            }
        }
        {
            unsigned store=writer_store(&result_dma),shown=reader_store(&display);
            if(store!=last_result_store){
                unsigned completed_store=last_result_store;++result_frames;
                if(sg_count){
                    uint32_t completed_frame=sg_frame[sg_head];unsigned was_live=sg_live[sg_head];
                    sg_head=(sg_head+1U)%SG_TAGS;--sg_count;
                    if(was_live&&completed_frame==live_candidate_frame){
                        const uint8_t *source=(const uint8_t *)(DB_RESULT_BASE+completed_store*RGB_BYTES);
                        Xil_DCacheInvalidateRange((INTPTR)source,RGB_BYTES);memcpy(LIVE_DISP_RGB,source,RGB_BYTES);
                        live_disp_ready=1;live_candidate_inflight=0;
                        if(live_sequence_active&&!liveness.active&&begin_live_sample(&liveness,&live_request,completed_frame))
                            db_log("LIVE disparity bound frame=%lu sample=%u\r\n",(unsigned long)completed_frame,live_samples+1U);
                    }
                }
                last_result_store=store;
            }
            if(shown!=last_display_store){++hdmi_updates;last_display_store=shown;}
        }
        if((uint32_t)(now-last_report)>=1000000U) {
            last_report=now;
            db_log("ONE_WAY_AX received=%lu verified=%lu submitted=%lu result=%lu hdmi=%lu input_hold_us=%lu rejected=%lu expired=%lu session=%08lx\r\n",
                (unsigned long)receiver.completed,(unsigned long)db_crc_amp_rx_completed,(unsigned long)submitted,
                (unsigned long)result_frames,(unsigned long)hdmi_updates,(unsigned long)last_sg_us,
                (unsigned long)receiver.rejected,(unsigned long)receiver.timed_out,(unsigned long)receiver.session);
            db_net_report(&network);
        }
    }
}

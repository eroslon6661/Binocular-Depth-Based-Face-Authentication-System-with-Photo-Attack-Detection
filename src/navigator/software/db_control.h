#ifndef DB_CONTROL_H
#define DB_CONTROL_H
#include <stdint.h>
#include <stddef.h>
#define DB_CONTROL_BYTES 64U
#define DB_CONTROL_PORT 5002U
#define DB_CONTROL_RETRY_US 50000U
#define DB_CONTROL_FRESH_US 500000U
#define DB_CONTROL_REQUEST_TIMEOUT_US 1500000U
enum {DB_CTRL_HELLO=1,DB_CTRL_HELLO_ACK,DB_CTRL_STATE,DB_CTRL_REQUEST,
      DB_CTRL_RESULT,DB_CTRL_RESULT_ACK,DB_CTRL_FRAME_ACK,DB_CTRL_PHOTO_REQUEST,DB_CTRL_PHOTO_ACK,
      DB_CTRL_LIVE_REQUEST,DB_CTRL_LIVE_RESULT,DB_CTRL_LIVE_ACK,DB_CTRL_DISPLAY_SET,DB_CTRL_DISPLAY_STATUS};
#define DB_CTRL_TYPE_COUNT 15U
enum {DB_CTRL_PENDING=0,DB_CTRL_OK=1,DB_CTRL_INVALID=2,DB_CTRL_TIMEOUT=3,DB_CTRL_SPOOF=4};
typedef struct {
    uint32_t session,calibration,id,frame,capture_us,distance_mm,status;
    uint16_t x,y;
    /* LIVE_REQUEST: five rectified left-image landmarks, x0,y0,...,x4,y4.
     * LIVE_RESULT: dense points, RMS/nose Q8, LR count, sample/pass counts,
     * nose-eye/nose-cheek Q8, distance span and regional-vote count. */
    uint16_t data[10];
    uint8_t type;
} DbControl;
typedef struct {
    uint32_t session,calibration,next_id,started_us;
    unsigned active,have_accepted;
    DbControl request,accepted;
} DbControlClient;
int db_control_encode(uint8_t out[DB_CONTROL_BYTES],const DbControl *message);
int db_control_decode(DbControl *message,const uint8_t *packet,size_t bytes);
void db_control_client_init(DbControlClient *client,uint32_t session,uint32_t calibration);
int db_control_request(DbControlClient *client,unsigned x,unsigned y,uint32_t now);
/* now belongs to ARM timeout time; capture_clock belongs to the PL image tags. */
int db_control_request_at(DbControlClient *client,unsigned x,unsigned y,uint32_t now,uint32_t capture_clock);
/* Photo requests name one immutable frame. Older peers reject this type. */
int db_control_request_frame(DbControlClient *client,unsigned x,unsigned y,uint32_t now,uint32_t frame,uint32_t capture_clock);
/* 1 = newly accepted result; 2 = identical retry to ACK without speaking again. */
int db_control_accept(DbControlClient *client,const DbControl *result,uint32_t capture_clock);
int db_control_expire(DbControlClient *client,uint32_t now);
int db_control_same_request(const DbControl *a,const DbControl *b);
int db_control_frame_eligible(const DbControl *request,uint32_t left_us,uint32_t right_us);
int db_control_pair_eligible(const DbControl *request,uint32_t frame,uint32_t left_us,uint32_t right_us);
int db_control_photo_ack(const DbControl *request,const DbControl *ack);
#endif

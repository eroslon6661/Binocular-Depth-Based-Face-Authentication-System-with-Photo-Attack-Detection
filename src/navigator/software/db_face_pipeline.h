#ifndef DB_FACE_PIPELINE_H
#define DB_FACE_PIPELINE_H

#include <stddef.h>
#include <stdint.h>
#include "db_face_identity.h"

#define DB_FACE_DETECT_SIZE 320U
#define DB_FACE_ALIGN_SIZE 112U
#define DB_FACE_LANDMARKS 5U
#define DB_FACE_PIPELINE_TIMEOUT_US 15000000U

typedef struct {
    float score;
    float x;
    float y;
    float width;
    float height;
    /* left eye, right eye, nose, left mouth, right mouth; source-image pixels */
    float landmark[DB_FACE_LANDMARKS][2];
} DbFaceDetection;

typedef struct {
    uint32_t frame;
    int32_t score_q15;
    unsigned matched;
    unsigned valid;
    unsigned person_id; /* 1 or 2 when matched; 0 otherwise */
} DbFaceResult;

typedef enum {
    DB_FACE_PIPELINE_DISABLED=0,
    DB_FACE_PIPELINE_IDLE,
    DB_FACE_PIPELINE_DETECTING,
    DB_FACE_PIPELINE_EMBEDDING,
    DB_FACE_PIPELINE_DONE,
    DB_FACE_PIPELINE_FAILED
} DbFacePipelineState;

typedef struct {
    DbFacePipelineState state;
    uint32_t frame;
    uint32_t started_us;
    const uint8_t *source_bgr;
    unsigned source_width;
    unsigned source_height;
    unsigned source_stride;
    DbFaceDetection detection;
    unsigned detection_pending;
    DbFaceResult result;
    uint8_t aligned_rgb[DB_FACE_ALIGN_SIZE*DB_FACE_ALIGN_SIZE*3U];
    int8_t embedding[DB_FACE_IDENTITY_DIM];
    uint32_t detected_us;
    uint32_t completed_us;
    uint32_t stage_started_us;
} DbFacePipeline;

/* The selected model pair is asynchronous. begin/poll calls must return
 * promptly so camera, Ethernet and audio servicing continue in main(). */
int db_face_pipeline_init(DbFacePipeline *pipeline);
int db_face_pipeline_available(const DbFacePipeline *pipeline);
int db_face_pipeline_begin(DbFacePipeline *pipeline,uint32_t frame,
    const uint8_t *source_bgr,unsigned width,unsigned height,unsigned stride,
    uint32_t now_us);
/* 0: busy, 1: result ready, -1: failed. */
int db_face_pipeline_poll(DbFacePipeline *pipeline,uint32_t now_us);
int db_face_pipeline_take_result(DbFacePipeline *pipeline,DbFaceResult *result);
/* One-shot notification as soon as YuNet finishes; MobileFaceNet continues. */
int db_face_pipeline_take_detection(DbFacePipeline *pipeline,DbFaceDetection *detection);

/* Platform inference contract. A real PL/PS INT8 backend must provide strong
 * definitions for these symbols. The weak defaults fail closed. YuNet returns
 * landmarks in source-image coordinates. MobileFaceNet returns an L2-normalized
 * 512-vector quantized with scale 1/127 and zero point 0. */
int db_face_nn_backend_init(void);
int db_face_yunet_begin(const uint8_t *source_bgr,unsigned width,
    unsigned height,unsigned stride);
int db_face_yunet_poll(DbFaceDetection *detection);
int db_face_mobilefacenet_begin(const uint8_t aligned_rgb[DB_FACE_ALIGN_SIZE*DB_FACE_ALIGN_SIZE*3U]);
int db_face_mobilefacenet_poll(int8_t embedding[DB_FACE_IDENTITY_DIM]);

#endif

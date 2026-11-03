#ifndef DB_WIRE_H
#define DB_WIRE_H
#include <stddef.h>
#include <stdint.h>

#define DB_HEADER_BYTES 48U
#define DB_PAYLOAD_BYTES 1424U
#define DB_PACKET_BYTES (DB_HEADER_BYTES + DB_PAYLOAD_BYTES)
#define DB_WIDTH 1280U
#define DB_HEIGHT 720U
#define DB_IMAGE_BYTES (DB_WIDTH * DB_HEIGHT)
#define DB_MAX_CHUNKS ((DB_IMAGE_BYTES + DB_PAYLOAD_BYTES - 1U) / DB_PAYLOAD_BYTES)
#define DB_RX_SLOTS 3U
#define DB_RAW 1U
#define DB_RECTIFIED 2U
#define DB_GREEN8 1U

/* Wire bytes are big endian. Never send sizeof(DbHeader). Timestamps refer
 * to the same capture-board clock; the worker must preserve them verbatim. */
typedef struct {
    uint8_t kind, camera, format;
    uint32_t session, frame, calibration;
    uint16_t width, height, chunk, chunks;
    uint32_t offset;
    uint16_t length, flags;
    uint32_t capture_us, image_bytes;
} DbHeader;

uint32_t db_crc32(const void *data, size_t count);
int db_packet_encode(uint8_t *packet, size_t capacity,
                     const DbHeader *h, const uint8_t *payload);
int db_packet_encode_header(uint8_t *header,size_t capacity,const DbHeader *h,const uint8_t *payload);
/* Serialize the same 44-byte prefix for CPU and PL CRC paths. */
int db_packet_write_fields(uint8_t *header,size_t capacity,const DbHeader *h);
int db_packet_encode_header_crc(uint8_t *header,size_t capacity,const DbHeader *h,uint32_t payload_crc);
int db_packet_decode(DbHeader *h, const uint8_t *packet, size_t bytes);

typedef enum { DB_FREE, DB_FILLING, DB_READY, DB_HELD, DB_VERIFY_WAIT, DB_VERIFYING } DbSlotState;
typedef struct {
    DbSlotState state;
    uint32_t frame, first_us, capture_us[2];
    uint16_t received[2];
    uint8_t dma_clean; /* Set only after the PL verifier's completed DDR flush. */
    uint8_t seen[2][(DB_MAX_CHUNKS + 7U) / 8U];
    uint8_t *image[2];
    /* Used by opt-in CPU1/PL verifiers. Immutable from VERIFY_WAIT
     * until completion; retained with the images on a worker fault. */
    uint8_t headers[2U*DB_MAX_CHUNKS*DB_HEADER_BYTES];
} DbSlot;
typedef struct {
    DbSlot slots[DB_RX_SLOTS];
    uint32_t session, calibration, timeout_us, max_skew_us;
    uint32_t watermark;
    uint8_t kind, delivered, defer_crc;
    uint64_t accepted, rejected, duplicates, completed, timed_out, queue_full;
} DbReceiver;

/* Call once with a negotiated/configured session. Reset explicitly on peer
 * restart; a data packet must never silently switch the receiver's session. */
void db_rx_init(DbReceiver *r, uint32_t session, uint32_t calibration,
                uint8_t kind, uint32_t timeout_us, uint32_t max_skew_us,
                uint8_t *images[DB_RX_SLOTS][2]);
void db_rx_expire(DbReceiver *r, uint32_t now_us);
int db_rx_push(DbReceiver *r, const uint8_t *packet, size_t bytes, uint32_t now_us);
DbSlot *db_rx_acquire_latest(DbReceiver *r);
void db_rx_release(DbSlot *slot);

typedef int (*DbSend)(void *context, const uint8_t *packet, size_t bytes);
typedef int (*DbSendChunk)(void *context,const DbHeader *header,const uint8_t *pixels);
typedef struct {
    DbHeader header;
    const uint8_t *image[2];
    uint32_t capture_us[2];
    uint16_t next_chunk;
    uint16_t packet_bytes;
    uint8_t camera, active;
    uint8_t packet[DB_PACKET_BYTES];
} DbSender;
int db_tx_begin(DbSender *s, uint8_t kind, uint32_t session, uint32_t frame,
                uint32_t calibration, const uint8_t *left, const uint8_t *right,
                uint32_t left_us, uint32_t right_us);
/* Bounded work. Source images must remain immutable until active becomes 0.
 * send() copies/retains the packet before returning; 0 means back pressure. */
unsigned db_tx_poll(DbSender *s, unsigned budget, DbSend send, void *context);
/* Encode directly in a transport-owned buffer. The callback must retain
 * all bytes before success; backpressure leaves the same chunk pending. */
unsigned db_tx_poll_chunks(DbSender *s,unsigned budget,DbSendChunk send,void *context);
#endif

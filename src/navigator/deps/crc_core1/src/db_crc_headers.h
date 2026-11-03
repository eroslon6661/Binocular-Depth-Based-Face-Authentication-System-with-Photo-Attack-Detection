#ifndef DB_CRC_HEADERS_H
#define DB_CRC_HEADERS_H
#include "db_wire.h"
#define DB_CRC_PAIR_HEADER_BYTES (2U*DB_MAX_CHUNKS*DB_HEADER_BYTES)
#define DB_CRC_TRANSMIT 0U
#define DB_CRC_VERIFY 1U
typedef struct {
    uint32_t kind,session,frame,calibration,source[2],stamp[2],bank;
    uint32_t operation,header_source;
} DbCrcWork;
/* Caller owns both immutable images and the entire private output bank. */
int db_crc_make_headers(uint8_t *headers,const DbCrcWork *work,
                        const uint8_t *left,const uint8_t *right);
int db_crc_check_headers(const uint8_t *headers,const DbCrcWork *work,
                         const uint8_t *left,const uint8_t *right);
int db_crc_header_matches(const DbCrcWork *work,const DbHeader *header,
                          const uint8_t *pixels);
int db_crc_header_fields(DbHeader *header,const DbCrcWork *work,unsigned camera,unsigned chunk);
#endif

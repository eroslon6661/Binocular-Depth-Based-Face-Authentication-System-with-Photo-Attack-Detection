#ifndef DB_CRC_AMP_H
#define DB_CRC_AMP_H
#include "db_crc_headers.h"
#ifndef DB_CRC_AMP_ENABLE
#define DB_CRC_AMP_ENABLE 0
#endif
#ifndef DB_PLCRC_ENABLE
#define DB_PLCRC_ENABLE 0
#endif
#if DB_PLCRC_ENABLE && DB_CRC_AMP_ENABLE
#error Select one CRC backend; they cannot own the same buffers concurrently.
#endif
#define DB_CRC_SHARED_BASE 0x09000000U
#define DB_CRC_CORE1_BASE 0x0A000000U
#define DB_CRC_MAGIC 0x43524332U
#define DB_CRC_BANKS 3U
typedef struct {
    volatile uint32_t magic,ready,request,done,error,work_us;
    volatile DbCrcWork work;
    uint8_t headers[DB_CRC_BANKS][DB_CRC_PAIR_HEADER_BYTES];
} DbCrcShared;
typedef char DbCrcSharedFits[(sizeof(DbCrcShared)<0x100000U)?1:-1];
#define DB_CRC_SHARED ((DbCrcShared *)(uintptr_t)DB_CRC_SHARED_BASE)
int db_crc_amp_init(void);
int db_crc_amp_enabled(void);
int db_crc_amp_busy(void);
int db_crc_amp_submit(unsigned bank,unsigned kind,uint32_t frame,
                      const uint8_t *left,const uint8_t *right,uint32_t ls,uint32_t rs);
/* 0 while idle/pending, bank+1 on completion, -1 on fault. On fault the
 * source and output bank MUST remain reserved until the entire board resets. */
int db_crc_amp_poll(void);
/* Round-robin arbitration with pending TX jobs. VERIFYING storage is never
 * timed out/reused while the selected backend owns it. RX CRC mismatch drops only that pair. */
void db_crc_amp_schedule_rx(DbReceiver *receiver,unsigned tx_waiting);
int db_crc_amp_try_header(uint8_t *destination,const DbHeader *header,const uint8_t *pixels);
extern unsigned db_crc_amp_completed,db_crc_amp_last_us,db_crc_amp_max_us;
extern unsigned db_crc_amp_verified;
extern unsigned db_crc_amp_header_hits,db_crc_amp_header_misses;
extern unsigned db_crc_amp_rx_completed,db_crc_amp_rx_rejected,db_crc_amp_rx_verified,db_crc_amp_rx_last_us;
#endif

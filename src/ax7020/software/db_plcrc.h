#ifndef DB_PLCRC_H
#define DB_PLCRC_H
#include "db_crc_amp.h"
#if DB_PLCRC_ENABLE
/* Wall times include the main-loop delay before observing completion.
 * They are elapsed stage times, not CPU utilization measurements. */
typedef struct {
    uint32_t copy_hw_us,tx_hw_us,rx_hw_us,rx_clean_us;
    uint32_t tx_verify_us,rx_verify_us;
} DbPlCrcTiming;
extern DbPlCrcTiming db_plcrc_timing;
/* The capture store remains DMA-owned until poll returns 1. Caller must
 * then check capture tags before commit. Destination bank remains reserved
 * through commit, CRC completion, packet transmission and GEM TX drain. */
int db_plcrc_copy_begin(unsigned bank,uint32_t frame,const uint8_t *left,const uint8_t *right,
                       uint8_t *copy_left,uint8_t *copy_right,uint32_t ls,uint32_t rs);
int db_plcrc_copy_poll(void);
int db_plcrc_copy_commit(void);
/* Only legal once poll returned 1; timeout/fault never releases ownership. */
void db_plcrc_copy_discard(void);
#endif
#endif

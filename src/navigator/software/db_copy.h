#ifndef DB_COPY_H
#define DB_COPY_H
#include <stdint.h>
int db_copy_init(void);
int db_copy_begin(const uint8_t *left,const uint8_t *right,uint8_t *out_left,uint8_t *out_right);
/* 0: running; 1: both channels stopped after completion; -1: fault/timeout.
 * On error the caller must keep the destination reserved until board reset. */
int db_copy_poll(void);
int db_copy_dma_owned(uint32_t source,uint32_t destination,unsigned bytes);
#endif

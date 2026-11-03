#ifndef DB_CRC_COMBINE_H
#define DB_CRC_COMBINE_H
#include <stdint.h>
#include <stddef.h>
/* Finalized IEEE CRCs. Produces CRC(a || b) from CRC(a), CRC(b), len(b).
 * No bytes are omitted and no payload needs to be read by the ARM core. */
uint32_t db_crc32_combine(uint32_t first,uint32_t second,size_t second_bytes);
void db_crc32_combine_init(void);
#endif

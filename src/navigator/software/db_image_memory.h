#ifndef DB_IMAGE_MEMORY_H
#define DB_IMAGE_MEMORY_H
#include <stdint.h>
#ifndef DB_IMAGE_L1_ONLY
#define DB_IMAGE_L1_ONLY 0
#endif
/* ARMv7 short descriptor: S=1, TEX=100, C=0, B=1, full AP.
 * Normal shareable, inner WB/WA, outer noncacheable. Both cores MUST agree. */
#define DB_IMAGE_L1_ATTRIBUTES 0x14DE6U
void db_image_memory_init(void);
int db_image_range_l1(uintptr_t address,unsigned length);
#endif

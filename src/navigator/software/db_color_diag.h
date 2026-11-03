#ifndef DB_COLOR_DIAG_H
#define DB_COLOR_DIAG_H
#include <stdint.h>
void db_color_diag_init(void);
void db_color_diag_poll(uint32_t now,unsigned busy);
#endif

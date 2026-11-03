#ifndef DB_HDMI_AX_H
#define DB_HDMI_AX_H
#include "db_control_net.h"
#include "xaxivdma.h"
int db_hdmi_ax_init(DbNet *,XAxiVdma *);
void db_hdmi_ax_poll(DbControlNet *,uint32_t session,uint32_t now);
unsigned db_hdmi_ax_mode(void);
#endif

#ifndef DB_HDMI_NAV_H
#define DB_HDMI_NAV_H
#include "db_control_net.h"
int db_hdmi_nav_init(DbNet *,uint32_t session);
void db_hdmi_nav_control(DbControlNet *,uint32_t now,unsigned toggle);
int db_hdmi_nav_color_active(uint32_t now);
void db_hdmi_nav_poll(uint32_t now,uint32_t capture_clock,unsigned idle);
#endif

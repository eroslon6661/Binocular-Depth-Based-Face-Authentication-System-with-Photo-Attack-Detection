#ifndef DB_RX_FLOW_H
#define DB_RX_FLOW_H
#include "xemacps.h"
extern unsigned db_rx_pause_active,db_rx_pause_requests,db_rx_resume_requests,db_rx_pause_failures;
void db_dma_rx_pressure(XEmacPs *mac);
#endif

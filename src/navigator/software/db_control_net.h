#ifndef DB_CONTROL_NET_H
#define DB_CONTROL_NET_H
#include "db_control.h"
#include "db_net.h"
typedef struct {
    struct udp_pcb *pcb;
    struct pbuf *tx[4];
    void *payload[4];
    DbControl inbox[DB_CTRL_TYPE_COUNT];
    uint8_t pending[DB_CTRL_TYPE_COUNT];
    uint32_t accepted,rejected,sent,backpressure;
} DbControlNet;
int db_control_net_open(DbControlNet *control,const DbNet *network);
int db_control_net_send(DbControlNet *control,const DbControl *message);
int db_control_net_take(DbControlNet *control,unsigned type,DbControl *message);
#endif

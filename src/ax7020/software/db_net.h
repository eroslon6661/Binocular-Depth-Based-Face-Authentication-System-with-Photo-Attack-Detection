#ifndef DB_NET_H
#define DB_NET_H
#include "db_wire.h"
#include "db_perf.h"
#include "lwip/netif.h"
#include "lwip/udp.h"
#define DB_TX_POOL_SIZE 64U
typedef struct {struct pbuf *p;void *payload;struct pbuf pixels;} DbTxBuffer;
typedef struct {
    struct netif interface;
    struct udp_pcb *udp;
    DbReceiver *receiver;
    uint8_t incoming[DB_PACKET_BYTES];
    uint64_t sent_bytes, received_bytes, send_stalls;
    uint32_t arp_retry_us;
    unsigned arp_requested;
    uint32_t last_send_us;
    uint32_t tx_progress_us,tx_head,tx_pending,tx_recoveries;
    uint32_t arp_stalls,udp_stalls;
    uint32_t rx_watchdog_us;
    DbTxBuffer tx_pool[DB_TX_POOL_SIZE];
    unsigned tx_cursor,tx_reserved;
    uint16_t tx_reserved_bytes;
    uint32_t tx_pool_stalls;
    uint32_t tx_pacing_waits;
    unsigned tx_source_cpu_written;
    uint64_t rx_work_ticks,tx_encode_ticks,tx_submit_ticks,poll_ticks;
    uint64_t prepare_ticks,prepare_max_ticks;
    uint32_t last_poll_us,poll_calls,service_gap_max_us;
} DbNet;
extern volatile unsigned db_gem_rx_alloc_failures;
/* Bring-up pacing control, zero means unrestricted; writable through JTAG. */
extern volatile unsigned db_net_tx_gap_us;
uint32_t db_time_us(void);
int db_net_open(DbNet *net,DbReceiver *receiver,int worker);
void db_net_poll(DbNet *net,unsigned packet_budget);
int db_net_send(void *context,const uint8_t *packet,size_t bytes);
int db_net_send_chunk(void *context,const DbHeader *header,const uint8_t *pixels);
int db_net_tx_idle(DbNet *net);
int db_net_prepare_tx(DbNet *net,const uint8_t *left,const uint8_t *right);
void db_net_report(DbNet *net);
#endif

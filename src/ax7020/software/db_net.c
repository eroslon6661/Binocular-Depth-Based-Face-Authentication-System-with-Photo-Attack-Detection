#include "db_net.h"
#include "db_config.h"
#include "db_log.h"
#include "db_rx_flow.h"
#include "db_crc_amp.h"
#include "db_clock.h"
#include "db_perf.h"
#include "lwip/memp.h"
#include "lwip/priv/memp_priv.h"
#include "lwip/stats.h"
#include "lwip/init.h"
#include "lwip/timeouts.h"
#include "lwip/sys.h"
#include "lwip/etharp.h"
#include "netif/xadapter.h"
#include "netif/xemacpsif.h"
#include "xil_exception.h"
#include "xscugic.h"
#include "xtime_l.h"
#include "xparameters.h"
#include "xuartps_hw.h"
#include "xil_cache.h"
#include <string.h>

/* PHY callback failure is XST_FAILURE (1), not an invalid MAC speed of 0. */
extern unsigned db_phy_link_ready;
extern volatile unsigned db_gem_rx_queue_drops,db_gem_rx_packets;
extern volatile unsigned db_gem_rx_recoveries;
/* Safe bring-up default also applies to SD boot before host UART control. */
volatile unsigned db_net_tx_gap_us=15U;
static void console_poll(void)
{
    static char command[8];static unsigned used;
    unsigned budget=8;
    while(budget-- && XUartPs_IsReceiveData(XPAR_XUARTPS_0_BASEADDR)) {
        char c=(char)XUartPs_ReadReg(XPAR_XUARTPS_0_BASEADDR,XUARTPS_FIFO_OFFSET);
        if(c=='\r')continue;
        if(c=='\n') {
            unsigned gap=0,i;
            if(used>=2 && command[0]=='p') {
                for(i=1;i<used && command[i]>='0' && command[i]<='9';++i)
                    gap=gap*10U+(unsigned)(command[i]-'0');
                if(i==used && gap<=100U) {
                    db_net_tx_gap_us=gap;db_log("NET TX_GAP_US=%lu\r\n",(unsigned long)gap);
                }
            }
            used=0;
        } else if(used<sizeof(command))command[used++]=c;
        else used=0;
    }
}

static uintptr_t tx_clean_source[2];
static unsigned tx_clean_valid;
/* Called by the actual GEM driver. Only explicitly published immutable
 * images may skip its per-packet cache flush; all headers/control traffic
 * retain the SDK flush. Publication happens after a whole-image clean. */
int db_dma_tx_source_clean(uintptr_t address,unsigned length)
{
    unsigned c;
    if(!tx_clean_valid || !length || length>DB_IMAGE_BYTES)return 0;
    for(c=0;c<2;++c)if(address>=tx_clean_source[c] &&
        address-tx_clean_source[c]<=DB_IMAGE_BYTES-length)return 1;
    return 0;
}
int db_net_tx_idle(DbNet *net)
{
    unsigned i;
    if(net->tx_reserved!=DB_TX_POOL_SIZE)return 0;
    for(i=0;i<DB_TX_POOL_SIZE;++i)if(net->tx_pool[i].p->ref!=1 || net->tx_pool[i].pixels.ref!=1)return 0;
    return 1;
}
int db_net_prepare_tx(DbNet *net,const uint8_t *left,const uint8_t *right)
{
    XTime start,end;
    if(!net->udp || !db_net_tx_idle(net))return 0;
    XTime_GetTime(&start);
    tx_clean_valid=0;
    if(net->tx_source_cpu_written) {
        Xil_DCacheFlushRange((INTPTR)left,DB_IMAGE_BYTES);
        Xil_DCacheFlushRange((INTPTR)right,DB_IMAGE_BYTES);
    }
    /* Worker images are PL-written and already invalidated before handing
     * them to this sender. Neither role may write/release them until idle. */
    tx_clean_source[0]=(uintptr_t)left;tx_clean_source[1]=(uintptr_t)right;
    __asm__ volatile("dmb sy" ::: "memory");
    tx_clean_valid=1;
    XTime_GetTime(&end);net->prepare_ticks+=end-start;
    if(end-start>net->prepare_max_ticks)net->prepare_max_ticks=end-start;
    return 1;
}

#if !NO_SYS || LWIP_IPV6
#error Build this application with standalone lwIP RAW API, NO_SYS=1, IPv4 only.
#endif
#if !LWIP_ALLOW_MEM_FREE_FROM_OTHER_CONTEXT
#error GEM frees PBUF_RAM from IRQ context; link the protected lwIP heap.
#endif
uint32_t db_time_us(void)
{
    static const DbClockRatio ratio=DB_CLOCK_RATIO_INITIALIZER(COUNTS_PER_SECOND);
    XTime t;XTime_GetTime(&t);
    return db_clock_ratio_us(&ratio,t);
}
#if DB_PERF_DIAG
uint64_t db_perf_platform_ticks(void)
{
    XTime t;XTime_GetTime(&t);return t;
}
static void diagnostic_irq_handler(void *argument)
{
    XTime start,end;XTime_GetTime(&start);
#if DB_PERF_CACHE_MASK
    /* ISR is read/write-one-to-clear in the Xilinx handler. Read only;
     * leave all acknowledgements and clear-on-read counters to their owners. */
    if(XEmacPs_ReadReg(XPAR_XEMACPS_0_BASEADDR,XEMACPS_ISR_OFFSET)&XEMACPS_IXR_RXOVR_MASK)
        db_perf_overrun_irq(start,COUNTS_PER_SECOND/10000U);
#endif
    XScuGic_DeviceInterruptHandler(argument);
    XTime_GetTime(&end);db_perf_irq_record(end-start);
}
#endif
/* The standalone Xilinx port expects the application to provide the clock
 * when lwIP timers are enabled (the FreeRTOS implementation is not used). */
u32_t sys_now(void)
{
    static const DbClockRatio ratio=DB_CLOCK_RATIO_INITIALIZER(COUNTS_PER_SECOND);
    XTime t;XTime_GetTime(&t);
    return db_clock_ratio_ms(&ratio,t);
}
static void receive_packet(void *arg,struct udp_pcb *pcb,struct pbuf *p,
                           const ip_addr_t *address,u16_t port)
{
    DbNet *net=(DbNet *)arg;
    DbPerfStamp diagnostic=db_perf_begin(DB_PERF_RX_CALLBACK);
    XTime profile_start,profile_end;XTime_GetTime(&profile_start);
    (void)pcb; (void)address; (void)port;
    if(p && p->tot_len>=DB_HEADER_BYTES && p->tot_len<=DB_PACKET_BYTES) {
        /* A standard UDP datagram fits one 1700-byte RX pbuf. Parse that
         * immutable payload directly, avoiding an extra full-packet copy.
         * Keep the chained-pbuf fallback; db_rx_push copies accepted pixels
         * into receiver-owned storage before this callback frees the pbuf. */
        const uint8_t *packet=(const uint8_t *)p->payload;
        if(p->len!=p->tot_len) {
            if(pbuf_copy_partial(p,net->incoming,p->tot_len,0)!=p->tot_len) {
                pbuf_free(p);
                XTime_GetTime(&profile_end);net->rx_work_ticks+=profile_end-profile_start;
                db_perf_end(DB_PERF_RX_CALLBACK,diagnostic);return;
            }
            packet=net->incoming;
        }
        if(db_rx_push(net->receiver,packet,p->tot_len,db_time_us()))
            net->received_bytes+=p->tot_len;
    }
    if(p) pbuf_free(p);
    XTime_GetTime(&profile_end);net->rx_work_ticks+=profile_end-profile_start;
    db_perf_end(DB_PERF_RX_CALLBACK,diagnostic);
}
int db_net_open(DbNet *net,DbReceiver *receiver,int worker)
{
    ip_addr_t local,mask,gateway,peer;
    unsigned char mac[6]={0x02,0x44,0x42,0x53,0x00,0x00};
    struct xemac_s *emac;
    xemacpsif_s *gem;
    memset(net,0,sizeof(*net)); net->receiver=receiver; mac[5]=worker?20:10;
    receiver->defer_crc=(uint8_t)db_crc_amp_enabled();
    net->tx_source_cpu_written=!worker;
    IP4_ADDR(&local,192,168,7,worker?20:10); IP4_ADDR(&peer,192,168,7,worker?10:20);
    IP4_ADDR(&mask,255,255,255,0); IP4_ADDR(&gateway,0,0,0,0);
    Xil_ExceptionInit();
    if(XScuGic_DeviceInitialize(XPAR_SCUGIC_SINGLE_DEVICE_ID)!=0) return 0;
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
#if DB_PERF_DIAG
        (Xil_ExceptionHandler)diagnostic_irq_handler,(void *)XPAR_SCUGIC_SINGLE_DEVICE_ID);
#else
        (Xil_ExceptionHandler)XScuGic_DeviceInterruptHandler,(void *)XPAR_SCUGIC_SINGLE_DEVICE_ID);
#endif
    lwip_init();
    if(!xemac_add(&net->interface,&local,&mask,&gateway,mac,XPAR_XEMACPS_0_BASEADDR)) return 0;
    emac=(struct xemac_s *)net->interface.state;
    gem=(xemacpsif_s *)emac->state;
    if(!db_phy_link_ready || XEmacPs_GetOperatingSpeed(&gem->emacps)!=1000U) {
        xil_printf("ERROR: dual-board video requires a 1000 Mbit/s link\r\n"); return 0;
    }
    /* This SDK subtracts the Ethernet header from XEMACPS_MTU (1500),
     * yielding 1486. lwIP's netif MTU is the IP packet size: Ethernet's
     * standard value is 1500, excluding the 14-byte link header. GEM's
     * 1536-byte RX buffers and 1518-byte TX limit accommodate this frame.
     * Our 1472-byte UDP payload must remain one unfragmented IP packet. */
    net->interface.mtu=1500U;
    XEmacPs_SetOptions(&gem->emacps,XEMACPS_FLOW_CONTROL_OPTION);
    xil_printf("DB NET IP_MTU=%u UDP_MAX=%u\r\n",
               (unsigned)net->interface.mtu,(unsigned)DB_PACKET_BYTES);
    xil_printf("DB DATAPATH clock=stateless_reciprocal tx_header=during_gap\r\n");
#if DB_PERF_DIAG
    xil_printf("DB PERF diagnostic=1 hz=%lu packet_stride=64 irq=all_gic\r\n",(unsigned long)COUNTS_PER_SECOND);
#endif
    netif_set_default(&net->interface); netif_set_up(&net->interface);
    net->udp=udp_new();
    if(!net->udp || udp_bind(net->udp,IP_ADDR_ANY,DB_UDP_PORT)!=ERR_OK) return 0;
    if(udp_connect(net->udp,&peer,DB_UDP_PORT)!=ERR_OK) return 0;
    udp_recv(net->udp,receive_packet,net);
    /* Keep one application reference for each TX pbuf. GEM owns an extra
     * reference until DMA completion; ref==1 is the only reusable state.
     * Video never allocates/frees heap blocks in its per-packet path. */
    net->tx_reserved=DB_TX_POOL_SIZE;
    {
        unsigned i;
        for(i=0;i<DB_TX_POOL_SIZE;++i) {
            net->tx_pool[i].p=pbuf_alloc(PBUF_TRANSPORT,DB_HEADER_BYTES,PBUF_RAM);
            if(!net->tx_pool[i].p) {
                while(i)pbuf_free(net->tx_pool[--i].p);
                xil_printf("ERROR: cannot initialize video TX pool\r\n");return 0;
            }
            net->tx_pool[i].payload=net->tx_pool[i].p->payload;
            net->tx_pool[i].pixels.type_internal=PBUF_ROM;
            net->tx_pool[i].pixels.ref=1;
        }
    }
    /* Completion is reclaimed by db_net_poll on every bounded iteration.
     * Avoid a TX-complete interrupt for every video packet; retain RX and
     * error interrupts and the existing TX watchdog/recovery path. */
    /* Keep RX-complete and error IRQs enabled: a polling-only trial lost
     * packets during peer bursts. TX completion is still reclaimed here. */
    XEmacPs_IntDisable(&gem->emacps,XEMACPS_IXR_TXCOMPL_MASK);
    /* Do not enable RX interrupts until the callback and its buffers exist. */
    Xil_ExceptionEnableMask(XIL_EXCEPTION_IRQ);
    return 1;
}
void db_net_poll(DbNet *net,unsigned budget)
{
    DbPerfStamp diagnostic=db_perf_begin(DB_PERF_POLL);
    SYS_ARCH_DECL_PROTECT(level);
    struct xemac_s *emac;
    xemacpsif_s *gem;
    XEmacPs_BdRing *txring;
    uint32_t now=db_time_us();
    XTime profile_start,profile_end;XTime_GetTime(&profile_start);
    if(!net->udp) {db_perf_end(DB_PERF_POLL,diagnostic);return;}
    if(net->last_poll_us && (uint32_t)(now-net->last_poll_us)>net->service_gap_max_us)
        net->service_gap_max_us=(uint32_t)(now-net->last_poll_us);
    net->last_poll_us=now;++net->poll_calls;
    console_poll();
    emac=(struct xemac_s *)net->interface.state;
    gem=(xemacpsif_s *)emac->state;
    /* A bounded interrupt can leave completed RX descriptors behind. Once
     * the ring fills, new arrivals cannot trigger another RX completion.
     * Harvest pending descriptors from the main loop as well. */
    SYS_ARCH_PROTECT(level);
    txring=&XEmacPs_GetTxRing(&gem->emacps);
    process_sent_bds(gem,txring);
    if(!txring->HwCnt || net->tx_head!=(uint32_t)txring->HwHead || net->tx_pending!=txring->HwCnt)
        net->tx_progress_us=now;
    else if((uint32_t)(now-net->tx_progress_us)>=250000U) {
        /* A peer power/reset cycle can leave GEM with an unfinished TX.
         * Release driver-owned pbuf references and restart only TX. The
         * partially delivered image is rejected by normal frame assembly. */
        HandleTxErrors(emac);++net->tx_recoveries;net->tx_progress_us=now;
    }
    net->tx_head=(uint32_t)txring->HwHead;net->tx_pending=txring->HwCnt;
    /* Zynq GEM erratum SI#692601: RX can become unresponsive under heavy
     * traffic without generating another interrupt. The Xilinx NO_SYS
     * application must call this workaround periodically, independently
     * of RX completions. RXCNT is clear-on-read and belongs exclusively
     * to the driver workaround; diagnostic reporting must not consume it. */
    if((uint32_t)(now-net->rx_watchdog_us)>=100000U) {
        resetrx_on_no_rxdata(gem);
        net->rx_watchdog_us=now;
    }
    if(XEmacPs_GetRxRing(&gem->emacps).HwCnt &&
       XEmacPs_BdIsRxNew(XEmacPs_GetRxRing(&gem->emacps).HwHead))
        emacps_recv_handler(emac);
    SYS_ARCH_UNPROTECT(level);
    /* In the verified Xilinx NO_SYS port each call processes one RX packet. */
    while(budget-- && xemacif_input(&net->interface));
    db_dma_rx_pressure(&gem->emacps);
    /* After a burst exhausts the pool, freeing queued pbufs must also refill
     * RX descriptors even if there is no new receive interrupt. */
    SYS_ARCH_PROTECT(level);
    if(XEmacPs_BdRingGetFreeCnt(&XEmacPs_GetRxRing(&gem->emacps)))
        setup_rx_bds(gem,&XEmacPs_GetRxRing(&gem->emacps));
    SYS_ARCH_UNPROTECT(level);
    sys_check_timeouts();
    db_rx_expire(net->receiver,db_time_us());
    XTime_GetTime(&profile_end);net->poll_ticks+=profile_end-profile_start;
    db_perf_end(DB_PERF_POLL,diagnostic);
    db_perf_log_poll(now);
}
int db_net_send(void *context,const uint8_t *data,size_t bytes)
{
    DbNet *net=(DbNet *)context;
    struct pbuf *p;
    err_t status;
    struct eth_addr *peer_mac;
    const ip4_addr_t *peer_ip;
    if(!net->udp || bytes>DB_PACKET_BYTES || bytes+28U>net->interface.mtu) return 0;
    if(db_net_tx_gap_us && (uint32_t)(db_time_us()-net->last_send_us)<db_net_tx_gap_us)
        return 0;
    /* With ARP_QUEUEING=0, udp_send can return ERR_OK while dropping the
     * image and sending an ARP request for every call. Gate image traffic
     * until the peer is resolved, with a bounded ARP request rate. */
    if(etharp_find_addr(&net->interface,ip_2_ip4(&net->udp->remote_ip),
                       &peer_mac,&peer_ip)<0) {
        uint32_t now=db_time_us();
        if(!net->arp_requested || (uint32_t)(now-net->arp_retry_us)>=250000U) {
            net->arp_requested=1;net->arp_retry_us=now;
            etharp_request(&net->interface,ip_2_ip4(&net->udp->remote_ip));
        }
        ++net->send_stalls;++net->arp_stalls;return 0;
    }
    p=pbuf_alloc(PBUF_TRANSPORT,(u16_t)bytes,PBUF_RAM);
    if(!p) { ++net->send_stalls; return 0; }
    status=pbuf_take(p,data,(u16_t)bytes);
    if(status==ERR_OK) status=udp_send(net->udp,p);
    pbuf_free(p); /* Driver retains its own reference until DMA completion. */
    if(status==ERR_OK) {net->sent_bytes+=bytes;net->last_send_us=db_time_us();}
    else {++net->send_stalls;++net->udp_stalls;}
    return status==ERR_OK;
}
int db_net_send_chunk(void *context,const DbHeader *header,const uint8_t *pixels)
{
    DbNet *net=(DbNet *)context;
    struct eth_addr *peer_mac;
    const ip4_addr_t *peer_ip;
    DbTxBuffer *buffer;
    err_t status;
    unsigned i;
    SYS_ARCH_DECL_PROTECT(level);
    if(!net->udp)return 0;
    if(etharp_find_addr(&net->interface,ip_2_ip4(&net->udp->remote_ip),&peer_mac,&peer_ip)<0) {
        uint32_t now=db_time_us();
        if(!net->arp_requested || (uint32_t)(now-net->arp_retry_us)>=250000U) {
            net->arp_requested=1;net->arp_retry_us=now;
            etharp_request(&net->interface,ip_2_ip4(&net->udp->remote_ip));
        }
        ++net->send_stalls;++net->arp_stalls;return 0;
    }
    if(net->tx_reserved==DB_TX_POOL_SIZE) {
        SYS_ARCH_PROTECT(level);
        for(i=0;i<DB_TX_POOL_SIZE;++i) {
            unsigned slot=(net->tx_cursor+i)%DB_TX_POOL_SIZE;
            if(net->tx_pool[slot].p->ref==1 && net->tx_pool[slot].pixels.ref==1) {
                net->tx_reserved=slot;net->tx_cursor=(slot+1U)%DB_TX_POOL_SIZE;break;
            }
        }
        SYS_ARCH_UNPROTECT(level);
        if(i==DB_TX_POOL_SIZE) {++net->tx_pool_stalls;++net->send_stalls;return 0;}
        buffer=&net->tx_pool[net->tx_reserved];
        /* UDP/IP/Ethernet prepend headers in place. Restore metadata only
         * after the previous DMA released this pbuf, never while ref>1. */
        buffer->p->payload=buffer->payload;
        buffer->p->len=buffer->p->tot_len=DB_HEADER_BYTES;
        {
            DbPerfStamp diagnostic=db_perf_begin(DB_PERF_TX_ENCODE);
            XTime profile_start,profile_end;XTime_GetTime(&profile_start);
            int bytes;
            if(db_crc_amp_try_header((uint8_t *)buffer->payload,header,pixels))bytes=DB_HEADER_BYTES+header->length;
            else bytes=db_packet_encode_header((uint8_t *)buffer->payload,DB_HEADER_BYTES,header,pixels);
            XTime_GetTime(&profile_end);net->tx_encode_ticks+=profile_end-profile_start;
            db_perf_end(DB_PERF_TX_ENCODE,diagnostic);
            if(bytes<0){net->tx_reserved=DB_TX_POOL_SIZE;return 0;}
            net->tx_reserved_bytes=(uint16_t)bytes;
        }
        buffer->pixels.payload=(void *)pixels;
        buffer->pixels.len=buffer->pixels.tot_len=header->length;
        buffer->pixels.next=NULL;
        buffer->p->next=&buffer->pixels;
    }
    buffer=&net->tx_pool[net->tx_reserved];
    if(buffer->p->ref!=1 || buffer->pixels.ref!=1) {++net->tx_pool_stalls;++net->send_stalls;return 0;}
    /* Prepare at most one immutable header while the previous packet's
     * pacing interval elapses. Do not pay CRC time after every interval.
     * Keep the same minimum gap measured from the last successful send's
     * completion; retries retain the reserved header and never re-encode. */
    if(db_net_tx_gap_us && (uint32_t)(db_time_us()-net->last_send_us)<db_net_tx_gap_us) {
        ++net->tx_pacing_waits;return 0;
    }
    buffer->p->payload=buffer->payload;
    buffer->p->len=DB_HEADER_BYTES;buffer->p->tot_len=net->tx_reserved_bytes;
#if DB_PERF_DIAG
    if(net->last_send_us)db_perf_tx_gap((uint32_t)(db_time_us()-net->last_send_us),db_net_tx_gap_us);
#endif
    {
        DbPerfStamp diagnostic=db_perf_begin(DB_PERF_TX_SUBMIT);
        XTime profile_start,profile_end;XTime_GetTime(&profile_start);
        status=udp_send(net->udp,buffer->p);
        XTime_GetTime(&profile_end);net->tx_submit_ticks+=profile_end-profile_start;
        db_perf_end(DB_PERF_TX_SUBMIT,diagnostic);
    }
    if(status!=ERR_OK) {++net->send_stalls;++net->udp_stalls;return 0;}
    net->sent_bytes+=net->tx_reserved_bytes;
    net->last_send_us=db_time_us();
    net->tx_reserved=DB_TX_POOL_SIZE;
    return 1;
}
void db_net_report(DbNet *net)
{
    struct xemac_s *emac;
    xemacpsif_s *gem;
    DbReceiver *r=net->receiver;
    if(!net->udp) return;
    emac=(struct xemac_s *)net->interface.state;gem=(xemacpsif_s *)emac->state;
    /* GEM counters are clear-on-read: these hardware fields are interval counts. */
    db_log("NET rx_dma=%lu accepted=%lu queue_full=%lu qdrop=%lu rx_recoveries=%lu fcs=%lu resource=%lu overrun=%lu ip_bad=%lu udp_bad=%lu gap_us=%lu\r\n",
        (unsigned long)db_gem_rx_packets,(unsigned long)r->accepted,
        (unsigned long)r->queue_full,(unsigned long)db_gem_rx_queue_drops,
        (unsigned long)db_gem_rx_recoveries,
        (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_RXFCSCNT_OFFSET),
        (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_RXRESERRCNT_OFFSET),
        (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_RXORCNT_OFFSET),
        (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_RXIPCCNT_OFFSET),
        (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_RXUDPCCNT_OFFSET),
        (unsigned long)db_net_tx_gap_us);
    db_log("NET_TX pending=%lu recoveries=%lu arp_stalls=%lu udp_stalls=%lu pool_stalls=%lu\r\n",
        (unsigned long)net->tx_pending,(unsigned long)net->tx_recoveries,
        (unsigned long)net->arp_stalls,(unsigned long)net->udp_stalls,(unsigned long)net->tx_pool_stalls);
    db_log("NET_SCHED poll_calls=%lu service_gap_max_us=%lu prepare_us=%lu prepare_max_us=%lu pacing_waits=%lu\r\n",
        (unsigned long)net->poll_calls,(unsigned long)net->service_gap_max_us,
        (unsigned long)(net->prepare_ticks*1000000ULL/COUNTS_PER_SECOND),
        (unsigned long)(net->prepare_max_ticks*1000000ULL/COUNTS_PER_SECOND),
        (unsigned long)net->tx_pacing_waits);
    net->poll_calls=net->service_gap_max_us=net->tx_pacing_waits=0;
    net->prepare_ticks=net->prepare_max_ticks=0;
    {
        const struct memp_desc *pool=memp_pools[MEMP_PBUF_POOL];
        XEmacPs_BdRing *rx=&XEmacPs_GetRxRing(&gem->emacps);
        db_log("NET_RX_STATE used=%lu capacity=%lu max_used=%lu free_head=%08lx ring_hw=%lu ring_free=%lu queue=%lu pause_requests=%lu resume_requests=%lu pause_failures=%lu pause_tx=%lu pause_rx=%lu\r\n",
            (unsigned long)pool->stats->used,(unsigned long)pool->num,(unsigned long)pool->stats->max,
            (unsigned long)(uintptr_t)*pool->tab,(unsigned long)rx->HwCnt,(unsigned long)rx->FreeCnt,
            (unsigned long)gem->recv_q->len,(unsigned long)db_rx_pause_requests,
            (unsigned long)db_rx_resume_requests,(unsigned long)db_rx_pause_failures,
            (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_TXPAUSECNT_OFFSET),
            (unsigned long)XEmacPs_ReadReg(gem->emacps.Config.BaseAddress,XEMACPS_RXPAUSECNT_OFFSET));
    }
    /* Inclusive wall-clock samples: poll includes RX callback and IRQs can
     * preempt any sample. Do not add these fields as exclusive CPU usage. */
    db_log("NET_CPU rx_callback_us=%lu tx_encode_us=%lu tx_submit_us=%lu poll_us=%lu\r\n",
        (unsigned long)(net->rx_work_ticks*1000000ULL/COUNTS_PER_SECOND),
        (unsigned long)(net->tx_encode_ticks*1000000ULL/COUNTS_PER_SECOND),
        (unsigned long)(net->tx_submit_ticks*1000000ULL/COUNTS_PER_SECOND),
        (unsigned long)(net->poll_ticks*1000000ULL/COUNTS_PER_SECOND));
    net->rx_work_ticks=net->tx_encode_ticks=net->tx_submit_ticks=net->poll_ticks=0;
}

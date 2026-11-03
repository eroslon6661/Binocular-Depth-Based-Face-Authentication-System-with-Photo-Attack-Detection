#include "db_rx_flow.h"
#include "lwip/memp.h"
#include "lwip/priv/memp_priv.h"
#include "lwip/stats.h"
#include "lwip/sys.h"
#include "db_net.h"
#include "xstatus.h"
#if !MEMP_STATS || MEMP_MEM_MALLOC
#error RX flow control requires counted fixed pbuf pools in this BSP.
#endif
unsigned db_rx_pause_active,db_rx_pause_requests,db_rx_resume_requests,db_rx_pause_failures;
static uint32_t last_request_us;
/* Reserve at least 112 of the 512 buffers before pressure can exhaust the
 * pool. 4000 quanta last 2.048 ms at the mandatory 1 Gbit/s link. This only
 * gates Ethernet transmission; pixel data and packet CRC stay unchanged. */
void db_dma_rx_pressure(XEmacPs *mac)
{
    SYS_ARCH_DECL_PROTECT(level);
    const struct memp_desc *pool=memp_pools[MEMP_PBUF_POOL];
    unsigned used,want;
    uint32_t now;
    SYS_ARCH_PROTECT(level);
    used=pool->stats->used;
    want=db_rx_pause_active?used>pool->num/2U+32U:used>=pool->num-112U;
    if(!want && !db_rx_pause_active){SYS_ARCH_UNPROTECT(level);return;}
    now=db_time_us();
    if(want!=db_rx_pause_active || (uint32_t)(now-last_request_us)>=500U) {
        XEmacPs_WriteReg(mac->Config.BaseAddress,XEMACPS_TXPAUSE_OFFSET,want?4000U:0U);
        if(XEmacPs_SendPausePacket(mac)==XST_SUCCESS) {
            last_request_us=now;db_rx_pause_active=want;
            if(want)++db_rx_pause_requests;else ++db_rx_resume_requests;
        } else ++db_rx_pause_failures;
    }
    SYS_ARCH_UNPROTECT(level);
}

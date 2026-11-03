/* CPU1 has a private BSP startup and no IRQ, network, UART or audio ownership. */
#include "db_crc_amp.h"
#include "db_config.h"
#include "xtime_l.h"
#include "xil_cache_l.h"
static void barrier(void){__asm__ volatile("dmb sy" ::: "memory");}
static void invalidate_local(void)
{
    uint32_t selector=0;
    /* CPU0 completed the global L2 handoff before publication. PL/DMA does
     * not snoop CPU1 L1, so discard its previous read-only image lines. Never
     * invoke a BSP global L2 operation from CPU1. */
    /* Clean/invalidate only the 32-KiB local L1 by set/way, preserving dirty
     * private stack/table bytes. Walking 1.84 MiB by MVA also broadcasts
     * thousands of needless maintenance requests through the shared SCU. */
    __asm__ volatile("mcr p15,2,%0,c0,c0,0\nisb sy" :: "r"(selector) : "memory");
    Xil_L1DCacheFlush();
}
int main(void)
{
    uint32_t last=0;
    while(DB_CRC_SHARED->magic!=DB_CRC_MAGIC)__asm__ volatile("wfe");
    barrier();DB_CRC_SHARED->ready=DB_CRC_MAGIC;barrier();
    for(;;) {
        uint32_t request=DB_CRC_SHARED->request;
        DbCrcWork work;uintptr_t base;unsigned error=0;XTime begin,end;
        if(request==last){__asm__ volatile("wfe");continue;}
        barrier();work=DB_CRC_SHARED->work;XTime_GetTime(&begin);
        base=work.operation==DB_CRC_VERIFY?DB_NETWORK_RX_BASE:
            (work.kind==DB_RAW?DB_RAW_TX_BASE:DB_WORKER_OUTPUT_BASE);
        if(work.bank>=DB_CRC_BANKS || (work.kind!=DB_RAW && work.kind!=DB_RECTIFIED) ||
           work.session!=DB_SESSION_ID || work.calibration!=DB_CALIBRATION_ID ||
           work.operation>DB_CRC_VERIFY ||
           (work.operation==DB_CRC_VERIFY && (work.header_source<0x00100000U ||
            work.header_source>0x01000000U-DB_CRC_PAIR_HEADER_BYTES)) ||
           work.source[0]!=base+work.bank*2U*DB_IMAGE_BYTES || work.source[1]!=work.source[0]+DB_IMAGE_BYTES)error=1;
        if(!error) {
            const uint8_t *left=(const uint8_t *)(uintptr_t)work.source[0],*right=(const uint8_t *)(uintptr_t)work.source[1];
            invalidate_local();
            if(work.operation==DB_CRC_VERIFY) {
                /* Shareable DDR and the enabled SCU snoop the frozen CPU0
                 * receive buffers, including dirty CPU0 L1 lines. */
                if(!db_crc_check_headers((const uint8_t *)(uintptr_t)work.header_source,&work,left,right))error=3;
            } else if(!db_crc_make_headers(DB_CRC_SHARED->headers[work.bank],&work,left,right))error=2;
        }
        XTime_GetTime(&end);DB_CRC_SHARED->work_us=(uint32_t)((end-begin)*1000000ULL/COUNTS_PER_SECOND);
        DB_CRC_SHARED->error=error;barrier();last=request;DB_CRC_SHARED->done=request;barrier();
    }
}

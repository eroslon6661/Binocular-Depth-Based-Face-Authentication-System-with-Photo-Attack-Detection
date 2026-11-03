#include "db_crc_amp.h"
#if !DB_PLCRC_ENABLE
#include "db_config.h"
#include "db_net.h"
#include "db_image_memory.h"
#include "xil_cache.h"
#include "xil_mmu.h"
#include "xil_io.h"
#include <string.h>
extern const uint8_t db_crc_core1_start[],db_crc_core1_end[];
static unsigned enabled,active,sequence,fault,verify_index,bank_valid[DB_CRC_BANKS];
static uint32_t started;
static DbCrcWork banks[DB_CRC_BANKS],pending;
static DbReceiver *rx_owner;
static DbSlot *rx_slot;
static unsigned last_operation;
unsigned db_crc_amp_completed,db_crc_amp_last_us,db_crc_amp_max_us;
unsigned db_crc_amp_verified;
unsigned db_crc_amp_header_hits,db_crc_amp_header_misses;
unsigned db_crc_amp_rx_completed,db_crc_amp_rx_rejected,db_crc_amp_rx_verified,db_crc_amp_rx_last_us;
static void barrier(void){__asm__ volatile("dmb sy" ::: "memory");}
int db_crc_amp_init(void)
{
#if !DB_CRC_AMP_ENABLE
    /* Experimental AMP is opt-in until sustained throughput is accepted. */
    enabled=0;return 0;
#else
    uint32_t now;
    db_image_memory_init();
    /* Run before camera/network DMA: the SDK TLB attribute change flushes
     * caches globally. Mailbox and header banks never use data caches. */
    Xil_SetTlbAttributes(DB_CRC_SHARED_BASE,NORM_NONCACHE);
    Xil_SetTlbAttributes(0xFFF00000U,NORM_NONCACHE);
    memset(DB_CRC_SHARED,0,sizeof(*DB_CRC_SHARED));
    memset(bank_valid,0,sizeof(bank_valid));
    Xil_DCacheFlushRange((INTPTR)db_crc_core1_start,(unsigned)(db_crc_core1_end-db_crc_core1_start));
    DB_CRC_SHARED->magic=DB_CRC_MAGIC;barrier();
    Xil_Out32(0xFFFFFFF0U,DB_CRC_CORE1_BASE);
    __asm__ volatile("dsb sy\nsev" ::: "memory");
    now=db_time_us();
    while(DB_CRC_SHARED->ready!=DB_CRC_MAGIC && (uint32_t)(db_time_us()-now)<100000U);
    enabled=DB_CRC_SHARED->ready==DB_CRC_MAGIC;active=sequence=fault=verify_index=0;
    db_crc_amp_completed=db_crc_amp_verified=db_crc_amp_last_us=db_crc_amp_max_us=0;
    db_crc_amp_header_hits=db_crc_amp_header_misses=0;
    rx_owner=NULL;rx_slot=NULL;last_operation=DB_CRC_TRANSMIT;
    db_crc_amp_rx_completed=db_crc_amp_rx_rejected=db_crc_amp_rx_verified=db_crc_amp_rx_last_us=0;
    return (int)enabled;
#endif
}
int db_crc_amp_enabled(void){return (int)enabled;}
int db_crc_amp_busy(void){return (int)active;}
static void publish(void)
{
    DB_CRC_SHARED->work=pending;DB_CRC_SHARED->error=0;barrier();
    if(++sequence==0)++sequence;
    started=db_time_us();active=1;verify_index=0;DB_CRC_SHARED->request=sequence;
    __asm__ volatile("dsb sy\nsev" ::: "memory");
}
int db_crc_amp_submit(unsigned bank,unsigned kind,uint32_t frame,
                      const uint8_t *left,const uint8_t *right,uint32_t ls,uint32_t rs)
{
    uintptr_t base=kind==DB_RAW?DB_RAW_TX_BASE:DB_WORKER_OUTPUT_BASE;
    if(!enabled || active || fault || bank>=DB_CRC_BANKS || (kind!=DB_RAW && kind!=DB_RECTIFIED) ||
       (uintptr_t)left!=base+bank*2U*DB_IMAGE_BYTES || (uintptr_t)right!=(uintptr_t)left+DB_IMAGE_BYTES)return 0;
    memset(&pending,0,sizeof(pending));pending.bank=bank;pending.kind=kind;
    pending.session=DB_SESSION_ID;pending.calibration=DB_CALIBRATION_ID;pending.frame=frame;
    pending.source[0]=(uint32_t)(uintptr_t)left;pending.source[1]=(uint32_t)(uintptr_t)right;
    pending.stamp[0]=ls;pending.stamp[1]=rs;bank_valid[bank]=0;
    publish();return 1;
}
void db_crc_amp_schedule_rx(DbReceiver *r,unsigned tx_waiting)
{
    unsigned i;DbSlot *s=NULL;
    if(!enabled || active || fault || !r || !r->defer_crc ||
       (tx_waiting && last_operation==DB_CRC_VERIFY))return;
    for(i=0;i<DB_RX_SLOTS;++i)if(r->slots[i].state==DB_VERIFY_WAIT &&
        (!s || (int32_t)(r->slots[i].frame-s->frame)<0))s=&r->slots[i];
    if(!s)return;
    memset(&pending,0,sizeof(pending));pending.kind=r->kind;pending.session=r->session;
    pending.frame=s->frame;pending.calibration=r->calibration;
    pending.operation=DB_CRC_VERIFY;pending.bank=(unsigned)(s-r->slots);
    for(i=0;i<2;++i){pending.source[i]=(uint32_t)(uintptr_t)s->image[i];pending.stamp[i]=s->capture_us[i];}
    pending.header_source=(uint32_t)(uintptr_t)s->headers;
    rx_owner=r;rx_slot=s;s->state=DB_VERIFYING;publish();
}
int db_crc_amp_poll(void)
{
    if(!active)return 0;
    if(fault)return -1;
    if((uint32_t)(db_time_us()-started)>500000U){fault=1;return -1;}
    if(DB_CRC_SHARED->done!=sequence) {
        return 0;
    }
    barrier();
    if(pending.operation==DB_CRC_VERIFY && DB_CRC_SHARED->error==3U) {
        /* CPU1 has stopped reading. A corrupt packet invalidates the pair,
         * never the board; no image bytes can reach PL or a measurement. */
        if(!rx_slot || rx_slot->state!=DB_VERIFYING){fault=1;return -1;}
        rx_slot->state=DB_FREE;++rx_owner->rejected;++db_crc_amp_rx_rejected;
        last_operation=DB_CRC_VERIFY;active=0;rx_slot=NULL;rx_owner=NULL;return 0;
    }
    if(DB_CRC_SHARED->error){fault=1;return -1;}
    /* Verify the first whole pair on CPU0 before trusting this cache handoff.
     * Eight headers per loop keep UART/audio/RX service available. */
    if(pending.operation==DB_CRC_VERIFY?!db_crc_amp_rx_verified:!db_crc_amp_verified) {
        unsigned budget=8;
        while(budget-- && verify_index<2U*DB_MAX_CHUNKS) {
            DbHeader h;uint8_t expected[DB_HEADER_BYTES];
            unsigned cam=verify_index/DB_MAX_CHUNKS,chunk=verify_index%DB_MAX_CHUNKS;
            db_crc_header_fields(&h,&pending,cam,chunk);
            if(db_packet_encode_header(expected,sizeof(expected),&h,
                (const uint8_t *)(uintptr_t)(pending.source[cam]+h.offset))<0 ||
               memcmp(expected,(pending.operation==DB_CRC_VERIFY?
                   (const uint8_t *)(uintptr_t)pending.header_source:DB_CRC_SHARED->headers[pending.bank])+
                   verify_index*DB_HEADER_BYTES,DB_HEADER_BYTES)) {
                fault=1;return -1;
            }
            ++verify_index;
        }
        if(verify_index<2U*DB_MAX_CHUNKS)return 0;
        if(pending.operation==DB_CRC_VERIFY)db_crc_amp_rx_verified=1;
        else db_crc_amp_verified=1;
    }
    last_operation=pending.operation;
    if(pending.operation==DB_CRC_VERIFY) {
        if(!rx_slot || rx_slot->state!=DB_VERIFYING){fault=1;return -1;}
        rx_slot->state=rx_owner->delivered && (int32_t)(rx_slot->frame-rx_owner->watermark)<=0?DB_FREE:DB_READY;
        if(rx_slot->state==DB_READY)++rx_owner->completed;
        ++db_crc_amp_rx_completed;db_crc_amp_rx_last_us=DB_CRC_SHARED->work_us;
        active=0;rx_owner=NULL;rx_slot=NULL;return 0;
    }
    banks[pending.bank]=pending;bank_valid[pending.bank]=1;active=0;
    db_crc_amp_last_us=DB_CRC_SHARED->work_us;
    if(db_crc_amp_last_us>db_crc_amp_max_us)db_crc_amp_max_us=db_crc_amp_last_us;
    ++db_crc_amp_completed;return (int)pending.bank+1;
}
int db_crc_amp_try_header(uint8_t *destination,const DbHeader *h,const uint8_t *pixels)
{
    unsigned bank;
    if(!enabled || !destination)return 0;
    for(bank=0;bank<DB_CRC_BANKS;++bank)if(bank_valid[bank] && db_crc_header_matches(&banks[bank],h,pixels)) {
        memcpy(destination,DB_CRC_SHARED->headers[bank]+(h->camera*DB_MAX_CHUNKS+h->chunk)*DB_HEADER_BYTES,DB_HEADER_BYTES);
        ++db_crc_amp_header_hits;
        return 1;
    }
    ++db_crc_amp_header_misses;
    return 0;
}
#endif

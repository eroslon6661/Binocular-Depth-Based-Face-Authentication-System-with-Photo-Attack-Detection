/* Same scheduler API as the experimental AMP backend, implemented entirely
 * with a dedicated PL AXI master. No CPU1 mailbox/cache handoff is required. */
#include "db_crc_amp.h"
#include "db_plcrc.h"
#if DB_PLCRC_ENABLE
#include "db_config.h"
#include "db_net.h"
#include "db_cache_job.h"
#include "db_crc_combine.h"
#include "xpacket_crc_accel.h"
#include "xparameters.h"
#include "xil_cache.h"
#include <string.h>
#ifndef XPAR_PACKET_CRC_DEVICE_ID
#error PL CRC requires the BSP exported from add_packet_crc.tcl.
#endif
#define PAIR_CHUNKS (2U*DB_MAX_CHUNKS)
#define CRC_MARKER 0xc3200000U
static XPacket_crc_accel core;
/* Each private bank includes entire cache lines. TX and RX never share a
 * metadata bank, and no bank is published while an AXI write is outstanding. */
static uint64_t results[DB_CRC_BANKS+1U][PAIR_CHUNKS] __attribute__((aligned(32)));
static DbCrcWork banks[DB_CRC_BANKS],pending;
static unsigned valid[DB_CRC_BANKS],enabled,active,fault,phase,verify_index,last_operation;
static unsigned copying,copy_complete;
static uint32_t copy_source[2];
static uint32_t started;
static uint32_t hardware_started,verification_started;
DbPlCrcTiming db_plcrc_timing;
static DbReceiver *rx_owner;
static DbSlot *rx_slot;
static DbCacheJob cache;
unsigned db_crc_amp_completed,db_crc_amp_last_us,db_crc_amp_max_us;
unsigned db_crc_amp_verified,db_crc_amp_header_hits,db_crc_amp_header_misses;
unsigned db_crc_amp_rx_completed,db_crc_amp_rx_rejected,db_crc_amp_rx_verified,db_crc_amp_rx_last_us;
static unsigned result_bank(void) {return pending.operation==DB_CRC_VERIFY?DB_CRC_BANKS:pending.bank;}
static void launch(void)
{
    unsigned b=result_bank();
    memset(results[b],0,sizeof(results[b]));
    Xil_DCacheFlushRange((INTPTR)results[b],sizeof(results[b]));
    XPacket_crc_accel_Set_left_r(&core,copying?copy_source[0]:pending.source[0]);
    XPacket_crc_accel_Set_right_r(&core,copying?copy_source[1]:pending.source[1]);
    /* CRC-only mode makes no writes to either source. */
    XPacket_crc_accel_Set_copy_left(&core,pending.source[0]);
    XPacket_crc_accel_Set_copy_right(&core,pending.source[1]);
    XPacket_crc_accel_Set_copy_pixels(&core,copying);
    XPacket_crc_accel_Set_checksums(&core,(uint32_t)(uintptr_t)results[b]);
    __asm__ volatile("dsb sy" ::: "memory");
    hardware_started=db_time_us();
    if(pending.operation==DB_CRC_VERIFY)
        db_plcrc_timing.rx_clean_us=(uint32_t)(hardware_started-started);
    XPacket_crc_accel_Start(&core);phase=1;
}
int db_crc_amp_init(void)
{
    enabled=active=fault=phase=verify_index=copying=copy_complete=0;last_operation=DB_CRC_TRANSMIT;
    memset(valid,0,sizeof(valid));rx_owner=NULL;rx_slot=NULL;
    memset(&db_plcrc_timing,0,sizeof(db_plcrc_timing));
    db_crc_amp_completed=db_crc_amp_last_us=db_crc_amp_max_us=db_crc_amp_verified=0;
    db_crc_amp_header_hits=db_crc_amp_header_misses=0;
    db_crc_amp_rx_completed=db_crc_amp_rx_rejected=db_crc_amp_rx_verified=db_crc_amp_rx_last_us=0;
    db_crc32_combine_init();
    if(XPacket_crc_accel_Initialize(&core,XPAR_PACKET_CRC_DEVICE_ID)!=XST_SUCCESS)return 0;
    XPacket_crc_accel_DisableAutoRestart(&core);
    XPacket_crc_accel_InterruptGlobalDisable(&core);
    enabled=1;return 1;
}
int db_crc_amp_enabled(void){return (int)enabled;}
int db_crc_amp_busy(void){return (int)active;}
int db_plcrc_copy_begin(unsigned bank,uint32_t frame,const uint8_t *left,const uint8_t *right,
                       uint8_t *copy_left,uint8_t *copy_right,uint32_t ls,uint32_t rs)
{
    if(!enabled || active || fault || bank>=DB_CRC_BANKS || !left || !right ||
       ((uintptr_t)left&7U) || ((uintptr_t)right&7U) ||
       (uintptr_t)left<DB_CAPTURE_BASE || (uintptr_t)left-DB_CAPTURE_BASE>=3U*DB_IMAGE_BYTES ||
       ((uintptr_t)left-DB_CAPTURE_BASE)%DB_IMAGE_BYTES ||
       (uintptr_t)right<DB_CAPTURE_RIGHT_BASE || (uintptr_t)right-DB_CAPTURE_RIGHT_BASE>=3U*DB_IMAGE_BYTES ||
       ((uintptr_t)right-DB_CAPTURE_RIGHT_BASE)%DB_IMAGE_BYTES ||
       (uintptr_t)copy_left!=DB_RAW_TX_BASE+bank*2U*DB_IMAGE_BYTES ||
       (uintptr_t)copy_right!=(uintptr_t)copy_left+DB_IMAGE_BYTES)return 0;
    memset(&pending,0,sizeof(pending));pending.bank=bank;pending.kind=DB_RAW;
    pending.session=DB_SESSION_ID;pending.calibration=DB_CALIBRATION_ID;pending.frame=frame;
    pending.source[0]=(uint32_t)(uintptr_t)copy_left;pending.source[1]=(uint32_t)(uintptr_t)copy_right;
    pending.stamp[0]=ls;pending.stamp[1]=rs;valid[bank]=0;
    copy_source[0]=(uint32_t)(uintptr_t)left;copy_source[1]=(uint32_t)(uintptr_t)right;
    copying=active=1;copy_complete=verify_index=0;started=db_time_us();launch();return 1;
}
int db_plcrc_copy_poll(void)
{
    if(!active || !copying)return 0;
    if(fault || (uint32_t)(db_time_us()-started)>500000U){fault=1;return -1;}
    if(!copy_complete) {
        if(!XPacket_crc_accel_IsDone(&core))return 0;
        __asm__ volatile("dsb sy" ::: "memory");
        if(XPacket_crc_accel_Get_completed(&core)!=PAIR_CHUNKS){fault=1;return -1;}
        db_plcrc_timing.copy_hw_us=(uint32_t)(db_time_us()-hardware_started);
        db_plcrc_timing.tx_hw_us=db_plcrc_timing.copy_hw_us;
        Xil_DCacheInvalidateRange((INTPTR)results[pending.bank],sizeof(results[pending.bank]));
        copy_complete=1;phase=2;
    }
    return 1;
}
int db_plcrc_copy_commit(void)
{
    if(!active || !copying || !copy_complete || fault)return 0;
    /* The caller has checked stable capture tags and invalidated the copied
     * destination. Remaining verification reads only the independent copy. */
    copying=0;verification_started=db_time_us();return 1;
}
void db_plcrc_copy_discard(void)
{
    if(active && copying && copy_complete && !fault) {
        copying=copy_complete=active=0;valid[pending.bank]=0;
    }
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
    pending.stamp[0]=ls;pending.stamp[1]=rs;valid[bank]=0;
    /* Both current callers provide clean PL/PS-DMA output after invalidate.
     * CPU reads during first-pair verification do not dirty these pixels. */
    started=db_time_us();active=1;verify_index=0;launch();return 1;
}
void db_crc_amp_schedule_rx(DbReceiver *r,unsigned tx_waiting)
{
    unsigned i;DbSlot *s=NULL;
    if(!enabled || active || fault || !r || !r->defer_crc ||
       (tx_waiting && last_operation==DB_CRC_VERIFY))return;
    for(i=0;i<DB_RX_SLOTS;++i)if(r->slots[i].state==DB_VERIFY_WAIT &&
        (!s || (int32_t)(r->slots[i].frame-s->frame)<0))s=&r->slots[i];
    if(!s)return;
    memset(&pending,0,sizeof(pending));pending.operation=DB_CRC_VERIFY;
    pending.kind=r->kind;pending.session=r->session;pending.frame=s->frame;pending.calibration=r->calibration;
    for(i=0;i<2;++i){pending.source[i]=(uint32_t)(uintptr_t)s->image[i];pending.stamp[i]=s->capture_us[i];}
    rx_owner=r;rx_slot=s;s->state=DB_VERIFYING;
    /* CPU memcpy received the payload. Clean it to DDR before HP reads, in
     * bounded polls so network, audio and keys keep getting serviced. */
    db_cache_begin(&cache,s->image[0],s->image[1],0);
    started=db_time_us();active=1;phase=verify_index=0;
}
int db_crc_amp_poll(void)
{
    unsigned budget,b,first_reference;
    uint32_t poll_started;
    if(!active)return 0;
    if(fault || (uint32_t)(db_time_us()-started)>500000U){fault=1;return -1;}
    /* Capture ownership must be checked at ap_done, before potentially slow
     * first-pair CPU verification. The capture loop performs this handoff. */
    if(copying)return 0;
    if(phase==0) {if(db_cache_poll(&cache))launch();return 0;}
    b=result_bank();
    if(phase==1) {
        if(!XPacket_crc_accel_IsDone(&core))return 0;
        __asm__ volatile("dsb sy" ::: "memory");
        if(XPacket_crc_accel_Get_completed(&core)!=PAIR_CHUNKS){fault=1;return -1;}
        verification_started=db_time_us();
        if(pending.operation==DB_CRC_VERIFY)
            db_plcrc_timing.rx_hw_us=(uint32_t)(verification_started-hardware_started);
        else db_plcrc_timing.tx_hw_us=(uint32_t)(verification_started-hardware_started);
        Xil_DCacheInvalidateRange((INTPTR)results[b],sizeof(results[b]));phase=2;
    }
    first_reference=pending.operation==DB_CRC_VERIFY?!db_crc_amp_rx_verified:!db_crc_amp_verified;
    budget=first_reference?16:pending.operation==DB_CRC_VERIFY?64:256;
    poll_started=db_time_us();
    while(budget-- && verify_index<PAIR_CHUNKS) {
        unsigned cam=verify_index/DB_MAX_CHUNKS,chunk=verify_index%DB_MAX_CHUNKS;
        DbHeader h;uint8_t expected[DB_HEADER_BYTES];
        uint32_t payload=(uint32_t)results[b][verify_index];
        if((uint32_t)(results[b][verify_index]>>32)!=(CRC_MARKER|verify_index)){fault=1;return -1;}
        /* Established TX jobs need only check every metadata marker here.
         * The exact header CRC is constructed once, when sending the packet.
         * RX still checks all original headers; first TX/RX still compares
         * every payload with the independent CPU implementation. */
        if(pending.operation==DB_CRC_TRANSMIT && !first_reference) {
            ++verify_index;
            if((uint32_t)(db_time_us()-poll_started)>=150U)break;
            continue;
        }
        db_crc_header_fields(&h,&pending,cam,chunk);
        if(db_packet_encode_header_crc(expected,sizeof(expected),&h,payload)<0){fault=1;return -1;}
        if(pending.operation==DB_CRC_VERIFY &&
           memcmp(expected,rx_slot->headers+verify_index*DB_HEADER_BYTES,DB_HEADER_BYTES)) {
            /* ap_done was observed: hardware has released all source bytes. */
            rx_slot->state=DB_FREE;++rx_owner->rejected;++db_crc_amp_rx_rejected;
            active=0;last_operation=DB_CRC_VERIFY;rx_owner=NULL;rx_slot=NULL;return 0;
        }
        /* One entire TX and RX pair must agree with CPU CRC, including tail
         * packets, before publishing READY. Mismatch latches a board fault. */
        if(first_reference) {
            uint8_t reference[DB_HEADER_BYTES];
            if(db_packet_encode_header(reference,sizeof(reference),&h,
                (const uint8_t *)(uintptr_t)(pending.source[cam]+h.offset))<0 ||
               memcmp(reference,expected,sizeof(reference))){fault=1;return -1;}
        }
        ++verify_index;
        /* Cooperative deadline: one chunk may exceed it during the first
         * CPU reference, but subsequent chunks yield to network/audio/keys. */
        if((uint32_t)(db_time_us()-poll_started)>=150U)break;
    }
    if(verify_index<PAIR_CHUNKS)return 0;
    last_operation=pending.operation;active=0;
    if(pending.operation==DB_CRC_VERIFY) {
        db_plcrc_timing.rx_verify_us=(uint32_t)(db_time_us()-verification_started);
        db_crc_amp_rx_verified=1;++db_crc_amp_rx_completed;
        db_crc_amp_rx_last_us=(uint32_t)(db_time_us()-started);
        rx_slot->dma_clean=1;
        rx_slot->state=rx_owner->delivered && (int32_t)(rx_slot->frame-rx_owner->watermark)<=0?DB_FREE:DB_READY;
        if(rx_slot->state==DB_READY)++rx_owner->completed;
        rx_owner=NULL;rx_slot=NULL;return 0;
    }
    banks[pending.bank]=pending;valid[pending.bank]=1;db_crc_amp_verified=1;++db_crc_amp_completed;
    db_plcrc_timing.tx_verify_us=(uint32_t)(db_time_us()-verification_started);
    db_crc_amp_last_us=(uint32_t)(db_time_us()-started);
    if(db_crc_amp_last_us>db_crc_amp_max_us)db_crc_amp_max_us=db_crc_amp_last_us;
    return (int)pending.bank+1;
}
int db_crc_amp_try_header(uint8_t *destination,const DbHeader *h,const uint8_t *pixels)
{
    unsigned bank;
    if(!enabled || !destination)return 0;
    for(bank=0;bank<DB_CRC_BANKS;++bank)if(valid[bank] && db_crc_header_matches(&banks[bank],h,pixels)) {
        unsigned n=h->camera*DB_MAX_CHUNKS+h->chunk;
        if(db_packet_encode_header_crc(destination,DB_HEADER_BYTES,h,(uint32_t)results[bank][n])<0)return 0;
        ++db_crc_amp_header_hits;return 1;
    }
    ++db_crc_amp_header_misses;return 0;
}
#endif

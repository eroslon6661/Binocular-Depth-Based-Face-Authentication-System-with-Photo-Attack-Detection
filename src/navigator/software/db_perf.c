#include "db_perf.h"
#if DB_PERF_DIAG
#include "db_log.h"
DbPerfCounter db_perf_counters[DB_PERF_SCOPES];
volatile uint64_t db_perf_irq_ticks,db_perf_irq_max;
volatile uint32_t db_perf_irq_count;
static uint32_t sgbm_started,sgbm_count,sgbm_max;
static uint64_t sgbm_total;
static uint32_t gap_calls,gap_samples,gap_late,gap_max;
static uint64_t gap_total,gap_excess;
static uint64_t mask_started,mask_last_end,mask_total,mask_max;
static uint32_t mask_count,overrun_irqs,overrun_after_mask;
/* Called only from main context. IRQ completes all 64-bit writes before
 * main resumes. Retry if an IRQ overlaps this snapshot: no masking needed. */
static DbPerfStamp snapshot(void)
{
    DbPerfStamp s;uint32_t before;
    do {
        before=db_perf_irq_count;
        s.tick=db_perf_platform_ticks();s.irq=db_perf_irq_ticks;
    } while(before!=db_perf_irq_count);
    s.active=1;return s;
}
DbPerfStamp db_perf_begin(unsigned id)
{
    DbPerfStamp empty={0,0,0};DbPerfCounter *c=&db_perf_counters[id];
    ++c->calls;
    /* Packet and polling paths sampled 1/64; bounded cache/copy/match
     * phases measured every call. No estimate is presented as exact sum. */
    if(id<DB_PERF_CACHE && ((c->calls-1U)&63U))return empty;
    return snapshot();
}
void db_perf_end(unsigned id,DbPerfStamp s)
{
    DbPerfCounter *c;DbPerfStamp e;uint64_t gross,irq,work;
    if(!s.active)return;
    e=snapshot();gross=e.tick-s.tick;irq=e.irq-s.irq;
    work=gross>=irq?gross-irq:0;c=&db_perf_counters[id];
    c->gross+=gross;c->irq+=irq;c->work+=work;++c->samples;
    if(work>c->max)c->max=work;
}
void db_perf_irq_record(uint64_t elapsed)
{
    db_perf_irq_ticks+=elapsed;
    if(elapsed>db_perf_irq_max)db_perf_irq_max=elapsed;
    ++db_perf_irq_count;
}
void db_perf_sgbm_start(uint32_t now){sgbm_started=now;}
void db_perf_sgbm_end(uint32_t now)
{
    uint32_t elapsed=now-sgbm_started;
    sgbm_total+=elapsed;++sgbm_count;
    if(elapsed>sgbm_max)sgbm_max=elapsed;
}
void db_perf_tx_gap(uint32_t elapsed,uint32_t requested)
{
    if((gap_calls++&63U)!=0U)return;
    ++gap_samples;gap_total+=elapsed;
    if(elapsed>requested)gap_excess+=elapsed-requested;
    if(elapsed>requested+5U)++gap_late;
    if(elapsed>gap_max)gap_max=elapsed;
}
void db_perf_mask_enter(uint32_t prior_mask)
{
    /* SDK has already masked IRQ here. Nested cache operations and IRQ
     * callers must not overwrite the outermost main-context interval. */
    if(!(prior_mask&0x80U))mask_started=db_perf_platform_ticks();
}
void db_perf_mask_leave(uint32_t prior_mask)
{
    if(!(prior_mask&0x80U)) {
        uint64_t now=db_perf_platform_ticks(),elapsed=now-mask_started;
        mask_total+=elapsed;++mask_count;if(elapsed>mask_max)mask_max=elapsed;
        mask_last_end=now;
    }
}
void db_perf_overrun_irq(uint64_t now,uint64_t nearby_ticks)
{
    ++overrun_irqs;
    if(mask_last_end && now-mask_last_end<=nearby_ticks)++overrun_after_mask;
}
void db_perf_log_poll(uint32_t now)
{
    static uint32_t last;static unsigned which;
    static const char *names[]={"poll","tx_encode","tx_submit","rx_crc_copy",
        "rx_callback","cache","raw_copy","match"};
    if((uint32_t)(now-last)<250000U)return;
    last=now;
    /* Spread records across the asynchronous UART ring. Cumulative raw
     * ticks avoid periodic resets racing with an active/nested scope. */
    if(which<DB_PERF_SCOPES) {
        DbPerfCounter *c=&db_perf_counters[which];
        db_log("PERF_SCOPE t=%lu id=%s calls=%lu samples=%lu gross=%llu irq=%llu work=%llu max=%llu\r\n",
            (unsigned long)now,names[which],(unsigned long)c->calls,(unsigned long)c->samples,
            (unsigned long long)c->gross,(unsigned long long)c->irq,
            (unsigned long long)c->work,(unsigned long long)c->max);
    } else if(which==DB_PERF_SCOPES) {
        DbPerfStamp s=snapshot();
        db_log("PERF_IRQ t=%lu count=%lu ticks=%llu max=%llu sgbm_count=%lu sgbm_us=%llu sgbm_max_us=%lu\r\n",
            (unsigned long)now,(unsigned long)db_perf_irq_count,
            (unsigned long long)s.irq,(unsigned long long)db_perf_irq_max,
            (unsigned long)sgbm_count,(unsigned long long)sgbm_total,(unsigned long)sgbm_max);
    } else if(which==DB_PERF_SCOPES+1U) {
        db_log("PERF_GAP t=%lu calls=%lu samples=%lu elapsed_us=%llu excess_us=%llu late5=%lu max_us=%lu\r\n",
            (unsigned long)now,(unsigned long)gap_calls,(unsigned long)gap_samples,
            (unsigned long long)gap_total,(unsigned long long)gap_excess,
            (unsigned long)gap_late,(unsigned long)gap_max);
    } else {
        db_log("PERF_MASK t=%lu count=%lu ticks=%llu max=%llu overrun_irq=%lu after_mask100=%lu\r\n",
            (unsigned long)now,(unsigned long)mask_count,(unsigned long long)mask_total,
            (unsigned long long)mask_max,(unsigned long)overrun_irqs,(unsigned long)overrun_after_mask);
    }
    which=(which+1U)%(DB_PERF_SCOPES+3U);
}
#endif

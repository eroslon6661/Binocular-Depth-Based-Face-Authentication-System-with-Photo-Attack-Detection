#ifndef DB_PERF_H
#define DB_PERF_H
#include <stdint.h>
#ifndef DB_PERF_DIAG
#define DB_PERF_DIAG 0
#endif
#ifndef DB_PERF_CACHE_MASK
#define DB_PERF_CACHE_MASK 0
#endif
enum { DB_PERF_POLL, DB_PERF_TX_ENCODE, DB_PERF_TX_SUBMIT, DB_PERF_RX_CRC,
       DB_PERF_RX_CALLBACK, DB_PERF_CACHE, DB_PERF_COPY, DB_PERF_MATCH,
       DB_PERF_SCOPES };
typedef struct {uint64_t tick,irq;unsigned active;} DbPerfStamp;
#if DB_PERF_DIAG
typedef struct {uint64_t gross,irq,work,max;uint32_t calls,samples;} DbPerfCounter;
extern DbPerfCounter db_perf_counters[DB_PERF_SCOPES];
extern volatile uint64_t db_perf_irq_ticks,db_perf_irq_max;
extern volatile uint32_t db_perf_irq_count;
uint64_t db_perf_platform_ticks(void);
DbPerfStamp db_perf_begin(unsigned id);
void db_perf_end(unsigned id,DbPerfStamp stamp);
void db_perf_irq_record(uint64_t elapsed);
void db_perf_log_poll(uint32_t now);
void db_perf_sgbm_start(uint32_t now);
void db_perf_sgbm_end(uint32_t now);
void db_perf_tx_gap(uint32_t elapsed,uint32_t requested);
void db_perf_mask_enter(uint32_t prior_mask);
void db_perf_mask_leave(uint32_t prior_mask);
void db_perf_overrun_irq(uint64_t now,uint64_t nearby_ticks);
#else
static inline DbPerfStamp db_perf_begin(unsigned id){DbPerfStamp s={0,0,0};(void)id;return s;}
static inline void db_perf_end(unsigned id,DbPerfStamp s){(void)id;(void)s;}
static inline void db_perf_log_poll(uint32_t now){(void)now;}
static inline void db_perf_sgbm_start(uint32_t now){(void)now;}
static inline void db_perf_sgbm_end(uint32_t now){(void)now;}
static inline void db_perf_tx_gap(uint32_t elapsed,uint32_t requested){(void)elapsed;(void)requested;}
#endif
#endif

#ifndef DB_CLOCK_H
#define DB_CLOCK_H
#include <stdint.h>
typedef struct {
    uint64_t second_tick,reciprocal;
    uint32_t frequency,base_us,base_ms,calls,rollovers;
} DbClock;
/* One owner, or caller must protect the entire read/update against IRQs. */
int db_clock_init(DbClock *clock,uint32_t frequency);
void db_clock_read(DbClock *clock,uint64_t ticks,uint32_t *us,uint32_t *ms);
/* Immutable reciprocals: safe to share with IRQs, with no anchor, lock or
 * per-read division. Frequency must exceed one MHz, as for DbClock. */
typedef struct {
    uint32_t frequency;
    uint64_t divisor,micro,milli;
} DbClockRatio;
#define DB_CLOCK_SCALE_RECIP(f,s) ((UINT64_MAX/(f))*(s)+(((UINT64_MAX%(f)+1ULL)*(s))/(f)))
#define DB_CLOCK_RATIO_INITIALIZER(f) {(f),UINT64_MAX/(f),DB_CLOCK_SCALE_RECIP(f,1000000ULL),DB_CLOCK_SCALE_RECIP(f,1000ULL)}
int db_clock_ratio_init(DbClockRatio *ratio,uint32_t frequency);
uint32_t db_clock_ratio_us(const DbClockRatio *ratio,uint64_t ticks);
uint32_t db_clock_ratio_ms(const DbClockRatio *ratio,uint64_t ticks);
#endif

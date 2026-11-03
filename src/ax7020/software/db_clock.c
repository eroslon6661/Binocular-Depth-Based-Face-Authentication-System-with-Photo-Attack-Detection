#include "db_clock.h"
#include <string.h>
/* Upper half of a 64x64 product using A9's native 32x32 multiplies.
 * Each intermediate sum fits 64 bits; no compiler 128-bit extension. */
static uint64_t multiply_high(uint64_t a,uint64_t b)
{
    uint64_t low=(uint64_t)(uint32_t)a*(uint32_t)b;
    uint64_t middle=(a>>32)*(uint32_t)b+(low>>32);
    uint64_t carry=(uint32_t)middle;
    uint64_t high=middle>>32;
    carry+=(uint64_t)(uint32_t)a*(b>>32);
    return (a>>32)*(b>>32)+high+(carry>>32);
}
int db_clock_ratio_init(DbClockRatio *ratio,uint32_t frequency)
{
    if(!ratio || frequency<=1000000U)return 0;
    *ratio=(DbClockRatio)DB_CLOCK_RATIO_INITIALIZER(frequency);return 1;
}
static uint32_t convert(const DbClockRatio *ratio,uint64_t ticks,uint64_t reciprocal,uint32_t scale)
{
    uint64_t seconds=multiply_high(ticks,ratio->divisor);
    uint64_t remainder=ticks-seconds*ratio->frequency;
    uint64_t product;
    uint32_t fraction;
    /* floor((2^64-1)/f) underestimates ticks/f by at most one. */
    if(remainder>=ratio->frequency){++seconds;remainder-=ratio->frequency;}
    fraction=(uint32_t)multiply_high(remainder,reciprocal);
    product=remainder*scale;
    /* The scaled reciprocal underestimates by < remainder/2^64.
     * One comparison restores exact floor division, including boundaries. */
    if((uint64_t)(fraction+1U)*ratio->frequency<=product)++fraction;
    return (uint32_t)seconds*scale+fraction;
}
uint32_t db_clock_ratio_us(const DbClockRatio *ratio,uint64_t ticks)
{return convert(ratio,ticks,ratio->micro,1000000U);}
uint32_t db_clock_ratio_ms(const DbClockRatio *ratio,uint64_t ticks)
{return convert(ratio,ticks,ratio->milli,1000U);}
int db_clock_init(DbClock *c,uint32_t frequency)
{
    if(!c || frequency<=1000000U)return 0;
    memset(c,0,sizeof(*c));c->frequency=frequency;
    /* ceil(2^64 * 10^6 / frequency), without a 128-bit operation. */
    c->reciprocal=(UINT64_MAX/frequency)*1000000ULL+
        (((UINT64_MAX%frequency+1ULL)*1000000ULL+frequency-1ULL)/frequency);
    return 1;
}
void db_clock_read(DbClock *c,uint64_t ticks,uint32_t *us,uint32_t *ms)
{
    uint64_t delta,low,high;
    uint32_t fraction,micro;
    if(ticks<c->second_tick){c->second_tick=0;c->base_us=c->base_ms=0;}
    delta=ticks-c->second_tick;
    if(delta>=c->frequency) {
        uint64_t seconds=delta/c->frequency;
        c->second_tick+=seconds*c->frequency;
        c->base_us+=(uint32_t)seconds*1000000U;c->base_ms+=(uint32_t)seconds*1000U;
        delta=ticks-c->second_tick;++c->rollovers;
    }
    fraction=(uint32_t)delta;
    low=(uint64_t)fraction*(uint32_t)c->reciprocal;
    high=(uint64_t)fraction*(c->reciprocal>>32)+(low>>32);
    micro=(uint32_t)(high>>32);
    /* Reciprocal rounding error is <frequency/2^64 <1/frequency;
     * therefore floor(fraction*10^6/frequency) is exact, even on a boundary. */
    if(us)*us=c->base_us+micro;
    if(ms)*ms=c->base_ms+micro/1000U;
    ++c->calls;
}

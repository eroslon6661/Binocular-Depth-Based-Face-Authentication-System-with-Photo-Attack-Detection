#include "db_flight.h"
#include <string.h>
void db_flight_init(DbFlight *f,uint32_t timeout_us)
{
    memset(f,0,sizeof(*f));f->timeout_us=timeout_us;
}
void db_flight_expire(DbFlight *f,uint32_t now)
{
    unsigned i;
    for(i=0;i<DB_FLIGHT_CAPACITY;++i)if(f->used[i] &&
        (uint32_t)(now-f->sent_us[i])>=f->timeout_us) {
        f->used[i]=0;--f->count;++f->expired;
    }
    /* Expiry only retires bookkeeping: it never releases CPU/PL/GEM-owned
     * image memory. Existing ownership and receiver timeouts still apply. */
}
int db_flight_available(DbFlight *f,uint32_t now)
{
    db_flight_expire(f,now);
    if(f->count<DB_FLIGHT_CAPACITY)return 1;
    ++f->waits;return 0;
}
int db_flight_sent(DbFlight *f,uint32_t frame,uint32_t now)
{
    unsigned i;
    if(f->count==DB_FLIGHT_CAPACITY)return 0;
    for(i=0;i<DB_FLIGHT_CAPACITY;++i)if(f->used[i] && f->frame[i]==frame)return 0;
    for(i=0;i<DB_FLIGHT_CAPACITY;++i)if(!f->used[i]) {
        f->used[i]=1;f->frame[i]=frame;f->sent_us[i]=now;
        if(++f->count>f->peak)f->peak=f->count;
        return 1;
    }
    return 0;
}
void db_flight_complete(DbFlight *f,uint32_t frame)
{
    unsigned i;
    /* The receiver consumes the latest pair and discards older incomplete
     * pairs. Retire earlier tickets too, without touching their buffers. */
    for(i=0;i<DB_FLIGHT_CAPACITY;++i)if(f->used[i] &&
        (int32_t)(frame-f->frame[i])>=0) {
        f->used[i]=0;--f->count;++f->acknowledged;
    }
}

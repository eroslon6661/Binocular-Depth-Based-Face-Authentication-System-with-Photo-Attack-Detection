#include "db_access.h"
#include <string.h>

void db_access_init(DbAccess *a)
{
    if(a)memset(a,0,sizeof(*a));
}

DbAccessEvent db_access_decide(DbAccess *a,unsigned identity_ok,unsigned live_ok,uint32_t now)
{
    DbAccessEvent event;
    if(!a)return DB_ACCESS_EVENT_NONE;
    if(identity_ok && live_ok) {
        a->unlocked=1U;
        a->close_at_us=now+DB_ACCESS_OPEN_US;
        event=DB_ACCESS_EVENT_OPENED;
    } else if(!identity_ok && live_ok) {
        event=DB_ACCESS_EVENT_DENY_UNKNOWN_LIVE;
    } else if(!identity_ok) {
        event=DB_ACCESS_EVENT_DENY_UNKNOWN_SPOOF;
    } else {
        event=DB_ACCESS_EVENT_DENY_USER001_SPOOF;
    }
    a->last_event=event;
    return event;
}

DbAccessEvent db_access_poll(DbAccess *a,uint32_t now)
{
    if(!a || !a->unlocked || (int32_t)(now-a->close_at_us)<0)return DB_ACCESS_EVENT_NONE;
    a->unlocked=0U;
    a->close_at_us=0U;
    a->last_event=DB_ACCESS_EVENT_CLOSED;
    return DB_ACCESS_EVENT_CLOSED;
}

unsigned db_access_unlocked(const DbAccess *a)
{
    return a?a->unlocked:0U;
}

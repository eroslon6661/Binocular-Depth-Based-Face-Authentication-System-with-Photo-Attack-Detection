#ifndef DB_ACCESS_H
#define DB_ACCESS_H

#include <stdint.h>

#define DB_ACCESS_OPEN_US 5000000U

typedef enum {
    DB_ACCESS_EVENT_NONE=0,
    DB_ACCESS_EVENT_OPENED,
    DB_ACCESS_EVENT_CLOSED,
    DB_ACCESS_EVENT_DENY_UNKNOWN_LIVE,
    DB_ACCESS_EVENT_DENY_UNKNOWN_SPOOF,
    DB_ACCESS_EVENT_DENY_USER001_SPOOF
} DbAccessEvent;

typedef struct {
    uint32_t close_at_us;
    unsigned unlocked;
    DbAccessEvent last_event;
} DbAccess;

void db_access_init(DbAccess *access);
DbAccessEvent db_access_decide(DbAccess *access,unsigned identity_ok,unsigned live_ok,uint32_t now_us);
DbAccessEvent db_access_poll(DbAccess *access,uint32_t now_us);
unsigned db_access_unlocked(const DbAccess *access);

#endif

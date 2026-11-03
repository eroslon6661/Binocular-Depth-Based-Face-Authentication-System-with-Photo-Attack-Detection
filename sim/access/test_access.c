#include "db_access.h"
#include <assert.h>
#include <stdio.h>

int main(void)
{
    DbAccess access;
    db_access_init(&access);
    assert(!db_access_unlocked(&access));

    assert(db_access_decide(&access,0,1,100U)==DB_ACCESS_EVENT_DENY_UNKNOWN_LIVE);
    assert(!db_access_unlocked(&access));
    assert(db_access_decide(&access,0,0,200U)==DB_ACCESS_EVENT_DENY_UNKNOWN_SPOOF);
    assert(!db_access_unlocked(&access));
    assert(db_access_decide(&access,1,0,300U)==DB_ACCESS_EVENT_DENY_USER001_SPOOF);
    assert(!db_access_unlocked(&access));

    assert(db_access_decide(&access,1,1,0xfffffff0U)==DB_ACCESS_EVENT_OPENED);
    assert(db_access_unlocked(&access));
    assert(db_access_poll(&access,0x00000010U)==DB_ACCESS_EVENT_NONE);
    assert(db_access_unlocked(&access));
    assert(db_access_poll(&access,0xfffffff0U+DB_ACCESS_OPEN_US-1U)==DB_ACCESS_EVENT_NONE);
    assert(db_access_poll(&access,0xfffffff0U+DB_ACCESS_OPEN_US)==DB_ACCESS_EVENT_CLOSED);
    assert(!db_access_unlocked(&access));
    assert(db_access_poll(&access,0U)==DB_ACCESS_EVENT_NONE);

    puts("ACCESS TESTS PASSED: four decisions, five-second auto-close, timer wraparound");
    return 0;
}

#ifndef DB_FLIGHT_H
#define DB_FLIGHT_H
#include <stdint.h>
/* End-to-end window; no control datagrams or protocol change. A validated
 * returned pair is acknowledged only after the SGBM readers release it. */
#define DB_FLIGHT_CAPACITY 3U
typedef struct {
    uint32_t frame[DB_FLIGHT_CAPACITY],sent_us[DB_FLIGHT_CAPACITY];
    unsigned used[DB_FLIGHT_CAPACITY],count,peak;
    uint32_t timeout_us,expired,acknowledged,waits;
} DbFlight;
void db_flight_init(DbFlight *f,uint32_t timeout_us);
void db_flight_expire(DbFlight *f,uint32_t now);
int db_flight_available(DbFlight *f,uint32_t now);
int db_flight_sent(DbFlight *f,uint32_t frame,uint32_t now);
void db_flight_complete(DbFlight *f,uint32_t frame);
#endif

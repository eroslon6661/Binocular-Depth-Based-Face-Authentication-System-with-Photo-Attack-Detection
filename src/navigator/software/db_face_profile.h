#ifndef DB_FACE_PROFILE_H
#define DB_FACE_PROFILE_H
#include <stdint.h>
typedef struct {
 uint32_t run;
 uint16_t net,op,type,layer;
 uint32_t cache_us,submit_us,wait_us,cpu_us,bytes;
} DbFacePerfEvent;
/* Single CPU0 producer/consumer. Never waits for UART or changes inference. */
void db_face_profile_push(const DbFacePerfEvent *event);
void db_face_profile_poll(uint32_t now_us);
#endif

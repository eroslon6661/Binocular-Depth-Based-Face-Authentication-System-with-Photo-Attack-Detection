#include "db_face_profile.h"
#include "db_log.h"
#define PERF_EVENTS 128U
static DbFacePerfEvent events[PERF_EVENTS];
static unsigned producer,consumer,dropped;
static uint32_t last_emit;
void db_face_profile_push(const DbFacePerfEvent *event)
{
 if(!event)return;
 if(producer-consumer==PERF_EVENTS){++dropped;return;}
 events[producer++&(PERF_EVENTS-1U)]=*event;
}
void db_face_profile_poll(uint32_t now)
{
 const DbFacePerfEvent *e;
 if((uint32_t)(now-last_emit)<20000U || db_log_space()<256U)return;
 if(dropped){db_log("FACE_PERF_DROP events=%u\r\n",dropped);dropped=0;last_emit=now;return;}
 if(consumer==producer)return;
 e=&events[consumer++&(PERF_EVENTS-1U)];last_emit=now;
 /* wait_us includes accelerator execution AND main-loop polling delay.
  * cpu_us includes flushes performed within CPU fallback operations. */
 db_log("FACE_PERF run=%lu net=%u op=%u type=%u layer=%u cache_us=%lu submit_us=%lu wait_us=%lu cpu_us=%lu bytes=%lu\r\n",
  (unsigned long)e->run,e->net,e->op,e->type,e->layer,
  (unsigned long)e->cache_us,(unsigned long)e->submit_us,(unsigned long)e->wait_us,
  (unsigned long)e->cpu_us,(unsigned long)e->bytes);
}

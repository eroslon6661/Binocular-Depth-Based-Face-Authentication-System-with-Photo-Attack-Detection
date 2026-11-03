#ifndef DB_TOUCH_H
#define DB_TOUCH_H
#include <stdint.h>
/* All calls are nonblocking. poll advances at most ONE I2C phase. */
typedef struct {
 void (*drive)(void *,unsigned); /* SCL/SDA pull-low bits; 0 releases both */
 unsigned (*sense)(void *);      /* SCL/SDA sampled high bits */
 void *context;
} DbI2cPins;
typedef struct {
 DbI2cPins pins;
 uint8_t tx[20],rx[16];
 unsigned state,pos,len,count,bit,value,read,reading,error;
 uint32_t start,last;
 int result;
} DbI2c;
void db_i2c_init(DbI2c *,const DbI2cPins *);
int db_i2c_begin(DbI2c *,unsigned address,unsigned reg,const uint8_t *data,unsigned count,unsigned read,uint32_t now);
void db_i2c_poll(DbI2c *,uint32_t now);
typedef struct {
 DbI2c bus;
 void (*control)(void *,unsigned reset_high,unsigned int_low);
 void *context;
 unsigned phase,online,errors,width,height,down,contacts,x,y,updated;
 unsigned profile_width,profile_height,using_profile;
 unsigned reporting,last_status,firmware,status_reads,ready_reports,malformed_reports;
 uint32_t deadline;
} DbTouch;
void db_touch_init(DbTouch *,const DbI2cPins *,void (*control)(void *,unsigned,unsigned),void *,uint32_t now);
/* Optional panel coordinate profile, used only if both documented resolution
 * sources return exactly zero after a verified GT911 product ID. */
void db_touch_set_profile(DbTouch *,unsigned width,unsigned height);
void db_touch_poll(DbTouch *,uint32_t now);
#endif

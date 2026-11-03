#ifndef DB_LOG_H
#define DB_LOG_H
void db_log(const char *format,...);
unsigned db_log_space(void);
void db_log_poll(unsigned byte_budget);
#endif

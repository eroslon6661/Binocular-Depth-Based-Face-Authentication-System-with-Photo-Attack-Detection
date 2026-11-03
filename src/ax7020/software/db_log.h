#ifndef DB_LOG_H
#define DB_LOG_H
void db_log(const char *format,...);
void db_log_poll(unsigned byte_budget);
#endif

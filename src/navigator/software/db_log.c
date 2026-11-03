/* UART polling must not block packet processing for several milliseconds. */
#include "db_log.h"
#include "xuartps_hw.h"
#include "xparameters.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdint.h>
static char ring[2048];
static unsigned producer,consumer;
void db_log(const char *format,...)
{
    char line[256];int count;unsigned i;
    va_list args;va_start(args,format);
    count=vsnprintf(line,sizeof(line),format,args);va_end(args);
    if(count<=0)return;
    if(count>=(int)sizeof(line))count=sizeof(line)-1;
    if((unsigned)count>sizeof(ring)-1U-(unsigned)(producer-consumer))return;
    for(i=0;i<(unsigned)count;++i)ring[(producer++)&(sizeof(ring)-1U)]=line[i];
}
void db_log_poll(unsigned budget)
{
    while(budget-- && consumer!=producer) {
        if(XUartPs_ReadReg(XPAR_XUARTPS_0_BASEADDR,XUARTPS_SR_OFFSET)&XUARTPS_SR_TXFULL)return;
        XUartPs_WriteReg(XPAR_XUARTPS_0_BASEADDR,XUARTPS_FIFO_OFFSET,
                        (uint8_t)ring[(consumer++)&(sizeof(ring)-1U)]);
    }
}

unsigned db_log_space(void)
{return sizeof(ring)-1U-(unsigned)(producer-consumer);}

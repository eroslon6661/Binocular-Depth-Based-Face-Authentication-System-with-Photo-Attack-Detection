#include "xiicps.h"
#include "xiicps_xfer.h"
#include "xtime_l.h"
#include "xstatus.h"
/* One-byte ES8388 read after its register-address write with repeated START.
 * The SDK 3.16 polled RX loop has no software deadline and omits TO from
 * its error mask. Keep its one-byte setup/order, but bound a stalled bus. */
int voice_codec_recv_one(XIicPs *bus,u8 *value)
{
    UINTPTR base=bus->Config.BaseAddress;
    const u32 errors=XIICPS_IXR_ARB_LOST_MASK|XIICPS_IXR_RX_OVR_MASK|
        XIICPS_IXR_RX_UNF_MASK|XIICPS_IXR_NACK_MASK|XIICPS_IXR_TO_MASK;
    XTime start,now;
    int status=XST_FAILURE;
    if(!value || bus->IsRepeatedStart)return XST_FAILURE;
    if(XIicPs_SetupMaster(bus,RECVING_ROLE)!=XST_SUCCESS)return XST_FAILURE;
    XIicPs_WriteReg(base,XIICPS_ISR_OFFSET,XIicPs_ReadReg(base,XIICPS_ISR_OFFSET));
    XIicPs_WriteReg(base,XIICPS_TRANS_SIZE_OFFSET,1U);
    XIicPs_WriteReg(base,XIICPS_ADDR_OFFSET,0x10U);
    XTime_GetTime(&start);
    for(;;) {
        u32 irq=XIicPs_ReadReg(base,XIICPS_ISR_OFFSET);
        if(irq&errors)break;
        if(XIicPs_ReadReg(base,XIICPS_SR_OFFSET)&XIICPS_SR_RXDV_MASK) {
            *value=(u8)XIicPs_ReadReg(base,XIICPS_DATA_OFFSET);
            if(!(XIicPs_ReadReg(base,XIICPS_ISR_OFFSET)&errors))status=XST_SUCCESS;
            break;
        }
        XTime_GetTime(&now);
        if(now-start>=COUNTS_PER_SECOND/100U)break;
    }
    XIicPs_WriteReg(base,XIICPS_CR_OFFSET,
        XIicPs_ReadReg(base,XIICPS_CR_OFFSET)&~XIICPS_CR_HOLD_MASK);
    return status;
}

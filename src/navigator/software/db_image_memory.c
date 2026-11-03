#include "db_image_memory.h"
#include "db_config.h"
#include "xil_mmu.h"
int db_image_range_l1(uintptr_t address,unsigned length)
{
    const uint32_t bases[3]={DB_RAW_TX_BASE,DB_NETWORK_RX_BASE,DB_WORKER_OUTPUT_BASE};unsigned i;
    if(!DB_IMAGE_L1_ONLY || !length || length>6U*DB_IMAGE_BYTES)return 0;
    for(i=0;i<3;++i)if(address>=bases[i] && address-bases[i]<=6U*DB_IMAGE_BYTES-length)return 1;
    return 0;
}
void db_image_memory_init(void)
{
#if DB_IMAGE_L1_ONLY
    const uint32_t bases[3]={DB_RAW_TX_BASE,DB_NETWORK_RX_BASE,DB_WORKER_OUTPUT_BASE};unsigned i,offset;
    /* Boot only, before CPU1 and ALL DMA. SDK cleans old L2 attributes and
     * invalidates TLBs; six exclusive 1-MiB sections cover each triple pair. */
    for(i=0;i<3;++i)for(offset=0;offset<6U*DB_IMAGE_BYTES;offset+=0x100000U)
        Xil_SetTlbAttributes(bases[i]+offset,DB_IMAGE_L1_ATTRIBUTES);
#endif
}

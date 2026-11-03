#include "db_crc_combine.h"
#include "db_wire.h"
static uint32_t shifts[2][4][256];
static unsigned initialized;
static uint32_t apply(const uint32_t *matrix,uint32_t value)
{
    uint32_t result=0;unsigned bit=0;
    while(value) {if(value&1U)result^=matrix[bit];value>>=1;++bit;}
    return result;
}
static void square(uint32_t *out,const uint32_t *matrix)
{
    unsigned bit;for(bit=0;bit<32;++bit)out[bit]=apply(matrix,matrix[bit]);
}
static void byte_operator(uint32_t *out,size_t count)
{
    uint32_t power[32],next[32];unsigned bit;
    for(bit=0;bit<32;++bit) {
        uint32_t v=1U<<bit;unsigned k;
        for(k=0;k<8;++k)v=(v>>1)^(0xedb88320U&(0U-(v&1U)));
        power[bit]=v;out[bit]=1U<<bit;
    }
    while(count) {
        if(count&1U)for(bit=0;bit<32;++bit)out[bit]=apply(power,out[bit]);
        count>>=1;
        if(count) {square(next,power);for(bit=0;bit<32;++bit)power[bit]=next[bit];}
    }
}
void db_crc32_combine_init(void)
{
    unsigned variant,byte,value;
    if(initialized)return;
    for(variant=0;variant<2;++variant) {
        uint32_t op[32];
        size_t n=variant?DB_IMAGE_BYTES-(DB_MAX_CHUNKS-1U)*DB_PAYLOAD_BYTES:DB_PAYLOAD_BYTES;
        byte_operator(op,n);
        for(byte=0;byte<4;++byte)for(value=0;value<256;++value)
            shifts[variant][byte][value]=apply(op,(uint32_t)value<<(8U*byte));
    }
    initialized=1;
}
uint32_t db_crc32_combine(uint32_t first,uint32_t second,size_t bytes)
{
    unsigned variant;
    uint32_t shifted;
    if(!bytes)return first;
    if(bytes==DB_PAYLOAD_BYTES)variant=0;
    else if(bytes==DB_IMAGE_BYTES-(DB_MAX_CHUNKS-1U)*DB_PAYLOAD_BYTES)variant=1;
    else {uint32_t op[32];byte_operator(op,bytes);return apply(op,first)^second;}
    db_crc32_combine_init();
    shifted=shifts[variant][0][first&255U]^shifts[variant][1][(first>>8)&255U]^
            shifts[variant][2][(first>>16)&255U]^shifts[variant][3][first>>24];
    return shifted^second;
}

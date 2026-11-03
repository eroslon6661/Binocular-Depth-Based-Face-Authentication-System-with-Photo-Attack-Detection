#include "db_wire.h"
#include "db_crc_combine.h"
int db_packet_encode_header_crc(uint8_t *header,size_t capacity,const DbHeader *h,uint32_t payload_crc)
{
    int bytes=db_packet_write_fields(header,capacity,h);
    uint32_t crc;
    if(bytes<0)return bytes;
    crc=db_crc32_combine(db_crc32(header,44),payload_crc,h->length);
    header[44]=(uint8_t)(crc>>24);header[45]=(uint8_t)(crc>>16);
    header[46]=(uint8_t)(crc>>8);header[47]=(uint8_t)crc;
    return bytes;
}

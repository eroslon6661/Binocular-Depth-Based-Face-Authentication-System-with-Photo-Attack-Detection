#include "db_crc_headers.h"
#include <string.h>
int db_crc_header_fields(DbHeader *h,const DbCrcWork *w,unsigned cam,unsigned chunk)
{
    if(!h || !w || cam>1 || chunk>=DB_MAX_CHUNKS || !w->session || !w->calibration ||
       (w->kind!=DB_RAW && w->kind!=DB_RECTIFIED))return 0;
    memset(h,0,sizeof(*h));h->kind=(uint8_t)w->kind;h->session=w->session;
    h->frame=w->frame;h->calibration=w->calibration;h->format=DB_GREEN8;
    h->width=DB_WIDTH;h->height=DB_HEIGHT;h->chunks=DB_MAX_CHUNKS;h->image_bytes=DB_IMAGE_BYTES;
    h->camera=(uint8_t)cam;h->chunk=(uint16_t)chunk;h->offset=chunk*DB_PAYLOAD_BYTES;
    h->length=(uint16_t)(DB_IMAGE_BYTES-h->offset>DB_PAYLOAD_BYTES?DB_PAYLOAD_BYTES:DB_IMAGE_BYTES-h->offset);
    h->capture_us=w->stamp[cam];return 1;
}
int db_crc_make_headers(uint8_t *headers,const DbCrcWork *w,
                        const uint8_t *left,const uint8_t *right)
{
    DbHeader h;unsigned cam,chunk;
    const uint8_t *images[2]={left,right};
    if(!headers || !w || !left || !right || !w->session || !w->calibration ||
       (w->kind!=DB_RAW && w->kind!=DB_RECTIFIED))return 0;
    for(cam=0;cam<2;++cam)for(chunk=0;chunk<DB_MAX_CHUNKS;++chunk) {
        if(!db_crc_header_fields(&h,w,cam,chunk))return 0;
        if(db_packet_encode_header(headers+(cam*DB_MAX_CHUNKS+chunk)*DB_HEADER_BYTES,
            DB_HEADER_BYTES,&h,images[cam]+h.offset)<0)return 0;
    }
    return 1;
}
int db_crc_check_headers(const uint8_t *headers,const DbCrcWork *w,
                         const uint8_t *left,const uint8_t *right)
{
    uint8_t expected[DB_HEADER_BYTES];DbHeader h;unsigned cam,chunk;
    const uint8_t *images[2]={left,right};
    if(!headers || !w || !left || !right)return 0;
    for(cam=0;cam<2;++cam)for(chunk=0;chunk<DB_MAX_CHUNKS;++chunk) {
        if(!db_crc_header_fields(&h,w,cam,chunk) ||
           db_packet_encode_header(expected,sizeof(expected),&h,images[cam]+h.offset)<0 ||
           memcmp(expected,headers+(cam*DB_MAX_CHUNKS+chunk)*DB_HEADER_BYTES,DB_HEADER_BYTES))return 0;
    }
    return 1;
}
int db_crc_header_matches(const DbCrcWork *w,const DbHeader *h,const uint8_t *pixels)
{
    uint32_t offset,length;
    if(!w || !h || !pixels || h->camera>1 || h->chunk>=DB_MAX_CHUNKS)return 0;
    offset=(uint32_t)h->chunk*DB_PAYLOAD_BYTES;length=DB_IMAGE_BYTES-offset;
    if(length>DB_PAYLOAD_BYTES)length=DB_PAYLOAD_BYTES;
    return h->kind==w->kind && h->session==w->session && h->frame==w->frame &&
        h->calibration==w->calibration && h->format==DB_GREEN8 && !h->flags &&
        h->width==DB_WIDTH && h->height==DB_HEIGHT && h->chunks==DB_MAX_CHUNKS &&
        h->image_bytes==DB_IMAGE_BYTES && h->offset==offset && h->length==length &&
        h->capture_us==w->stamp[h->camera] &&
        (uintptr_t)pixels==(uintptr_t)w->source[h->camera]+offset;
}

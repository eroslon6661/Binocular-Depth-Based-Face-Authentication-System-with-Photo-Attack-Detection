#include "db_wire.h"
#include "db_perf.h"
#include <string.h>

static uint32_t crc_table[16][256];
static int crc_ready;
/* out is either NULL or private, unseen receive storage. CRC failure never
 * publishes that storage. Fixed-size memcpy preserves unaligned safety. */
static uint32_t crc_update(uint32_t c, const uint8_t *p, size_t n,uint8_t *out)
{
    unsigned i, j;
    if (!crc_ready) {
        for (i = 0; i < 256; ++i) {
            uint32_t v = i;
            for (j = 0; j < 8; ++j) v = (v >> 1) ^ (0xEDB88320U & (0U - (v & 1U)));
            crc_table[0][i] = v;
        }
        for (j = 1; j < 16; ++j) {
            for (i = 0; i < 256; ++i) {
                uint32_t v = crc_table[j-1][i];
                crc_table[j][i] = (v >> 8) ^ crc_table[0][v & 255U];
            }
        }
        crc_ready = 1;
    }
    /* Sixteen bytes per dependency chain; same IEEE CRC and all payload
     * bytes remain checked. The optional stores fuse receive CRC and copy. */
    while(n>=16U) {
        uint32_t a,b,d,e;
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
        memcpy(&a,p,4);memcpy(&b,p+4,4);memcpy(&d,p+8,4);memcpy(&e,p+12,4);
#else
        a=(uint32_t)p[0]|((uint32_t)p[1]<<8)|((uint32_t)p[2]<<16)|((uint32_t)p[3]<<24);
        b=(uint32_t)p[4]|((uint32_t)p[5]<<8)|((uint32_t)p[6]<<16)|((uint32_t)p[7]<<24);
        d=(uint32_t)p[8]|((uint32_t)p[9]<<8)|((uint32_t)p[10]<<16)|((uint32_t)p[11]<<24);
        e=(uint32_t)p[12]|((uint32_t)p[13]<<8)|((uint32_t)p[14]<<16)|((uint32_t)p[15]<<24);
#endif
        if(out) {
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
            memcpy(out,&a,4);memcpy(out+4,&b,4);memcpy(out+8,&d,4);memcpy(out+12,&e,4);
#else
            memcpy(out,p,16);
#endif
            out+=16;
        }
        a^=c;
        c=crc_table[15][a&255U]^crc_table[14][(a>>8)&255U]^
          crc_table[13][(a>>16)&255U]^crc_table[12][a>>24]^
          crc_table[11][b&255U]^crc_table[10][(b>>8)&255U]^
          crc_table[9][(b>>16)&255U]^crc_table[8][b>>24]^
          crc_table[7][d&255U]^crc_table[6][(d>>8)&255U]^
          crc_table[5][(d>>16)&255U]^crc_table[4][d>>24]^
          crc_table[3][e&255U]^crc_table[2][(e>>8)&255U]^
          crc_table[1][(e>>16)&255U]^crc_table[0][e>>24];
        p+=16;n-=16;
    }
    while (n >= 8U) {
#if defined(__BYTE_ORDER__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
        /* memcpy permits unaligned input without type-punning UB. On A9
         * GCC emits word loads instead of eight separate byte loads. */
        uint32_t low,high;
        memcpy(&low,p,4);memcpy(&high,p+4,4);
        if(out){memcpy(out,&low,4);memcpy(out+4,&high,4);out+=8;}
        c^=low;
        c = crc_table[7][c & 255U] ^ crc_table[6][(c >> 8) & 255U] ^
            crc_table[5][(c >> 16) & 255U] ^ crc_table[4][c >> 24] ^
            crc_table[3][high & 255U] ^ crc_table[2][(high >> 8) & 255U] ^
            crc_table[1][(high >> 16) & 255U] ^ crc_table[0][high >> 24];
#else
        if(out){memcpy(out,p,8);out+=8;}
        c ^= (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
             ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
        c = crc_table[7][c & 255U] ^ crc_table[6][(c >> 8) & 255U] ^
            crc_table[5][(c >> 16) & 255U] ^ crc_table[4][c >> 24] ^
            crc_table[3][p[4]] ^ crc_table[2][p[5]] ^
            crc_table[1][p[6]] ^ crc_table[0][p[7]];
#endif
        p += 8; n -= 8;
    }
    while (n--) {
        uint8_t value=*p++;if(out)*out++=value;
        c=(c>>8)^crc_table[0][(c^value)&255U];
    }
    return c;
}
uint32_t db_crc32(const void *p, size_t n) { return ~crc_update(~0U, (const uint8_t *)p, n,NULL); }
static void put16(uint8_t *p, uint16_t v) { p[0]=(uint8_t)(v>>8); p[1]=(uint8_t)v; }
static void put32(uint8_t *p, uint32_t v) { put16(p,(uint16_t)(v>>16)); put16(p+2,(uint16_t)v); }
static uint16_t get16(const uint8_t *p) { return (uint16_t)(((unsigned)p[0]<<8)|p[1]); }
static uint32_t get32(const uint8_t *p) { return ((uint32_t)get16(p)<<16)|get16(p+2); }
static int valid_header(const DbHeader *h)
{
    uint32_t offset, length;
    if ((h->kind != DB_RAW && h->kind != DB_RECTIFIED) || h->camera > 1 ||
        h->format != DB_GREEN8 || !h->session || !h->calibration || h->flags ||
        h->width != DB_WIDTH || h->height != DB_HEIGHT || h->image_bytes != DB_IMAGE_BYTES ||
        h->chunks != DB_MAX_CHUNKS || h->chunk >= DB_MAX_CHUNKS) return 0;
    offset = (uint32_t)h->chunk * DB_PAYLOAD_BYTES;
    length = DB_IMAGE_BYTES - offset;
    if (length > DB_PAYLOAD_BYTES) length = DB_PAYLOAD_BYTES;
    return h->offset == offset && h->length == length;
}
int db_packet_write_fields(uint8_t *p,size_t cap,const DbHeader *h)
{
    if (!p || !h || !valid_header(h) || cap < DB_HEADER_BYTES) return -1;
    memcpy(p,"DBST",4); p[4]=1; p[5]=h->kind; p[6]=h->camera; p[7]=h->format;
    put32(p+8,h->session); put32(p+12,h->frame); put32(p+16,h->calibration);
    put16(p+20,h->width); put16(p+22,h->height); put16(p+24,h->chunk); put16(p+26,h->chunks);
    put32(p+28,h->offset); put16(p+32,h->length); put16(p+34,h->flags);
    put32(p+36,h->capture_us); put32(p+40,h->image_bytes);
    return (int)(DB_HEADER_BYTES+h->length);
}
int db_packet_encode_header(uint8_t *p,size_t cap,const DbHeader *h,const uint8_t *data)
{
    uint32_t c;
    int length;
    if(!data)return -1;
    length=db_packet_write_fields(p,cap,h);
    if(length<0)return length;
    c=crc_update(~0U,p,44,NULL); c=crc_update(c,data,h->length,NULL); put32(p+44,~c);
    return length;
}
int db_packet_encode(uint8_t *p,size_t cap,const DbHeader *h,const uint8_t *data)
{
    int length;
    if(!h || cap<DB_HEADER_BYTES+h->length)return -1;
    length=db_packet_encode_header(p,cap,h,data);
    if(length>0)memcpy(p+DB_HEADER_BYTES,data,h->length);
    return length;
}
static int parse_header(DbHeader *h,const uint8_t *p,size_t n)
{
    if (!h || !p || n < DB_HEADER_BYTES || n > DB_PACKET_BYTES || memcmp(p,"DBST",4) || p[4]!=1) return 0;
    h->kind=p[5]; h->camera=p[6]; h->format=p[7]; h->session=get32(p+8);
    h->frame=get32(p+12); h->calibration=get32(p+16);
    h->width=get16(p+20); h->height=get16(p+22); h->chunk=get16(p+24); h->chunks=get16(p+26);
    h->offset=get32(p+28); h->length=get16(p+32); h->flags=get16(p+34);
    h->capture_us=get32(p+36); h->image_bytes=get32(p+40);
    return valid_header(h) && n==DB_HEADER_BYTES+h->length;
}
static int packet_crc(const DbHeader *h,const uint8_t *p,uint8_t *out)
{
    DbPerfStamp diagnostic=db_perf_begin(DB_PERF_RX_CRC);
    uint32_t c=crc_update(~0U,p,44,NULL);
    c=crc_update(c,p+DB_HEADER_BYTES,h->length,out);
    db_perf_end(DB_PERF_RX_CRC,diagnostic);
    return ~c==get32(p+44);
}
int db_packet_decode(DbHeader *h, const uint8_t *p, size_t n)
{
    return parse_header(h,p,n) && packet_crc(h,p,NULL);
}
void db_rx_init(DbReceiver *r, uint32_t session, uint32_t calibration,
                uint8_t kind, uint32_t timeout, uint32_t skew,
                uint8_t *images[DB_RX_SLOTS][2])
{
    unsigned i,j;
    memset(r,0,sizeof(*r)); r->session=session; r->calibration=calibration;
    r->kind=kind; r->timeout_us=timeout; r->max_skew_us=skew;
    for(i=0;i<DB_RX_SLOTS;++i) for(j=0;j<2;++j) r->slots[i].image[j]=images[i][j];
}
void db_rx_expire(DbReceiver *r, uint32_t now)
{
    unsigned i;
    for(i=0;i<DB_RX_SLOTS;++i) {
        DbSlot *s=&r->slots[i];
        if(s->state==DB_FILLING && (uint32_t)(now-s->first_us)>=r->timeout_us) {
            s->state=DB_FREE; ++r->timed_out;
        }
    }
}
int db_rx_push(DbReceiver *r, const uint8_t *p, size_t n, uint32_t now)
{
    DbHeader h;
    DbSlot *s=NULL, *free_slot=NULL;
    unsigned i, cam, bit, byte;
    db_rx_expire(r,now);
    if(!parse_header(&h,p,n) || h.kind!=r->kind || h.session!=r->session ||
       h.calibration!=r->calibration || (r->delivered && (int32_t)(h.frame-r->watermark)<=0)) {
        ++r->rejected; return 0;
    }
    for(i=0;i<DB_RX_SLOTS;++i) {
        DbSlot *t=&r->slots[i];
        if(t->state!=DB_FREE && t->frame==h.frame) s=t;
        if(t->state==DB_FREE && !free_slot) free_slot=t;
    }
    if(!s) {
        if(!free_slot) { ++r->queue_full; return 0; }
        s=free_slot;
    }
    if(s->state!=DB_FILLING && s->state!=DB_FREE) { ++r->duplicates; return 0; }
    cam=h.camera; byte=h.chunk/8U; bit=1U<<(h.chunk%8U);
    if(s->state==DB_FILLING && s->received[cam] && s->capture_us[cam]!=h.capture_us) { ++r->rejected; return 0; }
    if(s->state==DB_FILLING && (s->seen[cam][byte]&bit)) {
        if(r->defer_crc){++r->duplicates;return 0;}
        if(!packet_crc(&h,p,NULL) || memcmp(s->image[cam]+h.offset,p+DB_HEADER_BYTES,h.length)) { ++r->rejected; return 0; }
        ++r->duplicates; return 1;
    }
    /* Only an unseen chunk in FREE/FILLING storage may be overwritten.
     * Keep state, bitmaps and counters unchanged until the CRC succeeds;
     * duplicates and HELD/READY images never enter the copying path. */
    if(r->defer_crc) {
        /* Stage unseen bytes only. Neither PL nor measurement may acquire
         * this pair until the selected verifier checks EVERY packet CRC. */
        memcpy(s->image[cam]+h.offset,p+DB_HEADER_BYTES,h.length);
        memcpy(s->headers+(cam*DB_MAX_CHUNKS+h.chunk)*DB_HEADER_BYTES,p,DB_HEADER_BYTES);
    } else if(!packet_crc(&h,p,s->image[cam]+h.offset)) {++r->rejected;return 0;}
    if(s->state==DB_FREE) {
        s->state=DB_FILLING;s->frame=h.frame;s->first_us=now;s->dma_clean=0;
        memset(s->seen,0,sizeof(s->seen));memset(s->received,0,sizeof(s->received));
    }
    s->capture_us[cam]=h.capture_us;
    s->seen[cam][byte]|=(uint8_t)bit; ++s->received[cam]; ++r->accepted;
    if(s->received[0]==DB_MAX_CHUNKS && s->received[1]==DB_MAX_CHUNKS) {
        int64_t delta=(int32_t)(s->capture_us[0]-s->capture_us[1]);
        if(delta<0) delta=-delta;
        if((uint64_t)delta>r->max_skew_us) { s->state=DB_FREE; ++r->rejected; return 0; }
        if(r->defer_crc)s->state=DB_VERIFY_WAIT;
        else {s->state=DB_READY; ++r->completed;}
    }
    return 1;
}
DbSlot *db_rx_acquire_latest(DbReceiver *r)
{
    DbSlot *best=NULL;
    unsigned i;
    for(i=0;i<DB_RX_SLOTS;++i) if(r->slots[i].state==DB_READY &&
        (!best || (int32_t)(r->slots[i].frame-best->frame)>0)) best=&r->slots[i];
    if(best) {
        best->state=DB_HELD; r->watermark=best->frame; r->delivered=1;
        for(i=0;i<DB_RX_SLOTS;++i) if(&r->slots[i]!=best &&
            (r->slots[i].state==DB_READY || r->slots[i].state==DB_FILLING) &&
            (int32_t)(r->slots[i].frame-best->frame)<0) r->slots[i].state=DB_FREE;
    }
    return best;
}
void db_rx_release(DbSlot *s) { if(s && s->state==DB_HELD) s->state=DB_FREE; }
int db_tx_begin(DbSender *s,uint8_t kind,uint32_t session,uint32_t frame,
                uint32_t calibration,const uint8_t *left,const uint8_t *right,
                uint32_t lu,uint32_t ru)
{
    if(!s || s->active || !left || !right || !session || !calibration ||
       (kind!=DB_RAW && kind!=DB_RECTIFIED)) return 0;
    memset(&s->header,0,sizeof(s->header)); s->header.kind=kind;
    s->header.format=DB_GREEN8; s->header.session=session; s->header.frame=frame;
    s->header.calibration=calibration; s->header.width=DB_WIDTH; s->header.height=DB_HEIGHT;
    s->header.chunks=DB_MAX_CHUNKS; s->header.image_bytes=DB_IMAGE_BYTES;
    s->image[0]=left; s->image[1]=right; s->capture_us[0]=lu; s->capture_us[1]=ru;
    s->camera=0; s->next_chunk=0; s->packet_bytes=0; s->active=1; return 1;
}
unsigned db_tx_poll(DbSender *s,unsigned budget,DbSend send,void *ctx)
{
    unsigned sent=0;
    while(s->active && sent<budget) {
        uint32_t remaining;
        int length;
        if(!s->packet_bytes) {
        s->header.camera=s->camera; s->header.chunk=s->next_chunk;
        s->header.offset=(uint32_t)s->next_chunk*DB_PAYLOAD_BYTES;
        remaining=DB_IMAGE_BYTES-s->header.offset;
        s->header.length=(uint16_t)(remaining>DB_PAYLOAD_BYTES?DB_PAYLOAD_BYTES:remaining);
        s->header.capture_us=s->capture_us[s->camera];
        length=db_packet_encode(s->packet,sizeof(s->packet),&s->header,
                                s->image[s->camera]+s->header.offset);
        if(length<0) break;
        s->packet_bytes=(uint16_t)length;
        }
        /* Retain the encoded packet across backpressure; its source remains
         * immutable. Recomputing its CRC on each retry starves RX servicing. */
        if(!send(ctx,s->packet,s->packet_bytes)) break;
        s->packet_bytes=0;
        ++sent;
        if(++s->next_chunk==DB_MAX_CHUNKS) {
            s->next_chunk=0;
            if(++s->camera==2) s->active=0;
        }
    }
    return sent;
}
unsigned db_tx_poll_chunks(DbSender *s,unsigned budget,DbSendChunk send,void *ctx)
{
    unsigned sent=0;
    while(s->active && sent<budget) {
        uint32_t remaining;
        s->header.camera=s->camera;s->header.chunk=s->next_chunk;
        s->header.offset=(uint32_t)s->next_chunk*DB_PAYLOAD_BYTES;
        remaining=DB_IMAGE_BYTES-s->header.offset;
        s->header.length=(uint16_t)(remaining>DB_PAYLOAD_BYTES?DB_PAYLOAD_BYTES:remaining);
        s->header.capture_us=s->capture_us[s->camera];
        if(!send(ctx,&s->header,s->image[s->camera]+s->header.offset))break;
        ++sent;
        if(++s->next_chunk==DB_MAX_CHUNKS) {
            s->next_chunk=0;
            if(++s->camera==2)s->active=0;
        }
    }
    return sent;
}

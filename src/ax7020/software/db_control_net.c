#include "db_control_net.h"
#include "lwip/pbuf.h"
#include <string.h>
static void receive(void *arg,struct udp_pcb *pcb,struct pbuf *p,const ip_addr_t *address,u16_t port)
{
    DbControlNet *c=(DbControlNet *)arg;DbControl m;uint8_t bytes[DB_CONTROL_BYTES];
    (void)pcb;(void)address;(void)port;
    if(p && p->tot_len==DB_CONTROL_BYTES && pbuf_copy_partial(p,bytes,sizeof(bytes),0)==sizeof(bytes) &&
       db_control_decode(&m,bytes,sizeof(bytes))) {
        unsigned t=m.type;
        if(!c->pending[t] || c->inbox[t].session!=m.session || (int32_t)(m.id-c->inbox[t].id)>=0) {
            c->inbox[t]=m;c->pending[t]=1;
        }
        ++c->accepted;
    } else ++c->rejected;
    if(p)pbuf_free(p);
}
int db_control_net_open(DbControlNet *c,const DbNet *n)
{
    unsigned i;memset(c,0,sizeof(*c));
    if(!n->udp)return 0;
    c->pcb=udp_new();
    if(!c->pcb || udp_bind(c->pcb,IP_ADDR_ANY,DB_CONTROL_PORT)!=ERR_OK ||
       udp_connect(c->pcb,&n->udp->remote_ip,DB_CONTROL_PORT)!=ERR_OK)goto fail;
    for(i=0;i<4;++i) {
        c->tx[i]=pbuf_alloc(PBUF_TRANSPORT,DB_CONTROL_BYTES,PBUF_RAM);
        if(!c->tx[i])goto fail;
        c->payload[i]=c->tx[i]->payload;
    }
    udp_recv(c->pcb,receive,c);return 1;
fail:
    for(i=0;i<4;++i)if(c->tx[i]){pbuf_free(c->tx[i]);c->tx[i]=NULL;}
    if(c->pcb){udp_remove(c->pcb);c->pcb=NULL;}
    return 0;
}
int db_control_net_send(DbControlNet *c,const DbControl *m)
{
    unsigned i;
    if(!c->pcb)return 0;
    for(i=0;i<4;++i)if(c->tx[i] && c->tx[i]->ref==1) {
        struct pbuf *p=c->tx[i];
        p->payload=c->payload[i];p->len=p->tot_len=DB_CONTROL_BYTES;p->next=NULL;
        if(!db_control_encode((uint8_t *)p->payload,m))return 0;
        if(udp_send(c->pcb,p)==ERR_OK){++c->sent;return 1;}
        break;
    }
    ++c->backpressure;return 0;
}
int db_control_net_take(DbControlNet *c,unsigned type,DbControl *m)
{
    if(type>=DB_CTRL_TYPE_COUNT || !c->pending[type])return 0;
    *m=c->inbox[type];c->pending[type]=0;return 1;
}

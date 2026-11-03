#include "db_rgb_ui.h"
#include "db_rgb_font.h"
#include "db_rgb_logo.h"
#include "db_face_gallery.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
int db_rgb_ui_touch(DbRgbUi *u,unsigned down,unsigned contacts,unsigned x,unsigned y,unsigned width,unsigned height)
{
 unsigned event=DB_SCREEN_EVENT_NONE;
 if(width && height && x<width && y<height) {
  x=x*DB_LCD_W/width;y=y*DB_LCD_H/height;
  if(y>=16U && y<88U) {
   if(x>=784U && x<1008U)event=DB_SCREEN_EVENT_CAPTURE;
   else if(x>=552U && x<768U)event=DB_SCREEN_EVENT_MODE;
   else if(x>=344U && x<536U)event=DB_SCREEN_EVENT_HDMI;
  }
 }
 return db_photo_button(&u->button,down,event!=0,contacts) && !u->controls_busy?(int)event:0;
}
int db_rgb_ui_set_mode(DbRgbUi *u,unsigned mode)
{
 if(!u || mode>DB_MODE_DISTANCE || u->controls_busy)return 0;
 u->mode=mode;memset(&u->photo,0,sizeof(u->photo));
 u->have_measurement=u->have_thumbs=0;u->thumb_frame=0;
 memset(&u->measurement,0,sizeof(u->measurement));db_rgb_ui_face_reset(u);return 1;
}
void db_rgb_ui_copy(DbRgbUi *u,const uint8_t *left,const uint8_t *right,unsigned offset,unsigned count)
{
 unsigned c,i,total=DB_THUMB_W*DB_THUMB_H;
 const uint8_t *raw[2]={left,right};
 if(offset>=total || count>total-offset || !left || !right)return;
 for(c=0;c<2;++c)for(i=offset;i<offset+count;++i) {
  unsigned x=i%DB_THUMB_W,y=i/DB_THUMB_W;
  unsigned src=((y*DB_HEIGHT/DB_THUMB_H)*DB_WIDTH+x*DB_WIDTH/DB_THUMB_W)*3U;
  memcpy(u->thumb[c]+i*3U,raw[c]+src,3);
 }
}
void db_rgb_ui_face_reset(DbRgbUi *u)
{
 u->face_frame=0;u->have_box=0;u->identity_state=DB_UI_ID_PENDING;
 u->person_id=0;u->reference_person=0;u->identity_score_q15=0;
 u->have_live=0;u->live_status=DB_CTRL_PENDING;
}
int db_rgb_ui_detection(DbRgbUi *u,uint32_t frame,const DbFaceDetection *d)
{
 float x0,y0,x1,y1;
 if(!u || u->mode!=DB_MODE_FACE || !d || !frame || u->photo.frame!=frame ||
    !isfinite(d->score) || d->score<0.6f || !isfinite(d->x) || !isfinite(d->y) ||
    !isfinite(d->width) || !isfinite(d->height) || d->width<=0 || d->height<=0)return 0;
 x0=fmaxf(0,d->x);y0=fmaxf(0,d->y);
 x1=fminf(DB_WIDTH,d->x+d->width);y1=fminf(DB_HEIGHT,d->y+d->height);
 if(x0>=x1 || y0>=y1)return 0;
 u->box_x0=(unsigned)(x0*DB_THUMB_W/DB_WIDTH);u->box_y0=(unsigned)(y0*DB_THUMB_H/DB_HEIGHT);
 u->box_x1=(unsigned)ceilf(x1*DB_THUMB_W/DB_WIDTH)-1U;
 u->box_y1=(unsigned)ceilf(y1*DB_THUMB_H/DB_HEIGHT)-1U;
 u->face_frame=frame;u->have_box=1;return 1;
}
int db_rgb_ui_identity(DbRgbUi *u,uint32_t frame,unsigned person,int32_t score,unsigned valid)
{
 if(!u || u->mode!=DB_MODE_FACE || !frame || u->photo.frame!=frame || person>DB_FACE_AUTHORIZED_COUNT)return 0;
 if(person && (!valid || score<DB_FACE_MATCH_THRESHOLD_Q15 || score>32768))return 0;
 u->face_frame=frame;u->person_id=person;u->identity_score_q15=score;
 u->identity_state=!valid?DB_UI_ID_ERROR:person?DB_UI_ID_MATCHED:DB_UI_ID_UNKNOWN;
 /* A fallback reference is presentation only, never an identity match. */
 u->reference_person=person?person:2U;return 1;
}
int db_rgb_ui_liveness(DbRgbUi *u,uint32_t frame,unsigned status)
{
 if(!u || u->mode!=DB_MODE_FACE || !frame || u->photo.frame!=frame || status<DB_CTRL_OK || status>DB_CTRL_SPOOF)return 0;
 u->face_frame=frame;u->have_live=1;u->live_status=status;return 1;
}

static int photos_visible(const DbRgbUi *u)
{
 /* Publish the current photo/reference pair only after judgement finishes.
  * A failed detector has no liveness request to await. Stale thumbnails and
  * late results from the previous capture must never reveal a reference. */
 if(u->mode==DB_MODE_DISTANCE)return u->photo.frame && u->have_thumbs &&
  u->thumb_frame==u->photo.frame &&
  (u->photo.state==DB_PHOTO_DONE || u->photo.state==DB_PHOTO_FAILED);
 return u->photo.frame && u->face_frame==u->photo.frame &&
  u->have_thumbs && u->thumb_frame==u->photo.frame &&
  (u->photo.state==DB_PHOTO_DONE || u->photo.state==DB_PHOTO_FAILED) &&
  u->identity_state!=DB_UI_ID_PENDING &&
  (u->have_live || (u->identity_state==DB_UI_ID_ERROR && !u->have_box));
}
static void span(uint8_t *p,unsigned x,unsigned n,unsigned color)
{
 unsigned i;if(x>=DB_LCD_W)return;if(n>DB_LCD_W-x)n=DB_LCD_W-x;
 for(i=x;i<x+n;++i){p[i*3]=(uint8_t)color;p[i*3+1]=(uint8_t)(color>>8);p[i*3+2]=(uint8_t)(color>>16);}
}
static void rectangle(uint8_t *p,unsigned row,unsigned x,unsigned y,unsigned w,unsigned h,unsigned color)
{if(row>=y && row<y+h)span(p,x,w,color);}
/* Font table uses code points, avoiding locale-dependent multibyte C strings. */
static void text(uint8_t *p,unsigned row,unsigned x,unsigned y,const uint16_t *str,unsigned scale,unsigned color)
{
 unsigned k,g,bit,r;
 if(row<y || row>=y+DB_FONT_H*scale)return;
 r=(row-y)/scale;
 for(k=0;str[k];++k) {
  for(g=0;g<DB_FONT_COUNT && db_font_codes[g]!=str[k];++g){}
  if(g==DB_FONT_COUNT)continue;
  for(bit=0;bit<DB_FONT_W;++bit)if(db_font[g][r]&(1U<<(DB_FONT_W-1U-bit)))
   span(p,x+k*DB_FONT_W*scale+bit*scale,scale,color);
 }
}
static void ascii(uint8_t *p,unsigned row,unsigned x,unsigned y,const char *s,unsigned scale,unsigned color)
{
 uint16_t code[64];unsigned i;
 for(i=0;i<63 && s[i];++i)code[i]=(unsigned char)s[i];
 code[i]=0;
 text(p,row,x,y,code,scale,color);
}
void db_rgb_ui_row(const DbRgbUi *u,unsigned row,uint8_t *p)
{
 static const uint16_t title[]={0x53,0x47,0x42,0x4d,0x20,0x53cc,0x76ee,0x8ba4,0x8bc1,0};
 static const uint16_t mode_range[]={0x5207,0x6362,0x6d4b,0x8ddd,0};
 static const uint16_t mode_face[]={0x5207,0x6362,0x8bc6,0x522b,0};
 static const uint16_t range_left[]={0x5de6,0x76f8,0x673a,0x539f,0x56fe,0};
 static const uint16_t range_right[]={0x53f3,0x76f8,0x673a,0x539f,0x56fe,0};
 static const uint16_t range_title[]={0x53,0x47,0x42,0x4d,0x20,0x53cc,0x76ee,0x6d4b,0x8ddd,0};
 static const uint16_t range_hint[]={0x6d4b,0x8ddd,0x4f4d,0x7f6e,0x4e0e,0x48,0x44,0x4d,0x49,0x5341,0x5b57,0x4e00,0x81f4,0};
 static const uint16_t wait_hint[]={0x5904,0x7406,0x6216,0x64ad,0x62a5,0x4e2d,0xff0c,0x8bf7,0x7a0d,0x5019,0};
 static const uint16_t capture[]={0x62cd,0x6444,0};
 static const uint16_t left[]={0x73b0,0x573a,0x62cd,0x6444,0x20,0x2f,0x20,0x4eba,0x8138,0x68c0,0x6d4b,0};
 static const uint16_t right[]={0x6388,0x6743,0x53c2,0x8003,0x7167,0};
 static const uint16_t distance[]={0x8ddd,0x79bb,0};
 static const uint16_t ready[]={0x7b49,0x5f85,0x62cd,0x6444,0};
 static const uint16_t busy[]={0x6b63,0x5728,0x62cd,0x6444,0};
 static const uint16_t measuring[]={0x6b63,0x5728,0x6d4b,0x8ddd,0};
 static const uint16_t done[]={0x62cd,0x6444,0x5b8c,0x6210,0};
 static const uint16_t failed[]={0x6d4b,0x8ddd,0x5931,0x8d25,0};
 static const uint16_t identity_wait[]={0x8eab,0x4efd,0x8bc6,0x522b,0x4e2d,0};
 static const uint16_t identity_ok[]={0x8eab,0x4efd,0x901a,0x8fc7,0};
 static const uint16_t identity_no[]={0x8eab,0x4efd,0x672a,0x8bc6,0x522b,0};
 static const uint16_t identity_error[]={0x8bc6,0x522b,0x5931,0x8d25,0};
 static const uint16_t live_wait[]={0x6d3b,0x4f53,0x5f85,0x68c0,0x6d4b,0};
 static const uint16_t live_ok[]={0x6d3b,0x4f53,0x901a,0x8fc7,0};
 static const uint16_t live_no[]={0x7167,0x7247,0x653b,0x51fb,0};
 static const uint16_t live_retry[]={0x6838,0x9a8c,0x5f85,0x91cd,0x62cd,0};
 static const uint16_t live_timeout[]={0x68c0,0x6d4b,0x8d85,0x65f6,0};
 static const uint16_t recognizing[]={0x6b63,0x5728,0x8bc6,0x522b,0};
 static const uint16_t recognized[]={0x8bc6,0x522b,0x5b8c,0x6210,0};
 static const uint16_t retry_hint[]={0x8bf7,0x91cd,0x62cd,0};
 static const uint16_t access_wait[]={0x7b49,0x5f85,0x8ba4,0x8bc1,0};
 static const uint16_t access_ok[]={0x8ba4,0x8bc1,0x901a,0x8fc7,0};
 static const uint16_t access_no[]={0x8ba4,0x8bc1,0x62d2,0x7edd,0};
 static const uint16_t touch_wait[]={0x89e6,0x6478,0x672a,0x5c31,0x7eea,0};
 char s[64];unsigned x,judgement_done,granted,show_photos=(unsigned)photos_visible(u);
 unsigned ref_person=u->identity_state==DB_UI_ID_MATCHED?u->person_id:2U;
 const uint16_t *ref=show_photos && u->mode==DB_MODE_FACE?db_face_reference_pixels(ref_person):NULL;
 const uint16_t *state[]={ready,busy,measuring,measuring,done,failed};
 if(row>=DB_LCD_H)return;
 span(p,0,DB_LCD_W,0x101c2b);
 rectangle(p,row,784,16,224,72,
  !u->touch_ready || u->controls_busy || (u->photo.state>=DB_PHOTO_CAPTURING && u->photo.state<=DB_PHOTO_MEASURING)?0x50606c:0x1c82a8);
 rectangle(p,row,552,16,216,72,!u->touch_ready || u->controls_busy?0x50606c:0x346a56);
 /* Shared static branding: only the left header and footer title change.
  * Keep capture/mode/HDMI touch regions and photograph geometry unchanged. */
 rectangle(p,row,16,8,312,96,0xffffff);
 if(row>=DB_RGB_LOGO_Y && row<DB_RGB_LOGO_Y+DB_RGB_LOGO_H)
  memcpy(p+DB_RGB_LOGO_X*3U,
   db_rgb_logo_bgr+(row-DB_RGB_LOGO_Y)*DB_RGB_LOGO_W*3U,DB_RGB_LOGO_W*3U);
 rectangle(p,row,344,16,192,72,!u->touch_ready || u->controls_busy || u->hdmi_pending?0x50606c:0x425d91);
 ascii(p,row,360,28,"HDMI",1,0xffffff);
 ascii(p,row,360,54,u->hdmi_pending?"WAIT":u->hdmi_mode?"L + R":"DEPTH",1,0xffffff);
 text(p,row,572,40,u->mode==DB_MODE_FACE?mode_range:mode_face,1,0xffffff);
 text(p,row,852,28,capture,2,0xffffff);
 text(p,row,16,108,u->mode==DB_MODE_DISTANCE?range_left:left,1,0xc4d9e6);
 text(p,row,528,108,u->mode==DB_MODE_DISTANCE?range_right:right,1,0xc4d9e6);
 if(show_photos && u->mode==DB_MODE_FACE) {
  if(u->identity_state==DB_UI_ID_MATCHED)snprintf(s,sizeof(s),"USER%02u",ref_person);
  else snprintf(s,sizeof(s),"DEFAULT USER%02u",ref_person);
  ascii(p,row,680,108,s,1,0xc4d9e6);
 }
 rectangle(p,row,16,142,480,270,0x263847);rectangle(p,row,528,142,480,270,0x263847);
 if(show_photos && row>=142 && row<412) {
  memcpy(p+16*3U,u->thumb[0]+(row-142)*DB_THUMB_W*3U,DB_THUMB_W*3U);
  if(u->mode==DB_MODE_DISTANCE)memcpy(p+528*3U,u->thumb[1]+(row-142)*DB_THUMB_W*3U,DB_THUMB_W*3U);
  /* Only a genuine detector result for this captured image can draw a box. */
  if(u->mode==DB_MODE_FACE && u->have_box && u->face_frame==u->thumb_frame && row>=142+u->box_y0 && row<=142+u->box_y1) {
   unsigned y=row-142;
   if(y-u->box_y0<2U || u->box_y1-y<2U)span(p,16+u->box_x0,u->box_x1-u->box_x0+1U,0x36e08c);
   else {unsigned edge=u->box_x1-u->box_x0+1U;if(edge>2U)edge=2U;
    span(p,16+u->box_x0,edge,0x36e08c);span(p,17+u->box_x1-edge,edge,0x36e08c);}
  }
 }
 /* Reference photograph retains its aspect ratio inside a fixed portrait area. */
 if(ref && row>=142 && row<412)for(x=0;x<DB_FACE_REFERENCE_W;++x) {
  uint16_t q=ref[(row-142)*DB_FACE_REFERENCE_W+x];unsigned o=(648U+x)*3U;
  p[o]=(uint8_t)(((q&31U)<<3)|((q&31U)>>2));
  p[o+1]=(uint8_t)((((q>>5)&63U)<<2)|(((q>>5)&63U)>>4));
  p[o+2]=(uint8_t)(((q>>11)<<3)|((q>>11)>>2));
 }
 if(u->mode==DB_MODE_DISTANCE) {
  text(p,row,24,448,distance,2,0xffffff);
  if(u->have_measurement && u->measurement.status==DB_CTRL_OK)
   snprintf(s,sizeof(s),"%lu.%03lu m",(unsigned long)(u->measurement.distance_mm/1000U),(unsigned long)(u->measurement.distance_mm%1000U));
  else if(!u->have_measurement && u->photo.state==DB_PHOTO_DONE && u->photo.status==DB_CTRL_OK)
   snprintf(s,sizeof(s),"%lu.%03lu m",(unsigned long)(u->photo.distance_mm/1000U),(unsigned long)(u->photo.distance_mm%1000U));
  else strcpy(s,"--- m");
  ascii(p,row,144,448,s,2,0x5be1c2);
  text(p,row,24,500,state[u->photo.state<=DB_PHOTO_FAILED?u->photo.state:DB_PHOTO_FAILED],1,0xc4d9e6);
  text(p,row,264,500,range_hint,1,0xc4d9e6);
  text(p,row,24,558,range_title,1,0x8ba6b8);
  if(!u->touch_ready)text(p,row,528,558,touch_wait,1,0x8ba6b8);
  else if(u->controls_busy)text(p,row,528,558,wait_hint,1,0x8ba6b8);
  return;
 }
 /* Face mode presents the authentication decision, never the separate
  * range request's distance/status. UNKNOWN and SPOOF remain distinct. */
 judgement_done=u->identity_state!=DB_UI_ID_PENDING &&
  (u->have_live || (u->identity_state==DB_UI_ID_ERROR && !u->have_box));
 granted=judgement_done && u->identity_state==DB_UI_ID_MATCHED &&
  u->have_live && u->live_status==DB_CTRL_OK;
 text(p,row,24,448,!judgement_done?access_wait:granted?access_ok:access_no,2,
  !judgement_done?0xc4d9e6:granted?0x5be1c2:0xf2b0a6);
 if(judgement_done && u->identity_state==DB_UI_ID_MATCHED) {
  unsigned score=u->identity_score_q15<0?0U:(unsigned)u->identity_score_q15*1000U/32768U;
  snprintf(s,sizeof(s),"USER%02u %u.%03u",u->person_id,score/1000U,score%1000U);ascii(p,row,528,448,s,1,0x5be1c2);
 } else ascii(p,row,528,448,"USER --",1,0xc4d9e6);
 text(p,row,24,500,!u->photo.frame?ready:judgement_done?recognized:
  u->photo.state==DB_PHOTO_CAPTURING?busy:recognizing,1,0xc4d9e6);
 text(p,row,264,500,u->identity_state==DB_UI_ID_MATCHED?identity_ok:u->identity_state==DB_UI_ID_UNKNOWN?identity_no:u->identity_state==DB_UI_ID_ERROR?identity_error:u->photo.frame?identity_wait:ready,1,0xc4d9e6);
 text(p,row,528,500,!u->have_live?live_wait:u->live_status==DB_CTRL_OK?live_ok:
  u->live_status==DB_CTRL_SPOOF?live_no:u->live_status==DB_CTRL_TIMEOUT?live_timeout:live_retry,1,0xc4d9e6);
 if(judgement_done && u->have_live &&
    (u->live_status==DB_CTRL_INVALID || u->live_status==DB_CTRL_TIMEOUT))
  text(p,row,784,500,retry_hint,1,0xc4d9e6);
 text(p,row,24,558,title,1,0x8ba6b8);
 if(!u->touch_ready)text(p,row,528,558,touch_wait,1,0x8ba6b8);
 else if(u->controls_busy)text(p,row,528,558,wait_hint,1,0x8ba6b8);
}

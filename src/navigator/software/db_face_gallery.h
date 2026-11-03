#ifndef DB_FACE_GALLERY_H
#define DB_FACE_GALLERY_H
#include "db_face_identity_template.h"
#define DB_FACE_AUTHORIZED_COUNT 2U
#define DB_FACE_REFERENCE_W 240U
#define DB_FACE_REFERENCE_H 270U
#define DB_FACE_PERSON02_FNV1A32 0x0b9f4c4cU
extern const int8_t db_face_person02_template_i8[DB_FACE_IDENTITY_DIM];
const int8_t *db_face_authorized_template(unsigned person);
const uint16_t *db_face_reference_pixels(unsigned person);
#define DB_FACE_PERSON02_CAMERA_FNV1A32 0xb9321f38U
extern const int8_t db_face_person02_camera_template_i8[DB_FACE_IDENTITY_DIM];
unsigned db_face_authorized_sample_count(unsigned person);
const int8_t *db_face_authorized_sample(unsigned person,unsigned sample);
#endif

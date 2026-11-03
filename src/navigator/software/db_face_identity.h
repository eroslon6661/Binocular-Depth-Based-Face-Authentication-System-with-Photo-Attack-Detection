#ifndef DB_FACE_IDENTITY_H
#define DB_FACE_IDENTITY_H
#include <stdint.h>
#include "db_face_identity_template.h"

/* Float input may be unnormalized. INT8 input must be an L2-normalized
 * embedding quantized with scale 1/127 and zero point 0. */
float db_face_similarity_f32(const float embedding[DB_FACE_IDENTITY_DIM]);
int db_face_match_f32(const float embedding[DB_FACE_IDENTITY_DIM],float *score);
int db_face_quantize_f32(const float embedding[DB_FACE_IDENTITY_DIM],
                         int8_t output[DB_FACE_IDENTITY_DIM]);
int32_t db_face_similarity_i8_q15(const int8_t embedding[DB_FACE_IDENTITY_DIM]);
int db_face_match_i8(const int8_t embedding[DB_FACE_IDENTITY_DIM],int32_t *score_q15);
/* 1-based enrolled ID on success; zero for unknown/ambiguous/invalid input.
 * The original person_01-only APIs above retain their original semantics. */
int db_face_identify_i8(const int8_t embedding[DB_FACE_IDENTITY_DIM],unsigned *person_id,int32_t *score_q15);
/* Highest sample score for one enrolled person; invalid input returns INT32_MIN. */
int32_t db_face_person_similarity_i8_q15(const int8_t embedding[DB_FACE_IDENTITY_DIM],unsigned person_id);
int db_face_identity_self_test(void);

#endif

#include "db_face_identity.h"
#include "db_face_gallery.h"
#include <math.h>
#include <stddef.h>
#include <stdint.h>

#define DB_FACE_INVALID_Q15 (-2147483647-1)

static uint32_t isqrt_u64(uint64_t value)
{
    uint64_t result=0,bit=(uint64_t)1U<<62;
    while(bit>value)bit>>=2;
    while(bit) {
        if(value>=result+bit) {
            value-=result+bit;
            result=(result>>1)+bit;
        } else result>>=1;
        bit>>=2;
    }
    return (uint32_t)result;
}

float db_face_similarity_f32(const float embedding[DB_FACE_IDENTITY_DIM])
{
    float dot=0.0f,norm2=0.0f;
    unsigned i;
    if(!embedding)return -2.0f;
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i) {
        dot+=embedding[i]*db_face_person01_template_f32[i];
        norm2+=embedding[i]*embedding[i];
    }
    if(!(norm2>0.0f))return -2.0f;
    return dot/sqrtf(norm2);
}

int db_face_match_f32(const float embedding[DB_FACE_IDENTITY_DIM],float *score)
{
    float value=db_face_similarity_f32(embedding);
    if(score)*score=value;
    return value>=DB_FACE_MATCH_THRESHOLD_F32;
}

int db_face_quantize_f32(const float embedding[DB_FACE_IDENTITY_DIM],
                         int8_t output[DB_FACE_IDENTITY_DIM])
{
    float norm2=0.0f,scale;
    unsigned i;
    if(!embedding || !output)return 0;
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i)norm2+=embedding[i]*embedding[i];
    if(!(norm2>0.0f))return 0;
    scale=127.0f/sqrtf(norm2);
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i) {
        float value=embedding[i]*scale;
        int quantized=(int)(value+(value>=0.0f?0.5f:-0.5f));
        if(quantized>127)quantized=127;
        if(quantized<-127)quantized=-127;
        output[i]=(int8_t)quantized;
    }
    return 1;
}

static int32_t similarity_i8(const int8_t embedding[DB_FACE_IDENTITY_DIM],const int8_t *reference_template)
{
    int64_t dot=0,scaled;
    uint64_t query_norm2=0,template_norm2=0,product;
    uint32_t denominator;
    unsigned i;
    if(!embedding || !reference_template)return DB_FACE_INVALID_Q15;
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i) {
        int32_t query=embedding[i],reference=reference_template[i];
        dot+=(int64_t)query*reference;
        query_norm2+=(uint64_t)(query*query);
        template_norm2+=(uint64_t)(reference*reference);
    }
    if(!query_norm2 || !template_norm2)return DB_FACE_INVALID_Q15;
    product=query_norm2*template_norm2;
    denominator=isqrt_u64(product);
    if(!denominator)return DB_FACE_INVALID_Q15;
    scaled=dot*32768LL;
    scaled=scaled>=0?(scaled+(int64_t)denominator/2)/(int64_t)denominator:
                     (scaled-(int64_t)denominator/2)/(int64_t)denominator;
    if(scaled>32768)scaled=32768;
    if(scaled<-32768)scaled=-32768;
    return (int32_t)scaled;
}

int32_t db_face_similarity_i8_q15(const int8_t embedding[DB_FACE_IDENTITY_DIM])
{return similarity_i8(embedding,db_face_person01_template_i8);}

int32_t db_face_person_similarity_i8_q15(const int8_t embedding[DB_FACE_IDENTITY_DIM],unsigned person_id)
{
    unsigned sample,count=db_face_authorized_sample_count(person_id);
    int32_t best=DB_FACE_INVALID_Q15;
    for(sample=0;sample<count;++sample) {
        int32_t s=similarity_i8(embedding,db_face_authorized_sample(person_id,sample));
        if(s>best)best=s;
    }
    return best;
}

int db_face_identify_i8(const int8_t embedding[DB_FACE_IDENTITY_DIM],unsigned *person_id,int32_t *score_q15)
{
    unsigned p,best_id=0;int32_t best=DB_FACE_INVALID_Q15,second=DB_FACE_INVALID_Q15;
    for(p=1;p<=DB_FACE_AUTHORIZED_COUNT;++p) {
        int32_t s=db_face_person_similarity_i8_q15(embedding,p);
        if(s>best){second=best;best=s;best_id=p;}else if(s>second)second=s;
    }
    if(best<DB_FACE_MATCH_THRESHOLD_Q15 || best==second)best_id=0;
    if(person_id)*person_id=best_id;
    if(score_q15)*score_q15=best;
    return best_id!=0;
}

int db_face_match_i8(const int8_t embedding[DB_FACE_IDENTITY_DIM],int32_t *score_q15)
{
    int32_t value=db_face_similarity_i8_q15(embedding);
    if(score_q15)*score_q15=value;
    return value>=DB_FACE_MATCH_THRESHOLD_Q15;
}

int db_face_identity_self_test(void)
{
    uint32_t checksum=0x811c9dc5U;
    int8_t quantized[DB_FACE_IDENTITY_DIM];
    int32_t score;
    unsigned i;
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i) {
        checksum^=(uint8_t)db_face_person01_template_i8[i];
        checksum*=0x01000193U;
    }
    if(checksum!=DB_FACE_TEMPLATE_FNV1A32)return 0;
    if(db_face_similarity_i8_q15(db_face_person01_template_i8)!=32768)return 0;
    if(!db_face_match_f32(db_face_person01_template_f32,NULL))return 0;
    if(!db_face_quantize_f32(db_face_person01_template_f32,quantized))return 0;
    if(!db_face_match_i8(quantized,&score) || score<32700)return 0;
    checksum=0x811c9dc5U;
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i){checksum^=(uint8_t)db_face_person02_template_i8[i];checksum*=0x01000193U;}
    if(checksum!=DB_FACE_PERSON02_FNV1A32)return 0;
    checksum=0x811c9dc5U;
    for(i=0;i<DB_FACE_IDENTITY_DIM;++i){checksum^=(uint8_t)db_face_person02_camera_template_i8[i];checksum*=0x01000193U;}
    if(checksum!=DB_FACE_PERSON02_CAMERA_FNV1A32)return 0;
    {unsigned person=0;
     if(!db_face_identify_i8(db_face_person01_template_i8,&person,&score) || person!=1 || score!=32768)return 0;
     if(!db_face_identify_i8(db_face_person02_template_i8,&person,&score) || person!=2 || score!=32768)return 0;
     if(!db_face_identify_i8(db_face_person02_camera_template_i8,&person,&score) || person!=2 || score!=32768)return 0;}
    return 1;
}

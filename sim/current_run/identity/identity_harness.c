#include <stdio.h>
#include <stdint.h>
#include "db_face_identity.h"
int main(int argc,char **argv){
 if(argc!=2)return 2;FILE *f=fopen(argv[1],"rb");if(!f)return 3;
 int8_t v[512];unsigned i=0,p;int32_t score;size_t n;
 puts("case,score1,score2,identified,person,score");
 while((n=fread(v,1,512,f))==512){int ok=db_face_identify_i8(v,&p,&score);
 printf("%u,%ld,%ld,%d,%u,%ld\n",i++,(long)db_face_person_similarity_i8_q15(v,1),(long)db_face_person_similarity_i8_q15(v,2),ok,p,(long)score);}
 fclose(f);return n?4:0;}

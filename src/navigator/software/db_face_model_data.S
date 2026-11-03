.section .db_face_models,"a"
.balign 64
.global db_yunet_pack_start
db_yunet_pack_start:
.incbin "yunet_320_hls_int8.pack"
.global db_yunet_pack_end
db_yunet_pack_end:
.balign 64
.global db_mobile_pack_start
db_mobile_pack_start:
.incbin "mobilefacenet_112_hls_int8.pack"
.global db_mobile_pack_end
db_mobile_pack_end:

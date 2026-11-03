.section .db_maps,"a"
.balign 64
.global db_map_left
db_map_left:
.incbin "map_left_q8.bin"
.balign 64
.global db_mask_left
db_mask_left:
.incbin "mask_left.bin"
.balign 64
.global db_map_right
db_map_right:
.incbin "map_right_q8.bin"
.balign 64
.global db_mask_right
db_mask_right:
.incbin "mask_right.bin"
.balign 64

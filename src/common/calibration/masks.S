.section .db_maps,"a"
.balign 64
.global db_mask_left
db_mask_left:
.incbin "mask_left.bin"
.balign 64
.global db_mask_right
db_mask_right:
.incbin "mask_right.bin"
.balign 64

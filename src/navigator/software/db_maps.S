.section .db_maps,"a"
.balign 64
.global db_map_left
db_map_left:
.incbin "E:/epifpga/dual_ov5640_sgbm_z7020(new)/dual_ov5640_sgbm_z7020_vivado2022_2/dual_board/generated/map_left_q8.bin"
.balign 64
.global db_mask_left
db_mask_left:
.incbin "E:/epifpga/dual_ov5640_sgbm_z7020(new)/dual_ov5640_sgbm_z7020_vivado2022_2/dual_board/generated/mask_left.bin"
.balign 64
.global db_map_right
db_map_right:
.incbin "E:/epifpga/dual_ov5640_sgbm_z7020(new)/dual_ov5640_sgbm_z7020_vivado2022_2/dual_board/generated/map_right_q8.bin"
.balign 64
.global db_mask_right
db_mask_right:
.incbin "E:/epifpga/dual_ov5640_sgbm_z7020(new)/dual_ov5640_sgbm_z7020_vivado2022_2/dual_board/generated/mask_right.bin"
.balign 64

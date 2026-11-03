.section .db_maps,"a"
.balign 64
.global db_mask_left
db_mask_left:
.incbin "E:/epifpga/qiansai/01_队友工程/shuangbanfpga/dual_fpga_verified_20261012/04_calibration/mask_left.bin"
.balign 64
.global db_mask_right
db_mask_right:
.incbin "E:/epifpga/qiansai/01_队友工程/shuangbanfpga/dual_fpga_verified_20261012/04_calibration/mask_right.bin"
.balign 64

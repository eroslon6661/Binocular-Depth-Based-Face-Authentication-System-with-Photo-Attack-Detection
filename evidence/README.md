# 原始报告来源
这些文件从本机既有构建结果复制，本次未重新综合或下板。SHA256_MANIFEST.json记录提交副本散列。
- navigator_baseline：F:/fpga_2026_1_work/reports/navigator/
- navigator_final：F:/fpga_2026_1_work/reports/navigator_bram4_stride_shift_compact90_right/
- ax7020_final：F:/fpga_2026_1_work/reports/ax7020/
- 面积优先、4路并行、BRAM与移位未紧凑布局的试验：同一reports目录下对应同名子目录。
- hls_equivalence_stride_shift.log：F:/fpga_2026_1_work/hls_face_tile_compare/tile8_bram4_stride_shift.log。第105行记录FACE_SPEED_EQUIVALENCE_PASS cases=297 output_bytes=695964; integer outputs exact。它是历史C仿真日志，不是本次重新运行或RTL形式验证。
原始报告头保留工具、生成日期、设计状态和来源路径。只比较同一阶段；布线与布线后物理优化的统计可作最终实现比较，但仍须同时看时序和约束。
原文中的主机名/路径不影响校验结果；本包不宣称这些本机绝对路径在其他机器可用。


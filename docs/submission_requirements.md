# 3.3.5.1 工程包内容索引

提交主版本为Vivado / Vitis 2026.1优化版。
|赛事要求|交付位置|验证结果与适用范围|
|---|---|---|
|完整RTL、HLS、PS与依赖源码|`src/`、`project_config.json`、`build/scripts/`|PS源码与稳定运行版本匹配；BSP、lwIP、CPU1、CPU0及FSBL源码重建流程已通过|
|仿真或验证结果及正确性说明|`sim/`、`data/full_model_frame_2495/`、`reports/full_model_same_frame_20261101.md`|SGM 4244组、HLS 297例、身份判定1067例；同帧完整人脸模型124个整数算子及512维特征逐位一致|
|综合与实现报告|`reports/synthesis/`、`reports/implementation/`、`reports/hls/`|保留两板原始资源、时序、DRC与HLS报告；领航者Slice 88.62%，AX7020 Slice 65.38%|
|时钟频率与关键性能指标|`reports/summary.md`、`reports/live_measurement_20261101.md`|领航者WNS为+0.325 ns，AX7020为+0.618 ns；持续深度更新27.9271帧/秒、身份推理平均2.6915秒|
|上板工程、运行脚本与实测数据|`board/`、`build/scripts/run_board.py`、`data/`|稳定镜像、JTAG入口、双串口原始日志、定量统计和同帧模型数据齐全|
|参考结果及对比数据|`sim/`、`reports/recheck/`、`data/full_model_frame_2495/`|包含黄金输出、逐字节或逐算子比较、散列与完整日志；ONNX数值差异单独披露|
|可复现构建脚本|`docs/reproduction.md`、`docs/full_source_rebuild_2026_1.md`|2026.1空目录连续重建两板驱动、网络库、双核应用、FSBL及BOOT通过|
|项目代码技能包|`ski11/`|包含7项工作流、校验脚本、模板、适用范围和失效条件|
|大模型协作记录|`collaboration/`|赛事要求的独立附件，不作为资源、性能或正确性结论的替代证据|

## 验证边界

1. `board/`中的稳定镜像已完成双板联调；`validation_candidates/`中的全源码重建候选物已完成编译、BOOT封装、上板验证和SD冷启动回归。
2. 完整人脸模型同帧比较基于一个真实正样本帧，证明该帧部署运算与独立整数参考一致，不代表多身份、多光照、多姿态和攻击场景的统计准确率。
3. 10次现场认证中身份匹配10次，最终准入10次、活体拒绝0次；全部原始记录均保留，不将该小样本结果表述为FAR或FRR。
4. 完整硬件重新布局布线可能受工具种子和运行环境影响，不承诺位流逐字节一致或资源数恰好复现为同一数值；复现验收以功能、接口、资源上限和时序报告为准。

# 3.3.5.2 技能包
## 目标与适用范围
仅包含Zynq/FPGA项目代码开发、调试、验证、优化和构建固化经验。包括RTL/HLS、PS软件、DMA与网络接口、工具链和产物校验；不包含报告写作、视频策划、图片处理、宣传素材或其他非代码工作流。工作流可以复制给具备文件阅读能力的大模型；无工具时由队员提供日志并执行命令。它不是跨板通用bitstream。

## 条目索引
|编号与入口|适用范围|使用方法|已验证效果与来源|失效条件|
|---|---|---|---|---|
|W01 [迁移与版本锁定](workflows/W01.md)|Vivado/Vitis版本迁移|填版本矩阵，分阶段构建与验收|T5 2023.2构建；T6 2026.1联调|缺XSA、IP源码或原构建选项|
|W02 [板端数据与黄金参考](workflows/W02.md)|视频缓存、视差、定点算子|固定帧与数据格式，逐级对比|T3撤回1.64m实测说法；T6算子等价记录|不同帧、不同ROI或舍入规则|
|W03 [双目与算法边界](workflows/W03.md)|标定、SGBM、测距|列坐标约定，先校正与参考对照|T4明确毫米单位不等于毫米精度；T5滤波回退|相机姿态变化、范围之外、无可靠真值|
|W04 [双板网络与启动排障](workflows/W04.md)|JTAG、PHY、UDP、DMA|先辨认板卡再沿计数器追踪|T6通信、采集与交互功能恢复|仅有Running或链路灯，无应用证据|
|W05 [不改数值的资源优化](workflows/W05.md)|Slice高而LUT有余量|试验矩阵、缓存映射、等价运算、布局|T6 Slice98.65%→88.62%，原报告已附|目标器件不同、BRAM超限、时序不足|
|W06 [性能恢复与瓶颈计时](workflows/W06.md)|迁移降帧、推理耗时|分段计时，复原构建参数|T6发送速率约13→28fps，深度更新实测27.9271fps|以HDMI刷新或阶段耗时代替端到端|
|W07 [固化和可复现交付](workflows/W07.md)|双板BOOT包与复现|板别清单、哈希、读回、冷启动|T6两板SD读回一致并完成冷启动验收|混板文件、缺依赖、仅写入未启动|
|W08 [认证结果汇合与语音反馈](workflows/W08.md)|身份、几何/活体、页面、权限与语音|按请求号和帧号汇合，只消费一次最终结论|由本项目认证错帧、混播和有日志无实声的纠错经验提炼|无请求/帧归属、只改提示文字、未做现场听取|
|W09 [全模型分层参考核验](workflows/W09.md)|整数部署参考、ONNX QDQ、特征与身份结果|固定同一真实输入，逐层定位首个差异|第2495帧的独立整数参考、板端结果和ONNX对照方法|输入或预处理不同、把余弦相似度当识别准确率|
|W10 [缓冲区所有权与帧归属](workflows/W10.md)|DMA多槽、采集/校正/发送并行、错帧|按硬件完成状态转移所有权并跟踪帧号|T6由软件取模猜槽改为读取实际完成槽位后恢复|无完成标志、所有者不明、缓存一致性未处理|
|W11 [整机回归与安全回退](workflows/W11.md)|候选版本验收、功能保持、退步回滚|固定认可基线，逐项回归后决定保留或否决|由音频有日志无实声、启动但画面停滞等纠错提炼|无可恢复基线、同时叠加多项改动、只测正常路径|
|V01 scripts/verify.py reports|Vivado文本资源/时序报告|见下方命令|对附带真实基线和最终报告运行|报告格式变更或关键字段缺失|
|V02 scripts/verify.py compare|定点输出二进制|黄金输出与候选输出逐字节比对|本次正反样例验证；不是历史297例工具|浮点容差、格式/帧不一致|
|V03 scripts/verify.py manifest|产物散列锁定|先make-manifest，再manifest|本次篡改/缺文件测试|哈希正确但来源或功能错误|
|模板 templates/|试验、接口、帧归属、认证追踪、整机回归与复现验收|复制填入自己项目的数据|从历史重复漏项提炼；陌生队伍尚未验收|照抄示例值、跳过实测|
|[代码案例与来源](references/code_cases.md)|历史代码故障与修复依据|按工作流查版本、问题与效果|对应早期双目、2023.2和2026.1工程|历史结果不能直接当新工程验证|
|references/pitfalls.md|代码和工程故障定位|按现象找到触发条件与排查顺序|对应代码案例|将可能原因当确定根因|

## 15分钟上手
1. 复制整个提交包到本地；保留evidence以运行示例。
2. 在本目录执行：
   python scripts/verify.py reports ../evidence/navigator_final/utilization.rpt ../evidence/navigator_final/timing_summary.rpt
   五类主要资源与已分析路径满足条件，但全表Bonded IOPADs为100%，返回FAIL（退出码1）；另列I/O延迟缺项待审查。这是对“每项资源≤90%”的严格检查，不是脚本故障。
3. 再检查基线：
   python scripts/verify.py reports ../evidence/navigator_baseline/utilization.rpt ../evidence/navigator_baseline/timing_summary.rpt
   基线Slice和建立时间不满足，预期FAIL（退出码1）。
4. 运行 python scripts/selftest.py，验证脚本能拒绝差异、空数据、缺失和篡改文件。
5. 选一个工作流，填写输入后把提示词发给模型；每次试验复制templates/experiment.md记录结果。

## 脚本输入输出
- compare：python scripts/verify.py compare golden.bin candidate.bin
  相同且非空返回0；不同或空文件返回1；读入错误返回2。只证明字节一致，不证明上游算法正确，也不是RTL全状态形式证明。
- reports：python scripts/verify.py reports utilization.rpt timing_summary.rpt --limit 90
  默认检查Slice、LUT、FF、BRAM、DSP；顺带检查报告内其他有分母的资源行，任何使用率超过上限均失败。0表示所检查条件通过，1表示超限/时序违例，2表示缺字段或约束覆盖需审查。时序WNS/WHS/WPWS及违例端点必须完整；I/O延迟缺项不能被吞掉。
- make-manifest：python scripts/verify.py make-manifest build manifest.json hardware/system.bit software/application.elf
  相对路径必须位于build内；输出JSON至标准输出，请由运行者保存成manifest.json，避免脚本覆盖现有清单。第二参数是逻辑清单名，便于记录。
- manifest：python scripts/verify.py manifest build manifest.json
  检查文件存在和SHA-256，禁止绝对路径及越界；无法验证工具安装、板卡接线或冷启动。
- selftest：临时目录里运行正常/异常样例，不接触板卡或现有工程。

## 失效与停止
缺数据就输出UNKNOWN，保留失败日志；不能为了得到绿色通过而填零、放宽阈值或跳过板卡身份核对。Pblock坐标、帧缓存地址、串口号、启动模式拨码均为案例专用，必须从新项目重建。
已验证的是历史工程中的方法和本次脚本测试；“陌生队伍在另一台电脑独立复现”仍待验收。


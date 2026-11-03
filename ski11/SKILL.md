---
name: fpga-collaboration-evidence
description: 用于Zynq/FPGA双板视觉与本地认证项目的迁移、数据通路排障、数值一致性、资源时序优化、认证结果汇合和启动镜像固化。仅处理代码、构建与可验证工程证据；不用于报告写作或把工具输出替代实物验收。
---

# 使用原则

先固定当前版本、板卡角色、输入、异常现象、必须保留的功能、允许修改的范围和要求返回的证据。缺少其中任何一项时，先把它列为待确认条件，不用历史案例中的值补齐。

按任务只读最相关的工作流：

- 工具链迁移与版本配套：`workflows/W01.md`
- 同帧数据、整数输出与黄金参考：`workflows/W02.md`
- 双目、SGBM与测距边界：`workflows/W03.md`
- 双板启动、网络、DMA与采集：`workflows/W04.md`
- 保持数值语义的资源及时序优化：`workflows/W05.md`
- 视频、推理与端到端性能计时：`workflows/W06.md`
- SD固化、散列与复现交付：`workflows/W07.md`
- 身份、几何/活体状态与语音反馈汇合：`workflows/W08.md`
- 同一真实输入的全模型分层参考核验：`workflows/W09.md`
- DMA缓冲区所有权、完成状态与帧归属：`workflows/W10.md`
- 整机功能回归、候选否决与安全回退：`workflows/W11.md`

一次试验只改变一类因素，并用 `templates/experiment.md` 记录基线、唯一改动、证伪观察、结果和回退决定。涉及认证状态时同时填写 `templates/auth_result_trace.md`；涉及跨板或DMA接口时填写 `templates/interface_contract.md` 和 `templates/frame_lineage.md`；整机交付前填写 `templates/regression_matrix.md`。

# 证据与结论

把结论标为以下一种，不混写层级：

- `PASS`：所声明范围内的检查已经通过，且证据可定位到输入、版本与原始记录。
- `FAIL`：出现数值差异、时序违例、功能回退或现场反例。
- `REVIEW`：工具已运行，但存在未约束路径、格式冲突或需要人工解释的结果。
- `UNKNOWN`：缺输入、日志、板卡观察或工具无法读取；不得改写为通过。

源码判断、构建成功、仿真通过、实现报告、板端日志和实物观察各自只能支持对应范围。编译成功、串口握手、发送速率、散列一致或提示文字正确，都不能单独证明整机功能通过。触摸与实体按键、真实照片、测距、身份与几何核验、显示和实际声音是独立回归项。

校验脚本使用 `scripts/verify.py`；命令、退出码和失效条件见 `README.md`。脚本失败、`REVIEW` 或 `UNKNOWN` 时，保留原始输出并停止扩大结论。任何数值语义变化都必须先取得授权并记录舍入、饱和、溢出和容差规则。

# 边界

历史案例仅在当前工程的器件、版本、输入与约束相符时参考；详情按需读 `references/code_cases.md` 和 `references/pitfalls.md`。不得沿用案例中的跳帽、绝对地址、COM口、Pblock坐标、帧率或精度数字。

范围限于RTL/HLS、PS软件、双板接口、验证脚本、构建和固化。不处理报告、视频或宣传素材制作，也不把模型建议视为项目组已采纳的决定。


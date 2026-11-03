# 从零复现教程（Vivado / Vitis 2026.1）

这份教程写给第一次接触本工程的人。你不需要先理解所有 RTL、HLS 或裸机软件；先按目的选择路线，再逐步执行即可。

> **最重要的原则**：先验证稳定版，再重建；所有新输出写到新目录；不要覆盖 `board/` 中已完成联调的文件。

---

## 1. 先选择你要复现到哪一步

“复现”可能有四种不同含义。请先选路线，避免为了看一个演示而等待数小时重新实现硬件。

|路线|你最终得到什么|是否接开发板|需要的软件|建议人群|
|---|---|---:|---|---|
|A. 直接运行稳定版|深度图、十字叉丝、拍摄和认证功能|需要|SD 启动无需 PC 工具；JTAG 需要 Vitis/XSDB|只想演示或验收功能|
|B. 离线验证|算法输出与黄金参考的比较结果|不需要|Python；部分项目需 Vivado/Vitis HLS 2026.1|先检查算法与交付完整性|
|C. 软件全源码重建|两板 BSP、lwIP、CPU1、CPU0、FSBL、BOOT.BIN|构建时不需要|Vitis 2026.1、Python 3|验证软件可构建性|
|D. 完整硬件重建|两板 Vivado 工程、报告、bit 和 XSA|构建时不需要|Vivado/Vitis 2026.1|完整工程复现与二次开发|

初次复现推荐顺序：**B → A → C → D**。这样即使后续构建失败，也能知道原始交付和开发板功能是否正常。

---

## 2. 先认识两块板和数据流

- **领航者 Zynq-7020**：双目采集、校正、人脸检测、特征提取、身份比对和按键交互。
- **黑金 ALINX AX7020**：接收双目帧、执行四路径 SGM 深度计算并驱动 HDMI 显示。
- **板间通信**：PS 千兆以太网直连，领航者 `192.168.7.10`，AX7020 `192.168.7.20`，UDP 端口 `5001`。

两块板器件型号相同，因此下载器识别到 Zynq-7020 并不能证明接对了板。移动 JTAG 下载线后必须重新确认物理板卡角色。

---

## 3. 准备硬件

### 3.1 必需硬件

- 领航者 Zynq-7020 开发板；
- 黑金 ALINX AX7020 开发板；
- 正点原子 OV5640 双目摄像头，接领航者 J4；
- 显示器及当前工程使用的显示连接；
- 两板直连网线；
- JTAG 下载器；
- 两根 USB-UART 串口线；
- 两块板各自电源；
- 若采用 SD 启动：两张可用 SD 卡。

### 3.2 接线顺序

1. 断电状态下连接双目摄像头到领航者 J4。
2. 将显示器连接到 AX7020 的显示输出。
3. 用网线直连两块板。
4. 将两块板的 USB-UART 分别接到电脑，记录新增的两个 COM 端口。
5. 如果使用 JTAG，只把下载器接到当前要下载的板上。
6. 检查两板启动模式；JTAG 和 SD 启动的拨码/跳帽按各自板卡手册设置。
7. 最后上电。

不要带电插拔摄像头排线。移动 JTAG 下载器时不要同时改变网线、串口线和供电，否则排错时难以判断是哪一步造成变化。

---

## 4. 准备电脑环境

### 4.1 软件要求

|软件|用途|要求|
|---|---|---|
|Python 3|交付校验、构建编排和离线测试|包内基础脚本只依赖标准库|
|Vivado 2026.1|重建 RTL/BD、综合、实现、生成 bit/XSA|安装 Zynq-7000 器件支持|
|Vitis 2026.1|ARM 编译器、Vitis 平台、FSBL、XSDB|必须与 Vivado 同为 2026.1|
|Vitis HLS 2026.1|HLS C 仿真、综合和 IP 导出|完整 HLS 重建时需要|
|串口工具|查看两板运行日志|任选，波特率按工程配置|

不要把 2022.2 或其他版本生成的 BSP、FSBL、XSA、bit、ELF 混入 2026.1 主版本。

### 4.2 把工程复制到短英文路径

不要直接在 RAR/ZIP 内运行。不要使用中文路径或过深目录。下面示例统一使用：

```text
工程根目录：F:/amd_stereo_2026_1
AMD 工具根目录：E:/vivado2026.1/2026.1
本次输出根目录：F:/repro_run01
```

正确的工程根目录应直接包含：

```text
README.md
project_config.json
src/
build/
board/
reports/
```

打开 PowerShell：

```powershell
Set-Location 'F:/amd_stereo_2026_1'
$ToolRoot = 'E:/vivado2026.1/2026.1'
$RunRoot = 'F:/repro_run01'
python --version
Test-Path './project_config.json'
Test-Path './build/scripts/rebuild_all_software.py'
Test-Path $RunRoot
```

预期结果：Python 输出版本号，两个工程文件检查为 `True`，`$RunRoot` 为 `False`。输出目录必须是尚不存在的新目录；如已存在，请改用 `F:/repro_run02`。

### 4.3 检查 AMD 工具是否齐全

```powershell
$RequiredTools = @(
    'Vivado/bin/vivado.bat',
    'Vitis/bin/vitis.bat',
    'Vitis/bin/xsdb.bat',
    'Vitis/gnuwin/bin/make.exe',
    'gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe',
    'gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-ar.exe',
    'gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-objcopy.exe'
)
foreach ($RelativePath in $RequiredTools) {
    $ToolPath = Join-Path $ToolRoot $RelativePath
    if (-not (Test-Path -LiteralPath $ToolPath)) {
        throw "缺少工具：$ToolPath"
    }
}
& "$ToolRoot/gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe" --version
```

没有“缺少工具”异常且编译器能输出版本，即通过。既有复核使用 2026.1 配套 GCC 13.4.0；以本机实际输出和构建日志为准。

---

## 5. 第一步：检查交付包是否完整

这一步不连接开发板，也不会修改工程文件。

```powershell
Set-Location 'F:/amd_stereo_2026_1'
python ./scripts/verify_delivery.py
python ./ski11/scripts/selftest.py
```

### 成功判据

- `verify_delivery.py` 输出中出现 `"passed": true`；
- 各项 `navigator_*`、`ax7020_*`、`manifest_hashes`、`manifest_complete` 均为 `true`；
- 技能包自检通过。

### 如果失败

- `manifest_hashes` 失败：文件内容被修改，但清单未同步；
- `manifest_complete` 失败：工程中新增或缺少文件；
- `*_source_binding` 失败：源码与已记录的软件构建清单不一致；
- `*_boot_inputs` 失败：BOOT.BIN 与配套 FSBL/bit/ELF 不一致；
- `*_report_bit_binding` 失败：实现报告与稳定 bit 不是同一交付组合。

先保留原始输出，不要通过删除文件来“消除”失败。清单一致只证明文件状态一致，不等于功能已经上板验证。

---

## 路线 A：直接运行稳定版（最快看到结果）

稳定文件位于：

```text
board/navigator/
board/ax7020/
```

### A1. 使用 SD 卡启动

1. 分别找到：
   - `board/navigator/sd/BOOT.BIN`
   - `board/ax7020/sd/BOOT.BIN`
2. 准备两张 SD 卡，按板卡要求格式化启动分区。
3. 每张卡根目录只放对应板卡的 `BOOT.BIN`，不要交叉复制。
4. 两板断电，插入各自 SD 卡。
5. 按板卡手册设置为 SD 启动。
6. 先给 AX7020 上电，再给领航者上电。
7. 观察两块板串口和 AX7020 显示器。

### A2. 使用 JTAG 下载

先启动 Vitis 硬件服务器，连接下载器。脚本默认只打印计划，不会真正下载：

```powershell
python ./build/scripts/run_board.py ax7020 --serial YOUR_CABLE_SERIAL
```

确认下载器确实插在 AX7020 后，执行：

```powershell
New-Item -ItemType Directory -Force 'F:/repro_run01/board_logs' | Out-Null
python ./build/scripts/run_board.py ax7020 `
  --serial YOUR_CABLE_SERIAL `
  --xsdb "$ToolRoot/Vitis/bin/xsdb.bat" `
  --execute `
  --confirmed-role ax7020 `
  --log 'F:/repro_run01/board_logs/ax7020.txt'
```

保持 AX7020 供电和网线不动，把下载器移到领航者，重新确认角色后执行：

```powershell
python ./build/scripts/run_board.py navigator `
  --serial YOUR_CABLE_SERIAL `
  --xsdb "$ToolRoot/Vitis/bin/xsdb.bat" `
  --execute `
  --confirmed-role navigator `
  --log 'F:/repro_run01/board_logs/navigator.txt'
```

`YOUR_CABLE_SERIAL` 是下载器序列号，不是 COM 端口。若只有一根下载线，推荐始终先下载 AX7020，再下载领航者。

### A3. 正常运行时应看到什么

1. AX7020 串口持续报告接收、深度和显示更新；
2. 领航者串口持续报告采集、校正、发送和 peer 状态；
3. 网口指示灯亮或闪烁；
4. 显示器出现连续深度图和十字叉丝；
5. 按移动键，十字叉丝位置改变；
6. 按拍摄键，领航者完成一次人脸认证并给出结果。

若两板刚启动，先等待网络和图像链路稳定，再判断功能是否异常。

---

## 路线 B：离线验证算法和黄金参考

### B1. SGM 路径核验证

```powershell
python ./sim/sgbm_path/run_check.py `
  --vivado-bin "$ToolRoot/Vivado/bin" `
  --output 'F:/repro_run01/sgm'
```

该测试使用固定随机种子，生成 `input.mem`、`expected.mem`、`tb.sv` 和工具日志。实际 AX7020 工程使用的 `path_core.v` 与测试路径核逐字节一致。

成功判据：4,244 组输入、275,860 个候选输出与黄金参考一致，日志无 mismatch。

### B2. HLS C 仿真

```powershell
python ./build/scripts/run_hls.py `
  --vitis-run "$ToolRoot/Vitis/bin/vitis-run.bat" `
  --out 'F:/repro_run01/hls_csim' `
  --mode csim
```

此测试比较独立整数参考与优化 C++ 实现，不连接开发板，也不下载模型。

如需综合并导出 HLS IP，改用新的输出目录：

```powershell
python ./build/scripts/run_hls.py `
  --vitis-run "$ToolRoot/Vitis/bin/vitis-run.bat" `
  --out 'F:/repro_run01/hls_export' `
  --mode export
```

导出的新 IP 不会自动覆盖 `src/` 中随包提供的优化 IP。替换 IP 后必须重新做 Vivado 实现、软件接口核对和上板回归。

### B3. 完整人脸模型同帧复核

入口和数据说明见：

- [完整人脸模型同帧复核](../sim/full_model/README.md)
- [同帧验证报告](../reports/full_model_same_frame_20261101.md)
- `data/full_model_frame_2495/`

该验证覆盖一个真实正样本帧、124 个整数算子和 512 维特征。它证明该帧的板端整数计算与独立参考一致，不代表大规模人脸数据集准确率。

---

## 路线 C：两板软件从源码重建

本路线会重新构建：

```text
BSP 驱动与 libxil.a
→ lwIP 与 liblwip4.a
→ CPU1 辅助程序
→ CPU0 主应用
→ FSBL
→ BOOT.BIN
```

构建过程中不需要连接开发板，也不会写 SD 卡。

### C1. 一条命令重建全部软件

```powershell
$SoftwareOut = 'F:/repro_run01/software'
python ./build/scripts/rebuild_all_software.py `
  --tool-root "$ToolRoot" `
  --out "$SoftwareOut"
if ($LASTEXITCODE -ne 0) {
    throw "软件重建失败，请检查 $SoftwareOut 下对应步骤日志。"
}
```

请耐心等待。详细编译输出写入日志，控制台短时间不刷新不等于程序卡死。

### C2. 构建阶段和日志

|控制台阶段|实际内容|首先查看的日志|
|---|---|---|
|`navigator_dependencies`|领航者 BSP、lwIP、CPU1|`navigator_dependencies.log`|
|`navigator_application`|领航者 CPU0 应用|`navigator_application.log`|
|`ax7020_dependencies`|AX7020 BSP、lwIP、CPU1|`ax7020_dependencies.log`|
|`ax7020_application`|AX7020 CPU0 应用|`ax7020_application.log`|
|`fsbl`|为两块板生成平台和 FSBL|`fsbl.log`|
|`navigator_boot`|封装领航者 BOOT.BIN|`navigator_boot.log`|
|`ax7020_boot`|封装 AX7020 BOOT.BIN|`ax7020_boot.log`|

### C3. 成功判据

控制台最后出现：

```text
ALL_SOFTWARE_SOURCE_BUILD_PASS
```

并生成：

```text
F:/repro_run01/software/result.json
F:/repro_run01/software/.../application.elf
F:/repro_run01/software/.../fsbl.elf
F:/repro_run01/software/.../BOOT.BIN
```

这个标志只说明编译、链接和封装成功，不代表新镜像已经通过板端功能和 SD 冷启动测试。

### C4. 为什么不能直接用 IDE 默认设置编译

领航者主应用需要保留 `-O3` 和部分预览模块的 NEON 选项。使用 IDE 默认 Debug/低优化配置可能显著降低帧率。包内脚本会读取既定构建配置并动态生成嵌入数据汇编，因此应优先使用脚本。

更详细的逐文件说明、输出结构和失败重试方式见[两板驱动、双核应用和 FSBL 从源码重建](full_source_rebuild_2026_1.md)。

---

## 路线 D：Vivado 硬件也从零重建

这一部分耗时最长。它会重新创建两块板的 Vivado 工程，综合、布局布线并生成报告、bit 和 XSA。

### D1. 创建两板工程

```powershell
$HardwareOut = 'F:/repro_run01/hardware'
powershell -File ./build/scripts/recreate_projects.ps1 `
  -ToolRoot $ToolRoot `
  -OutputRoot $HardwareOut
```

脚本会注册包内 IP、创建 Block Design、校验设计并生成输出产品。成功后应存在：

```text
F:/repro_run01/hardware/navigator/nav_v3.xpr
F:/repro_run01/hardware/ax7020/ax7020.xpr
```

### D2. 综合并实现领航者

```powershell
& "$ToolRoot/Vivado/bin/vivado.bat" `
  -mode batch `
  -source ./build/scripts/build_hardware.tcl `
  -tclargs `
  'F:/repro_run01/hardware/navigator/nav_v3.xpr' `
  'F:/repro_run01/nav_reports' `
  navigator
```

### D3. 综合并实现 AX7020

```powershell
& "$ToolRoot/Vivado/bin/vivado.bat" `
  -mode batch `
  -source ./build/scripts/build_hardware.tcl `
  -tclargs `
  'F:/repro_run01/hardware/ax7020/ax7020.xpr' `
  'F:/repro_run01/ax_reports' `
  ax7020
```

### D4. 这一步做了哪些优化

领航者实现流程会在 `opt_design` 后对高密度逻辑使用 CLB 布局范围，再执行 Explore 布局布线和 AggressiveExplore 物理优化。BRAM、DSP、时钟、PS 和 I/O 不受该 CLB 区域限制。

布局限制只约束可放置区域，不保证每次实现自动通过时序。不同电脑、工具并行度和实现种子可能使资源或 WNS 略有变化。

### D5. 硬件构建验收清单

不要只看“Generate Bitstream completed”。必须同时检查：

- 综合和实现均完成；
- DRC 无 Error；
- 所有网络完成布线；
- WNS 为正，TNS 为 0，失败端点为 0；
- Hold 和 Pulse Width 无失败端点；
- 领航者和 AX7020 各类资源均低于 90%；
- 输出 bit 和 XSA 均存在；
- 报告中的目标器件、时钟和版本正确。

包内正式结果为：领航者 WNS `+0.325 ns`、Slice `88.62%`；AX7020 WNS `+0.618 ns`、Slice `65.38%`。重新实现的具体数值允许因布局布线而变化，但必须满足验收条件。

---

## 6. 新硬件与新软件怎样配套

这是最容易出错的一步。以下文件形成一组配套关系：

```text
Vivado 硬件设计
  ├─ system.bit
  └─ system.xsa
       ├─ BSP / 驱动
       ├─ FSBL
       └─ 主应用 application.elf
```

如果硬件地址、Device ID、寄存器接口或中断发生变化，旧 BSP/FSBL/ELF 可能仍能编译，但运行结果不正确。新硬件必须使用对应 XSA 重新生成软件平台并做完整上板回归。

不要把新生成的文件直接复制覆盖 `board/`。先放到独立候选目录，记录 SHA-256，并完成：

1. JTAG 下载；
2. 双串口启动检查；
3. 双板以太网与深度图；
4. 十字叉丝移动；
5. 拍摄与认证；
6. 持续运行和异常计数；
7. SD 冷启动。

---

## 7. 生成新的 SD 启动镜像

如果只想重新封装已验证稳定版输入：

```powershell
python ./build/scripts/build_sd.py ax `
  --tool-root "$ToolRoot" `
  --out 'F:/repro_run01/new_boot/ax/BOOT.BIN'

python ./build/scripts/build_sd.py nav `
  --tool-root "$ToolRoot" `
  --out 'F:/repro_run01/new_boot/nav/BOOT.BIN'
```

脚本默认使用 `board/` 中已配套的 FSBL、bit 和 ELF，只在磁盘生成 BOOT.BIN，不会自动写卡。

测试新版本时，显式传入同一组经过核对的 `--bit`、`--elf`、`--fsbl`。封装成功只表示 Bootgen 成功，仍需写卡读回和两板断电冷启动验收。

---

## 8. 最终验收步骤

建议按以下顺序记录结果：

### 8.1 离线

- [ ] `verify_delivery.py` 通过；
- [ ] 技能包自检通过；
- [ ] SGM 路径核无 mismatch；
- [ ] HLS C 仿真通过；
- [ ] 两板软件全源码重建通过；
- [ ] 两板硬件实现报告满足资源和时序要求。

### 8.2 JTAG 上板

- [ ] AX7020 正常启动；
- [ ] 领航者正常启动；
- [ ] 两板网口灯亮/闪；
- [ ] 两串口角色与日志内容对应；
- [ ] 深度图连续显示；
- [ ] 十字叉丝可以移动；
- [ ] 拍摄键有响应；
- [ ] 人脸认证结果正常；
- [ ] 持续运行时异常计数没有增长。

### 8.3 SD 冷启动

- [ ] 两板分别写入正确的 BOOT.BIN；
- [ ] 设置为 SD 启动；
- [ ] 完全断电后重新上电；
- [ ] 不连接 JTAG 仍能完成深度显示和认证；
- [ ] 记录写入文件、读回散列、串口日志和测试时间。

---

## 常见故障与排查顺序

|现象|最常见原因|先做什么|
|---|---|---|
|脚本提示找不到 `project_config.json`|不在工程根目录|运行 `Get-Location` 和 `Test-Path ./project_config.json`|
|ARM 链接失败或路径异常|中文/超长路径|把完整工程复制到短英文路径|
|找不到编译器、Vitis 或 Bootgen|`$ToolRoot` 错误或安装不完整|执行第 4.3 节工具检查|
|输出目录已存在|脚本防止覆盖旧证据|换用新的 `repro_run02`|
|Vivado 能生成 bit 但 WNS 为负|布局布线未收敛|查看最差路径、实现策略和布局范围，不要直接下板当正式版本|
|显示器只有十字叉丝|AX7020 显示链路运行，但没有有效深度帧|检查两板程序配套、网线、IP/端口、启动顺序和帧计数|
|网口灯不亮|网线、PHY、供电或软件未启动|检查物理链路，再看两板串口启动日志|
|深度图很卡|领航者编译优化丢失或帧链路阻塞|确认主应用 `-O3`、NEON 选项和发送/接收计数|
|按键没有反应|领航者应用未运行或按键映射/状态异常|先看领航者串口，再确认下载的是领航者版本|
|`invalid command name ps7_init`|初始化 TCL 与硬件/XSA 不配套|使用同一硬件导出的 `ps7_init.tcl`，不要手改函数名|
|JTAG 扫描链全为 0|板未供电、接头松动或方向错误|检查目标板电源和下载器板端接头|
|两个 COM 口分不清|Windows 端口号会变化|逐个断开/接入并记录板卡角色，不依赖历史 COM3/COM11|
|SD 卡启动无反应|启动模式错误或 BOOT.BIN 放错板|核对拨码/跳帽、卡根目录和板卡角色|

排错时一次只改变一个因素，并保存两块板的串口日志。不要同时换程序、网线、启动模式和供电，否则无法定位原因。

---

## 9. 复现完成后应保存什么

建议把每次复现结果放在独立目录，至少保留：

```text
repro_run01/
├── commands.txt             # 实际执行命令和工具路径
├── software/                # 编译日志、result.json、ELF、FSBL、BOOT.BIN
├── hardware/                # 两板 Vivado 工程
├── nav_reports/             # 领航者资源、时序、DRC、bit、XSA
├── ax_reports/              # AX7020 资源、时序、DRC、bit、XSA
├── sgm/                     # SGM 输入、黄金输出和日志
├── hls_csim/                # HLS C 仿真结果
├── board_logs/              # 两板串口/JTAG运行日志
└── hashes.txt               # 候选产物 SHA-256
```

这样能够区分“原始稳定交付”“本次重建结果”和“后续修改版本”，避免把不同版本的报告、位流和软件混在一起。

---

## 10. 进一步阅读

- [项目总览与指标](../README.md)
- [全软件源码重建的逐文件说明](full_source_rebuild_2026_1.md)
- [资源、时序与性能汇总](../reports/summary.md)
- [完整人脸模型同帧验证](../reports/full_model_same_frame_20261101.md)
- [赛事交付内容索引](submission_requirements.md)
- [SGM 路径核复现说明](../sim/sgbm_path/)
- [HLS 与数值等价证据](../sim/hls/)


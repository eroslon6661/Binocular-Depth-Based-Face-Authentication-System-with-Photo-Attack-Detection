# 两板驱动、双核应用和 FSBL 从源码重建

本说明面向首次接触工程的复现人员，给出环境准备、执行步骤、输出文件、成功判据和失败定位方法。下文命令均在 Windows PowerShell 中执行，路径可按实际安装位置调整。

## 1. 复现范围与工具分工

主入口为 `build/scripts/rebuild_all_software.py`。它重建两块板的软件依赖与启动镜像，不连接开发板、不下载程序，也不写入 SD 卡。执行本流程时可以不接开发板。

|内容|本流程如何处理|使用工具|
|---|---|---|
|主应用 BSP 驱动和 lwIP|使用包内源码与配置重新编译静态库|2026.1 配套 ARM GCC、make|
|CPU1 辅助程序|重新编译、链接，并转换为二进制|ARM GCC、objcopy|
|CPU0 主应用|重新编译源文件，链接新驱动库并嵌入新 CPU1 程序|ARM GCC|
|FSBL 启动程序|从包内 XSA 新建平台，生成并编译启动 BSP 和 FSBL|Vitis 2026.1|
|BOOT.BIN|组合新 FSBL、包内位流和新主应用|Bootgen 2026.1|
|FPGA 硬件|本流程复用包内 XSA 和位流；重新综合、布局布线见第 8 节|Vivado 2026.1|
|HLS 加速器|本流程使用硬件平台中已有的 IP；源码验证和重新导出见第 8 节|Vitis HLS 2026.1|
|模型权重、标定表及其他业务数据|作为已有输入使用，不重新训练、标定或修改|按 `project_config.json` 及应用源码引用|

“软件从源码重建”和“包含 FPGA 的完整硬件重建”是不同范围。完整硬件复现需要安装并调用 Vivado；仅执行本文的软件主入口不会重新综合 RTL。主入口调用厂商命令行工具，不要求手动打开 Vivado/Vitis 图形界面。

主应用保留包内兼容的驱动 API、BSP 配置头和链接脚本，重新编译库文件；FSBL 则使用 2026.1 安装目录中的源码生成。驱动 API 版本与编译器版本不能混为一谈，本流程不自动把主应用改写为新的 SDT 驱动 API。

## 2. 准备目录与运行环境

### 2.1 安装与输入要求

- Windows 环境，安装 Python 3。既有复核使用的脚本只依赖 Python 标准库；FSBL 步骤由 Vitis 自身 Python 环境运行。
- 安装 AMD 2026.1 工具，包含 Vitis、ARM 裸机编译器、make 和 Bootgen；完整硬件复现还需 Vivado、Zynq-7000 器件支持与所需许可证。
- 软件和硬件各自使用新的输出目录，不把输出写回 `src/`、`board/` 或原始报告目录。
- 将工程复制到短英文路径。不要直接在压缩包内运行，也不要仅复制 `build/scripts/`。

以下示例约定：

|变量|示例|含义|
|---|---|---|
|工程根目录|`F:/amd_stereo_2026_1`|直接包含 `project_config.json`、`src/`、`build/` 的目录|
|工具根目录|`E:/vivado2026.1/2026.1`|其下包含 `Vivado/`、`Vitis/`、`gnu/`|
|本次软件输出|`F:/repro_run01/software`|开始前必须不存在，由脚本创建|

用文件资源管理器将工程根目录的全部内容复制到 `F:/amd_stereo_2026_1`，然后打开 PowerShell，执行：

```powershell
Set-Location 'F:/amd_stereo_2026_1'
$ToolRoot = 'E:/vivado2026.1/2026.1'
$BuildOut = 'F:/repro_run01/software'
python --version
Test-Path './project_config.json'
Test-Path './build/scripts/rebuild_all_software.py'
Test-Path $BuildOut
```

成功判据：Python 能输出版本；两个输入检查均为 `True`；输出目录检查为 `False`。如输出目录已存在，改用 `F:/repro_run02/software` 等新目录，保留旧日志供定位，不要在旧结果上覆盖执行。

### 2.2 检查工具是否齐全

继续在同一个 PowerShell 窗口执行：

```powershell
$RequiredTools = @(
    'Vitis/bin/vitis.bat',
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
$BootgenCandidates = @(
    (Join-Path $ToolRoot 'Vivado/bin/unwrapped/win64.o/bootgen.exe'),
    (Join-Path $ToolRoot 'Vitis/bin/unwrapped/win64.o/bootgen.exe')
)
if (-not ($BootgenCandidates | Where-Object { Test-Path -LiteralPath $_ })) {
    throw '未找到 Bootgen，请核对工具安装目录。'
}
& "$ToolRoot/gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe" --version
```

成功判据：没有“缺少工具”异常，编译器输出版本信息。既有记录使用 2026.1 配套 GCC 13.4.0；实际执行版本应以本机输出和生成日志为准。不要从其他工具版本临时拼接编译器、运行库或 Vitis 组件。

### 2.3 检查工程输入

```powershell
$RequiredInputs = @(
    'src/navigator/software',
    'src/navigator/deps/bsp/include',
    'src/navigator/deps/bsp/libsrc',
    'src/navigator/deps/crc_core1/src',
    'src/ax7020/software',
    'src/ax7020/deps/bsp/include',
    'src/ax7020/deps/bsp/libsrc',
    'src/ax7020/deps/crc_core1/src',
    'reports/implementation/navigator/system.xsa',
    'reports/implementation/ax7020/system.xsa',
    'board/navigator/jtag/system.bit',
    'board/ax7020/jtag/system.bit'
)
foreach ($InputPath in $RequiredInputs) {
    if (-not (Test-Path -LiteralPath $InputPath)) {
        throw "缺少工程输入：$InputPath"
    }
}
python ./scripts/verify_delivery.py
```

`verify_delivery.py` 为只读检查，会核对文件清单、源码与应用绑定、BOOT 输入及报告与位流配对。完整未修改交付包应返回 `passed: true`。若自行修改过文档但未同步根目录 `manifest.json`，清单校验可能失败；需要根据具体失败项区分文档变更与源码/镜像不匹配。重算清单仅记录当前文件状态，不能证明修改后的算法正确或硬件已通过验证。

## 3. 执行两板软件全源重建

确认上述目录和工具检查完成，在工程根目录运行：

```powershell
python ./build/scripts/rebuild_all_software.py --tool-root "$ToolRoot" --out "$BuildOut"
if ($LASTEXITCODE -ne 0) {
    throw "软件重建失败，请检查 $BuildOut 下对应步骤日志。"
}
```

脚本按如下顺序执行，控制台会输出 `BUILD_STEP` 阶段标识。编译器详细输出写入日志，因此控制台短时间没有新行不等于卡住。

|阶段标识|实际执行内容|首先查看的日志|
|---|---|---|
|`navigator_dependencies`|领航者 BSP、lwIP、CPU1 重建|`navigator_dependencies.log`|
|`navigator_application`|领航者 CPU0 主应用编译与链接|`navigator_application.log`|
|`ax7020_dependencies`|AX7020 BSP、lwIP、CPU1 重建|`ax7020_dependencies.log`|
|`ax7020_application`|AX7020 CPU0 主应用编译与链接|`ax7020_application.log`|
|`fsbl`|为两块板分别生成平台和 FSBL|`fsbl.log`|
|`navigator_boot`|封装领航者启动镜像|`navigator_boot.log`|
|`ax7020_boot`|封装 AX7020 启动镜像|`ax7020_boot.log`|

所有表中日志均位于 `$BuildOut`。脚本遇到子步骤非零退出码即停止，不应忽略异常继续把已有文件当作完整结果。

全部阶段成功后，控制台最后出现：

```text
ALL_SOFTWARE_SOURCE_BUILD_PASS
```

同时应生成 `$BuildOut/result.json`。该标志表示构建与封装完成，不表示已经下载、SD 启动或通过整机功能测试。

## 4. 每一步具体重建了什么

### 4.1 BSP、网络库与 CPU1

`rebuild_legacy_dependencies.py` 将包内 BSP 的 `include/`、`libsrc/` 复制到新输出目录，并过滤原有 `.o`、`.a`、`.d`、`.elf`、`.bin` 构建文件。随后重新编译驱动、生成 `libxil.a`，通过 make 编译 lwIP 得到 `liblwip4.a`。

CPU1 由包内 `deps/crc_core1/src/`、`lscript.ld` 和 `build_options.json` 重建，链接新生成的 `libxil.a`，再经 objcopy 得到 `crc_core1.bin`。既有记录中领航者和 AX7020 的 libxil 对象数分别为 145、135；对象数以本次 `result.json` 为准，不能单凭数量相同判断结果正确。

### 4.2 CPU0 主应用

`build_software.py` 接收新 BSP 路径和新 CPU1 二进制，重新编译包内 PS 源码并链接为 `application.elf`。脚本保留主应用 `-O3`、相关功能宏，以及 `db_preview_pixels.c`、`db_preview_shading.c` 的 NEON 编译选项。

不要用 IDE 默认低优化配置替换上述选项后仍沿用原帧率结论。驱动编译的 `-O2` 与主应用的 `-O3` 是脚本各自的既定设置，无需人为统一。

### 4.3 FSBL

主入口使用以下形式调用 Vitis 专用脚本：

```text
Vitis/bin/vitis.bat -s build/scripts/rebuild_fsbl_2026.py --workspace <新工作区>
```

不能改为普通 `python rebuild_fsbl_2026.py`：脚本依赖 Vitis 提供的 `vitis` 模块及服务。它读取 `reports/implementation/<板卡>/system.xsa`，为 `ps7_cortexa9_0` 创建 standalone 平台并构建 FSBL。

此入口固定读取包内 XSA，没有 `--xsa` 参数。将新硬件报告生成在另一个目录，不会使该脚本自动切换到新 XSA。

### 4.4 BOOT.BIN

`build_sd.py` 按 FSBL → 位流 → CPU0 应用的顺序调用 Bootgen。主入口显式传入新 FSBL 与新应用，但没有传 `--bit`，因此使用 `board/<板卡>/jtag/system.bit`。

两块板必须分别封装，不能交换 BOOT.BIN。Bootgen 成功只表示镜像封装成功，不能证明其中硬件和软件在板上兼容。

## 5. 输出目录与成功检查

本次运行的文件写入 `--out` 指定目录，不会自动更新包内 `validation_candidates/`。目录结构中的主要文件如下：

```text
F:/repro_run01/software/
  commands.json
  result.json
  navigator_dependencies.log
  navigator_application.log
  ax7020_dependencies.log
  ax7020_application.log
  fsbl.log
  navigator_boot.log
  ax7020_boot.log
  navigator_deps/
    bsp/lib/libxil.a
    bsp/lib/liblwip4.a
    crc_core1/crc_core1.elf
    crc_core1/crc_core1.bin
    bsp_build.log
    lwip_build.log
    cpu1_build.log
    commands.json
    result.json
  ax7020_deps/                    # 结构与 navigator_deps 相同
  navigator_app/
    application.elf
    application.map
    build_manifest.json
  ax7020_app/                     # 结构与 navigator_app 相同
  fsbl_workspace/
    source_build_result.json
    navigator_source/zynq_fsbl/build/fsbl.elf
    ax7020_source/zynq_fsbl/build/fsbl.elf
  navigator/BOOT.BIN
  ax7020/BOOT.BIN
```

主入口按上述 FSBL 路径取文件。若实际 Vitis 输出布局不同，必须检查 `fsbl.log` 和 `source_build_result.json` 中的真实路径，不能随意拿旧 FSBL 补齐。

执行以下只读检查：

```powershell
$ExpectedOutputs = @(
    'navigator_deps/bsp/lib/libxil.a',
    'navigator_deps/bsp/lib/liblwip4.a',
    'navigator_deps/crc_core1/crc_core1.bin',
    'ax7020_deps/bsp/lib/libxil.a',
    'ax7020_deps/bsp/lib/liblwip4.a',
    'ax7020_deps/crc_core1/crc_core1.bin',
    'navigator_app/application.elf',
    'ax7020_app/application.elf',
    'fsbl_workspace/navigator_source/zynq_fsbl/build/fsbl.elf',
    'fsbl_workspace/ax7020_source/zynq_fsbl/build/fsbl.elf',
    'navigator/BOOT.BIN',
    'ax7020/BOOT.BIN',
    'result.json'
)
foreach ($RelativePath in $ExpectedOutputs) {
    $OutputPath = Join-Path $BuildOut $RelativePath
    if (-not (Test-Path -LiteralPath $OutputPath)) {
        throw "缺少输出：$OutputPath"
    }
    if ((Get-Item -LiteralPath $OutputPath).Length -eq 0) {
        throw "输出为空：$OutputPath"
    }
}
Get-Content -LiteralPath "$BuildOut/result.json"
Get-FileHash -LiteralPath "$BuildOut/navigator/BOOT.BIN" -Algorithm SHA256
Get-FileHash -LiteralPath "$BuildOut/ax7020/BOOT.BIN" -Algorithm SHA256
```

应同时满足：脚本退出码为 0、出现完成标志、文件非空、记录与所用输入对应。`result.json` 中 `pl_reimplemented`、`board_tested`、`sd_written` 为 `false` 是本流程的正常状态，分别表示尚未重新实现硬件、尚未板验、尚未写卡。

保留 `commands.json`、各阶段日志、应用 `build_manifest.json`、FSBL 的 `source_build_result.json` 和本次产物。根目录 `scripts/verify_delivery.py` 检查的是包内文件，不会自动验证新建的 `$BuildOut` 目录。

## 6. 失败时如何定位和重试

先查看控制台最后一个 `BUILD_STEP`，再打开对应日志。例如 FSBL 阶段失败：

```powershell
Get-Content -LiteralPath "$BuildOut/fsbl.log" -Tail 100
```

依赖编译失败时，继续查看 `<板卡>_deps/bsp_build.log`、`lwip_build.log`、`cpu1_build.log`；若生成了 `last_failure.log`，也一并查看。

|现象|常见原因|处理方法|
|---|---|---|
|`Use a new output directory` 或目录已存在|重复使用旧输出路径|保留旧结果，修改 `$BuildOut` 后从主入口重试|
|找不到脚本或 `project_config.json`|未进入工程根目录，或多套了一层目录|进入直接包含 `project_config.json` 的目录|
|`ASCII-only absolute path` 或链接器路径异常|工程绝对路径含中文或路径过长|完整复制到短英文路径，使用新的英文输出路径|
|找不到 GCC、make、Bootgen|安装不完整或 `--tool-root` 指向错误层级|按第 2 节逐项检查工具文件|
|`No module named vitis`|用系统 Python 执行了 FSBL 专用脚本|由主入口或 `vitis.bat -s` 启动|
|`Missing embedded data`|模型、标定表或 CPU1 输入缺失|按错误路径核查 `project_config.json` 对应输入，不用空文件代替|
|驱动头文件、DeviceID 或 baseaddress 不匹配|混入了另一硬件平台或不兼容驱动 API|恢复与目标硬件对应的 BSP 配置，核对寄存器及地址映射|
|`fsbl.elf` 缺失|平台构建失败，或生成路径与入口预期不符|查看 `fsbl.log` 及 FSBL 结果记录，确认真实失败原因|
|链接成功但帧率下降|主应用编译选项与基线不同|检查 `-O3`、NEON 和功能宏，并实测帧率|
|BOOT 封装成功但不启动|FSBL、位流、应用或启动模式不匹配|核对两板角色及文件来源，按上板流程检查启动模式和日志|

主入口不提供断点续跑参数。为避免混合失败前后的文件，建议保留失败目录，修复输入或环境后改用新的输出目录完整重跑。BSP 归档响应文件由脚本生成，使用正斜杠和逐路径引号，不必手工替换为 Windows 反斜杠格式。

## 7. 既有证据与本次结果的区别

包内记录显示，2026-11-01曾在新目录连续完成两板软件全源重建与封装。历史日志、命令和散列保存在 `reports/recheck/full_source_build/`；当时归档的候选文件位于 `validation_candidates/navigator/`、`validation_candidates/ax7020/`。

这些是已有执行记录，不是新电脑、新源码或本次输出的通过证明。本次结果应以第 3～5 节产生的日志及文件为准。包内 `board/` 保存原稳定镜像，本流程不覆盖它；包内归档的候选BOOT已完成冷启动和整机功能验收，重新构建得到的新输出仍须重新验收。

## 8. 若需连 FPGA 硬件也从零重建

### 8.1 用 Vivado 创建工程、综合并实现

这一步需要 Vivado 2026.1。可由脚本自动调用，无需手工搭建 block design。保持 PowerShell 位于工程根目录，另选新的硬件输出路径：

```powershell
$HardwareOut = 'F:/repro_run01/hardware'
$NavReports = 'F:/repro_run01/nav_reports'
$AxReports = 'F:/repro_run01/ax_reports'
& ./build/scripts/recreate_projects.ps1 -ToolRoot "$ToolRoot" -OutputRoot "$HardwareOut"
if ($LASTEXITCODE -ne 0) { throw 'Vivado 工程创建失败。' }
& "$ToolRoot/Vivado/bin/vivado.bat" -mode batch -source ./build/scripts/build_hardware.tcl -tclargs "$HardwareOut/navigator/nav_v3.xpr" "$NavReports" navigator
if ($LASTEXITCODE -ne 0) { throw '领航者硬件构建失败。' }
& "$ToolRoot/Vivado/bin/vivado.bat" -mode batch -source ./build/scripts/build_hardware.tcl -tclargs "$HardwareOut/ax7020/ax7020.xpr" "$AxReports" ax7020
if ($LASTEXITCODE -ne 0) { throw 'AX7020 硬件构建失败。' }
```

以上三个输出位置应未被旧运行占用。若 PowerShell 阻止执行 `.ps1`，按本机脚本执行管理要求处理，不将脚本被阻止误判为 Vivado 综合错误。

每块板完成后会输出 `HARDWARE_BUILD_PASS role=...`，报告目录包含 `system.bit`、`system.xsa`、`system_routed.dcp`、`timing_summary.rpt`、`utilization.rpt`、`drc.rpt`、`bus_skew.rpt` 等文件。

该完成标志不是完整验收门槛。必须查看实际建立、保持和脉宽结果、未约束项、DRC、总线偏斜及资源占用；WNS为负时不能仅因位流已生成而判为合格。

如需在图形界面查看最终结果，可打开新的 Vivado 窗口，在其 Tcl Console 中执行：

```tcl
open_checkpoint {F:/repro_run01/nav_reports/system_routed.dcp}
report_timing_summary -name Reproduced_Navigator_Timing -delay_type min_max -report_unconstrained
report_utilization -name Reproduced_Navigator_Utilization
```

查看 AX7020 时使用另一个窗口，并将路径换为 `F:/repro_run01/ax_reports/system_routed.dcp`。详细硬件步骤与板端操作见[构建、运行与复核](reproduction.md)。

### 8.2 HLS 源码验证与 IP 重建的范围

默认 Vivado 工程重建注册包内已导出的 IP。若还需重新运行 HLS，可先执行：

```powershell
python ./build/scripts/run_hls.py --vitis-run "$ToolRoot/Vitis/bin/vitis-run.bat" --out F:/repro_run01/hls_csim --mode csim
if ($LASTEXITCODE -ne 0) { throw 'HLS C 仿真失败。' }
python ./build/scripts/run_hls.py --vitis-run "$ToolRoot/Vitis/bin/vitis-run.bat" --out F:/repro_run01/hls_export --mode export
if ($LASTEXITCODE -ne 0) { throw 'HLS 导出失败。' }
```

两个输出目录都须是新目录。`csim` 比较 C 级数值结果；`export` 进入综合和 IP 导出流程。导出的新 IP 不会被上述 Vivado 重建命令自动替换到工程中。采用它之前，需在单独工作副本中完成 IP 注册/替换，核对 AXI-Lite 寄存器偏移、地址宽度、握手和复位，再重建硬件并进行功能验证。不能把 C 仿真通过等同于 RTL 协同仿真或上板通过。

### 8.3 新硬件与软件如何配套

第 3 节的一键软件入口始终读取包内 XSA 和位流，不能直接将它生成的 BOOT.BIN 标注为第 8.1 节新硬件的产物。

要使用新硬件，需要先核对新 XSA 中的 PS 配置、时钟、外设地址、IP 接口与软件假设是否一致；再用该 XSA 在 Vitis 2026.1 中生成对应平台和 FSBL。主应用 BSP 配置及驱动也须与新硬件一致。若接口发生变化，需完成相应软件适配，而不是只替换位流。

现有 `rebuild_fsbl_2026.py` 未提供外部 XSA 参数。因此，新 XSA 的平台生成属于需显式执行的额外步骤，不能声称现有一键入口已经完成。得到并验证配套文件后，可用以下模板封装新镜像；运行前必须把占位路径替换为实际文件：

```text
python build/scripts/build_sd.py nav --tool-root <工具根目录> --bit <领航者新system.bit> --fsbl <由配套XSA生成的fsbl.elf> --elf <配套application.elf> --out <新目录>/navigator/BOOT.BIN
python build/scripts/build_sd.py ax --tool-root <工具根目录> --bit <AX7020新system.bit> --fsbl <由配套XSA生成的fsbl.elf> --elf <配套application.elf> --out <新目录>/ax7020/BOOT.BIN
```

## 9. 进入上板验证前的交接清单

- 保留每块板的角色、XSA、位流、FSBL、应用和 BOOT 的来源路径与散列。
- 确认本次构建范围：仅软件重建，或软件与硬件都已重建；未执行的步骤不能写成通过。
- 按[复现操作第 4、5 节](reproduction.md)进行上板和 SD 验收。包内默认 JTAG 入口使用稳定镜像，不会自动下载本次输出目录中的候选文件。
- 验证双目左右帧计数、两板网络、深度画面、持续帧率、十字叉丝按键与拍摄认证，并记录失败情况。
- 新 BOOT.BIN 写卡后完成断电重启验证；单次 JTAG 运行正常不能替代 SD 冷启动验收。

至此，软件构建、硬件实现、镜像封装与板端验证分别有明确的输入、输出和验收记录，可以区分构建成功与系统运行成功。

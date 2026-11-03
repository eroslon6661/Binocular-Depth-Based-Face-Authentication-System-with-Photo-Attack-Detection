# 同帧完整人脸模型复核

适用：本包2026.1领航者、相同DDR布局、YuNet320与MobileFaceNet112权重和描述。不是任意板卡通用的内存转储程序。

离线复核不需接板。先安装Python依赖（本次numpy来自运行环境；ONNX1.23.2、ONNX Runtime1.31.1），在工程根执行：

```
python -m pip install numpy onnx==1.23.2 onnxruntime==1.31.1
python sim/full_model/compare_snapshot.py --capture data/full_model_frame_2495/capture --out F:/new_check/onnx
python sim/full_model/integer_reference.py --capture data/full_model_frame_2495/capture --out F:/new_check/integer
```

MATLAB可选复核：把sim/full_model加入路径，执行check_embeddings_matlab('F:/new_check/onnx')。只读已导出特征，不需深度学习工具箱，也不把MATLAB结果等同于板端模型准确率。

重新采集时先用prepare_snapshot.py --out <新源码目录>生成诊断副本，再使用build_software.py nav --source <副本> --out <新构建目录>编译；依照build/scripts/run_board.py核实角色后下载诊断ELF。一次认证完成后，使用xsdb dump_snapshot.tcl <新导出目录>导出；该脚本当前限定JTAG-HS1序列号210512180081，换下载器必须先核实并修改过滤条件。随后恢复board/navigator/jtag配套程序。prepare_snapshot.py生成的复制点占用0x1c000000至0x1d50003f的指定区域，板卡内存、链接脚本或固定缓冲布局变更后必须重新审核，不能直接套用。

失效条件：完成标记不对、帧号中途变化、内存长度不符、模型描述或权重不匹配、改用其他模型、捕获后再次认证、缓存未刷回。脚本在标记、帧号或长度不符时拒绝导出，在描述不符时拒绝比较。本次导出未暂停CPU，快照区在下一次拍摄前保持不变。

`generate_face_runtime.py`来自既有项目生成器，当前生成结果与实际描述整文件SHA256一致；整数参考与ONNX参考独立实现。结果和边界见`reports/full_model_same_frame_20261101.md`。完整诊断ELF位于`data/`，仅用于复核，不是默认上板镜像。

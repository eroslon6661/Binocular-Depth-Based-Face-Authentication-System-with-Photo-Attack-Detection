# Navigator calibrated INT8 face models

Generated with Python 3.12 and ONNX Runtime static MinMax calibration from the
22 accepted board captures (12 `person_01`, 10 impostor captures).

- `yunet_320_hls_int8.pack`: 53 Conv layers in the `face_int8_accel` ABI.
- `yunet_320_hls_int8.json`: layer shapes, scales, offsets and checksums.
- `mobilefacenet_112_hls_int8.pack`: 49 Conv + 1 Gemm layers in the same ABI.
- `mobilefacenet_112_hls_int8.json`: layer shapes, scales, offsets and checksums.

The full calibrated QDQ ONNX models and `calibration_report.json` are in
`models/calibrated_int8_20261015`. The board packs contain signed INT8 OHWI
weights, INT32 bias, per-output-channel Q31 multipliers, signed shifts, and Q15
PReLU slopes. They are embedded at DDR `0x18000000` by `db_face_model_data.S`.

The generated static schedule lives in `software/src/db_face_model_generated.*`.
`db_face_hls_backend.c` performs letterbox/preprocessing, asynchronous HLS layer
dispatch, integer Add/MaxPool/Resize, YuNet decode, MobileFaceNet final BN/L2
normalization, and returns the INT8 512-vector to `db_face_match_i8()`.

Quantized matching calibration (Q15): threshold 16384, genuine minimum 24004,
impostor maximum 11328. Final acceptance must still be checked on the physical
board because the accelerator schedule is not represented by ONNX Runtime.

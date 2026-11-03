# Offline face-model selection

These files are the pinned reference models for the two-board offline face-lock
implementation.  Do not silently replace them: model preprocessing, embeddings,
thresholds, INT8 calibration data, and generated FPGA weights are version-coupled.

## YuNet detector

- Runtime/HLS source: `yunet/face_detection_yunet_2026may.onnx`
- SHA-256: `EBAFCE4E3C118D6554634BE5C27AB333B4C047A9A8C3FAF1D7CF93101C22F0F0`
- Source: OpenCV Zoo `face_detection_yunet` model directory.
- Reason: the graph has dynamic image dimensions, so it runs directly at the
  selected 320x320 detector size.  It returns confidence, bounding box, and five
  landmarks at strides 8, 16, and 32.
- The older fixed 640x640 `face_detection_yunet_2023mar.onnx` is retained as a
  compatibility/reference copy.
- Reference-copy SHA-256:
  `8F2383E4DD3CFBB4553EA8718107FC0423210DC964F9F4280604804ED2552FA4`

## MobileFaceNet recognizer

- Runtime/HLS source: `insightface_buffalo_sc/w600k_mbf.onnx`
- SHA-256: `9CC6E4A75F0E2BF0B1AED94578F144D15175F357BDC05E815E5C4A02B319EB4F`
- Official package: InsightFace `buffalo_sc.zip`
- Package SHA-256:
  `57D31B56B6FFA911C8A73CFC1707C73CAB76EFE7F13B675A05223BF42DE47C72`
- Input: aligned RGB face, NCHW float reference tensor, 112x112, normalized with
  `(pixel - 127.5) / 127.5`.
- Output: 512-dimensional embedding; L2-normalize before cosine similarity.
- `det_500m.onnx` is part of the official package but is not selected because
  YuNet is the detector for this project.

## Validation performed

- Both selected ONNX files pass `onnx.checker.check_model` and ONNX Runtime CPU
  inference.
- YuNet at 320x320 detected exactly one face in each of three supplied portraits,
  with scores 0.9381 to 0.9390.
- MobileFaceNet produced finite 512-dimensional normalized embeddings.
- Same-person pairwise cosine similarities across those portraits were
  0.9325, 0.9369, and 0.9510.
- Validation outputs are in `../captures/face_model_validation_320_20261014/`.

## Licensing note

OpenCV Zoo is Apache-2.0 but individual model terms still apply. InsightFace
states that its supplied pretrained model weights are for non-commercial
research use. This project selected those weights for the stated competition
prototype. A commercial product must replace or separately license the
recognition weights.

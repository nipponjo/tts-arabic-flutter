# tts_arabic_flutter

A basic [Flutter](https://flutter.dev/) demo app for Arabic TTS with models from [tts_arabic](https://github.com/nipponjo/tts_arabic) / [tts-arabic-pytorch](https://github.com/nipponjo/tts-arabic-pytorch). 

The app runs [ONNX](https://github.com/onnx/onnx) models using the package [onnxruntime_flutter](https://github.com/gtbluesky/onnxruntime_flutter).

## Setup

0. (Set up [Flutter](https://flutter.dev/))
1. Download the onnx models from [Google drive](https://drive.google.com/drive/folders/1cz3TRIgNsjcf0CvYPwjnVPdtWyI1iKVN). By default, `mixer128.onnx` and `vocos22.onnx` are activated.
2. Put the onnx files into the `assets/models` folder.
3. (Modify the following lines in `pubspec.yaml` and `main.dart` to use other models than `mixer128.onnx` and `vocos22.onnx`)

in `pubspec.yaml`
```yaml
assets:
  - assets/models/mixer128.onnx
  - assets/models/vocos22.onnx
```
in `main.dart`
```dart
_ttsModel!.initSessions(
  modelPath: "assets/models/mixer128.onnx",
  vocoderPath: "assets/models/vocos22.onnx",
);
```

## Supported models:
|Model|Model ID|Type|#params|File|Paper|
|-------|---|---|------|----|---|
|FastPitch|fastpitch|Text->Mel|46.3M|fp_ms.onnx|[arxiv](https://arxiv.org/abs/2006.06873)|
|MixerTTS|mixer128|Text->Mel|2.9M|mixer128.onnx|[arxiv](https://arxiv.org/abs/2110.03584)|
|MixerTTS|mixer80|Text->Mel|1.5M|mixer80.onnx|[arxiv](https://arxiv.org/abs/2110.03584)|
|Vocos|vocos|Vocoder|13.4M|vocos22.onnx|[arxiv](https://arxiv.org/abs/2306.00814)|

## Preview:

<div align="center">
  <img src="https://github.com/user-attachments/assets/fc2484ec-edf7-4637-b01e-cb5563b643e0" width="50%"></img>
</div>


## Getting Started with Flutter

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

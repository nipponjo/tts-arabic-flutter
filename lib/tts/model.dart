import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:onnxruntime/onnxruntime.dart';
import 'package:just_audio/just_audio.dart';

import 'ar_tokenizer.dart';
import 'audio.dart';

List<int> arabToTokenIds(String arabic) {
  return tokenizerPhon(arabic);
}

class TTS {
  final AudioPlayer _audioPlayer = AudioPlayer();
  OrtSession? _ttsSession;
  OrtSession? _vocoderSession;

  final int sampleRate;

  TTS({
    this.sampleRate = 22050,
  });

  void initSessions({
    modelPath = "assets/models/mixer128.onnx",
    vocoderPath = "assets/models/vocos22.onnx",
  }) async {
    // INIT ONNX ENVIRONMENT
    OrtEnv.instance.init();

    // INIT TEXT->MEL MODEL
    final sessionOptions = OrtSessionOptions();
    final rawAssetFile = await rootBundle.load(modelPath);
    final bytes = rawAssetFile.buffer.asUint8List();
    _ttsSession = OrtSession.fromBuffer(bytes, sessionOptions);

    // INIT VOCODER MODEL
    final sessionOptions2 = OrtSessionOptions();
    final rawAssetFile2 = await rootBundle.load(vocoderPath);
    final bytes2 = rawAssetFile2.buffer.asUint8List();
    _vocoderSession = OrtSession.fromBuffer(bytes2, sessionOptions2);

    sessionOptions2.release();
    sessionOptions.release();

    // OrtEnv.instance.availableProviders().forEach((element) {
    //   print('onnx provider=$element');
    // });
  }

  void release() {
    _audioPlayer.stop();
    _audioPlayer.dispose();

    _ttsSession?.release();
    _ttsSession = null;
    _vocoderSession?.release();
    _vocoderSession = null;
    OrtEnv.instance.release();
  }

  Future<List<int>> tts(
    String text, {
    double pace = 1,
    int speaker = 0,
    double pmul = 1,
    double padd = 0,
    double denoise = 0.005,
  }) async {
    // if (ttsSession == null)
    final runOptions = OrtRunOptions();
    runOptions.setRunLogVerbosityLevel(2);

    final stopwatch = Stopwatch();

    // String ara = words[5];
    // print(transliterate(text));

    List<List<int>> tokenIds = [arabToTokenIds(text)];
    final inputOrt = OrtValueTensor.createTensorWithDataList(tokenIds);
    final OrtValueTensor paceOrt =
        OrtValueTensor.createTensorWithDataList(Float32List.fromList([pace]));
    final OrtValueTensor speakerOrt =
        OrtValueTensor.createTensorWithDataList(Int32List.fromList([speaker]));
    final OrtValueTensor pmulOrt =
        OrtValueTensor.createTensorWithDataList(Float32List.fromList([pmul]));
    final OrtValueTensor paddOrt =
        OrtValueTensor.createTensorWithDataList(Float32List.fromList([padd]));

    // print(inputOrt);
    final Map<String, OrtValue> inputs = {
      'token_ids': inputOrt,
      'pace': paceOrt,
      'speaker': speakerOrt,
      'pitch_mul': pmulOrt,
      'pitch_add': paddOrt
    };
    stopwatch.start();
    final List<OrtValue?> melSpecOrt = _ttsSession!.run(runOptions, inputs);
    stopwatch.stop();
    final melTimeMs = stopwatch.elapsedMilliseconds;
    // print("Elapsed ms $melTimeMs");
    stopwatch.reset();
    // print(outputs);

    final OrtValueTensor denoiseOrt = OrtValueTensor.createTensorWithDataList(
        Float32List.fromList([denoise]));
    stopwatch.start();
    final waveOutOrt = _vocoderSession!.run(runOptions, {
      'mel_spec': melSpecOrt[0]!,
      'denoise': denoiseOrt,
    });
    stopwatch.stop();
    final vocoderTimeMs = stopwatch.elapsedMilliseconds;
    // print("Elapsed ms $vocoderTimeMs");
    stopwatch.reset();

    // var outFloats2 = outputs2[0]?.value;
    List<List<double>> waveOut = waveOutOrt[0]?.value as List<List<double>>;

    // print(outFloats2);
    // printShape(waveOut);

    List<int> pcmWave = convertToPCM16(waveOut[0]);

    await _audioPlayer.stop();
    File audioFile = await writeToWavFile(pcmWave, sampleRate, 1);
    _audioPlayer.setFilePath(audioFile.path);
    _audioPlayer.play();

    // release options
    runOptions.release();

    // release inputs
    inputOrt.release();
    paceOrt.release();
    speakerOrt.release();
    pmulOrt.release();
    paddOrt.release();
    denoiseOrt.release();

    // release outputs

    for (OrtValue? element in melSpecOrt) {
      element?.release();
    }
    for (OrtValue? element in waveOutOrt) {
      element?.release();
    }

    return [melTimeMs, vocoderTimeMs];
  }
}

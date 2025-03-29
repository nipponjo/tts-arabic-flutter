// MIT License

// Copyright (c) 2019 Neural Arabic Text Diacritization: Outperforming State of the Art Using FFNN and RNN

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter/services.dart';

import '../model.dart';
import 'symbols.dart';

String removeDiacritics(String data) {
  for (var diacritic in DIACRITICS_LIST) {
    data = data.replaceAll(diacritic, '');
  }
  return data;
}

class Shakkelha extends Vowelizer {
  OrtSession? _modelSession;

  Shakkelha();

  @override
  void initSessions({
    String modelPath = "assets/models/shakkelha.onnx",
  }) async {
    final rawAssetFile = await rootBundle.load(modelPath);

    // INIT ONNX ENVIRONMENT
    OrtEnv.instance.init();

    // INIT TEXT->MEL MODEL
    final sessionOptions = OrtSessionOptions();
    final bytes = rawAssetFile.buffer.asUint8List();

    _modelSession = OrtSession.fromBuffer(bytes, sessionOptions);

    sessionOptions.release();

    // OrtEnv.instance.availableProviders().forEach((element) {
    //   print('onnx provider=$element');
    // });
  }

  @override
  void release() {
    _modelSession?.release();
    _modelSession = null;

    OrtEnv.instance.release();
  }

  List<int> encode(String inputText) {
    List<int> x = [RNN_BIG_CHARACTERS_MAPPING['<SOS>']!];

    for (var char in inputText.split('')) {
      if (DIACRITICS_LIST.contains(char)) {
        continue;
      }
      x.add(RNN_BIG_CHARACTERS_MAPPING[char] ??
          RNN_BIG_CHARACTERS_MAPPING['<UNK>']!);
    }

    x.add(RNN_BIG_CHARACTERS_MAPPING['<EOS>']!);
    return x;
  }

  String decode(List<List<List<double>>> probs, String inputText) {
    List<List<double>> probs_ = probs[0].sublist(1);
    String output = '';

    String cleanText = removeDiacritics(inputText);
    for (int i = 0; i < cleanText.length; i++) {
      String char = cleanText[i];
      output += char;
      if (!ARABIC_LETTERS_LIST.contains(char)) {
        continue;
      }

      int prediction =
          probs_[i].indexOf(probs_[i].reduce((a, b) => a > b ? a : b));
      if (RNN_REV_CLASSES_MAPPING[prediction]?.contains('<') ?? false) {
        continue;
      }

      output += RNN_REV_CLASSES_MAPPING[prediction] ?? '';
    }

    return output;
  }

  @override
  String vowelize(String text) {
    final runOptions = OrtRunOptions();
    final List<List<int>> tokenIds = [encode(text)];
    final inputOrt = OrtValueTensor.createTensorWithDataList(tokenIds);

    // print(inputOrt);
    final Map<String, OrtValue> inputs = {
      'input': inputOrt,
    };

    final List<OrtValue?> probsOrt = _modelSession!.run(runOptions, inputs);

    // var outFloats2 = outputs2[0]?.value;
    final List<List<List<double>>> probsOut =
        probsOrt[0]?.value as List<List<List<double>>>;

    final String outputText = decode(probsOut, text);

    // release options
    runOptions.release();

    // release inputs
    inputOrt.release();

    // release outputs
    for (OrtValue? element in probsOrt) {
      element?.release();
    }

    return outputText;
  }
}

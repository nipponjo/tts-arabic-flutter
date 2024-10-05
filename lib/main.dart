import 'package:flutter/material.dart';

import 'tts/model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arabic TTS Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Arabic TTS Demo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TTS? _ttsModel;
  List<int> _counter = [0, 0];

  final _textController = TextEditingController();

  double _speakerSliderValue = 0;
  double _paceSliderValue = 1;
  double _pitchAddSliderValue = 0;
  double _pitchMulSliderValue = 1;
  double _denoiseSliderValue = 0.005;

  final List<String> textExamples = [
    "اَلسَّلامُ عَلَيكُم يَا صَدِيقِي.",
    "أتَاحَتْ لِلبَائِعِ المُتَجَوِّلِ أنْ يَكُونَ جَاذِباً لِلمُوَاطِنِ الأقَلِّ دَخْلاً",
    "أَحْرَزَتْ مُنْتَخَبَاتُ البَرَازِيلِ وَأَلمَانِيَا وَرُوسِيَا فَوْزاً فِي مُقَابَلَاتِهِم الإِعْدَادِيَّةِ الَّتِي أُقِيمَتْ اِسْتِعْدَاداً لِنِهَائِيَاتِ كَأْسِ العَالَم اَلَّتِي سَتَنْطَلِقُ بَعْدَ أَقَلِّ مِنْ أُسْبُوع",
    "أَخْفَقَ مَجْلِسُ النُّوَّابِ اللُّبْنَانِيُّ فِي اِخْتِيَارِ رَئِيسٍ جَدِيدٍ لِلبِلَادِ خَلَفاً لِلرَّئِيسِ الحَالِيِّ الَّذِي تَنْتَهِي وِلَايَتُهُ فِي الخَامِسِ وَالعِشْرِينْ مِنْ مَايُو أَيَارَ المُقْبِل",
  ];

  int exampleIdx = 0;

  @override
  void initState() {
    super.initState();
    _ttsModel = TTS();
    _ttsModel!.initSessions(
      modelPath: "assets/models/mixer128.onnx",
      vocoderPath: "assets/models/vocos22.onnx",
    );

    _textController.text = textExamples[0];
  }

  void _incrementCounter() async {
    final times = await _ttsModel!.tts(
      _textController.text,
      pace: _paceSliderValue,
      speaker: _speakerSliderValue.round(),
      pmul: _pitchMulSliderValue,
      padd: _pitchAddSliderValue,
      denoise: _denoiseSliderValue,
    );
    setState(() {
      _counter = times;
    });
  }

  void _previousSentence() {
    exampleIdx = (exampleIdx - 1) % textExamples.length;
    _textController.text = textExamples[exampleIdx];
  }

  void _nextSentence() {
    exampleIdx = (exampleIdx + 1) % textExamples.length;
    _textController.text = textExamples[exampleIdx];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: _previousSentence,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        readOnly: false,
                        autocorrect: false,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            prefixIcon: IconButton(
                              onPressed: _textController.clear,
                              icon: const Icon(Icons.clear),
                            )),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: _nextSentence,
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Inference times (Text->Mel, Vocoder) / ms:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              '(${_counter[0]}, ${_counter[1]})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SliderWithLabel(
                label: 'Speaker:',
                value: _speakerSliderValue,
                min: 0,
                max: 3,
                divisions: 3,
                digits: 0,
                onChanged: (d) {
                  setState(() {
                    _speakerSliderValue = d;
                  });
                }),
            SliderWithLabel(
                label: 'Pace:',
                value: _paceSliderValue,
                min: 0.5,
                max: 2,
                divisions: 50,
                onChanged: (d) {
                  setState(() {
                    _paceSliderValue = d;
                  });
                }),
            SliderWithLabel(
                label: 'Pitch add:',
                value: _pitchAddSliderValue,
                min: -2,
                max: 2,
                divisions: 30,
                onChanged: (d) {
                  setState(() {
                    _pitchAddSliderValue = d;
                  });
                }),
            SliderWithLabel(
                label: 'Pitch mul:',
                value: _pitchMulSliderValue,
                min: -2,
                max: 2,
                divisions: 30,
                onChanged: (d) {
                  setState(() {
                    _pitchMulSliderValue = d;
                  });
                }),
            SliderWithLabel(
                label: 'Denoise:',
                value: _denoiseSliderValue,
                min: 0,
                max: 0.03,
                divisions: 50,
                digits: 3,
                onChanged: (d) {
                  setState(() {
                    _denoiseSliderValue = d;
                  });
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.volume_up),
      ),
    );
  }

  @override
  void dispose() {
    _ttsModel?.release();
    super.dispose();
  }
}

class SliderWithLabel extends StatelessWidget {
  final double value;
  final String label;
  final double min;
  final double max;
  final int divisions;
  final int digits;
  final Function(double) onChanged;

  const SliderWithLabel({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 100,
    this.digits = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                label: value.toStringAsFixed(digits),
                onChanged: onChanged,
              ),
            ],
          ),
          Text(value.toStringAsFixed(digits)),
        ],
      ),
    );
  }
}

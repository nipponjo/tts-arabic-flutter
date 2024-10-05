import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

List<int> convertToPCM16(List<double> audioData) {
  return audioData
      .map((sample) => (sample * 32767).toInt().clamp(-32768, 32767))
      .toList(growable: false);
}

Future<File> writeToWavFile(
    List<int> audioData, int sampleRate, int channels) async {
  const int waveHeaderSize = 44;

  final audioBuffer = Int16List.fromList(audioData).buffer;
  final int fileSize = waveHeaderSize + audioBuffer.lengthInBytes;

  final ByteData wavFile = ByteData(fileSize);

  // RIFF header
  wavFile.setUint8(0, 0x52); // R
  wavFile.setUint8(1, 0x49); // I
  wavFile.setUint8(2, 0x46); // F
  wavFile.setUint8(3, 0x46); // F
  wavFile.setUint32(4, fileSize - 8, Endian.little); // File size - 8
  wavFile.setUint8(8, 0x57); // W
  wavFile.setUint8(9, 0x41); // A
  wavFile.setUint8(10, 0x56); // V
  wavFile.setUint8(11, 0x45); // E

  // fmt subchunk
  wavFile.setUint8(12, 0x66); // f
  wavFile.setUint8(13, 0x6d); // m
  wavFile.setUint8(14, 0x74); // t
  wavFile.setUint8(15, 0x20); // (space)
  wavFile.setUint32(16, 16, Endian.little); // Subchunk1 size (16 for PCM)
  wavFile.setUint16(20, 1, Endian.little); // Audio format (1 for PCM)
  wavFile.setUint16(22, channels, Endian.little); // Number of channels
  wavFile.setUint32(24, sampleRate, Endian.little); // Sample rate
  wavFile.setUint32(28, sampleRate * channels * 2, Endian.little); // Byte rate
  wavFile.setUint16(32, channels * 2, Endian.little); // Block align
  wavFile.setUint16(34, 16, Endian.little); // Bits per sample

  // data subchunk
  wavFile.setUint8(36, 0x64); // d
  wavFile.setUint8(37, 0x61); // a
  wavFile.setUint8(38, 0x74); // t
  wavFile.setUint8(39, 0x61); // a
  wavFile.setUint32(
      40, audioBuffer.lengthInBytes, Endian.little); // Subchunk2 size

  final audioBytes = Uint8List.view(audioBuffer);
  for (int i = 0; i < audioBytes.length; i++) {
    wavFile.setUint8(44 + i, audioBytes[i]);
  }

  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/temp_audio_arabic_tts_demo.wav');
  await file.writeAsBytes(wavFile.buffer.asUint8List());
  // print('WAV file written: ${file.path}');
  return file;
}

void printShape(dynamic array) {
  List<int> shape = [];
  dynamic currentLevel = array;

  while (currentLevel is List) {
    shape.add(currentLevel.length);
    if (currentLevel.isNotEmpty) {
      currentLevel = currentLevel[0];
    } else {
      break;
    }
  }
}

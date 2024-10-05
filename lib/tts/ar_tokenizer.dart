import 'ar_phonemizer.dart';

const Map<String, int> tokenToId = {
  '_pad_': 0,
  '_eos_': 1,
  '_sil_': 2,
  // '_dbl_': 3,
  '#': 3,
  ' ': 4,
  '.': 5,
  ',': 6,
  '?': 7,
  '!': 8,
  '<': 9,
  'b': 10,
  't': 11,
  '^': 12,
  'j': 13,
  'H': 14,
  'x': 15,
  'd': 16,
  '*': 17,
  'r': 18,
  'z': 19,
  's': 20,
  '\$': 21,
  'S': 22,
  'D': 23,
  'T': 24,
  'Z': 25,
  'E': 26,
  'g': 27,
  'f': 28,
  'q': 29,
  'k': 30,
  'l': 31,
  'm': 32,
  'n': 33,
  'h': 34,
  'w': 35,
  'y': 36,
  'v': 37,
  'a': 38,
  'u': 39,
  'i': 40,
  'A': 41,
  'U': 42,
  'I': 43
};

List<int> tokenizerPhon(String arabic) {
  final String phonemes =
      phonemize(arabic).replaceAllMapped(RegExp('(.)\\1'), (m) => "${m[1]}#");
  // print(phonemes);

  List<String> tokens = phonemes.split('');
  if (tokens.last != '.') {
    tokens.add(' ');
    tokens.add('.');
  }
  tokens.add('_eos_');

  return tokens.map((token) => tokenToId[token] ?? 0).toList(growable: false);
}

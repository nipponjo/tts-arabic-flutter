// simplified and ported to Dart
// from: https://github.com/nawarhalabi/Arabic-Phonetiser/blob/master/phonetise-Buckwalter.py
// license: Creative Commons Attribution-NonCommercial 4.0 International License.
// https://creativecommons.org/licenses/by-nc/4.0/

const Map<String, String> _buckwToArabicMap = {
  'b': '\u0628',
  '*': '\u0630',
  'T': '\u0637',
  'm': '\u0645',
  't': '\u062a',
  'r': '\u0631',
  'Z': '\u0638',
  'n': '\u0646',
  '^': '\u062b',
  'z': '\u0632',
  'E': '\u0639',
  'h': '\u0647',
  'j': '\u062c',
  's': '\u0633',
  'g': '\u063a',
  'H': '\u062d',
  'q': '\u0642',
  'f': '\u0641',
  'x': '\u062e',
  'S': '\u0635',
  '\$': '\u0634',
  'd': '\u062f',
  'D': '\u0636',
  'k': '\u0643',
  '>': '\u0623',
  '\'': '\u0621',
  '}': '\u0626',
  '&': '\u0624',
  '<': '\u0625',
  '|': '\u0622',
  'A': '\u0627',
  'Y': '\u0649',
  'p': '\u0629',
  'y': '\u064a',
  'l': '\u0644',
  'w': '\u0648',
  'F': '\u064b',
  'N': '\u064c',
  'K': '\u064d',
  'a': '\u064e',
  'u': '\u064f',
  'i': '\u0650',
  '~': '\u0651',
  'o': '\u0652',
  '{': '\u0671'
};

const Map<String, String> _arabicToBuckwMap = {
  '\u0628': 'b',
  '\u0630': '*',
  '\u0637': 'T',
  '\u0645': 'm',
  '\u062a': 't',
  '\u0631': 'r',
  '\u0638': 'Z',
  '\u0646': 'n',
  '\u062b': '^',
  '\u0632': 'z',
  '\u0639': 'E',
  '\u0647': 'h',
  '\u062c': 'j',
  '\u0633': 's',
  '\u063a': 'g',
  '\u062d': 'H',
  '\u0642': 'q',
  '\u0641': 'f',
  '\u062e': 'x',
  '\u0635': 'S',
  '\u0634': '\$',
  '\u062f': 'd',
  '\u0636': 'D',
  '\u0643': 'k',
  '\u0623': '>',
  '\u0621': '\'',
  '\u0626': '}',
  '\u0624': '&',
  '\u0625': '<',
  '\u0622': '|',
  '\u0627': 'A',
  '\u0649': 'Y',
  '\u0629': 'p',
  '\u064a': 'y',
  '\u0644': 'l',
  '\u0648': 'w',
  '\u064b': 'F',
  '\u064c': 'N',
  '\u064d': 'K',
  '\u064e': 'a',
  '\u064f': 'u',
  '\u0650': 'i',
  '\u0651': '~',
  '\u0652': 'o',
  '\u0671': '{'
};

String _mapBuckwToArabic(Match m) {
  return _buckwToArabicMap[m[0]] ?? m[0] ?? "";
}

String _mapArabicToBuckw(Match m) {
  return _arabicToBuckwMap[m[0]] ?? m[0] ?? "";
}

String arabToBuckw(String arab) {
  return arab.replaceAllMapped(RegExp(r'.'), _mapArabicToBuckw);
}

String buckwToArab(String buckw) {
  return buckw.replaceAllMapped(RegExp(r'.'), _mapBuckwToArabic);
}

const Map<String, String> unambiguousConsonantMap = {
  'b': 'b', '*': '*', 'T': 'T', 'm': 'm',
  't': 't', 'r': 'r', 'Z': 'Z', 'n': 'n',
  '^': '^', 'z': 'z', 'E': 'E', 'h': 'h',
  'j': 'j', 's': 's', 'g': 'g', 'H': 'H',
  'q': 'q', 'f': 'f', 'x': 'x', 'S': 'S',
  '\$': '\$', 'd': 'd', 'D': 'D', 'k': 'k',
  // Hamza
  '>': '<', '\'': '<', '}': '<', '&': '<',
  '<': '<'
};

const String diacritics = "oauiFNK~";
const String diacriticsWithoutShadda = "oauiFNK";
const String emphatics = "DSTZgxq";
const String forwardEmphatics = "gx";
const String consonants = "><}&'bt^jHxd*rzs\$SDTZEgfqklmnh|";
const String punctuation = ".:,!?";

const Map<String, String> preprocessingReplacements = {
  'AF': 'F',
  '\u0640': '',
  'o': '',
  'aA': 'A',
  'aY': 'Y',
  ' A': ' ',
  'F': 'an',
  'N': 'un',
  'K': 'in',
  '|': '>A',
  'i~': '~i',
  'a~': '~a',
  'u~': '~u',
  'Ai': '<i',
  'Aa': '>a',
  'Au': '>u',
};

List<String> preprocessUtterance(String utterance) {
  // Replace using the translation map
  preprocessingReplacements.forEach((key, value) {
    utterance = utterance.replaceAll(key, value);
  });

  // Handle Hamza types and vowel modifications
  utterance = utterance
      .replaceAllMapped(RegExp(r'^>([^auAw])'), (match) => '>a${match[1]}')
      .replaceAllMapped(RegExp(r' >([^auAw ])'), (match) => ' >a${match[1]}')
      .replaceAllMapped(RegExp(r'<([^i])'), (match) => '<i${match[1]}');

  // Add space between punctuation and preceding non-whitespace character
  utterance = utterance.replaceAllMapped(
      RegExp(r'(\S)([.?,!])'), (match) => '${match[1]} ${match[2]}');

  // Split the utterance into words and return
  return utterance.split(' ');
}

const Map<String, List<String>> fixedWords = {
  'h*A': ['hA*A', 'hA*a'],
  'h*h': ['hA*ihi', 'hA*ih'],
  'h*An': ['hA*Ani', 'hA*An'],
  "h&lA'": ['hA<ulA<i', 'hA<ulA<'],
  '*lk': ['*Alika', '*Alik'],
  'k*lk': ['ka*Alika', 'ka*Alik'],
  '*lkm': ['*Alikum'],
  '>wl}k': ['<ulA<ika', '<ulA<ik'],
  'Th': ['TAha'],
  'lkn': ['lAkinna', 'lAkin'],
  'lknh': ['lAkinnahu'],
  'lknhm': ['lAkinnahum'],
  'lknk': ['lAkinnaka', 'lAkinnaki'],
  'lknkm': ['lAkinnakum'],
  'lknkmA': ['lAkinnakumA'],
  'lknnA': ['lAkinnanA'],
  'AlrHmn': ['rraHmAni', 'rraHmAn'],
  'Allh': ['llAhi', 'llAh', 'llAhu', 'llAha', 'llAh', 'llA'],
  'h*yn': ['hA*ayni', 'hA*ayn'],
  'nt': ['nit'],
  'fydyw': ['vidyU'],
  'lndn': ['landun']
};

String? isFixedWord(String word) {
  final String lastLetter = word[word.length - 1];

  // Remove all non-consonant characters from the word
  final String wordConsonants =
      word.replaceAll(RegExp(r"[^h*Ahn\'>wl}kmyTtfd]"), '');

  if (fixedWords.containsKey(wordConsonants)) {
    // Check if there is more than one pronunciation option
    if (fixedWords[wordConsonants]!.length > 1) {
      for (String pronunciation in fixedWords[wordConsonants]!) {
        if (pronunciation.endsWith(lastLetter)) {
          // Return the matching pronunciation
          return pronunciation;
        }
      }
    } else {
      // Return the first pronunciation if only one exists
      return fixedWords[wordConsonants]![0];
    }
  }

  return null;
}

String processWord(String word) {
  if (punctuation.contains(word)) {
    return word;
  }

  final String? fixedRes = isFixedWord(word);
  if (fixedRes != null) {
    return fixedRes;
  }

  // List<String> pronunciations = [];  // Start with an empty list of possible pronunciations
  // isFixedWord(word, '', word, pronunciations);

  bool emphaticContext =
      false; // Indicates whether current character is in an emphatic context
  word = 'bb${word}ee'; // Add start/end markers to the word

  String phones = ''; // Empty string to hold word pronunciation

  // MAIN LOOP: Iterate over the word characters
  for (int index = 2; index < word.length - 2; index++) {
    String letter_2 = word[index - 2];
    String letter_1 = word[index - 1];
    String letter = word[index];
    String letter1 = word[index + 1];
    String letter2 = word[index + 2];

    // Update emphatic context based on current and following letters
    if (consonants.contains(letter) && !emphatics.contains(letter)) {
      emphaticContext = false;
    }
    if (emphatics.contains(letter)) {
      emphaticContext = true;
    }
    if (emphatics.contains(letter1) && !forwardEmphatics.contains(letter1)) {
      emphaticContext = true;
    }

    // Handle unambiguous consonant phones
    if (unambiguousConsonantMap.containsKey(letter)) {
      phones += unambiguousConsonantMap[letter] ?? '';
    }
    // Special handling for 'l' (Lam)
    else if (letter == 'l') {
      if (!diacritics.contains(letter1) &&
          !'AYwyaui'.contains(letter1) &&
          letter2 == '~') {
        phones += ''; // omit
      } else {
        phones += 'l';
      }
    }
    // Shadda doubles the previous letter
    else if (letter == '~' && !'wy'.contains(letter_1) && phones.isNotEmpty) {
      phones += phones[phones.length - 1];
    }
    // Madda (|)
    else if (letter == '|') {
      phones += emphaticContext ? 'A' : '<';
    }
    // Ta' marboota (p)
    else if (letter == 'p') {
      phones += diacritics.contains(letter1) ? 't' : '';
    }
    // Handle vowels and complex cases for Waw and Ya'
    else if ('AYwyaui'.contains(letter)) {
      if ('wy'.contains(letter)) {
        if ("${diacriticsWithoutShadda}AY".contains(letter1) ||
            ('wy'.contains(letter1) && !"${diacritics}Awy".contains(letter2)) ||
            (diacriticsWithoutShadda.contains(letter_1) &&
                "${consonants}e".contains(letter1))) {
          if (letter == 'w' && letter_1 == 'u' && !'aiAY'.contains(letter1)) {
            phones += 'U';
          } else if (letter == 'y' &&
              letter_1 == 'i' &&
              !'auAY'.contains(letter1)) {
            phones += 'I';
          } else if (letter == 'w' && letter1 == 'A' && letter2 == 'e') {
            phones += 'w';
          } else {
            phones += letter;
          }
        } else if (letter1 == '~') {
          if (letter_1 == 'a' ||
              (letter == 'w' && 'iy'.contains(letter_1)) ||
              (letter == 'y' && 'wu'.contains(letter_1))) {
            phones += '$letter$letter';
          } else {
            phones += '${letter == 'w' ? 'U' : 'I'}$letter';
          }
        } else if ("${consonants}ui".contains(letter_1) && letter1 == 'e') {
          phones += letter == 'w' ? 'U' : 'I';
        } else {
          phones += letter == 'w' ? 'U' : 'I';
        }
      } else if ('ui'.contains(letter)) {
        phones += letter;
      } else {
        if (letter == 'A' && 'wk'.contains(letter_1) && letter_2 == 'b') {
          // phones += [['a', 'a:']] // multi
          phones += 'a'; // multi
        } else if (letter == 'A' && 'ui'.contains(letter_1)) {
          continue;
        }
        // Waw al jama3a: The Alif after is optional
        else if (letter == 'A' && letter_1 == 'w' && letter1 == 'e') {
          // phones += [['a:', '']] // multi
          phones += 'A'; // multi
        } else if ('AY'.contains(letter) && letter1 == 'e') {
          // phones += [['a:', 'a']] // multi
          phones += 'A'; // multi
        } else {
          if (letter == 'a') {
            phones += 'a';
          } else {
            phones += 'A';
          }
        }
      }
    }
  }

  return phones;
}

String postprocessUtterance(String phonemes) {
  phonemes = phonemes
      .replaceAll('aA', 'A')
      .replaceAll('iI', 'I')
      .replaceAll('uU', 'U')
      .replaceAll('aa', 'A');
  return phonemes;
}

String phonemize(String text) {
  final String buckw = arabToBuckw(text);
  final List<String> words = preprocessUtterance(buckw);
  final List<String> phonemes =
      words.map((word) => processWord(word)).toList(growable: false);
  final String phonemesStr = postprocessUtterance(phonemes.join(' '));
  return phonemesStr;
}

const Map<String, String> nawarToIPA = {
  "<": "ʔ",
  "^": "θ",
  "j": "d͡ʒ",
  "H": "ħ",
  "*": "ð",
  "\$": "ʃ",
  "S": "sˤ",
  "D": "dˤ",
  "T": "tˤ",
  "Z": "ðˤ",
  "ž": "ʒ",
  "E": "ʕ",
  "g": "ɣ",
  "ḷ": "ɫ",
  "U": "uː",
  "I": "iː",
  "A": "aː",
  "y": "j",
  "O": "oː",
};

// const List<String> textExamples = [
//   "اَلسَّلامُ عَلَيكُم يَا صَدِيقِي.",
//   "أتَاحَتْ لِلبَائِعِ المُتَجَوِّلِ أنْ يَكُونَ جَاذِباً لِلمُوَاطِنِ الأقَلِّ دَخْلاً",
//   "أَحْرَزَتْ مُنْتَخَبَاتُ البَرَازِيلِ وَأَلمَانِيَا وَرُوسِيَا فَوْزاً فِي مُقَابَلَاتِهِم الإِعْدَادِيَّةِ الَّتِي أُقِيمَتْ اِسْتِعْدَاداً لِنِهَائِيَاتِ كَأْسِ العَالَم اَلَّتِي سَتَنْطَلِقُ بَعْدَ أَقَلِّ مِنْ أُسْبُوع",
//   "أَخْفَقَ مَجْلِسُ النُّوَّابِ اللُّبْنَانِيُّ فِي اِخْتِيَارِ رَئِيسٍ جَدِيدٍ لِلبِلَادِ خَلَفاً لِلرَّئِيسِ الحَالِيِّ الَّذِي تَنْتَهِي وِلَايَتُهُ فِي الخَامِسِ وَالعِشْرِينْ مِنْ مَايُو أَيَارَ المُقْبِل",
// ];

// void main() async {
//   Stopwatch timer = Stopwatch();

//   var textExample = textExamples[1];

//   String phonemesStr = phonemize(textExample);
//   timer.start();
//   for (int i = 0; i < 1000; i++) {
//     phonemesStr = phonemize(textExample);
//   }
//   timer.stop();
//   String phonemesIPA = phonemesStr.replaceAllMapped(
//       RegExp(r'.'), (m) => nawarToIPA[m[0]] ?? m[0] ?? "");
//   // print(buckw.substring(3, 8));
//   // print(buckw);
//   // print(words);
//   // print(phonemes);
//   print(phonemesStr);
//   print(phonemesIPA);
//   print(timer.elapsedMilliseconds);
// }

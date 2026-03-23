/// English to Hangul conversion module.
///
/// Converts English words to Korean pronunciation using CMU pronunciation dictionary.

import 'dart:convert';
import 'dart:io';

import 'jamo.dart';

/// ARPAbet to choseong (initial consonant) mapping
const Map<String, String> _toChoseong = {
  'B': 'ᄇ',
  'CH': 'ᄎ',
  'D': 'ᄃ',
  'DH': 'ᄃ',
  'DZ': 'ᄌ',
  'F': 'ᄑ',
  'G': 'ᄀ',
  'HH': 'ᄒ',
  'JH': 'ᄌ',
  'K': 'ᄏ',
  'L': 'ᄅ',
  'M': 'ᄆ',
  'N': 'ᄂ',
  'NG': 'ᄋ',
  'P': 'ᄑ',
  'R': 'ᄅ',
  'S': 'ᄉ',
  'SH': 'ᄉ',
  'T': 'ᄐ',
  'TH': 'ᄉ',
  'TS': 'ᄎ',
  'V': 'ᄇ',
  'W': 'W',
  'Y': 'Y',
  'Z': 'ᄌ',
  'ZH': 'ᄌ',
};

/// ARPAbet to jungseong (vowel) mapping
const Map<String, String> _toJungseong = {
  'AA': 'ᅡ',
  'AE': 'ᅢ',
  'AH': 'ᅥ',
  'AO': 'ᅩ',
  'AW': 'ᅡ우',
  'AWER': 'ᅡ워',
  'AY': 'ᅡ이',
  'EH': 'ᅦ',
  'ER': 'ᅥ',
  'EY': 'ᅦ이',
  'IH': 'ᅵ',
  'IY': 'ᅵ',
  'OW': 'ᅩ',
  'OY': 'ᅩ이',
  'UH': 'ᅮ',
  'UW': 'ᅮ',
};

/// ARPAbet to jongseong (final consonant) mapping
const Map<String, String> _toJongseong = {
  'B': 'ᆸ',
  'CH': 'ᆾ',
  'D': 'ᆮ',
  'DH': 'ᆮ',
  'F': 'ᇁ',
  'G': 'ᆨ',
  'HH': 'ᇂ',
  'JH': 'ᆽ',
  'K': 'ᆨ',
  'L': 'ᆯ',
  'M': 'ᆷ',
  'N': 'ᆫ',
  'NG': 'ᆼ',
  'P': 'ᆸ',
  'R': 'ᆯ',
  'S': 'ᆺ',
  'SH': 'ᆺ',
  'T': 'ᆺ',
  'TH': 'ᆺ',
  'V': 'ᆸ',
  'W': 'ᆼ',
  'Y': 'ᆼ',
  'Z': 'ᆽ',
  'ZH': 'ᆽ',
};

/// Modify arpabets to fit Korean pronunciation rules
List<String> _adjust(List<String> arpabets) {
  var string = ' ${arpabets.join(' ')} \$';
  string = string.replaceAll(RegExp(r'\d'), ''); // Remove stress marks
  string = string.replaceAll(' T S ', ' TS ');
  string = string.replaceAll(' D Z ', ' DZ ');
  string = string.replaceAll(' AW ER ', ' AWER ');
  string = string.replaceAll(' IH R \$', ' IH ER ');
  string = string.replaceAll(' EH R \$', ' EH ER ');
  string = string.replaceAll(' \$', '');

  return string.trim().split(' ').where((s) => s.isNotEmpty).toList();
}

/// Reconstruct jamo string with postprocessing
String _reconstruct(String string) {
  const pairs = [
    ('그W', 'ᄀW'),
    ('흐W', 'ᄒW'),
    ('크W', 'ᄏW'),
    ('ᄂYᅥ', '니어'),
    ('ᄃYᅥ', '디어'),
    ('ᄅYᅥ', '리어'),
    ('Yᅵ', 'ᅵ'),
    ('Yᅡ', 'ᅣ'),
    ('Yᅢ', 'ᅤ'),
    ('Yᅥ', 'ᅧ'),
    ('Yᅦ', 'ᅨ'),
    ('Yᅩ', 'ᅭ'),
    ('Yᅮ', 'ᅲ'),
    ('Wᅡ', 'ᅪ'),
    ('Wᅢ', 'ᅫ'),
    ('Wᅥ', 'ᅯ'),
    ('Wᅩ', 'ᅯ'),
    ('Wᅮ', 'ᅮ'),
    ('Wᅦ', 'ᅰ'),
    ('Wᅵ', 'ᅱ'),
    ('ᅳᅵ', 'ᅴ'),
    ('Y', 'ᅵ'),
    ('W', 'ᅮ'),
  ];

  for (final (pattern, replacement) in pairs) {
    string = string.replaceAll(pattern, replacement);
  }
  return string;
}

/// Convert ARPAbet phonemes to Hangul jamo
String _phonemesToHangul(List<String> phonemes) {
  const shortVowels = ['AE', 'AH', 'AX', 'EH', 'IH', 'IX', 'UH'];
  const vowels = 'AEIOUY';
  const consonants = 'BCDFGHJKLMNPQRSTVWXZ';
  const syllableFinalOrConsonants = r'$BCDFGHJKLMNPQRSTVWXZ';

  var ret = '';

  for (var i = 0; i < phonemes.length; i++) {
    final p = phonemes[i];
    final pPrev = i > 0 ? phonemes[i - 1] : '^';
    final pNext = i < phonemes.length - 1 ? phonemes[i + 1] : r'$';
    final pNext2 = i < phonemes.length - 2 ? phonemes[i + 2] : r'$';

    // Rule 1: Voiceless plosives (P, T, K)
    if (['P', 'T', 'K'].contains(p)) {
      if (shortVowels.contains(pPrev.substring(0, pPrev.length.clamp(0, 2))) &&
          pNext == r'$') {
        ret += _toJongseong[p] ?? '';
      } else if (shortVowels.contains(pPrev.substring(0, pPrev.length.clamp(0, 2))) &&
          !'AEIOULRMN'.contains(pNext[0])) {
        ret += _toJongseong[p] ?? '';
      } else if (syllableFinalOrConsonants.contains(pNext[0])) {
        ret += _toChoseong[p] ?? '';
        ret += 'ᅳ';
      } else {
        ret += _toChoseong[p] ?? '';
      }
    }
    // Rule 2: Voiced plosives (B, D, G)
    else if (['B', 'D', 'G'].contains(p)) {
      ret += _toChoseong[p] ?? '';
      if (syllableFinalOrConsonants.contains(pNext[0])) {
        ret += 'ᅳ';
      }
    }
    // Rule 3: Fricatives (S, Z, F, V, TH, DH, SH, ZH)
    else if (['S', 'Z', 'F', 'V', 'TH', 'DH', 'SH', 'ZH'].contains(p)) {
      ret += _toChoseong[p] ?? '';

      if (['S', 'Z', 'F', 'V', 'TH', 'DH'].contains(p)) {
        if (syllableFinalOrConsonants.contains(pNext[0])) {
          ret += 'ᅳ';
        }
      } else if (p == 'SH') {
        if (pNext == r'$') {
          ret += 'ᅵ';
        } else if (consonants.contains(pNext[0])) {
          ret += 'ᅲ';
        } else {
          ret += 'Y';
        }
      } else if (p == 'ZH') {
        if (syllableFinalOrConsonants.contains(pNext[0])) {
          ret += 'ᅵ';
        }
      }
    }
    // Rule 4: Affricates (TS, DZ, CH, JH)
    else if (['TS', 'DZ', 'CH', 'JH'].contains(p)) {
      ret += _toChoseong[p] ?? '';

      if (syllableFinalOrConsonants.contains(pNext[0])) {
        if (['TS', 'DZ'].contains(p)) {
          ret += 'ᅳ';
        } else {
          ret += 'ᅵ';
        }
      }
    }
    // Rule 5: Nasals (M, N, NG)
    else if (['M', 'N', 'NG'].contains(p)) {
      if (['M', 'N'].contains(p) && vowels.contains(pNext[0])) {
        ret += _toChoseong[p] ?? '';
      } else {
        ret += _toJongseong[p] ?? '';
      }
    }
    // Rule 6: Liquid (L)
    else if (p == 'L') {
      if (pPrev == '^') {
        ret += _toChoseong[p] ?? '';
      } else if (syllableFinalOrConsonants.contains(pNext[0])) {
        ret += _toJongseong[p] ?? '';
      } else if (['M', 'N'].contains(pPrev)) {
        ret += _toChoseong[p] ?? '';
      } else if (vowels.contains(pNext[0])) {
        ret += 'ᆯᄅ';
      } else if (['M', 'N'].contains(pNext) && !vowels.contains(pNext2[0])) {
        ret += 'ᆯ르';
      }
    }
    // ER
    else if (p == 'ER') {
      if (vowels.contains(pPrev[0])) {
        ret += 'ᄋ';
      }
      ret += _toJungseong[p] ?? '';
      if (vowels.contains(pNext[0])) {
        ret += 'ᄅ';
      }
    }
    // R
    else if (p == 'R') {
      if (vowels.contains(pNext[0])) {
        ret += _toChoseong[p] ?? '';
      }
    }
    // Vowels
    else if ('AEIOU'.contains(p[0])) {
      ret += _toJungseong[p] ?? p;
    }
    // Default: consonant
    else {
      ret += _toChoseong[p] ?? p;
    }
  }

  ret = _reconstruct(ret);
  ret = compose(ret);
  // Remove remaining jamo
  ret = ret.replaceAll(RegExp(r'[\u1100-\u11FF]'), '');

  return ret;
}

/// CMU Dictionary holder
class CmuDict {
  final Map<String, List<String>> _dict;

  CmuDict._(this._dict);

  /// Load CMU dictionary from JSON file
  static Future<CmuDict> load(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    final dict = <String, List<String>>{};
    json.forEach((key, value) {
      dict[key.toLowerCase()] = (value as List).cast<String>();
    });

    return CmuDict._(dict);
  }

  /// Load from JSON string
  static CmuDict fromJson(String jsonContent) {
    final json = jsonDecode(jsonContent) as Map<String, dynamic>;

    final dict = <String, List<String>>{};
    json.forEach((key, value) {
      dict[key.toLowerCase()] = (value as List).cast<String>();
    });

    return CmuDict._(dict);
  }

  /// Create empty dictionary
  static CmuDict empty() => CmuDict._({});

  /// Get pronunciation for a word
  List<String>? getPronunciation(String word) {
    return _dict[word.toLowerCase()];
  }

  /// Check if word exists in dictionary
  bool contains(String word) {
    return _dict.containsKey(word.toLowerCase());
  }

  /// Get dictionary size
  int get length => _dict.length;
}

/// Convert English words in a string to Hangul
///
/// [string]: Input string containing Korean and English
/// [cmu]: CMU pronunciation dictionary
///
/// Returns string with English words converted to Hangul
String convertEng(String string, CmuDict cmu) {
  final engWords = RegExp(r"[A-Za-z']+").allMatches(string);

  for (final match in engWords) {
    final engWord = match.group(0)!;
    final word = engWord.toLowerCase();

    if (!cmu.contains(word)) continue;

    final arpabets = cmu.getPronunciation(word)!;
    final phonemes = _adjust(arpabets);
    final hangul = _phonemesToHangul(phonemes);

    string = string.replaceRange(match.start, match.end, hangul);
  }

  return string;
}

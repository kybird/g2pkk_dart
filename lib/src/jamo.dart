/// Hangul Jamo utilities for decomposition and composition.
///
/// This module provides functions to decompose Korean syllables into
/// their constituent jamo (consonant/vowel) components and compose
/// jamo back into syllables.

/// Hangul syllable ranges
const int _hangulBase = 0xAC00;
const int _hangulEnd = 0xD7A3;

/// Choseong (initial consonant) constants
const List<String> choseongList = [
  'ᄀ', 'ᄁ', 'ᄂ', 'ᄃ', 'ᄄ', 'ᄅ', 'ᄆ', 'ᄇ', 'ᄈ', 'ᄉ',
  'ᄊ', 'ᄋ', 'ᄌ', 'ᄍ', 'ᄎ', 'ᄏ', 'ᄐ', 'ᄑ', 'ᄒ'
];

/// Jungseong (vowel) constants
const List<String> jungseongList = [
  'ᅡ', 'ᅢ', 'ᅣ', 'ᅤ', 'ᅥ', 'ᅦ', 'ᅧ', 'ᅨ', 'ᅩ', 'ᅪ',
  'ᅫ', 'ᅬ', 'ᅭ', 'ᅮ', 'ᅯ', 'ᅰ', 'ᅱ', 'ᅲ', 'ᅳ', 'ᅴ',
  'ᅵ'
];

/// Jongseong (final consonant) constants
const List<String> jongseongList = [
  '', 'ᆨ', 'ᆩ', 'ᆪ', 'ᆫ', 'ᆬ', 'ᆭ', 'ᆮ', 'ᆯ', 'ᆰ',
  'ᆱ', 'ᆲ', 'ᆳ', 'ᆴ', 'ᆵ', 'ᆶ', 'ᆷ', 'ᆸ', 'ᆹ', 'ᆺ',
  'ᆻ', 'ᆼ', 'ᆽ', 'ᆾ', 'ᆿ', 'ᇀ', 'ᇁ', 'ᇂ'
];

/// Decompose a Hangul syllable into its jamo components.
///
/// Returns a string of jamo characters (choseong + jungseong + jongseong).
/// If the character is not a Hangul syllable, returns it unchanged.
String h2j(String char) {
  if (char.length != 1) {
    // Process each character
    return char.split('').map(h2j).join();
  }

  final codeUnit = char.codeUnitAt(0);

  // Check if it's a Hangul syllable
  if (codeUnit < _hangulBase || codeUnit > _hangulEnd) {
    return char;
  }

  final syllableIndex = codeUnit - _hangulBase;
  final choseongIndex = syllableIndex ~/ (21 * 28);
  final jungseongIndex = (syllableIndex % (21 * 28)) ~/ 28;
  final jongseongIndex = syllableIndex % 28;

  final result = StringBuffer();
  result.write(choseongList[choseongIndex]);
  result.write(jungseongList[jungseongIndex]);
  if (jongseongIndex > 0) {
    result.write(jongseongList[jongseongIndex]);
  }

  return result.toString();
}

/// Decompose a string of Hangul syllables into jamo.
String h2jString(String text) {
  return text.split('').map(h2j).join();
}

/// Compose jamo into a Hangul syllable.
///
/// Takes 2 or 3 jamo characters (choseong + jungseong [+ jongseong])
/// and returns the composed syllable.
String j2h(String jamo) {
  if (jamo.length < 2 || jamo.length > 3) {
    return jamo;
  }

  final choseong = jamo[0];
  final jungseong = jamo[1];
  final jongseong = jamo.length == 3 ? jamo[2] : '';

  final choseongIndex = choseongList.indexOf(choseong);
  final jungseongIndex = jungseongList.indexOf(jungseong);
  final jongseongIndex = jongseongList.indexOf(jongseong);

  if (choseongIndex == -1 || jungseongIndex == -1) {
    return jamo;
  }

  if (jongseong.isNotEmpty && jongseongIndex == -1) {
    return jamo;
  }

  final syllableIndex =
      (choseongIndex * 21 + jungseongIndex) * 28 + jongseongIndex;
  return String.fromCharCode(_hangulBase + syllableIndex);
}

/// Compose a string of jamo into Hangul syllables.
///
/// This function takes a string containing jamo characters and
/// composes them into syllables where possible.
String compose(String letters) {
  // Insert placeholder ᄋ before vowels at the start or after non-choseong
  final buffer = StringBuffer();
  final runes = letters.runes.toList();

  for (int i = 0; i < runes.length; i++) {
    final char = String.fromCharCode(runes[i]);

    // Check if this is a jungseong (vowel)
    if (jungseongList.contains(char)) {
      // Check if we need to insert placeholder
      bool needsPlaceholder = true;
      if (i > 0) {
        final prevChar = String.fromCharCode(runes[i - 1]);
        if (choseongList.contains(prevChar)) {
          needsPlaceholder = false;
        }
      }

      if (needsPlaceholder) {
        buffer.write('ᄋ');
      }
    }
    buffer.write(char);
  }

  letters = buffer.toString();

  // Compose C+V+C patterns
  final cvcPattern = RegExp(
      r'[\u1100-\u1112][\u1161-\u1175][\u11A8-\u11C2]');
  letters = _composePattern(letters, cvcPattern);

  // Compose C+V patterns
  final cvPattern = RegExp(r'[\u1100-\u1112][\u1161-\u1175]');
  letters = _composePattern(letters, cvPattern);

  return letters;
}

String _composePattern(String text, RegExp pattern) {
  final matches = pattern.allMatches(text);
  for (final match in matches.toList().reversed) {
    final matched = match.group(0)!;
    final composed = j2h(matched);
    text = text.replaceRange(match.start, match.end, composed);
  }
  return text;
}

/// Check if a character is a choseong (initial consonant).
bool isChoseong(String char) {
  return choseongList.contains(char);
}

/// Check if a character is a jungseong (vowel).
bool isJungseong(String char) {
  return jungseongList.contains(char);
}

/// Check if a character is a jongseong (final consonant).
bool isJongseong(String char) {
  return jongseongList.contains(char) && char.isNotEmpty;
}

/// Get the last character of a decomposed string.
String? getLastJamo(String decomposed) {
  if (decomposed.isEmpty) return null;
  return decomposed[decomposed.length - 1];
}

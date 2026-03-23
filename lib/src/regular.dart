/// Regular link rules for Korean pronunciation.
///
/// These rules handle the linking of consonants across syllable boundaries.

import 'utils.dart';

/// Rule 13: Link rule 1 - Basic onset linking
/// Handles pronunciation when jongseong meets onset ㅇ
String link1(String inp, bool descriptive, bool verbose) {
  const rule = '제13항 연음 규칙';
  String out = inp;

  final pairs = [
    ('ᆨᄋ', 'ᄀ'),
    ('ᆩᄋ', 'ᄁ'),
    ('ᆫᄋ', 'ᄂ'),
    ('ᆮᄋ', 'ᄃ'),
    ('ᆯᄋ', 'ᄅ'),
    ('ᆷᄋ', 'ᄆ'),
    ('ᆸᄋ', 'ᄇ'),
    ('ᆺᄋ', 'ᄉ'),
    ('ᆻᄋ', 'ᄊ'),
    ('ᆽᄋ', 'ᄌ'),
    ('ᆾᄋ', 'ᄎ'),
    ('ᆿᄋ', 'ᄏ'),
    ('ᇀᄋ', 'ᄐ'),
    ('ᇁᄋ', 'ᄑ'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAll(pattern, replacement);
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 14: Link rule 2 - Complex coda linking
/// Handles pronunciation of complex codas when meeting onset ㅇ
String link2(String inp, bool descriptive, bool verbose) {
  const rule = '제14항 겹받침 연음';
  String out = inp;

  final pairs = [
    ('ᆪᄋ', 'ᆨᄊ'),
    ('ᆬᄋ', 'ᆫᄌ'),
    ('ᆰᄋ', 'ᆯᄀ'),
    ('ᆱᄋ', 'ᆯᄆ'),
    ('ᆲᄋ', 'ᆯᄇ'),
    ('ᆳᄋ', 'ᆯᄊ'),
    ('ᆴᄋ', 'ᆯᄐ'),
    ('ᆵᄋ', 'ᆯᄑ'),
    ('ᆹᄋ', 'ᆸᄊ'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAll(pattern, replacement);
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 15: Link rule 3 - Space-separated linking
/// Handles pronunciation across word boundaries
String link3(String inp, bool descriptive, bool verbose) {
  const rule = '제15항 자음 동화';
  String out = inp;

  final pairs = [
    ('ᆨ ᄋ', ' ᄀ'),
    ('ᆩ ᄋ', ' ᄁ'),
    ('ᆫ ᄋ', ' ᄂ'),
    ('ᆮ ᄋ', ' ᄃ'),
    ('ᆯ ᄋ', ' ᄅ'),
    ('ᆷ ᄋ', ' ᄆ'),
    ('ᆸ ᄋ', ' ᄇ'),
    ('ᆺ ᄋ', ' ᄉ'),
    ('ᆻ ᄋ', ' ᄊ'),
    ('ᆽ ᄋ', ' ᄌ'),
    ('ᆾ ᄋ', ' ᄎ'),
    ('ᆿ ᄋ', ' ᄏ'),
    ('ᇀ ᄋ', ' ᄐ'),
    ('ᇁ ᄋ', ' ᄑ'),
    ('ᆪ ᄋ', 'ᆨ ᄊ'),
    ('ᆬ ᄋ', 'ᆫ ᄌ'),
    ('ᆰ ᄋ', 'ᆯ ᄀ'),
    ('ᆱ ᄋ', 'ᆯ ᄆ'),
    ('ᆲ ᄋ', 'ᆯ ᄇ'),
    ('ᆳ ᄋ', 'ᆯ ᄊ'),
    ('ᆴ ᄋ', 'ᆯ ᄐ'),
    ('ᆵ ᄋ', 'ᆯ ᄑ'),
    ('ᆹ ᄋ', 'ᆸ ᄊ'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAll(pattern, replacement);
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 12.4: Link rule 4 - Special cases with ㅎ
String link4(String inp, bool descriptive, bool verbose) {
  const rule = '제12항 받침 \'ㅎ\'의 발음';
  String out = inp;

  final pairs = [
    ('ᇂᄋ', 'ᄋ'),
    ('ᆭᄋ', 'ᄂ'),
    ('ᆶᄋ', 'ᄅ'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAll(pattern, replacement);
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Apply all link rules in sequence
String applyLinkRules(String inp, bool descriptive, bool verbose) {
  String out = inp;
  out = link1(out, descriptive, verbose);
  out = link2(out, descriptive, verbose);
  out = link3(out, descriptive, verbose);
  out = link4(out, descriptive, verbose);
  return out;
}

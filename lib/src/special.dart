/// Special pronunciation rules for Korean.
///
/// These rules handle specific pronunciation changes that occur
/// in certain phonetic contexts.

import 'utils.dart';

typedef SpecialRuleFunc = String Function(String, bool, bool);

/// Rule 5.1: ㅈ/ㅊ/ㅉ + ㅖ -> ㅈ/ㅊ/ㅉ + ㅔ
String jyeo(String inp, bool descriptive, bool verbose) {
  const rule = '제5항 어두의 두음 발음';
  final out = inp.replaceAllMapped(
    RegExp(r'([ᄌᄍᄎ])ᅧ'),
    (m) => '${m.group(1)}ᅥ',
  );
  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 5.2: ㅖ pronunciation
/// In descriptive mode, most ㅖ are pronounced as ㅔ
String ye(String inp, bool descriptive, bool verbose) {
  const rule = '제5항 어두의 두음 발음';
  String out;

  if (descriptive) {
    out = inp.replaceAllMapped(
      RegExp(r'([ᄀᄁᄃᄄㄹᄆᄇᄈᄌᄍᄎᄏᄐᄑᄒ])ᅨ'),
      (m) => '${m.group(1)}ᅦ',
    );
  } else {
    out = inp;
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 5.3: Consonant + ㅢ -> Consonant + ㅣ
String consonantUi(String inp, bool descriptive, bool verbose) {
  const rule = '제5항 모음 ㅢ의 발음';
  final out = inp.replaceAllMapped(
    RegExp(r'([ᄀᄁᄂᄃᄄᄅᄆᄇᄈᄉᄊᄌᄍᄎᄏᄐᄑᄒ])ᅴ'),
    (m) => '${m.group(1)}ᅵ',
  );
  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 5.4.2: Josa ㅢ pronunciation
/// In descriptive mode, the josa '의' is often pronounced as [ㅔ]
String josaUi(String inp, bool descriptive, bool verbose) {
  const rule = '제5항 모음 ㅢ의 발음';
  String out;

  if (descriptive) {
    out = inp.replaceAll('의/J', '에');
  } else {
    out = inp.replaceAll('/J', '');
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 5.4.1: Vowel ㅢ pronunciation
/// In descriptive mode, non-initial ㅢ is often pronounced as [ㅣ]
String vowelUi(String inp, bool descriptive, bool verbose) {
  const rule = '제5항 모음 ㅢ의 발음';
  String out;

  if (descriptive) {
    out = inp.replaceAllMapped(
      RegExp(r'(\Sᄋ)ᅴ'),
      (m) => '${m.group(1)}ᅵ',
    );
  } else {
    out = inp;
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 16: Jamo pronunciation
/// Handles pronunciation of consonant clusters in certain contexts
String jamo(String inp, bool descriptive, bool verbose) {
  const rule = '제16항 받침 \'ㄷ\', \'ㅌ\', \'ㅅ\', \'ㅆ\', \'ㅈ\', \'ㅊ\', \'ㅎ\'의 발음';
  String out = inp;

  out = out.replaceAllMapped(
    RegExp(r'([그])ᆮᄋ'),
    (m) => '${m.group(1)}ᄉ',
  );
  out = out.replaceAllMapped(
    RegExp(r'([으])[ᆽᆾᇀᇂ]ᄋ'),
    (m) => '${m.group(1)}ᄉ',
  );
  out = out.replaceAllMapped(
    RegExp(r'([으])[ᆿ]ᄋ'),
    (m) => '${m.group(1)}ᄀ',
  );
  out = out.replaceAllMapped(
    RegExp(r'([으])[ᇁ]ᄋ'),
    (m) => '${m.group(1)}ᄇ',
  );

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 11.1: ㄺ + ㄱ pronunciation
String rieulgiyeok(String inp, bool descriptive, bool verbose) {
  const rule = '제11항 겹받침의 발음';
  String out = inp;

  out = out.replaceAllMapped(
    RegExp(r'ᆰ/P([ᄀᄁ])'),
    (m) => 'ᆯ${m.group(1) == 'ᄀ' ? 'ᄁ' : 'ᄁ'}',
  );

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 25: ㄼ/ㄵ + consonant pronunciation
String rieulbieub(String inp, bool descriptive, bool verbose) {
  const rule = '제25항 자음 동화';
  String out = inp;

  out = out.replaceAllMapped(
    RegExp(r'([ᆲᆴ])/Pᄀ'),
    (m) => '${m.group(1)}ᄁ',
  );
  out = out.replaceAllMapped(
    RegExp(r'([ᆲᆴ])/Pᄃ'),
    (m) => '${m.group(1)}ᄄ',
  );
  out = out.replaceAllMapped(
    RegExp(r'([ᆲᆴ])/Pᄉ'),
    (m) => '${m.group(1)}ᄊ',
  );
  out = out.replaceAllMapped(
    RegExp(r'([ᆲᆴ])/Pᄌ'),
    (m) => '${m.group(1)}ᄍ',
  );

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 24: Verb ㄴ/ㅁ pronunciation
String verbNieun(String inp, bool descriptive, bool verbose) {
  const rule = '제24항 자음 동화';
  String out = inp;

  final pairs = [
    (RegExp(r'([ᆫᆷ])/Pᄀ'), r'$1ᄁ'),
    (RegExp(r'([ᆫᆷ])/Pᄃ'), r'$1ᄄ'),
    (RegExp(r'([ᆫᆷ])/Pᄉ'), r'$1ᄊ'),
    (RegExp(r'([ᆫᆷ])/Pᄌ'), r'$1ᄍ'),
    (RegExp(r'ᆬ/Pᄀ'), 'ᆫᄁ'),
    (RegExp(r'ᆬ/Pᄃ'), 'ᆫᄄ'),
    (RegExp(r'ᆬ/Pᄉ'), 'ᆫᄊ'),
    (RegExp(r'ᆬ/Pᄌ'), 'ᆫᄍ'),
    (RegExp(r'ᆱ/Pᄀ'), 'ᆷᄁ'),
    (RegExp(r'ᆱ/Pᄃ'), 'ᆷᄄ'),
    (RegExp(r'ᆱ/Pᄉ'), 'ᆷᄊ'),
    (RegExp(r'ᆱ/Pᄌ'), 'ᆷᄍ'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAllMapped(pattern, (match) {
      var result = replacement;
      for (int i = 1; i <= match.groupCount; i++) {
        result = result.replaceAll('\$$i', match.group(i) ?? '');
      }
      return result;
    });
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 10.1: Balb (밟) pronunciation
String balb(String inp, bool descriptive, bool verbose) {
  const rule = '제10항 받침 \'ㄼ\'의 발음';
  String out = inp;
  final syllableFinalOrConsonants = r'($|[^ᄋᄒ])';

  // Exceptions
  out = out.replaceAllMapped(
    RegExp('(바)ᆲ($syllableFinalOrConsonants)'),
    (m) => '${m.group(1)}ᆸ${m.group(2)}',
  );
  out = out.replaceAllMapped(
    RegExp(r'(너)ᆲ([ᄌᄍ]ᅮ|[ᄃᄄ]ᅮ)'),
    (m) => '${m.group(1)}ᆸ${m.group(2)}',
  );

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 17: Palatalization
String palatalize(String inp, bool descriptive, bool verbose) {
  const rule = '제17항 구개음화';
  String out = inp;

  out = out.replaceAllMapped(
    RegExp(r'ᆮᄋ([ᅵᅧ])'),
    (m) => 'ᄌ${m.group(1)}',
  );
  out = out.replaceAllMapped(
    RegExp(r'ᇀᄋ([ᅵᅧ])'),
    (m) => 'ᄎ${m.group(1)}',
  );
  out = out.replaceAllMapped(
    RegExp(r'ᆴᄋ([ᅵᅧ])'),
    (m) => 'ᆯᄎ${m.group(1)}',
  );
  out = out.replaceAllMapped(
    RegExp(r'ᆮᄒ([ᅵ])'),
    (m) => 'ᄎ${m.group(1)}',
  );

  gloss(verbose, out, inp, rule);
  return out;
}

/// Rule 27: Modifying rieul (ㄹ) pronunciation
String modifyingRieul(String inp, bool descriptive, bool verbose) {
  const rule = '제27항 사이시옷 발음';
  String out = inp;

  final pairs = [
    ('ᆯ/E ᄀ', 'ᆯ ᄁ'),
    ('ᆯ/E ᄃ', 'ᆯ ᄄ'),
    ('ᆯ/E ᄇ', 'ᆯ ᄈ'),
    ('ᆯ/E ᄉ', 'ᆯ ᄊ'),
    ('ᆯ/E ᄌ', 'ᆯ ᄍ'),
    ('ᆯ걸', 'ᆯ껄'),
    ('ᆯ밖에', 'ᆯ빠께'),
    ('ᆯ세라', 'ᆯ쎄라'),
    ('ᆯ수록', 'ᆯ쑤록'),
    ('ᆯ지라도', 'ᆯ찌라도'),
    ('ᆯ지언정', 'ᆯ찌언정'),
    ('ᆯ진대', 'ᆯ찐대'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAll(pattern, replacement);
  }

  gloss(verbose, out, inp, rule);
  return out;
}

/// List of all special rule functions in order
final List<SpecialRuleFunc> specialRules = [
  jyeo,
  ye,
  consonantUi,
  josaUi,
  vowelUi,
  jamo,
  rieulgiyeok,
  rieulbieub,
  verbNieun,
  balb,
  palatalize,
  modifyingRieul,
];

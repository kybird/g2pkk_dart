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

/// 제5항·제20항: 어절 경계를 넘는 유음화 차단용 경계 보호.
///
/// 규칙 테이블은 `받침( ?)초성` 꼴로 공백 한 칸도 통과시킨다. 유음화(제20항)의
/// 예시는 모두 한 어절 내부(난로·신라·천리)이고 제5항이 어절 단위 발음의
/// 원칙이므로, ㄴ류 받침+ㄹ 초성·ㄹ류 받침+ㄴ 초성 경계('이끈 리더'·'물
/// 노래')에서는 받침을 바꾸지 않는다. 테이블 적용 직전에 이 경계들의 공백을
/// 임시 마커(U+200B)로 바꾸고 [restoreCrossSpaceLiquidization]으로 복원한다.
/// link3(경계 연음 재분절) 등 다른 어절 경계 규칙은 건드리지 않는다.
const boundaryGuardChar = '\u200B';

/// 유음화 셀(→ ㄹㄹ)에 해당하는 어절 경계만 보호한다.
String guardCrossSpaceLiquidization(String inp) => inp
    .replaceAllMapped(
      RegExp(r'([ᆫᆬᆭᆲᆳᆴᆶ]) (ᄅ)'),
      (m) => '${m.group(1)}$boundaryGuardChar${m.group(2)}',
    )
    .replaceAllMapped(
      RegExp(r'([ᆯᆳᆴᆶ]) (ᄂ)'),
      (m) => '${m.group(1)}$boundaryGuardChar${m.group(2)}',
    );

/// [guardCrossSpaceLiquidization]이 삽입한 마커를 공백으로 되돌린다.
/// 입력에 원래 섞여 있던 U+200B도 함께 공백이 된다(무해 — 표기 문자일 뿐).
String restoreCrossSpaceLiquidization(String inp) =>
    inp.replaceAll(boundaryGuardChar, ' ');

/// Apply all link rules in sequence
///
/// [linkAcrossSpace]: 어절 경계(공백)를 넘는 연음 재분절(link3)을 적용할지.
/// 기본 true(기존 동작 — Matcha 계열 라벨의 학습 분포). false면 경계에서
/// 받침을 왼쪽 음절에 유지하고 다음 어절의 초성 ㅇ을 명시하는 표기가 된다
/// (예: '검은 에쿠스'가 '검으 네쿠스'가 아니라 '검은 에쿠스'로 남음).
/// 음소열은 양 표기가 동일하며 — 이는 GPT-SoVITS 배포 가중치가 학습한
/// g2pk2 계열 표기 분포와 짝을 맞추는 용도(2026-10-22).
String applyLinkRules(String inp, bool descriptive, bool verbose,
    {bool linkAcrossSpace = true}) {
  String out = inp;
  out = link1(out, descriptive, verbose);
  out = link2(out, descriptive, verbose);
  if (linkAcrossSpace) {
    out = link3(out, descriptive, verbose);
  }
  out = link4(out, descriptive, verbose);
  return out;
}

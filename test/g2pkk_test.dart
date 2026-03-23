import 'package:test/test.dart';
import 'package:g2pkk/g2pkk.dart';

void main() {
  group('Jamo', () {
    test('h2j decomposes hangul syllables', () {
      // 가 -> 가
      expect(h2j('가'), equals('가'));

      // 한 -> 한
      expect(h2j('한'), equals('한'));

      // 굳 -> 굳
      expect(h2j('굳'), equals('굳'));
    });

    test('h2jString decomposes strings', () {
      // 하나 -> 하나 (나 has no batchim)
      expect(h2jString('하나'), equals('하나'));
      // 한글 -> 한글
      expect(h2jString('한글'), equals('한글'));
    });

    test('j2h composes jamo', () {
      // 가 -> 가
      expect(j2h('가'), equals('가'));

      // 한 -> 한
      expect(j2h('한'), equals('한'));
    });

    test('compose assembles jamo back to syllables', () {
      final result = compose('한글');
      expect(result, equals('한글'));
    });
  });

  group('G2p', () {
    final g2p = G2p();

    test('converts simple text', () {
      final result = g2p.call('하나');
      expect(result, isNotEmpty);
    });

    test('applies idioms', () {
      // 문고리 -> 문꼬리
      final result = g2p.call('문고리');
      expect(result, equals('문꼬리'));
    });

    test('handles empty string', () {
      expect(g2p.call(''), equals(''));
    });

    test('handles text with spaces', () {
      final result = g2p.call('안 녕 하 세 요');
      expect(result, isNotEmpty);
    });

    test('descriptive mode', () {
      // In descriptive mode, some vowels are normalized
      final normal = g2p.call('예의', descriptive: false);
      final descriptive = g2p.call('예의', descriptive: true);
      // The results may differ based on descriptive rules
      expect(normal, isNotEmpty);
      expect(descriptive, isNotEmpty);
    });

    test('group vowels', () {
      final result = g2p.call('개기', groupVowels: true);
      // With groupVowels, ᅢ becomes ᅦ
      expect(result, contains('게'));
    });

    test('keeps jamo when toSyl is false', () {
      final result = g2p.call('가', toSyl: false);
      // Should contain jamo, not syllable
      expect(result, contains(RegExp(r'[\u1100-\u11FF]')));
    });

    test('palatalization rule', () {
      // 굳이 -> 구지 (palatalization)
      final result = g2p.call('굳이');
      expect(result, equals('구지'));
    });

    test('pronunciation of 없었어', () {
      // 없었어 -> 업써써
      final result = g2p.call('없었어');
      expect(result, equals('업써써'));
    });

    test('linking rule', () {
      // 밥을 -> 바블 (when followed by 이/을 etc.)
      final result = g2p.call('밥을');
      expect(result, isNotEmpty);
    });

    test('converts numbers', () {
      // Numbers with pure Korean counters (개, 명, 번, 시, 살, etc.)
      // 3개 -> 세개 (pure Korean for small numbers with counters)
      final result = g2p.call('3개');
      expect(result, equals('세개'));

      // Multi-digit numbers are converted as whole numbers, then pronunciation rules apply
      // 123 -> 백이십삼 -> 배기십쌈 (with pronunciation rules)
      final result2 = g2p.call('123');
      expect(result2, equals('배기십쌈'));

      // Time uses pure Korean for hours
      final result3 = g2p.call('3시');
      expect(result3, equals('세시'));

      // Year uses sino-Korean, pronunciation rules apply
      // 2024년 -> 이천이십사년 -> 이처니십싸년
      final result4 = g2p.call('2024년');
      expect(result4, equals('이처니십싸년'));
    });

    test('pronunciation of 8살때', () {
      // 8살떄 -> 여덜쌀때
      final result = g2p.call('8살때');
      expect(result, equals('여덜쌀때'));
    });

    test('percent symbol handling', () {
      expect(g2p.call('15%를'), equals('시보퍼센트를'));
      expect(g2p.call('15％를'), equals('시보퍼센트를'));
    });

    test('verb tensification without mecab for 안고 phrase', () {
      expect(g2p.call('껴안고 정열의 키스'), equals('껴안꼬 정여릐 키스'));
      expect(g2p.call('안/P고'), equals('안꼬'));
    });

    test('quoted corpus phrases stay intact', () {
      final s53 = g2p.call("내가 선거운동 '흉내'를 내는 거라 망정이지, '진짜' 선거운동을 했다면···");
      final s85 = g2p.call('“지랄하고 앉았네···”');

      final n53 = s53.replaceAll(RegExp(r'[^가-힣]'), '');
      final n85 = s85.replaceAll(RegExp(r'[^가-힣]'), '');

      expect(n53, equals('내가선거운동흉내를내는거라망정이지진짜선거운동을핻따면'));
      expect(n85, equals('지랄하고안잔네'));
    });

    test('corpus phrase #397', () {
      expect(g2p.call('지금도 자주 몬다.'), equals('지금도 자주 몬따.'));
    });

    test('verb stem with 고서 keeps tensification', () {
      expect(g2p.call('머금고서'), equals('머금꼬서'));
    });

    test('corpus phrase with 안고 있었고', () {
      final out = g2p.call('갓난아기를 안고 있었고');
      final normalized = out.replaceAll(RegExp(r'[^가-힣]'), '');
      expect(normalized, equals('간나나기를안꼬이썯꼬'));
    });

    test('no over-tensification in common words', () {
      expect(g2p.call('심지어'), equals('심지어'));
      expect(g2p.call('잠시'), equals('잠시'));
      expect(g2p.call('말인지'), equals('마린지'));
    });
  });

  group('Numerals', () {
    test('processNum sino-korean', () {
      expect(processNum('123', sino: true), equals('백이십삼'));
      expect(processNum('1', sino: true), equals('일'));
      expect(processNum('10', sino: true), equals('십'));
      expect(processNum('100', sino: true), equals('백'));
      expect(processNum('1000', sino: true), equals('천'));
      expect(processNum('10000', sino: true), equals('만'));
      expect(processNum('0', sino: true), equals('영'));
      expect(processNum('123456789', sino: true), equals('일억이천삼백사십오만육천칠백팔십구'));
    });

    test('processNum pure korean', () {
      expect(processNum('1', sino: false), equals('한'));
      expect(processNum('2', sino: false), equals('두'));
      expect(processNum('3', sino: false), equals('세'));
      expect(processNum('4', sino: false), equals('네'));
      expect(processNum('10', sino: false), equals('열'));
      expect(processNum('20', sino: false), equals('스무'));
      expect(processNum('15', sino: false), equals('열다섯'));
      expect(processNum('99', sino: false), equals('아흔아홉'));
      // Large numbers fall back to sino-Korean
      expect(processNum('100', sino: false), equals('백'));
    });

    test('convertNum with bound nouns (with /B annotation)', () {
      // Bound nouns use pure Korean numerals
      final result = convertNum('3개/B');
      expect(result, equals('세개/B'));
    });

    test('convertNum with regular nouns', () {
      // Regular nouns use sino-Korean numerals
      final result = convertNum('3년');
      expect(result, equals('삼년'));
    });

    test('convertNum without annotation - pure Korean counters', () {
      // Time (시) uses pure Korean for hours
      expect(convertNum('3시'), equals('세시'));
      expect(convertNum('12시'), equals('열두시'));

      // Common counters with pure Korean
      expect(convertNum('5개'), equals('다섯개'));
      expect(convertNum('3명'), equals('세명'));
      expect(convertNum('2번'), equals('두번'));
      expect(convertNum('4살'), equals('네살'));
      expect(convertNum('10살'), equals('열살'));
    });

    test('convertNum without annotation - sino-Korean counters', () {
      // Year (년) always uses sino-Korean
      expect(convertNum('2024년'), equals('이천이십사년'));
      expect(convertNum('3년'), equals('삼년'));

      // Month/day always use sino-Korean
      expect(convertNum('3월'), equals('삼월'));
      expect(convertNum('15일'), equals('십오일'));
      expect(convertNum('10분'), equals('십분'));
    });

    test('convertNum multi-digit numbers', () {
      // Multi-digit numbers are converted as whole numbers
      expect(convertNum('123'), equals('백이십삼'));
      expect(convertNum('1000'), equals('천'));
      expect(convertNum('10000'), equals('만'));
    });

    test('convertNum with commas', () {
      expect(convertNum('1,000'), equals('천'));
      expect(convertNum('10,000'), equals('만'));
      expect(convertNum('1,234,567'), equals('백이십삼만사천오백육십칠'));
    });

    test('convertNum mixed text', () {
      expect(convertNum('사과 3개'), equals('사과 세개'));
      expect(convertNum('3시 10분에 만나자'), equals('세시 십분에 만나자'));
      expect(convertNum('가격은 15000원'), equals('가격은 만오천원'));
    });

    test('convertNum edge cases', () {
      // Large numbers with pure Korean counters fall back to sino-Korean
      expect(convertNum('100개'), equals('백개'));
      expect(convertNum('0'), equals('영'));
    });

    test('convertNum with particles after counters', () {
      // Counter followed by particles should still detect the counter
      expect(convertNum('3명이서'), equals('세명이서'));
      expect(convertNum('5개를'), equals('다섯개를'));
      expect(convertNum('2번은'), equals('두번은'));
      expect(convertNum('10살의'), equals('열살의'));
    });
  });
}

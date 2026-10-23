import 'dart:io';
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

  group('Real Rules', () {
    final g2p = G2p();

    test('Link rules', () {
      // test_link2.dart
      expect(g2p.call('옷이'), equals('오시'));
      expect(g2p.call('깎아'), equals('까까'));
      expect(g2p.call('앉아'), equals('안자'));
      expect(g2p.call('닭을'), equals('달글'));
      expect(g2p.call('삶아'), equals('살마'));
      expect(g2p.call('넓어'), equals('널버'));
      expect(g2p.call('외곬으로'), equals('외골쓰로'));
      expect(g2p.call('핥아'), equals('할타'));
      expect(g2p.call('읊어'), equals('을퍼'));
      expect(g2p.call('값이'), equals('갑씨'));
    });

    test('Saisiot compound before 이: ㄴ insertion, not liaison', () {
      // 나랏일 = 나랏 + 일: ㄴ 첨가 후 비음화 -> [나란닐] (제4항, 제20항)
      expect(g2p.call('나랏일'), equals('나란닐'));
      // Contrast: 옷 + 이(조사) is plain liaison -> [오시]
      expect(g2p.call('옷이'), equals('오시'));
    });

    test('Rule 10 & Table rules', () {
      // test_rule10.dart, test_table_rules.dart
      expect(g2p.call('읊다'), equals('읍따'));
      expect(g2p.call('넓다'), equals('널따'));
      expect(g2p.call('앉다'), equals('안다')); // Due to lack of mecab, /P is not generated
    });

    test('Verb tensification (안고, etc.)', () {
      // test_anko.dart, test_verbnieun_impl.dart, test_안고.dart
      // NOTE: User mentioned that forcing /P marker caused a 99% -> 20% reproduction rate drop.
      // We test the expected standard output here natively, noting that mecabb-less annotation
      // might prevent /P marking from firing automatically in the current Dart port.
      // But passing the marker manually should work correctly.
      expect(g2p.call('안/P고'), equals('안꼬'));
      expect(g2p.call('신/P고'), equals('신꼬'));
      expect(g2p.call('젊/P지'), equals('점찌'));
      expect(g2p.call('얹/P다'), equals('언따'));
    });
  });

  group('Mecab annotation', () {
    test('annotate injects markers from POS tags (g2pkk port)', () {
      String annotated(String input, List<(String, String)> tokens) =>
          annotate(input, _FakeAnalyzer(tokens));

      // 용언 어간(V) + 비음/ㄹ받침 -> /P (제23항 경음화 트리거)
      expect(annotated('안고', [('안', 'VV'), ('고', 'EF')]), equals('안/P고'));

      // 단위성 의존명사 NNBC -> /B (순우리말 수사 트리거)
      expect(annotated('3개', [('3', 'SN'), ('개', 'NNBC')]), equals('3개/B'));

      // 조사 의 + J -> /J
      expect(
          annotated('나의 집', [('나', 'NP'), ('의', 'JKG'), ('집', 'NNG')]),
          equals('나의/J 집'));

      // 어미(E) + ㄹ 받침 -> /E (ㄹ 탈락/경음화 트리거)
      expect(annotated('갈걸', [('갈걸', 'EF')]), equals('갈걸/E'));

      // 복합 태그는 '+' 마지막 세그먼트 기준 (XSV+VV -> V)
      expect(annotated('안고', [('안', 'XSV+VV'), ('고', 'EC')]),
          equals('안/P고'));
    });

    test('annotate keeps alignment across spaces', () {
      expect(
          annotate('앉다 신다', _FakeAnalyzer(
              [('앉', 'VV'), ('다', 'EF'), ('신', 'VV'), ('다', 'EF')])),
          equals('앉/P다 신/P다'));
    });

    test('annotate returns input unchanged when tokens do not reassemble it', () {
      // 토큰 합성('옷') != 공백 제거 원문('옷이') -> 안전장치 발동
      expect(annotate('옷이', _FakeAnalyzer([('옷', 'NNG')])),
          equals('옷이'));
    });

    test('G2p with analyzer: /P drives tensification without hardcodes', () {
      final analyzer = _MappingAnalyzer({
        '앉다': [('앉', 'VV'), ('다', 'EF')],
        '안고': [('안', 'VV'), ('고', 'EC')],
        '3개': [('3', 'SN'), ('개', 'NNBC')],
      });
      final g2pMecab = G2p(mecab: analyzer);

      expect(g2pMecab.call('앉다'), equals('안따'));
      expect(g2pMecab.call('안고'), equals('안꼬'));
      expect(g2pMecab.call('3개'), equals('세개'));
    });

    test('G2p with analyzer: /B bound noun uses pure-Korean counters too', () {
      // '명'은 pureKoreanCounterSet에는 있지만 boundNounSet에는 없는 단위명사 —
      // /B 경로가 이를 놓치면 '2명'이 [이명](한자수)으로 회귀한다.
      final analyzer = _MappingAnalyzer({
        '2명': [('2', 'SN'), ('명', 'NNBC')],
        '3개': [('3', 'SN'), ('개', 'NNBC')],
      });
      final g2pMecab = G2p(mecab: analyzer);

      expect(g2pMecab.call('2명'), equals('두명'));
      expect(g2pMecab.call('3개'), equals('세개'));
    });

    test('G2p without analyzer keeps mecab-less behavior', () {
      final g2p = G2p();
      expect(g2p.call('앉다'), equals('안다'));
      // 안전장치: 분석 결과가 원문과 안 맞으면 원문 그대로 진행
      final g2pMismatch =
          G2p(mecab: _MappingAnalyzer({'옷이': [('옷', 'NNG')]}));
      expect(g2pMismatch.call('옷이'), equals('오시'));
    });

    test('idioms still win over mecab analysis', () {
      final g2pMecab = G2p(mecab: _MappingAnalyzer({
        '나란닐': [('나란닐', 'NNG')],
      }));
      expect(g2pMecab.call('나랏일'), equals('나란닐'));
    });

    test('adverb ㄷ-series coda + vowel-initial content links as [ㄷ] (제9항·제15항)',
        () {
      // 붙여 쓴 부사 '못'을 mecab이 못/알아먹는다로 분석하면 어절 경계를 만들어
      // ㅅ의 대표음 [ㄷ]으로 연음한다: 못알아먹는다[모다라멍는다].
      // 근거: 표준 발음법 제9항(어말 ㄷ류 대표음 [ㄷ])·제15항(실질 형태소 앞
      // 대표음 연결), 국립국어원 온라인가나다 '부정부사 못의 발음'
      // ('못 올 일이'[모돌 이리], '못 잊어'[몬니저]).
      final g2pMecab = G2p(mecab: _MappingAnalyzer({
        '못알아먹는다': [('못', 'MAG'), ('알아먹', 'VV'), ('는다', 'EF')],
        '못읽은': [('못', 'MAG'), ('읽', 'VV'), ('은', 'ETM')],
        '못옵니까': [('못', 'MAG'), ('옵', 'VV'), ('니까', 'EF')],
        '못 알아먹는다': [
          ('못', 'MAG'),
          ('알아먹', 'VV'),
          ('는다', 'EF')
        ],
        '곧없다': [('곧', 'MAG'), ('없', 'VA'), ('다', 'EF')],
      }));

      expect(g2pMecab.call('못알아먹는다'), equals('모 다라멍는다'));
      expect(g2pMecab.call('못읽은'), equals('모 딜근'));
      expect(g2pMecab.call('못옵니까'), equals('모 돔니까'));
      expect(g2pMecab.call('곧없다'), equals('고 덥따'));
      // 이미 띄어 쓴 입력은 이중 공백 없이 동일 결과
      expect(g2pMecab.call('못 알아먹는다'), equals(g2pMecab.call('못알아먹는다')));
    });

    test('compound-tag next morpheme still counts as content (VV+EF)', () {
      // mecab이 '옵니까'를 VV+EF 한 토큰으로 내도 실질 어간(V)이 보이면
      // 부사 경계가 적용된다.
      final g2pMecab = G2p(mecab: _MappingAnalyzer({
        '못옵니까': [('못', 'MAG'), ('옵니까', 'VV+EF')],
      }));
      expect(g2pMecab.call('못옵니까'), equals('모 돔니까'));
    });

    test('josa/eomi after dIEUT coda keeps in-word linking (제13항)', () {
      // 수정 금지 대조군 — 부사 경계 삽입이 조사·어미 연음을 망치면 안 된다.
      final g2pMecab = G2p(mecab: _MappingAnalyzer({
        '못이': [('못', 'NNG'), ('이', 'JKS')],
        '잘못을': [('잘못', 'MAG'), ('을', 'JKO')],
        '못하다': [('못', 'MAG'), ('하', 'XSV'), ('다', 'EF')],
        '못할': [('못', 'MAG'), ('할', 'VV+ETX')],
      }));

      expect(g2pMecab.call('못이'), equals('모시')); // 명사 못+조사: 옷이[오시]급
      expect(g2pMecab.call('잘못을'), equals('잘모슬')); // 조사 을: 제13항 연음
      expect(g2pMecab.call('못하다'), equals('모타다')); // ㅇ 아님: 경계 없음
      expect(g2pMecab.call('못할'), equals('모탈'));
    });

    test('annotate inserts adverb boundary only for attached input', () {
      expect(
          annotate('못알아먹는다',
              _FakeAnalyzer([('못', 'MAG'), ('알아먹', 'VV'), ('는다', 'EF')])),
          equals('못 알아먹는다'));
      // 이미 띄어 쓴 경계는 이중 공백 없이 유지
      expect(
          annotate('못 알아먹는다',
              _FakeAnalyzer([('못', 'MAG'), ('알아먹', 'VV'), ('는다', 'EF')])),
          equals('못 알아먹는다'));
      // 명사 못+조사는 경계 없음
      expect(annotate('못이', _FakeAnalyzer([('못', 'NNG'), ('이', 'JKS')])),
          equals('못이'));
      // 부사+조사(형식 형태소)도 경계 없음
      expect(annotate('잘못을', _FakeAnalyzer([('잘못', 'MAG'), ('을', 'JKO')])),
          equals('잘못을'));
    });
  });

  group('Exceptions and Edge Cases', () {
    final g2p = G2p();

    test('Backreference replace behavior', () {
      // test_both_issues.dart, test_backref.dart
      // Verify Dart replaceAllMapped is used properly for backrefs instead of raw replaceAll
      final withMarker = '안/P고';
      // If we manually apply regex that mimics verbNieun:
      final fixed = withMarker.replaceAllMapped(
        RegExp(r'([ᆫᆷ])/Pᄀ'),
        (m) => '${m.group(1)}ᄁ',
      );
      expect(fixed, equals('안꼬'));
      expect(g2p.call('안/P고'), equals('안꼬')); // G2P should handle it
    });

    test('MECAB/Annotation missing marker', () {
      // verify_issue.dart
      final result = g2p.call('안고');
      expect(result, equals('안꼬'));
    });
  });

  group('File and Asset Based Tests', () {
    test('File-based test runner (test_cases.txt)', () {
      final file = File('test/data/test_cases.txt');
      if (!file.existsSync()) {
        print('Skipping: test/data/test_cases.txt not found.');
        return; // Don't fail if the file isn't there, just skip
      }

      final g2p = G2p();
      final lines = file.readAsLinesSync();
      int runCount = 0;

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final parts = line.split('|');
        if (parts.length >= 2) {
          final input = parts[0].trim();
          final expected = parts[1].trim();
          
          final result = g2p.call(input);
          expect(result, equals(expected), reason: 'Failed for input: \$input');
          runCount++;
        }
      }
      
      expect(runCount, greaterThan(0), reason: 'No valid tests found in file');
      print('Ran \$runCount file-based tests successfully.');
    });

    test('English CMUDict conversion', () async {
      final cmudictPath = 'lib/cmudict.json';
      final file = File(cmudictPath);
      
      if (file.existsSync()) {
        final g2pWithEng = await G2p.create(cmuDictPath: cmudictPath);
        expect(g2pWithEng.call('game을 했다'), equals('게이믈 핻따'));
        expect(g2pWithEng.call('file 3개'), equals('파일 세개'));
        expect(g2pWithEng.call('computer'), equals('컴퓨터'));
      } else {
        print('Skipping: cmudict.json not found at \$cmudictPath');
      }
    });
  });
  group('linkAcrossSpace (boundary notation)', () {
    final g2p = G2p();

    test('default: cross-space linking resyllabifies (historical distribution)', () {
      expect(g2p.call('검은 에쿠스'), equals('거므 네쿠스'));
      expect(g2p.call('다는 이미'), equals('다느 니미'));
    });

    test('linkAcrossSpace=false keeps batchim + explicit onset ㅇ (g2pk2 notation)', () {
      expect(
        g2p.call('검은 에쿠스', linkAcrossSpace: false),
        equals('거믄 에쿠스'),
      );
      expect(
        g2p.call('다는 이미', linkAcrossSpace: false),
        equals('다는 이미'),
      );
    });

    test('within-word linking is unaffected by the flag', () {
      expect(g2p.call('한국어', linkAcrossSpace: false), equals('한구거'));
      expect(g2p.call('한국어'), equals('한구거'));
    });

    test('idiom table (saisiot fix) survives both notations', () {
      expect(g2p.call('나랏일', linkAcrossSpace: false), equals('나란닐'));
    });

    test('jamo output (toSyl:false) boundary forms', () {
      expect(
        g2p.call('검은 에쿠스', toSyl: false, linkAcrossSpace: false),
        equals('거믄 에쿠스'),
      );
    });
  });
}

/// Fake analyzer returning a fixed token list regardless of input.
class _FakeAnalyzer implements MorphAnalyzer {
  _FakeAnalyzer(this.tokens);

  final List<(String, String)> tokens;

  @override
  List<(String, String)> pos(String text) => tokens;
}

/// Fake analyzer keyed by input string, mimicking per-call analysis.
class _MappingAnalyzer implements MorphAnalyzer {
  _MappingAnalyzer(this.table);

  final Map<String, List<(String, String)>> table;

  @override
  List<(String, String)> pos(String text) =>
      table[text] ?? const <(String, String)>[];

}
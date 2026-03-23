/// Number conversion utilities for Korean text.
///
/// Converts Arabic numerals to Korean words (sino-Korean or pure Korean).
/// This version works without mecab by detecting common patterns.

/// Bound nouns that are preceded by pure Korean numerals.
const String _boundNouns =
    '군데 권 개 그루 닢 대 두 마리 모 모금 뭇 발 발짝 방 번 벌 보루 살 수 술 시 쌈 움큼 정 짝 채 척 첩 축 켈레 톨 통';

/// Counter words that typically use pure Korean numerals for small numbers (1-99).
const String _pureKoreanCounters =
    '개 명 번 대 권 잔 그릇 병 장 자루 송이 마리 채 층 칸 '
    /// Time units that use pure Korean for hours
    '시 '
    /// Age uses pure Korean
    '살';

/// Sino-Korean counter words (always use sino-Korean regardless of number size).
const String _sinoCounters = '년 월 일 요일 초 분 주일 회 차 배 배율';

final Set<String> boundNounSet = _boundNouns.split(' ').toSet();
final Set<String> pureKoreanCounterSet = _pureKoreanCounters.split(' ').toSet();
final Set<String> sinoCounterSet = _sinoCounters.split(' ').toSet();

/// Process a string looking like Arabic number.
///
/// [num]: String consisting of digits and commas. e.g., "12,345"
/// [sino]: If true, uses sino-Korean numerals (일, 이, ...).
///         If false, uses pure Korean numerals in modifying forms (한, 두, ...).
///
/// Example:
/// ```dart
/// processNum('123456789', sino: true); // 일억이천삼백사십오만육천칠백팔십구
/// processNum('3', sino: false); // 세
/// ```
String processNum(String num, {bool sino = true}) {
  num = num.replaceAll(',', '');

  if (num == '0') return '영';
  if (!sino && num == '20') return '스무';

  // Pure Korean only supports up to 99
  if (!sino && num.length > 2) {
    sino = true; // Fall back to sino-Korean for larger numbers
  }

  const digits = '123456789';
  const names = '일이삼사오육칠팔구';

  final digit2name = <String, String>{};
  for (int i = 0; i < digits.length; i++) {
    digit2name[digits[i]] = names[i];
  }

  const modifiers = ['한', '두', '세', '네', '다섯', '여섯', '일곱', '여덟', '아홉'];
  const decimals = ['열', '스물', '서른', '마흔', '쉰', '예순', '일흔', '여든', '아흔'];

  final digit2mod = <String, String>{};
  final digit2dec = <String, String>{};
  for (int i = 0; i < digits.length; i++) {
    digit2mod[digits[i]] = modifiers[i];
    digit2dec[digits[i]] = decimals[i];
  }

  final spelledOut = <String>[];

  for (int i = 0; i < num.length; i++) {
    final digit = num[i];
    final pos = num.length - i - 1; // Position from right (0 = ones, 1 = tens, ...)

    String name = '';

    if (sino) {
      if (pos == 0) {
        name = digit2name[digit] ?? '';
      } else if (pos == 1) {
        name = (digit2name[digit] ?? '') + '십';
        name = name.replaceAll('일십', '십');
      }
    } else {
      if (pos == 0) {
        name = digit2mod[digit] ?? '';
      } else if (pos == 1) {
        name = digit2dec[digit] ?? '';
      }
    }

    if (digit == '0') {
      if (pos % 4 == 0) {
        final lastThree = spelledOut.length >= 3
            ? spelledOut.sublist(spelledOut.length - 3)
            : spelledOut;
        if (lastThree.join() == '') {
          spelledOut.add('');
          continue;
        }
      } else {
        spelledOut.add('');
        continue;
      }
    }

    if (pos == 2) {
      name = (digit2name[digit] ?? '') + '백';
      name = name.replaceAll('일백', '백');
    } else if (pos == 3) {
      name = (digit2name[digit] ?? '') + '천';
      name = name.replaceAll('일천', '천');
    } else if (pos == 4) {
      name = (digit2name[digit] ?? '') + '만';
      name = name.replaceAll('일만', '만');
    } else if (pos == 5) {
      name = (digit2name[digit] ?? '') + '십';
      name = name.replaceAll('일십', '십');
    } else if (pos == 6) {
      name = (digit2name[digit] ?? '') + '백';
      name = name.replaceAll('일백', '백');
    } else if (pos == 7) {
      name = (digit2name[digit] ?? '') + '천';
      name = name.replaceAll('일천', '천');
    } else if (pos == 8) {
      name = (digit2name[digit] ?? '') + '억';
    } else if (pos == 9) {
      name = (digit2name[digit] ?? '') + '십';
    } else if (pos == 10) {
      name = (digit2name[digit] ?? '') + '백';
    } else if (pos == 11) {
      name = (digit2name[digit] ?? '') + '천';
    } else if (pos == 12) {
      name = (digit2name[digit] ?? '') + '조';
    } else if (pos == 13) {
      name = (digit2name[digit] ?? '') + '십';
    } else if (pos == 14) {
      name = (digit2name[digit] ?? '') + '백';
    } else if (pos == 15) {
      name = (digit2name[digit] ?? '') + '천';
    }

    spelledOut.add(name);
  }

  return spelledOut.join();
}

/// Extract the counter word from text following a number.
///
/// Counters are typically 1-2 syllables, followed by particles or spaces.
/// This function extracts just the counter portion.
String _extractCounter(String text) {
  // Extract Korean characters
  final match = RegExp(r'^([ㄱ-힣]+)').firstMatch(text);
  if (match == null) return '';

  final koreanText = match.group(1)!;

  // Direct match for known counters.
  if (pureKoreanCounterSet.contains(koreanText) ||
      sinoCounterSet.contains(koreanText) ||
      boundNounSet.contains(koreanText)) {
    return koreanText;
  }

  // Handle age expressions like "살때" / common typo "살떄".
  // This keeps numeral choice stable without broad text normalization.
  if (koreanText.length == 2) {
    final first = koreanText.substring(0, 1);
    final second = koreanText.substring(1);
    if ((pureKoreanCounterSet.contains(first) ||
            sinoCounterSet.contains(first) ||
            boundNounSet.contains(first)) &&
        (second == '때' || second == '떄')) {
      return first;
    }
  }

  // Common particles that follow counters
  const particles = [
    '이랑', '하고', '부터', '까지', '마저', '조차', '마는', '이라도',
    '에게', '한테', '께', '에', '으로', '로', '으로서', '로서',
    '으로써', '로써', '으로부터', '로부터', '에다', '이다',
    '이', '가', '은', '는', '을', '를', '과', '와', '도', '만', '뿐', '요', '의'
  ];

  // Sort by length (longest first) to match longest particle first
  final sortedParticles = particles.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  for (final particle in sortedParticles) {
    if (koreanText.endsWith(particle) && koreanText.length > particle.length) {
      return koreanText.substring(0, koreanText.length - particle.length);
    }
  }

  // If it's short and not recognized as a counter, keep current behavior
  // and return as-is.
  if (koreanText.length <= 2) {
    return koreanText;
  }

  // Check if first 1-2 chars are a known counter
  for (final len in [2, 1]) {
    if (len >= koreanText.length) continue;
    final potential = koreanText.substring(0, len);
    if (pureKoreanCounterSet.contains(potential) ||
        sinoCounterSet.contains(potential) ||
        boundNounSet.contains(potential)) {
      return potential;
    }
  }

  // Default: return first 1-2 characters as potential counter
  return koreanText.length <= 2 ? koreanText : koreanText.substring(0, 2);
}

/// Check if a number should use pure Korean numerals based on context.
///
/// [num]: The number string
/// [followingText]: The text immediately following the number
bool _shouldUsePureKorean(String num, String followingText) {
  // If number is too large (>99), always use sino-Korean
  final numValue = int.tryParse(num.replaceAll(',', ''));
  if (numValue == null || numValue > 99) return false;

  // Extract the counter word (first Korean word after the number)
  final counter = _extractCounter(followingText);
  if (counter.isEmpty) return false;

  // Sino-Korean counters always use sino-Korean
  if (sinoCounterSet.contains(counter)) return false;

  // Pure Korean counters use pure Korean for small numbers
  if (pureKoreanCounterSet.contains(counter)) return true;

  // Check bound nouns from original list
  if (boundNounSet.contains(counter)) return true;

  return false;
}

/// Convert annotated string such that Arabic numerals are spelled out.
///
/// This function handles:
/// 1. `/B` annotated bound nouns (from mecab)
/// 2. Common patterns without annotation (time, counters, etc.)
/// 3. Multi-digit numbers as whole numbers (not digit-by-digit)
///
/// Example:
/// ```dart
/// convertNum('우리 3시 10분에 만나자');
/// // => 우리 세시 십분에 만나자.
/// convertNum('사과 3개');
/// // => 사과 세개
/// ```
String convertNum(String string) {
  final buffer = StringBuffer();
  var i = 0;

  while (i < string.length) {
    // Check if we're at the start of a number
    if (_isDigit(string[i]) || (string[i] == ',' && i > 0 && _isDigit(string[i - 1]))) {
      // Skip comma if it's at the start
      if (string[i] == ',') {
        buffer.write(string[i]);
        i++;
        continue;
      }

      // Collect the full number (including commas)
      final numBuffer = StringBuffer();
      while (i < string.length && (_isDigit(string[i]) || string[i] == ',')) {
        numBuffer.write(string[i]);
        i++;
      }

      final numStr = numBuffer.toString();

      // Skip if it's just commas
      if (numStr.replaceAll(',', '').isEmpty) {
        buffer.write(numStr);
        continue;
      }

      // Percent handling fallback.
      // Idioms usually convert % -> 퍼센트 first, but some inputs may bypass
      // idiom replacement (e.g., custom idiom table). Keep this behavior local
      // to percent only and avoid touching general numeral logic.
      if (i < string.length && (string[i] == '%' || string[i] == '％')) {
        final spelledOut = processNum(numStr, sino: true);
        buffer.write(spelledOut);
        buffer.write('퍼센트');
        i++; // consume percent sign
        continue;
      }

      // Check for /B annotation (mecab)
      if (i < string.length && string[i] != '/') {
        final remaining = string.substring(i);

        // Check for bound noun pattern with /B
        final boundMatch = RegExp(r'^([ㄱ-힣]+)/B').firstMatch(remaining);
        if (boundMatch != null) {
          final bn = boundMatch.group(1)!;
          final usePureKorean = boundNounSet.contains(bn);
          final spelledOut = processNum(numStr, sino: !usePureKorean);
          buffer.write(spelledOut);
          buffer.write(bn);
          buffer.write('/B');
          i += boundMatch.end;
          continue;
        }

        // Without mecab: detect counter patterns
        final usePureKorean = _shouldUsePureKorean(numStr, remaining);
        final spelledOut = processNum(numStr, sino: !usePureKorean);
        buffer.write(spelledOut);
      } else if (i < string.length && string[i] == '/') {
        // Has annotation, check for /B
        final remaining = string.substring(i);
        final boundMatch = RegExp(r'^/([PJEB])').firstMatch(remaining);
        if (boundMatch != null) {
          final annotation = boundMatch.group(1)!;
          final spelledOut = processNum(numStr);
          buffer.write(spelledOut);
          buffer.write('/$annotation');
          i += boundMatch.end;
          continue;
        }
        // Just convert the number
        buffer.write(processNum(numStr));
      } else {
        // End of string or space/special char after number
        // Convert as sino-Korean by default
        buffer.write(processNum(numStr));
      }
    } else {
      buffer.write(string[i]);
      i++;
    }
  }

  return buffer.toString();
}

/// Check if a character is a digit
bool _isDigit(String char) {
  return char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39;
}

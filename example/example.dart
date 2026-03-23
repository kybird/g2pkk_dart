/// Example usage of the g2pkk library.

import 'dart:io';
import 'package:g2pkk/g2pkk.dart';

void main() async {
  // Create a G2p instance
  final g2p = G2p();

  // Basic usage
  print('=== Basic Usage ===');
  print(g2p.call('하나')); // 하나
  print(g2p.call('한글')); // 한글

  // Idioms are applied
  print('\n=== Idioms ===');
  print(g2p.call('문고리')); // 문꼬리
  print(g2p.call('갈등')); // 갈뜽
  print(g2p.call('신바람')); // 신빠람

  // Palatalization rule
  print('\n=== Palatalization ===');
  print(g2p.call('굳이')); // 구지
  print(g2p.call('같이')); // 가치

  // Number conversion
  print('\n=== Number Conversion ===');
  print(g2p.call('123')); // 이리삼 (일이삼 -> 발음규칙 적용)
  print(g2p.call('3개')); // 삼개

  // English conversion (requires cmudict.json)
  print('\n=== English Conversion ===');
  final cmudictPath = 'lib/cmudict.json';
  if (await File(cmudictPath).exists()) {
    final g2pWithEng = await G2p.create(cmuDictPath: cmudictPath);
    print(g2pWithEng.call('game을 했다')); // 게임을 했다
    print(g2pWithEng.call('file 3개')); // 파일 삼개
    print(g2pWithEng.call('computer')); // 컴퓨터
  } else {
    print('cmudict.json not found at $cmudictPath');
    print('To enable English conversion, download cmudict.json');
  }

  // Other options
  print('\n=== Other Options ===');

  // Descriptive mode (casual pronunciation)
  print(g2p.call('예의', descriptive: false)); // Standard
  print(g2p.call('예의', descriptive: true)); // Descriptive

  // Group vowels (normalize similar vowels)
  print(g2p.call('개기')); // 개기
  print(g2p.call('개기', groupVowels: true)); // 게기 (ㅐ -> ㅔ)

  // Keep as jamo (don't compose to syllables)
  print(g2p.call('한글', toSyl: false)); // Returns jamo

  // Verbose mode (shows transformation steps)
  print('\n=== Verbose Mode ===');
  g2p.call('밥을', verbose: true);
}

# g2pkk

A Korean Grapheme-to-Phoneme conversion library for Dart.
This is a port of the Python [g2pK](https://github.com/kyubyong/g2pK) library.

## Features

- Convert Korean text to phonetic pronunciation
- Apply standard Korean pronunciation rules
- Handle special cases and idioms
- Support for descriptive (casual) pronunciation
- **Number conversion** (Arabic numerals to Korean words)
- **English to Hangul conversion** (with CMU dict)

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  g2pkk: ^0.1.0
```

## Usage

```dart
import 'package:g2pkk/g2pkk.dart';

void main() async {
  // Basic usage (without English conversion)
  final g2p = G2p();

  print(g2p.call('하나')); // 하나
  print(g2p.call('한글')); // 한글

  // Idioms are applied automatically
  print(g2p.call('문고리')); // 문꼬리
  print(g2p.call('갈등')); // 갈뜽

  // Number conversion (digit by digit)
  print(g2p.call('123')); // 이리삼 (일이삼 with pronunciation rules)
  print(g2p.call('3개')); // 삼개

  // With English conversion (requires cmudict.json)
  final g2pWithEng = await G2p.create(cmuDictPath: 'path/to/cmudict.json');
  print(g2pWithEng.call('game을 했다')); // 게이믈 핻따
  print(g2pWithEng.call('file 3개')); // 파일 삼개
  print(g2pWithEng.call('computer')); // 컴퓨터

  // With options
  print(g2p.call('예의', descriptive: true)); // Descriptive mode
  print(g2p.call('개기', groupVowels: true)); // Normalize vowels
  print(g2p.call('한글', toSyl: false)); // Keep as jamo
}
```

## API

### `G2p.call(string, options)`

Convert Korean text to phonetic pronunciation.

**Parameters:**
- `string` (String): Input Korean text
- `descriptive` (bool, default: false): Apply descriptive pronunciation rules
- `verbose` (bool, default: false): Print transformation steps
- `groupVowels` (bool, default: false): Normalize similar vowels (ㅐ→ㅔ, etc.)
- `toSyl` (bool, default: true): Compose jamo back to syllables

### `G2p.create(options)`

Create a G2p instance asynchronously with optional CMU dict for English conversion.

```dart
final g2p = await G2p.create(cmuDictPath: 'path/to/cmudict.json');
```

### English Conversion

```dart
import 'package:g2pkk/g2pkk.dart';

// Load CMU dict
final cmu = await CmuDict.load('cmudict.json');

// Convert English in text
print(convertEng('game을 했다', cmu)); // 게임을 했다
```

### Number Conversion

```dart
import 'package:g2pkk/g2pkk.dart';

// Process individual numbers
print(processNum('123', sino: true)); // 백이십삼
print(processNum('3', sino: false));  // 세 (pure Korean)

// Convert numbers in text
print(convertNum('3년')); // 삼년
```

### Jamo Utilities

```dart
import 'package:g2pkk/g2pkk.dart';

// Decompose syllable to jamo
String jamo = h2j('한'); // '한'
String jamoStr = h2jString('한글'); // '한글'

// Compose jamo to syllable
String syllable = j2h('한'); // '한'

// Compose jamo string
String text = compose('한글'); // '한글'
```

## Implemented Rules

This Dart port implements:

1. **Idioms** - Special pronunciation for common words
2. **Special Rules** - Vowel/consonant transformations
3. **Regular Table** - Batchim + onset combinations
4. **Link Rules** - Cross-syllable linking
5. **Composition** - Jamo to syllable assembly
6. **Number Conversion** - Arabic numerals to Korean words
7. **English Conversion** - English words to Korean pronunciation

## Differences from Python Version

This version does **not** include:
- Mecab annotation (requires external morphological analyzer)

Note: Without mecab annotation, bound nouns (의존명사) cannot be automatically detected,
so all numbers are converted digit-by-digit using sino-Korean numerals.

## CMU Dict

For English to Hangul conversion, you need the CMU pronunciation dictionary.
The package includes a `cmudict.json` file in the `lib/` directory.

To use your own dictionary:
```dart
final g2p = await G2p.create(cmuDictPath: 'path/to/your/cmudict.json');
```

## License

MIT License

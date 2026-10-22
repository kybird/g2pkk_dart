/// Korean Grapheme-to-Phoneme conversion library.
///
/// This library converts Korean text to its phonetic pronunciation
/// following standard Korean pronunciation rules.
library g2pkk;

export 'src/g2pkk.dart';
export 'src/english.dart';
export 'src/jamo.dart';
export 'src/numerals.dart';
// utils: only the public extension surface. `group` (vowel grouping) is
// deliberately not exported — it collides with package:test's `group`.
export 'src/utils.dart'
    show MorphAnalyzer, annotate, RuleEntry, parseIdioms, parseTable;

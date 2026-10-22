/// Utility functions for g2pkk.

import 'jamo.dart';

/// Rule entry from table.csv
class RuleEntry {

  const RuleEntry(this.pattern, this.replacement, this.ruleIds);
  final String pattern;
  final String replacement;
  final List<String> ruleIds;
}

/// Parse the rule table from CSV format.
List<RuleEntry> parseTable(String csvContent) {
  final lines = csvContent.split('\n');
  if (lines.isEmpty) return [];

  final onsets = lines[0].split(',');
  final table = <RuleEntry>[];

  for (int lineIdx = 1; lineIdx < lines.length; lineIdx++) {
    final line = lines[lineIdx];
    if (line.trim().isEmpty) continue;

    final cols = line.split(',');
    if (cols.isEmpty) continue;

    final coda = cols[0];

    for (int i = 1; i < cols.length && i < onsets.length; i++) {
      final cell = cols[i];
      if (cell.isEmpty) continue;

      final onset = _normalizeOnsetPattern(onsets[i]);
      final pattern = '$coda$onset';

      String replacement;
      List<String> ruleIds;

      if (cell.contains('(')) {
        final parenIndex = cell.indexOf('(');
        replacement = cell.substring(0, parenIndex);
        final ruleStr = cell.substring(parenIndex + 1, cell.length - 1);
        ruleIds = ruleStr.split('/');
      } else {
        replacement = cell;
        ruleIds = [];
      }

      // Convert Python-style backreferences (\1) to Dart-style ($1)
      replacement = replacement.replaceAll(r'\1', r'$1');

      table.add(RuleEntry(pattern, replacement, ruleIds));
    }
  }

  return table;
}

String _normalizeOnsetPattern(String onset) {
  var out = onset;

  // Python's table uses (\W|$) with Unicode-aware behavior.
  // Dart RegExp treats \W differently for jamo, so force an explicit
  // non-word class that keeps Hangul Jamo (U+1100..U+11FF) as word chars.
  out = out.replaceAll(
    r'(\W|\$)',
    r'([^0-9A-Za-z_\u1100-\u11FF]|$)',
  );
  out = out.replaceAll(
    r'(\W|$)',
    r'([^0-9A-Za-z_\u1100-\u11FF]|$)',
  );

  return out;
}

/// Morphological analyzer contract, mirroring python-mecab-ko's `pos()`.
///
/// Implementations return `(surface, tag)` pairs per morpheme. The tags use
/// mecab-ko conventions (e.g. VV, EF, JKS, NNBC); compound tags such as
/// `VV+EF` are allowed. Concatenating all surfaces must yield the input with
/// spaces removed — otherwise [annotate] ignores the analysis and keeps the
/// input untouched.
abstract interface class MorphAnalyzer {
  /// Analyze [text] into (surface, tag) morpheme pairs.
  List<(String, String)> pos(String text);
}

/// Port of the Python g2pkk `annotate()`: POS-based marker injection.
///
/// Given morphemes from [mecab], appends rule-trigger markers after the last
/// character of eligible morphemes:
/// - `의` carrying a josa tag (J) -> `/J`
/// - an ending (E) with final `ㄹ` -> `/E`
/// - a predicate stem (V) with final `ㄴ, ㄵ, ㅁ, ㄹㅁ, ㄺ, ㄼ, ㄾ` -> `/P`
/// - a unit-bound noun (NNBC) -> `/B`
///
/// Markers are consumed by the special rules (`verbNieun`,
/// `modifyingRieul`, ...), numeral conversion (`/B`), and finally stripped.
/// Returns [string] unchanged when the analysis does not reassemble it.
String annotate(String string, MorphAnalyzer mecab) {
  final tokens = mecab.pos(string);
  if (string.replaceAll(' ', '') != tokens.map((t) => t.$1).join()) {
    return string;
  }

  // One tag letter per character, placed at each morpheme's last character.
  final tagSeq = StringBuffer();
  for (final (surface, rawTag) in tokens) {
    var tag = rawTag.split('+').last;
    tag = tag.isEmpty ? '_' : (tag == 'NNBC' ? 'B' : tag[0]);
    tagSeq.write('_' * (surface.length - 1) + tag);
  }
  var tags = tagSeq.toString();

  // Re-insert blanks so tags align 1:1 with the original string.
  for (int i = 0; i < string.length; i++) {
    if (string[i] == ' ') {
      tags = '${tags.substring(0, i)} ${tags.substring(i)}';
    }
  }

  final out = StringBuffer();
  for (int i = 0; i < string.length; i++) {
    final char = string[i];
    out.write(char);
    final tag = i < tags.length ? tags[i] : '';
    if (tag == 'J') {
      if (char == '의') out.write('/J');
    } else if (tag == 'E') {
      if (_lastJamo(char) == 'ᆯ') out.write('/E');
    } else if (tag == 'V') {
      if ('ᆫᆬᆷᆱᆰᆲᆴ'.contains(_lastJamo(char))) out.write('/P');
    } else if (tag == 'B') {
      out.write('/B');
    }
  }
  return out.toString();
}

String _lastJamo(String char) {
  final jamo = h2j(char);
  return jamo.isEmpty ? '' : jamo[jamo.length - 1];
}

/// Parse idioms from text format.
/// Format: str1===str2 (one per line, # for comments)
List<(String, String)> parseIdioms(String content) {
  final idioms = <(String, String)>[];

  for (final line in content.split('\n')) {
    final trimmed = line.split('#')[0].trim();
    if (trimmed.contains('===')) {
      final parts = trimmed.split('===');
      if (parts.length == 2) {
        idioms.add((parts[0], parts[1]));
      }
    }
  }

  return idioms;
}

/// Group similar vowels together.
/// Contemporary Korean speakers often don't distinguish certain vowels.
String group(String inp) {
  return inp
      .replaceAll('ᅢ', 'ᅦ')
      .replaceAll('ᅤ', 'ᅨ')
      .replaceAll('ᅫ', 'ᅬ')
      .replaceAll('ᅰ', 'ᅬ');
}

/// Display gloss information for verbose mode.
void gloss(bool verbose, String out, String inp, String rule) {
  if (verbose && out != inp && out != inp.replaceAll(RegExp(r'/[EJPB]'), '')) {
    print('${compose(inp)} -> ${compose(out)}');
    print('\x1B[1;31m$rule\x1B[0m');
  }
}

/// Parse rule ID to text mapping.
Map<String, String> parseRules(String content) {
  final rules = <String, String>{};
  final sections = content.trim().split('\n\n');

  for (final section in sections) {
    final lines = section.split('\n');
    if (lines.isEmpty) continue;

    final ruleId = lines[0].trim();
    final text = lines.sublist(1).join('\n');
    rules[ruleId] = text;
  }

  return rules;
}

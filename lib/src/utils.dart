/// Utility functions for g2pkk.

import 'jamo.dart';

/// Rule entry from table.csv
class RuleEntry {
  final String pattern;
  final String replacement;
  final List<String> ruleIds;

  const RuleEntry(this.pattern, this.replacement, this.ruleIds);
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

String annotateLite(String text) {
  const targetFinals = {'ᆫ', 'ᆬ', 'ᆷ', 'ᆱ', 'ᆰ', 'ᆲ', 'ᆴ'};
  const triggerOnsets = {'ᄀ', 'ᄃ', 'ᄉ', 'ᄌ'};
  const likelyEndings = {
    '고',
    '게',
    '기',
    '다',
    '지',
    '자',
    '죠',
    '서',
    '시',
    '소',
  };

  final chars = text.split('');
  final out = StringBuffer();

  for (int i = 0; i < chars.length; i++) {
    final current = chars[i];
    out.write(current);

    if (!_isHangulSyllable(current) || i + 1 >= chars.length) {
      continue;
    }

    final next = chars[i + 1];
    if (!_isHangulSyllable(next) || !likelyEndings.contains(next)) {
      continue;
    }

    final curJamo = h2j(current);
    if (curJamo.length < 3 || !targetFinals.contains(curJamo[2])) {
      continue;
    }

    final nextJamo = h2j(next);
    if (nextJamo.isEmpty || !triggerOnsets.contains(nextJamo[0])) {
      continue;
    }

    out.write('/P');
  }

  return out.toString();
}

bool _isHangulSyllable(String char) {
  if (char.isEmpty) return false;
  final code = char.codeUnitAt(0);
  return code >= 0xAC00 && code <= 0xD7A3;
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

import 'package:g2pkk/g2pkk.dart';

void main() {
  final g2p = G2p();
  
  print('=== Table rules for ᆫ ===\n');
  for (final entry in g2p.table) {
    if (entry.pattern.startsWith('ᆫ')) {
      print('${entry.pattern} -> ${entry.replacement} (${entry.ruleIds})');
    }
  }
  
  print('\n=== Table rules that might match ᆫ followed by anything ===\n');
  for (final entry in g2p.table) {
    if (entry.pattern.contains('ᆫ')) {
      // Check if this would match 'ᆫ' + something
      if (RegExp(entry.pattern).hasMatch('ᆫᄀ') || 
          RegExp(entry.pattern).hasMatch('ᆫ ᄀ') ||
          RegExp(entry.pattern).hasMatch('ᆫ ᄀ')) {
        print('${entry.pattern} -> ${entry.replacement} (${entry.ruleIds})');
      }
    }
  }
  
  print('\n=== Testing rule matching ===\n');
  final testCases = [
    'ᆫᄀ', 'ᆫ ᄀ', 'ᆫᄃ', 'ᆫᄉ', 'ᆫᄌ',
    'ᆬᄀ', 'ᆬ ᄀ', 'ᆱᄀ', 'ᆱ ᄀ'
  ];
  
  for (final testCase in testCases) {
    print('\nTesting: $testCase');
    for (final entry in g2p.table) {
      if (RegExp(entry.pattern).hasMatch(testCase)) {
        final result = testCase.replaceAllMapped(
          RegExp(entry.pattern),
          (match) {
            var res = entry.replacement;
            for (int i = 1; i <= match.groupCount; i++) {
              res = res.replaceAll('\$$i', match.group(i) ?? '');
            }
            return res;
          },
        );
        print('  ${entry.pattern} -> ${entry.replacement} = $result');
      }
    }
  }
}

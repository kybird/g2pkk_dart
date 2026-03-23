import 'package:g2pkk/g2pkk.dart';

void main() {
  final g2p = G2p();
  final inp = '안고';
  
  print("Testing table rule backreference handling:\n");
  print("Input: $inp\n");
  
  // Find the rule for ᆫᄀ
  for (final entry in g2p.table) {
    if (entry.pattern.contains('ᆫ') && entry.pattern.contains('ᄀ') && !entry.pattern.contains('ᆬ')) {
      print("Pattern: ${entry.pattern}");
      print("Replacement: ${entry.replacement}");
      print("Rule IDs: ${entry.ruleIds}\n");
      
      final testInp = 'ᆫ( ?)ᄀ';
      final testReplacement = entry.replacement;
      print("Test pattern: $testInp");
      print("Test replacement: $testReplacement");
      
      // Test with actual match
      final matchInp = 'ᆫᄀ';
      final result = matchInp.replaceAllMapped(
        RegExp(testInp),
        (match) {
          var result = testReplacement;
          for (int i = 1; i <= match.groupCount; i++) {
            result = result.replaceAll('\$$i', match.group(i) ?? '');
          }
          return result;
        },
      );
      print("Result: $result");
      print("Expected: Should be some transformation\n");
    }
  }
}

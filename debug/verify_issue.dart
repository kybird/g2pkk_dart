import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/special.dart';

void main() {
  print('=== VERIFICATION: Why 안고 -> 안꼬 is not firing ===\n');
  
  // 1. Check decomposition
  print('1. DECOMPOSITION:');
  final decomposed = h2jString('안고');
  print('   안고 -> $decomposed');
  print('   Expected pattern for verbNieun: ᆫ/Pᄀ');
  print('   Actual pattern found: ᆫᄀ (no /P marker!)\n');
  
  // 2. Test current pipeline (without /P)
  print('2. CURRENT PIPELINE (without /P):');
  final g2p = G2p();
  final result = g2p.call('안고');
  print('   Output: $result');
  print('   Expected: 안꼬');
  print('   Match: ${result == '안꼬' ? 'YES' : 'NO ❌'}\n');
  
  // 3. Test with manual /P marker
  print('3. WITH MANUAL /P MARKER:');
  final withMarker = g2p.call('안/P고');
  print('   Input: 안/P고');
  print('   Output: $withMarker');
  print('   Expected: 안꼬');
  print('   Issue: Output shows literal backslash-1 instead of backreference ❌\n');
  
  // 4. Test verbNieun rule directly
  print('4. VERB_NIEUN RULE DIRECT TEST:');
  final testJamo = '안/P고';
  print('   Input jamo: $testJamo');
  final afterVerbNieun = verbNieun(testJamo, false, true);
  print('   After verbNieun: $afterVerbNieun');
  print('   Expected: 안꼬');
  print('   Issue: Rule uses backslash-1 backreference, fails in Dart ❌\n');
  
  // 5. Check pipeline code
  print('5. PIPELINE ANALYSIS:');
  print('   File: g2pkk.dart');
  print('   Line 305: // string = annotate(string, mecab);  // COMMENTED OUT!');
  print('   Line 318: inp = inp.replaceAll(RegExp(r\'/[PJEB]\'), \'\');  // Removes markers');
  print('   Result: No /P markers are ever generated\n');
  
  print('=== ROOT CAUSE SUMMARY ===');
  print('PRIMARY ISSUE: No /P annotation marker is generated');
  print('  - The annotate() function (Python: utils.py:165-198) is not implemented');
  print('  - This function uses mecab morphological analyzer to identify verbs');
  print('  - Verbs ending with ㄴ/ㄹ/ㅁ get /P marker before consonants');
  print('  - Without /P, the verbNieun rule pattern never matches\n');
  
  print('SECONDARY ISSUE: Backreference syntax in special.dart');
  print('  - verbNieun uses raw string with backslash-1 (Python style)');
  print('  - Dart needs dollar-1 and replaceAllMapped for backreferences');
  print('  - Current code uses replaceAll which treats backslash-1 literally');
}

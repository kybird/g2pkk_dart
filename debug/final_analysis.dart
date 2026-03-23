import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/jamo.dart';
import 'package:g2pkk/src/special.dart';

void main() {
  print('=== FINAL ANALYSIS: 안고 -> 안꼬 FAILURE ===');
  print('');
  
  final g2p = G2p();
  
  // Show what verbNieun expects
  print('1. WHAT verbNieun EXPECTS:');
  print('   File: lib/src/special.dart');
  print('   Lines: 153-179 (function verbNieun)');
  print('   Pattern: ([ᆫᆷ])/Pᄀ');
  print('   Replacement: r\'\1ᄁ\'');
  print('   This requires: jamo ending with ㄴ/ㅁ, then /P marker, then ㄱ');
  print('');
  
  // Show what actually happens
  print('2. WHAT ACTUALLY HAPPENS:');
  final input = '안고';
  print('   Input: $input');
  final decomposed = h2jString(input);
  print('   Decomposed: $decomposed');
  print('   Pattern present: ᆫᄀ (NO /P marker!)');
  print('   verbNieun can match? NO - missing /P marker');
  print('');
  
  // Show where /P should come from
  print('3. WHERE /P SHOULD COME FROM:');
  print('   Python implementation: g2pkk/utils.py');
  print('   Lines: 165-198 (function annotate)');
  print('   Key code (lines 192-194):');
  print('     elif tag == "V":');
  print('       if h2j(char)[-1] in "ᆫᆬᆷᆱᆰᆲᆴ":');
  print('         annotated += "/P"');
  print('   This adds /P after verbs ending with ㄴ/ㄹ/ㅁ');
  print('');
  
  // Show Dart pipeline
  print('4. DART PIPELINE:');
  print('   File: lib/src/g2pkk.dart');
  print('   Lines: 296-360 (function call)');
  print('   Step 3 (line 305): // string = annotate(string, mecab);');
  print('   ^^ COMMENTED OUT - no morphological analysis!');
  print('   Step 6 (lines 314-316): Apply special rules including verbNieun');
  print('   Line 318: Remove /P markers (but none were generated!)');
  print('');
  
  // Test with manual /P
  print('5. EVEN WITH /P MARKER - SECONDARY BUG:');
  print('   Test: g2p.call(\'안/P고\')');
  final withP = g2p.call('안/P고');
  print('   Result: $withP');
  print('   Expected: 안꼬');
  print('   Issue: verbNieun uses r\'\1ᄁ\' which Dart treats literally');
  print('   Dart replaceAll does NOT support backreferences');
  print('   Should use replaceAllMapped with callback function');
  print('');
  
  // Summary
  print('=== ROOT CAUSE ===');
  print('GATE 1 (MISSING): No /P annotation marker generated');
  print('   - annotate() function not implemented (requires mecab)');
  print('   - Pipeline step 3 commented out in g2pkk.dart:305');
  print('   - verbNieun pattern never matches without /P');
  print('');
  print('GATE 2 (BROKEN): Backreference syntax incorrect');
  print('   - special.dart:159 uses r\'\1ᄁ\' (Python style)');
  print('   - Dart needs replaceAllMapped with group() access');
  print('   - Current code uses replaceAll which fails');
  print('');
  
  print('=== EXPECTED TRANSFORMATION ===');
  print('   껴안고 정열의 키스');
  print('   ↓ (idioms)');
  print('   껴안고 정열의 키스');
  print('   ↓ (annotate with mecab)');
  print('   껴안/P고 정열의 키스  <- /P added because 안 is verb ending');
  print('   ↓ (decompose)');
  print('   껴안/P고 정ᅧᆯ의 키스');
  print('   ↓ (verbNieun: ᆫ/Pᄀ -> ᆫᄁ)');
  print('   껴안꼬 정ᅧᆯ의 키스');
  print('   ↓ (other rules + compose)');
  print('   껴안꼬 정여릐 키스');
  print('');
  print('=== ACTUAL OUTPUT ===');
  print('   껴안고 정여릐 키스  <- /P never generated, verbNieun never fires');
}

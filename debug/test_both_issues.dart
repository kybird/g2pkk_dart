import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/special.dart';
import 'package:g2pkk/src/regular.dart';

void main() {
  print('=== Demonstrating both issues ===\n');
  
  final g2p = G2p();
  
  // Issue 1: Missing annotation stage
  print('ISSUE 1: Missing annotation stage\n');
  print('Without /P marker:');
  final withoutMarker = '안고';
  print('  Input: $withoutMarker');
  print('  After verb_nieun: ${verbNieun(withoutMarker, false, false)}');
  print('  After link rules: ${applyLinkRules(withoutMarker, false, false)}');
  print('  Composed: ${compose(applyLinkRules(withoutMarker, false, false))}');
  print('  Expected: 안꼬\n');
  
  print('With /P marker (manual annotation):');
  final withMarker = '안/P고';
  print('  Input: $withMarker');
  print('  After verb_nieun (CURRENT - broken): ${verbNieun(withMarker, false, false)}');
  print('  After verb_nieun (FIXED - using replaceAllMapped): ${verbNieunFixed(withMarker)}');
  print("  After removing /P: ${verbNieunFixed(withMarker).replaceAll(RegExp(r'/P'), '')}");
  print("  After link rules: ${applyLinkRules(verbNieunFixed(withMarker).replaceAll(RegExp(r'/P'), ''), false, false)}");
  print("  Composed: ${compose(applyLinkRules(verbNieunFixed(withMarker).replaceAll(RegExp(r'/P'), ''), false, false))}");
  print('  Expected: 안꼬\n');
  
  // Issue 2: Broken backreference handling
  print('ISSUE 2: Broken backreference handling in verb_nieun\n');
  print('Current implementation uses replaceAll:');
  final test1 = '안/P고'.replaceAll(RegExp(r'([ᆫᆷ])/Pᄀ'), r'\1ᄁ');
  print("  '안/P고' with r'\\1ᄁ' = $test1");
  print("  Wrong! Should be '안꼬'\n");
  
  print('Fixed implementation uses replaceAllMapped:');
  final test2 = '안/P고'.replaceAllMapped(
    RegExp(r'([ᆫᆷ])/Pᄀ'),
    (m) => '${m.group(1)}ᄁ',
  );
  print("  '안/P고' with replaceAllMapped = $test2");
  print('  Correct!\n');
}

// Fixed version of verbNieun using replaceAllMapped
String verbNieunFixed(String inp) {
  String out = inp;
  
  final pairs = [
    (RegExp(r'([ᆫᆷ])/Pᄀ'), (m) => '${m.group(1)}ᄁ'),
    (RegExp(r'([ᆫᆷ])/Pᄃ'), (m) => '${m.group(1)}ᄄ'),
    (RegExp(r'([ᆫᆷ])/Pᄉ'), (m) => '${m.group(1)}ᄊ'),
    (RegExp(r'([ᆫᆷ])/Pᄌ'), (m) => '${m.group(1)}ᄍ'),
    (RegExp(r'ᆬ/Pᄀ'), (m) => 'ᆫᄁ'),
    (RegExp(r'ᆬ/Pᄃ'), (m) => 'ᆫᄄ'),
    (RegExp(r'ᆬ/Pᄉ'), (m) => 'ᆫᄊ'),
    (RegExp(r'ᆬ/Pᄌ'), (m) => 'ᆫᄍ'),
    (RegExp(r'ᆱ/Pᄀ'), (m) => 'ᆷᄁ'),
    (RegExp(r'ᆱ/Pᄃ'), (m) => 'ᆷᄄ'),
    (RegExp(r'ᆱ/Pᄉ'), (m) => 'ᆷᄊ'),
    (RegExp(r'ᆱ/Pᄌ'), (m) => 'ᆷᄍ'),
  ];
  
  for (final (pattern, replacer) in pairs) {
    out = out.replaceAllMapped(pattern, replacer);
  }
  
  return out;
}

import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/jamo.dart';

void main() {
  // Test 안고 step by step
  print("=== Testing 안고 ===\n");
  
  // Step 1: Decompose
  final inp = h2jString('안고');
  print("Decomposed: $inp");
  print("  Expected: 안고\n");
  
  // Step 2: Check what rules would match
  final g2p = G2p();
  print("Rules that match 'ᆫᄀ':");
  for (final entry in g2p.table) {
    if (entry.pattern.contains('ᆫ')) {
      final hasMatch = RegExp(entry.pattern).hasMatch(inp);
      if (hasMatch) {
        print("  Pattern: ${entry.pattern}");
        print("  Replacement: ${entry.replacement}");
        print("  Rule IDs: ${entry.ruleIds}");
        // Try applying
        final result = inp.replaceAll(RegExp(entry.pattern), entry.replacement);
        print("  Result: $result\n");
      }
    }
  }
  
  // Also test with /P marker
  final inp2 = '안/P고';
  print("\n=== Testing with /P marker ===\n");
  print("Input: $inp2\n");
  
  print("Rules that match 'ᆫ/Pᄀ':");
  for (final entry in g2p.table) {
    if (entry.pattern.contains('ᆫ') && entry.pattern.contains('/P')) {
      final hasMatch = RegExp(entry.pattern).hasMatch(inp2);
      if (hasMatch) {
        print("  Pattern: ${entry.pattern}");
        print("  Replacement: ${entry.replacement}");
        print("  Rule IDs: ${entry.ruleIds}");
      }
    }
  }
  
  // Test verbNieun directly
  print("\n=== Testing verbNieun directly ===\n");
  final verbResult = inp2.replaceAll(RegExp(r'([ᆫᆷ])/Pᄀ'), r'\1ᄁ');
  print("After verbNieun: $verbResult");
  print("  Expected: 안꼬\n");
  
  // Final conversion
  print("\n=== Full conversion ===\n");
  final finalResult = g2p.call('안고');
  print("Full result: $finalResult");
  print("  Expected: 안꼬");
}

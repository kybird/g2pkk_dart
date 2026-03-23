import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/jamo.dart';
import 'package:g2pkk/src/regular.dart';

void main() {
  print("=== Full trace of '없었어' ===\n");
  
  final g2p = G2p();
  final inp = '없얻어'; // h2j('없었어')
  
  print("Step 1: Decomposed: $inp\n");
  
  // Apply special rules (simplified)
  print("Step 2: After special rules (skipped for simplicity)\n");
  
  // Remove annotations
  var current = inp;
  print("Step 3: After removing annotations: $current\n");
  
  // Table rules
  print("Step 4: Table rules");
  for (final entry in g2p.table) {
    final prev = current;
    if (current.contains(RegExp(entry.pattern))) {
      try {
        current = current.replaceAllMapped(
          RegExp(entry.pattern),
          (match) {
            var result = entry.replacement;
            for (int i = 1; i <= match.groupCount; i++) {
              result = result.replaceAll('\$$i', match.group(i) ?? '');
            }
            return result;
          },
        );
        if (prev != current) {
          print("  Applied ${entry.pattern} -> ${entry.replacement}: $prev -> $current");
        }
      } catch (e) {
        // Skip
      }
    }
  }
  print("After table rules: $current\n");
  
  // Link rules
  print("Step 5: Link rules");
  print("Before link1: $current");
  current = link1(current, false, false);
  print("After link1: $current\n");
  
  print("Before link2: $current");
  current = link2(current, false, false);
  print("After link2: $current\n");
  
  print("Before link3: $current");
  current = link3(current, false, false);
  print("After link3: $current\n");
  
  print("Before link4: $current");
  current = link4(current, false, false);
  print("After link4: $current\n");
  
  // Compose
  final composed = compose(current);
  print("Step 6: Composed: $composed");
  print("Expected: 업써써");
}

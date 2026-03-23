import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/utils.dart';
import 'dart:mirrors';

void main() {
  // Use reflection to access private member
  final g2p = G2p();
  final g2pMirror = reflect(g2p);
  final table = g2pMirror.getField(Symbol('table')).reflectee as List<RuleEntry>;
  
  print('Searching for rule with pattern containing ᆹ and ᄋ:');
  for (final entry in table) {
    if (entry.pattern.contains('ᆹ') && entry.pattern.contains('ᄋ')) {
      print('Pattern: ${entry.pattern}');
      print('Replacement: ${entry.replacement}');
      print('Rule IDs: ${entry.ruleIds}');
      print('---');
    }
  }
  
  print('\nAll entries with ᆹ:');
  for (final entry in table) {
    if (entry.pattern.contains('ᆹ')) {
      print('${entry.pattern} -> ${entry.replacement} (${entry.ruleIds.join(", ")})');
    }
  }
}

import 'package:g2pkk/g2pkk.dart';

void main() {
  // Test the table rule issue
  print('Testing ᆹᄋ rule:');
  print('Expected pattern: ᆹᄋ');
  print('Expected replacement: ᆸᄊ');
  
  // Check what the table actually contains
  final g2p = G2p();
  print('\nTable rules for ᆹ:');
  for (final entry in g2p.table) {
    if (entry.pattern.startsWith('ᆹ')) {
      print('  ${entry.pattern} -> ${entry.replacement} (rules: ${entry.ruleIds})');
    }
  }
  
  print('\nTable rules for ᆺ:');
  for (final entry in g2p.table) {
    if (entry.pattern.startsWith('ᆺ')) {
      print('  ${entry.pattern} -> ${entry.replacement} (rules: ${entry.ruleIds})');
    }
  }
  
  print('\nTable rules for ᆻ:');
  for (final entry in g2p.table) {
    if (entry.pattern.startsWith('ᆻ')) {
      print('  ${entry.pattern} -> ${entry.replacement} (rules: ${entry.ruleIds})');
    }
  }
}

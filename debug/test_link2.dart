import 'package:g2pkk/g2pkk.dart';
import 'package:g2pkk/src/regular.dart';

void main() {
  print("Testing link2 rule:");
  final test = 'ᆹᄋ';
  final result = link2(test, false, true);
  print("link2('$test') = '$result'");
  print("Expected: 'ᆸᄊ'");
  
  print("\nAll link2 pairs:");
  for (final (pattern, replacement) in [
    ('ᆪᄋ', 'ᆨᄊ'),
    ('ᆬᄋ', 'ᆫᄌ'),
    ('ᆰᄋ', 'ᆯᄀ'),
    ('ᆱᄋ', 'ᆯᄆ'),
    ('ᆲᄋ', 'ᆯᄇ'),
    ('ᆳᄋ', 'ᆯᄊ'),
    ('ᆴᄋ', 'ᆯᄐ'),
    ('ᆵᄋ', 'ᆯᄑ'),
    ('ᆹᄋ', 'ᆸᄊ'),
  ]) {
    print("  $pattern -> $replacement");
  }
}

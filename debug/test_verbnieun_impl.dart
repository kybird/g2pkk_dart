import 'package:g2pkk/g2pkk.dart';

void main() {
  print('=== Testing current verbNieun implementation ===\n');
  
  final g2p = G2p();
  
  // Test the special rules pipeline
  final inp = '안/P고';
  print('Input: $inp\n');
  
  // Apply special rules one by one
  print('Applying special rules in sequence:');
  String current = inp;
  
  // Test verbNieun specifically
  print('\nBefore verbNieun: $current');
  current = verbNieunTest(current, false, false);
  print('After verbNieun: $current');
  print('Expected: 안꼬');
}

// Copy of verbNieun from special.dart for testing
String verbNieunTest(String inp, bool descriptive, bool verbose) {
  String out = inp;

  final pairs = [
    (RegExp(r'([ᆫᆷ])/Pᄀ'), r'\1ᄁ'),
    (RegExp(r'([ᆫᆷ])/Pᄃ'), r'\1ᄄ'),
    (RegExp(r'([ᆫᆷ])/Pᄉ'), r'\1ᄊ'),
    (RegExp(r'([ᆫᆷ])/Pᄌ'), r'\1ᄍ'),
    (RegExp(r'ᆬ/Pᄀ'), 'ᆫᄁ'),
    (RegExp(r'ᆬ/Pᄃ'), 'ᆫᄄ'),
    (RegExp(r'ᆬ/Pᄉ'), 'ᆫᄊ'),
    (RegExp(r'ᆬ/Pᄌ'), 'ᆫᄍ'),
    (RegExp(r'ᆱ/Pᄀ'), 'ᆷᄁ'),
    (RegExp(r'ᆱ/Pᄃ'), 'ᆷᄄ'),
    (RegExp(r'ᆱ/Pᄉ'), 'ᆷᄊ'),
    (RegExp(r'ᆱ/Pᄌ'), 'ᆷᄍ'),
  ];

  for (final (pattern, replacement) in pairs) {
    out = out.replaceAll(pattern, replacement);
  }

  return out;
}

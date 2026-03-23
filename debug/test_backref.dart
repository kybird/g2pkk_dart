void main() {
  // Test Dart's replaceAll backreference behavior
  final text = 'hello world';
  final pattern = RegExp(r'(hello) (world)');
  
  print('Testing replaceAll with dollar syntax:');
  final result1 = text.replaceAll(pattern, r'$2 $1');
  print('  Input: $text');
  print('  Pattern: (hello) (world)');
  print('  Replacement: \$2 \$1');
  print('  Result: $result1');
  print('  Expected: world hello');
  
  print('\nTesting replaceAll with backslash syntax:');
  final result2 = text.replaceAll(pattern, r'\2 \1');
  print('  Replacement: \2 \1');
  print('  Result: $result2');
  print('  Expected: literal backslash-2 backslash-1');
}

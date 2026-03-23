void main() {
  // Test Dart's replaceAllMapped backreference behavior
  final text = 'hello world';
  final pattern = RegExp(r'(hello) (world)');
  
  print('Testing replaceAllMapped:');
  final result = text.replaceAllMapped(pattern, (match) {
    return '${match.group(2)!} ${match.group(1)!}';
  });
  print('  Input: $text');
  print('  Pattern: (hello) (world)');
  print('  Replacement: group(2) + " " + group(1)');
  print('  Result: $result');
  print('  Expected: world hello');
  
  // Test if replaceAll supports $ in replacement
  print('\nTesting replaceAll with \$ in non-raw string:');
  final result2 = text.replaceAll(pattern, '\$2 \$1');
  print('  Replacement (non-raw): \$2 \$1');
  print('  Result: $result2');
}

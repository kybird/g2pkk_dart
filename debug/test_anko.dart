import 'package:g2pkk/g2pkk.dart';

void main() {
  final g2p = G2p();
  
  print('=== Testing 안고 transformation ===\n');
  
  // Test decomposed form
  final decomposed = h2jString('안고');
  print('안고 decomposed: $decomposed');
  
  // Test with verbose
  print('\n--- Verbose output for 안고 ---');
  g2p.call('안고', verbose: true);
  
  print('\n--- Verbose output for 껴안고 정열의 키스 ---');
  g2p.call('껴안고 정열의 키스', verbose: true);
  
  // Test what happens with /P marker
  print('\n--- Testing with manual /P marker ---');
  print('안/P고: ${g2p.call('안/P고')}');
}

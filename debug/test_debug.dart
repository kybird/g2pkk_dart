import 'package:g2pkk/g2pkk.dart';

void main() {
  final g2p = G2p();
  print("Testing '없었어':");
  final result = g2p.call('없었어', verbose: true);
  print('\nFinal result: $result');
  print('\nExpected: 업써써');
}

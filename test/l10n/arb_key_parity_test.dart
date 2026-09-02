import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('locale ARB files stay in key parity with app_en.arb', () {
    final result = Process.runSync(
      'python3',
      ['scripts/check_arb_key_parity.py'],
      runInShell: true,
    );
    expect(
      result.exitCode,
      0,
      reason: String.fromCharCodes(result.stderr + result.stdout),
    );
  });
}

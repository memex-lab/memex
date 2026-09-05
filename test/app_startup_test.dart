import 'package:flutter_test/flutter_test.dart';
import 'package:memex/app_startup.dart';

void main() {
  test('runs independent startup work concurrently', () async {
    final started = <String>[];
    final finished = <String>[];

    Future<void> slow(String name) async {
      started.add(name);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      finished.add(name);
    }

    final startedAt = DateTime.now();
    await initializeIndependentStartupServices(
      initL10n: () => slow('l10n'),
      initWorkmanager: () => slow('workmanager'),
      initAgentBridge: () => slow('bridge'),
      startLocalServer: () => slow('server'),
    );
    final elapsed = DateTime.now().difference(startedAt);

    expect(started, hasLength(4));
    expect(finished.toSet(), {'l10n', 'workmanager', 'bridge', 'server'});
    expect(elapsed.inMilliseconds, lessThan(120));
  });
}

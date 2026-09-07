import 'package:flutter_test/flutter_test.dart';
import 'package:memex/app_startup.dart';

void main() {
  test(
    'initializes l10n before running native startup work concurrently',
    () async {
      final started = <String>[];
      final finished = <String>[];
      var l10nReady = false;

      Future<void> slow(String name) async {
        started.add(name);
        await Future<void>.delayed(const Duration(milliseconds: 40));
        finished.add(name);
      }

      final startedAt = DateTime.now();
      Future<void> afterL10n(String name) async {
        expect(l10nReady, isTrue);
        await slow(name);
      }

      await initializeStartupServices(
        initL10n: () async {
          await slow('l10n');
          l10nReady = true;
        },
        initWorkmanager: () => afterL10n('workmanager'),
        initAgentBridge: () => afterL10n('bridge'),
        startLocalServer: () => afterL10n('server'),
      );
      final elapsed = DateTime.now().difference(startedAt);

      expect(started.first, 'l10n');
      expect(started, hasLength(4));
      expect(finished.toSet(), {'l10n', 'workmanager', 'bridge', 'server'});
      expect(elapsed.inMilliseconds, lessThan(120));
    },
  );
}

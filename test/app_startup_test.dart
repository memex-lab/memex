import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/app_startup.dart';

void main() {
  test('localization finishes before all three independent services start',
      () async {
    final localized = Completer<void>();
    final releaseWorkers = Completer<void>();
    final allStarted = Completer<void>();
    final started = <String>[];
    Future<void> worker(String name) async {
      started.add(name);
      if (started.length == 3) allStarted.complete();
      await releaseWorkers.future;
    }

    final startup = initializeStartupServices(
      initL10n: () => localized.future,
      initWorkmanager: () => worker('workmanager'),
      initAgentBridge: () => worker('bridge'),
      startLocalServer: () => worker('server'),
    );
    expect(started, isEmpty);
    localized.complete();
    await allStarted.future;
    expect(started, unorderedEquals(['workmanager', 'bridge', 'server']));
    releaseWorkers.complete();
    await startup;
  });
}

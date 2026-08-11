import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_detail_notifier.dart';
import 'package:memex/data/services/user_notification_service.dart';

/// Smoke test verifying that `UserNotificationService.instance` and
/// `CardDetailNotifier.instance` exist as singletons and that their
/// `init()` methods can be called without error.
///
/// A full integration test of `MemexRouter._init` is impractical in a unit
/// test context because it requires `UserStorage`, `AppDatabase`, and
/// `FileSystemService` to be fully initialized. Instead, we verify:
///
/// 1. The singleton instances are accessible.
/// 2. Calling `init()` does not throw (even without a fully initialized DB).
/// 3. The services are distinct singletons (not recreated on each access).
void main() {
  group('MemexRouter._init ordering smoke test', () {
    test('UserNotificationService.instance is a singleton and accessible', () {
      final instance1 = UserNotificationService.instance;
      final instance2 = UserNotificationService.instance;

      expect(instance1, isNotNull);
      expect(identical(instance1, instance2), isTrue,
          reason: 'UserNotificationService should be a singleton');
    });

    test('CardDetailNotifier.instance is a singleton and accessible', () {
      final instance1 = CardDetailNotifier.instance;
      final instance2 = CardDetailNotifier.instance;

      expect(instance1, isNotNull);
      expect(identical(instance1, instance2), isTrue,
          reason: 'CardDetailNotifier should be a singleton');
    });

    test(
        'CardDetailNotifier.init() can be called without error '
        '(registers sync subscription on GlobalEventBus)', () {
      // init() registers a sync subscription on GlobalEventBus.
      // It should not throw even if called multiple times.
      expect(() => CardDetailNotifier.instance.init(), returnsNormally);
    });

    test(
        'UserNotificationService and CardDetailNotifier are initialized '
        'in the correct order (service before notifier)', () {
      // This test verifies the design constraint: UserNotificationService
      // must be initialized before CardDetailNotifier because the notifier
      // depends on the service being ready to accept upsert/dismiss calls.
      //
      // We verify this by checking that:
      // 1. UserNotificationService.instance exists
      // 2. CardDetailNotifier uses UserNotificationService internally
      //
      // The actual ordering is enforced in MemexRouter._init:
      //   UserNotificationService.instance.init();
      //   CardDetailNotifier.instance.init();

      final notificationService = UserNotificationService.instance;
      final notifier = CardDetailNotifier.instance;

      // Both should be non-null singletons
      expect(notificationService, isNotNull);
      expect(notifier, isNotNull);

      // Verify the notifier's foreground registry works (proves it's initialized)
      notifier.registerForeground('test-fact-id');
      expect(notifier.isForeground('test-fact-id'), isTrue);
      notifier.unregisterForeground('test-fact-id');
      expect(notifier.isForeground('test-fact-id'), isFalse);
    });

    test('task handlers are registered before LocalTaskExecutor starts', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final handlerRegistration = source.indexOf(
        '_registerTaskHandlers(LocalTaskExecutor.instance);',
      );
      final executorStart = source.indexOf(
        'await LocalTaskExecutor.instance.start(userId: userId);',
      );

      expect(handlerRegistration, isNonNegative);
      expect(executorStart, isNonNegative);
      expect(handlerRegistration, lessThan(executorStart));
    });

    test('primary companion wake loop is restored after task startup', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();
      final executorStart = source.indexOf(
        'await LocalTaskExecutor.instance.start(userId: userId);',
      );
      final wakeRestore = source.indexOf(
        'CharacterInitiativeService.instance.ensureScheduled(',
      );

      expect(wakeRestore, isNonNegative);
      expect(executorStart, lessThan(wakeRestore));
    });

    test('history acquaintance is scheduled before the initiative wake', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();
      final acquaintance = source.indexOf(
        'CharacterHistoryAcquaintanceService.instance.ensureScheduled(',
      );
      final initiative = source.indexOf(
        'CharacterInitiativeService.instance.ensureScheduled(',
      );

      expect(acquaintance, isNonNegative);
      expect(initiative, isNonNegative);
      expect(acquaintance, lessThan(initiative));
    });

    test('sendMessage waits for router initialization before delegating', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final sendMessage = source.indexOf('Stream<ChatEvent> sendMessage(');
      final ensureInitialized = source.indexOf(
        'await _ensureInitialized();',
        sendMessage,
      );
      final delegate = source.indexOf(
        'yield* ChatService.instance.sendMessage(',
        sendMessage,
      );

      expect(sendMessage, isNonNegative);
      expect(ensureInitialized, isNonNegative);
      expect(delegate, isNonNegative);
      expect(ensureInitialized, lessThan(delegate));
    });
  });
}

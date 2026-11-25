import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/card_detail_notifier.dart';

void main() {
  group('MemexRouter._init ordering smoke test', () {
    test(
        'CardDetailNotifier.init() can be called without error '
        '(registers sync subscription on GlobalEventBus)', () {
      // init() registers a sync subscription on GlobalEventBus.
      // It should not throw even if called multiple times.
      expect(() => CardDetailNotifier.instance.init(), returnsNormally);
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

    test('sendMessage waits for full router initialization before delegating',
        () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final sendMessage = source.indexOf('Stream<ChatEvent> sendMessage(');
      final ensureInitialized = source.indexOf(
        'await _ensureFullyInitialized();',
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

    test('timeline init completes core before awaiting deferred work', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final initCore = source.indexOf('Future<String?> _initCore() async {');
      final completeCore = source.indexOf('coreCompleter.complete();');
      final awaitDeferred = source.indexOf('await _initDeferred(');
      final customAgents = source.indexOf(
        'await CustomAgentConfigService.instance.registerAll(userId);',
      );
      final migrate = source.indexOf('await migrateCardsToFactAssets(userId);');

      expect(initCore, isNonNegative);
      expect(completeCore, isNonNegative);
      expect(awaitDeferred, isNonNegative);
      expect(completeCore, lessThan(awaitDeferred));
      expect(migrate, greaterThan(initCore));
      expect(customAgents, greaterThan(awaitDeferred));
    });

    test('user changes serialize and invalidate deferred initialization', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      expect(source, contains('await previousLifecycle;'));
      expect(source, contains('generation != _initGeneration'));
      expect(source, contains('_initGeneration += 1;'));
      expect(
        source,
        contains(
          "_logger.severe('Failed deferred MemexRouter init: \$e');\n      rethrow;",
        ),
      );
    });

    test('fetchTimelineCards waits only for core initialization', () {
      final source =
          File('lib/data/repositories/memex_router.dart').readAsStringSync();

      final fetch = source.indexOf(
        'Future<Result<List<TimelineCardModel>>> fetchTimelineCards(',
      );
      final ensureCore = source.indexOf(
        'await _ensureInitialized();',
        fetch,
      );
      final ensureFull = source.indexOf(
        'await _ensureFullyInitialized();',
        fetch,
      );
      final nextMethod = source.indexOf(
        'Future<Result<Map<String, dynamic>>> fetchAggregatedTimeline(',
        fetch,
      );

      expect(fetch, isNonNegative);
      expect(ensureCore, isNonNegative);
      expect(ensureCore, lessThan(nextMethod));
      expect(ensureFull == -1 || ensureFull > nextMethod, isTrue);
    });
  });
}

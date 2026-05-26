import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/retry_failed_cards.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'retry_failed_cards_user';
  const userInputObserver = 'retry_failed_cards_user_input_observer';
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(userId);
    tempDir = await Directory.systemTemp.createTemp('memex_retry_cards_');
    await FileSystemService.init(tempDir.path);
    EventBusService.instance.clearHandlers();
    await EventBusService.instance.disconnect();
    _unsubscribeDefaultUserInputTasks();
    GlobalEventBus.instance.unsubscribeSync(
      eventType: SystemEventTypes.userInputSubmitted,
      subscriptionId: userInputObserver,
    );
  });

  tearDown(() async {
    _unsubscribeDefaultUserInputTasks();
    GlobalEventBus.instance.unsubscribeSync(
      eventType: SystemEventTypes.userInputSubmitted,
      subscriptionId: userInputObserver,
    );
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'retryFailedCardGeneration restores status and republishes pipeline',
    () async {
      const factId = '2026/05/25.md#ts_1';
      SystemEvent<UserInputSubmittedPayload>? observedEvent;

      await _writeFactAndCard(
        factId: factId,
        time: DateTime(2026, 5, 25, 9, 30),
        content: '今天想把失败的卡片恢复一下\n\n![image](fs://photo.jpg)',
        status: 'failed',
        failureReason: 'LLM timeout',
      );

      GlobalEventBus.instance.subscribeSync<UserInputSubmittedPayload>(
        eventType: SystemEventTypes.userInputSubmitted,
        subscription: EventSyncSubscription<UserInputSubmittedPayload>(
          subscriptionId: userInputObserver,
          handler: (_, event) async {
            observedEvent = event;
          },
        ),
      );

      final didRetry = await retryFailedCardGeneration(factId);

      expect(didRetry, isTrue);

      final card = await FileSystemService.instance.readCardFile(
        userId,
        factId,
      );
      expect(card, isNotNull);
      expect(card!.status, 'processing');
      expect(card.failureReason, isNull);

      expect(observedEvent, isNotNull);
      final payload = observedEvent!.payload;
      expect(payload.factId, factId);
      expect(payload.combinedText, contains('失败的卡片'));
      expect(payload.markdownEntry, contains('## <id:ts_1> 09:30:00 "{}"'));
      expect(
        payload.assetPaths.single,
        endsWith('Facts/assets/photo.jpg'),
      );
      expect(
        payload.createdAtTs,
        DateTime(2026, 5, 25, 9, 30).millisecondsSinceEpoch ~/ 1000,
      );
    },
  );

  test('retryAllFailedCardGenerations retries only failed cards', () async {
    const failedOne = '2026/05/25.md#ts_1';
    const completed = '2026/05/25.md#ts_2';
    const failedTwo = '2026/05/25.md#ts_3';
    final observedFactIds = <String>[];

    await _writeFactAndCard(
      factId: failedOne,
      time: DateTime(2026, 5, 25, 10),
      content: '第一张失败卡片',
      status: 'failed',
      failureReason: 'Server error',
    );
    await _writeFactAndCard(
      factId: completed,
      time: DateTime(2026, 5, 25, 11),
      content: '已完成卡片',
      status: 'completed',
    );
    await _writeFactAndCard(
      factId: failedTwo,
      time: DateTime(2026, 5, 25, 12),
      content: '第二张失败卡片',
      status: 'failed',
      failureReason: 'Network error',
    );

    expect(await countFailedCardGenerations(), 2);

    GlobalEventBus.instance.subscribeSync<UserInputSubmittedPayload>(
      eventType: SystemEventTypes.userInputSubmitted,
      subscription: EventSyncSubscription<UserInputSubmittedPayload>(
        subscriptionId: userInputObserver,
        handler: (_, event) async {
          observedFactIds.add(event.payload.factId);
        },
      ),
    );

    final result = await retryAllFailedCardGenerations();

    expect(result.requested, 2);
    expect(result.retried, 2);
    expect(result.skipped, 0);
    expect(result.errors, isEmpty);
    expect(observedFactIds, unorderedEquals([failedOne, failedTwo]));
    expect(await countFailedCardGenerations(), 0);

    final completedCard = await FileSystemService.instance.readCardFile(
      userId,
      completed,
    );
    expect(completedCard!.status, 'completed');
  });
}

Future<void> _writeFactAndCard({
  required String factId,
  required DateTime time,
  required String content,
  required String status,
  String? failureReason,
}) async {
  final fs = FileSystemService.instance;
  final simpleFactId = fs.extractSimpleFactId(factId);
  final timeStr =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  await fs.appendToDailyFactFile(
    'retry_failed_cards_user',
    time,
    '## <id:$simpleFactId> $timeStr "{}"\n\n$content\n',
  );
  await fs.safeWriteCardFile(
    'retry_failed_cards_user',
    factId,
    CardData(
      factId: factId,
      timestamp: time.millisecondsSinceEpoch ~/ 1000,
      status: status,
      tags: const [],
      uiConfigs: [
        UiConfig(templateId: 'classic_card', data: {'content': content}),
      ],
      failureReason: failureReason,
    ),
  );
}

void _unsubscribeDefaultUserInputTasks() {
  for (final id in const [
    'analyze_assets',
    'card_agent',
    'pkm_agent',
    'comment_agent',
    'schedule_refresh_router',
  ]) {
    GlobalEventBus.instance.unsubscribe(
      eventType: SystemEventTypes.userInputSubmitted,
      subscriptionId: id,
    );
  }
}

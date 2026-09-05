import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/timeline_card_event_publisher.dart';
import 'package:memex/domain/models/card_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'timeline_event_user';
  const cardId = '2026/06/20.md#ts_1';
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_timeline_event_');
    await FileSystemService.init(tempDir.path);
    EventBusService.instance.clearHandlers();
    await EventBusService.instance.connect();
  });

  tearDown(() async {
    EventBusService.instance.clearHandlers();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('emits a processing placeholder without rendering templates', () async {
    final messages = <EventBusMessage>[];
    EventBusService.instance.addHandler(
      EventBusMessageType.cardAdded,
      messages.add,
    );

    await emitTimelineCardAdded(
      userId: userId,
      cardId: cardId,
      cardData: const CardData(
        factId: cardId,
        timestamp: 1781971200,
        status: 'processing',
        tags: [],
        title: null,
        fact: 'Just captured.',
        uiConfigs: [
          UiConfig(templateId: 'classic_card', data: {'content': ''}),
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(messages, hasLength(1));
    final message = messages.single as CardAddedMessage;
    expect(message.status, 'processing');
    expect(message.html, isEmpty);
    expect(message.uiConfigs.single.templateId, 'classic_card');
    expect(message.rawText, 'Just captured.');
  });

  test('emits card added with rendered card fields', () async {
    final messages = <EventBusMessage>[];
    EventBusService.instance.addHandler(
      EventBusMessageType.cardAdded,
      messages.add,
    );

    await emitTimelineCardAdded(
      userId: userId,
      cardId: cardId,
      cardData: const CardData(
        factId: cardId,
        timestamp: 1781971200,
        status: 'completed',
        tags: ['Knowledge'],
        title: 'Finished card',
        fact: 'The agent finished the record.',
        uiConfigs: [
          UiConfig(
            templateId: 'article',
            data: {'body': 'The agent finished the record.'},
          ),
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(messages, hasLength(1));
    expect(messages.single, isA<CardAddedMessage>());
    final message = messages.single as CardAddedMessage;
    expect(message.id, cardId);
    expect(message.status, 'completed');
    expect(message.title, 'Finished card');
    expect(message.rawText, 'The agent finished the record.');
    expect(message.tags, ['Knowledge']);
    expect(message.uiConfigs.single.templateId, 'article');
  });

  test('emits card updated with failure reason', () async {
    final messages = <EventBusMessage>[];
    EventBusService.instance.addHandler(
      EventBusMessageType.cardUpdated,
      messages.add,
    );

    await emitTimelineCardUpdated(
      userId: userId,
      cardId: cardId,
      cardData: const CardData(
        factId: cardId,
        timestamp: 1781971200,
        status: 'failed',
        tags: ['Error'],
        title: 'Failed card',
        fact: 'Original text.',
        failureReason: 'tool failed',
        uiConfigs: [],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(messages, hasLength(1));
    expect(messages.single, isA<CardUpdatedMessage>());
    final message = messages.single as CardUpdatedMessage;
    expect(message.id, cardId);
    expect(message.status, 'failed');
    expect(message.title, 'Failed card');
    expect(message.rawText, 'Original text.');
    expect(message.failureReason, 'tool failed');
  });
}

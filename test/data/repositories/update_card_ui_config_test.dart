import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/update_card_ui_config.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'test_user';
  const cardId = '2026/04/28.md#ts_1';
  const subscriptionId = 'test_card_ui_config_updated_listener';
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.saveUser(userId);
    await UserStorage.setLocale(const Locale('en'));
    tempDir = await Directory.systemTemp.createTemp('memex_update_config_');
    await FileSystemService.init(tempDir.path);
    GlobalEventBus.instance.unsubscribeSync(
      eventType: SystemEventTypes.cardUiConfigUpdated,
      subscriptionId: subscriptionId,
    );
  });

  tearDown(() async {
    GlobalEventBus.instance.unsubscribeSync(
      eventType: SystemEventTypes.cardUiConfigUpdated,
      subscriptionId: subscriptionId,
    );
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('publishes card UI config update event after writing task data',
      () async {
    await FileSystemService.instance.safeWriteCardFile(
      userId,
      cardId,
      const CardData(
        factId: cardId,
        timestamp: 1777332000,
        status: 'completed',
        tags: [],
        uiConfigs: [
          UiConfig(
            templateId: 'task',
            data: {'title': 'Clean home', 'is_completed': false},
          ),
        ],
      ),
    );

    CardUiConfigUpdatedPayload? observedPayload;
    GlobalEventBus.instance.subscribeSync<CardUiConfigUpdatedPayload>(
      eventType: SystemEventTypes.cardUiConfigUpdated,
      subscription: EventSyncSubscription<CardUiConfigUpdatedPayload>(
        subscriptionId: subscriptionId,
        handler: (_, event) async {
          observedPayload = event.payload;
        },
      ),
    );

    final success = await updateCardUiConfigEndpoint(
      cardId,
      0,
      const {'is_completed': true},
    );

    expect(success, isTrue);
    expect(observedPayload, isNotNull);
    expect(observedPayload!.cardId, cardId);
    expect(observedPayload!.templateId, 'task');
    expect(observedPayload!.updates['is_completed'], isTrue);
    expect(observedPayload!.previousData['is_completed'], isFalse);
    expect(observedPayload!.updatedData['is_completed'], isTrue);

    final card = await FileSystemService.instance.readCardFile(userId, cardId);
    expect(card!.uiConfigs.single.data['is_completed'], isTrue);
  });
}

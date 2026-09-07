import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/hydrate_card.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/hydrated_card_cache.dart';
import 'package:memex/domain/models/card_model.dart';

const userId = 'hydrate_cache_user';
const factId = '2026/06/20.md#ts_1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('memex_hydrate_cache_');
    await FileSystemService.init(tempDir.path);
    HydratedCardCache.instance.clear();
  });

  tearDown(() async {
    HydratedCardCache.instance.clear();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('reuses the same hydrated card when YAML has not changed', () async {
    await FileSystemService.instance.safeWriteCardFile(
      userId,
      factId,
      const CardData(
        factId: factId,
        timestamp: 1781971200,
        status: 'completed',
        tags: ['Knowledge'],
        title: 'Cached card',
        fact: 'Unchanged body.',
        uiConfigs: [
          UiConfig(templateId: 'article', data: {'body': 'Unchanged body.'}),
        ],
      ),
    );

    final first = await hydrateCard(userId, factId);
    final second = await hydrateCard(userId, factId);

    expect(first, isNotNull);
    expect(identical(first, second), isTrue);
    expect(HydratedCardCache.instance.length, 1);
  });

  test('misses the cache after the card YAML changes', () async {
    await FileSystemService.instance.safeWriteCardFile(
      userId,
      factId,
      const CardData(
        factId: factId,
        timestamp: 1781971200,
        status: 'completed',
        tags: ['Knowledge'],
        title: 'Before',
        fact: 'First version.',
        uiConfigs: [
          UiConfig(templateId: 'article', data: {'body': 'First version.'}),
        ],
      ),
    );
    final first = await hydrateCard(userId, factId);

    await FileSystemService.instance.safeWriteCardFile(
      userId,
      factId,
      const CardData(
        factId: factId,
        timestamp: 1781971200,
        status: 'completed',
        tags: ['Knowledge'],
        title: 'After',
        fact: 'Second version.',
        uiConfigs: [
          UiConfig(templateId: 'article', data: {'body': 'Second version.'}),
        ],
      ),
    );
    final second = await hydrateCard(userId, factId);

    expect(first?.title, 'Before');
    expect(second?.title, 'After');
    expect(identical(first, second), isFalse);
  });

  test(
    'does not reuse hydrated cards across users with matching YAML',
    () async {
      const secondUserId = 'hydrate_cache_other_user';
      const cardData = CardData(
        factId: factId,
        timestamp: 1781971200,
        status: 'completed',
        tags: ['Knowledge'],
        title: 'Shared card',
        fact: 'Same YAML.',
        uiConfigs: [
          UiConfig(templateId: 'article', data: {'body': 'Same YAML.'}),
        ],
      );
      await FileSystemService.instance.safeWriteCardFile(
        userId,
        factId,
        cardData,
      );
      await FileSystemService.instance.safeWriteCardFile(
        secondUserId,
        factId,
        cardData,
      );

      final first = await hydrateCard(userId, factId);
      final second = await hydrateCard(secondUserId, factId);

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(identical(first, second), isFalse);
      expect(HydratedCardCache.instance.length, 2);
    },
  );

  test('clearUser invalidates only the selected workspace', () async {
    const secondUserId = 'hydrate_cache_other_user';
    final card = await _seedAndHydrate(userId);
    final second = await _seedAndHydrate(secondUserId);

    HydratedCardCache.instance.clearUser(userId);

    expect(HydratedCardCache.instance.length, 1);
    expect(
      HydratedCardCache.instance.get(
        secondUserId,
        factId,
        hydratedCardContentHash(_cardData),
      ),
      same(second),
    );
    expect(card, isNotNull);
  });
}

const _cardData = CardData(
  factId: factId,
  timestamp: 1781971200,
  status: 'completed',
  tags: ['Knowledge'],
  title: 'Cached card',
  fact: 'Unchanged body.',
  uiConfigs: [
    UiConfig(templateId: 'article', data: {'body': 'Unchanged body.'}),
  ],
);

Future<Object?> _seedAndHydrate(String userId) async {
  await FileSystemService.instance.safeWriteCardFile(userId, factId, _cardData);
  return hydrateCard(userId, factId);
}

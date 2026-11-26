import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/data/repositories/get_timeline_cards.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final seed in [7, 31, 71]) {
    test('Timeline pages match surviving entries after rebuild (seed $seed)',
        () async {
      const user = 'pagination-reader';
      final random = Random(seed);
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      await UserStorage.saveUser(user);
      final temp = await Directory.systemTemp.createTemp('memex-pages');
      addTearDown(() => temp.delete(recursive: true));
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      addTearDown(db.close);
      await FileSystemService.init(temp.path);
      final files = FileSystemService.instance;
      final expected = <String, CardData>{};
      // Generate ties, edits to existing cards, changes of tag and a deletion.
      for (final slot in [
        ...List.generate(12, (i) => i),
        ...List.generate(8, (_) => random.nextInt(12))
      ]) {
        final id = '2026/11/25.md#ts_${slot + 1}';
        final card = CardData(
            factId: id,
            timestamp: 1795564800 + random.nextInt(4),
            tags: [random.nextBool() ? 'work' : 'home'],
            fact: 'Entry $slot version ${random.nextInt(10000)}',
            status: 'completed',
            uiConfigs: []);
        expect(await files.safeWriteCardFile(user, id, card), isTrue);
        expected[id] = card;
      }
      final deleted = expected.keys.elementAt(random.nextInt(expected.length));
      expect(await deleteCardEndpoint(deleted), isTrue);
      expected.remove(deleted);
      Future<void> checkPages() async {
        for (final tag in [null, 'work', 'home']) {
          final records = expected.values
              .where((c) => tag == null || c.tags.contains(tag))
              .toList()
            ..sort((a, b) {
              final byTime = b.timestamp.compareTo(a.timestamp);
              return byTime != 0 ? byTime : b.factId.compareTo(a.factId);
            });
          final ids = <String>[];
          for (var page = 1; page <= (records.length / 3).ceil() + 1; page++) {
            final batch = await getTimelineCards(
                page: page, limit: 3, tags: tag == null ? null : [tag]);
            for (final card in batch) {
              ids.add(card.id);
              expect(card.rawText, expected[card.id]?.fact);
            }
          }
          expect(ids, records.map((c) => c.factId),
              reason: 'filter=$tag, seed=$seed');
        }
      }

      await checkPages();
      await files.rebuildCardCache(user);
      await checkPages();
    });
  }
}

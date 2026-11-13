import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/db/app_database.dart';

void main() {
  test('pending FTS rebuild survives clearing the in-memory flag', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      await db.customSelect('SELECT 1').get();
      await db.markFtsRebuildPending();
      db.clearFtsRebuildFlag();

      expect(db.needsFtsRebuild, isFalse);
      expect(await db.readFtsRebuildPending(), isTrue);

      await db.clearPersistedFtsRebuildFlag();
      expect(await db.readFtsRebuildPending(), isFalse);
    } finally {
      await db.close();
    }
  });
}

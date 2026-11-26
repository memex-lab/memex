import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memex/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  group('AppDatabase connection options', () {
    test('requests shared connections for native isolates', () {
      expect(AppDatabase.nativeOptionsForTesting.shareAcrossIsolates, isTrue);
    });

    test(
      'configures WAL and busy timeout on native SQLite connections',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('memex_db_test_');
        final dbFile = File('${tempDir.path}/connection.sqlite');
        final database = sqlite.sqlite3.open(dbFile.path);

        try {
          AppDatabase.nativeOptionsForTesting.setup!(database);

          final journalMode = database
              .select('PRAGMA journal_mode;')
              .first
              .values
              .single
              .toString()
              .toLowerCase();
          final busyTimeout =
              database.select('PRAGMA busy_timeout;').first.values.single
                  as int;

          expect(journalMode, 'wal');
          expect(busyTimeout, 5000);
        } finally {
          database.close();
          await tempDir.delete(recursive: true);
        }
      },
    );
  });
}

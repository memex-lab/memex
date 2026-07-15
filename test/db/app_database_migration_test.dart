import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/persona_chat_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  group('AppDatabase migrations', () {
    test('upgrades schema 14 to 19 with a reply cursor baseline', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_app_database_migration_',
      );
      final dbFile = File('${tempDir.path}/memex.sqlite');
      _createSchema14Database(dbFile);

      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      try {
        final schemaVersion = await _userVersion(db);
        expect(schemaVersion, 19);

        final taskColumns = await _columnNames(db, 'tasks');
        expect(taskColumns, contains('run_id'));

        final legacyTask = await (db.select(db.tasks)
              ..where((task) => task.id.equals('legacy-task')))
            .getSingle();
        expect(legacyTask.runId, isNull);

        final taskIndices = await _indexNames(db, 'tasks');
        expect(taskIndices, contains('idx_tasks_run_id'));

        final tables = await _tableNames(db);
        expect(tables, isNot(contains('agent_runs')));

        final chatColumns = await _columnNames(db, 'persona_chat_messages');
        expect(
          chatColumns,
          containsAll(['origin', 'contact_episode_id']),
        );
        expect(chatColumns, isNot(contains('handled_by_episode_id')));

        final chatIndices = await _indexNames(db, 'persona_chat_messages');
        expect(chatIndices, contains('idx_persona_chat_episode'));
        expect(chatIndices, isNot(contains('idx_persona_chat_unhandled')));

        final cursor = await db.select(db.personaChatReplyCursors).getSingle();
        expect(cursor.characterId, 'legacy-character');
        expect(cursor.consumedThroughMessageId, 1);
      } finally {
        await db.close();
        await tempDir.delete(recursive: true);
      }
    });

    test('upgrades schema 18 without consuming its pending user message',
        () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'memex_app_database_v18_migration_',
      );
      final dbFile = File('${tempDir.path}/memex.sqlite');
      _createSchema18Database(dbFile);

      final db = AppDatabase.forTesting(NativeDatabase(dbFile));
      try {
        expect(await _userVersion(db), 19);
        final cursor = await db.select(db.personaChatReplyCursors).getSingle();
        expect(cursor.consumedThroughMessageId, 2);

        final pending = await PersonaChatService.forTesting(db)
            .getPendingUserMessages('legacy-character');
        expect(pending.map((message) => message.content), [
          'pending user message',
        ]);

        final oldMarkers = await db
            .customSelect(
              'SELECT handled_by_episode_id FROM persona_chat_messages',
            )
            .get();
        expect(
          oldMarkers.map(
            (row) => row.readNullable<String>('handled_by_episode_id'),
          ),
          everyElement(isNull),
        );
        expect(
          await _indexNames(db, 'persona_chat_messages'),
          isNot(contains('idx_persona_chat_unhandled')),
        );
      } finally {
        await db.close();
        await tempDir.delete(recursive: true);
      }
    });
  });
}

void _createSchema14Database(File file) {
  final db = sqlite.sqlite3.open(file.path);
  try {
    db.execute('''
CREATE TABLE tasks (
  id TEXT NOT NULL PRIMARY KEY,
  type TEXT NOT NULL,
  payload TEXT NULL,
  status TEXT NOT NULL,
  priority INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NULL,
  scheduled_at INTEGER NULL,
  completed_at INTEGER NULL,
  updated_at INTEGER NULL,
  retry_count INTEGER NOT NULL DEFAULT 0,
  max_retries INTEGER NOT NULL DEFAULT 3,
  error TEXT NULL,
  result TEXT NULL,
  biz_id TEXT NULL,
  dependencies TEXT NULL
);
''');
    db.execute('''
CREATE TABLE persona_chat_messages (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  character_id TEXT NOT NULL,
  is_from_character INTEGER NOT NULL,
  content TEXT NOT NULL,
  fact_id TEXT NULL,
  is_read INTEGER NOT NULL DEFAULT 0,
  timestamp INTEGER NOT NULL,
  message_type TEXT NOT NULL DEFAULT 'chat'
);
''');
    db.execute('''
INSERT INTO persona_chat_messages (
  character_id,
  is_from_character,
  content,
  is_read,
  timestamp,
  message_type
) VALUES (
  'legacy-character',
  0,
  'legacy user message',
  1,
  1700000000,
  'chat'
);
''');
    db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    db.execute('CREATE INDEX idx_tasks_scheduled_at ON tasks(scheduled_at)');
    db.execute('CREATE INDEX idx_tasks_type_biz_id ON tasks(type, biz_id)');
    db.execute(
      '''
INSERT INTO tasks (
  id,
  type,
  payload,
  status,
  priority,
  created_at,
  retry_count,
  max_retries
) VALUES (
  'legacy-task',
  'super_agent_chat_turn_task',
  '{}',
  'pending',
  0,
  1700000000,
  0,
  3
);
''',
    );
    db.execute('PRAGMA user_version = 14');
  } finally {
    db.dispose();
  }
}

void _createSchema18Database(File file) {
  final db = sqlite.sqlite3.open(file.path);
  try {
    db.execute('''
CREATE TABLE persona_chat_messages (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  character_id TEXT NOT NULL,
  is_from_character INTEGER NOT NULL,
  content TEXT NOT NULL,
  fact_id TEXT NULL,
  is_read INTEGER NOT NULL DEFAULT 0,
  timestamp INTEGER NOT NULL,
  message_type TEXT NOT NULL DEFAULT 'chat',
  origin TEXT NOT NULL DEFAULT 'conversation',
  contact_episode_id TEXT NULL,
  handled_by_episode_id TEXT NULL
);
''');
    db.execute('''
INSERT INTO persona_chat_messages (
  id, character_id, is_from_character, content, is_read, timestamp,
  handled_by_episode_id
) VALUES
  (1, 'legacy-character', 0, 'legacy user message', 1, 1700000000,
   'legacy_history'),
  (2, 'legacy-character', 0, 'processed user message', 1, 1700000001,
   'character_conversation:old-task'),
  (3, 'legacy-character', 0, 'pending user message', 1, 1700000002, NULL);
''');
    db.execute(
      'CREATE INDEX idx_persona_chat_unhandled '
      'ON persona_chat_messages('
      'character_id, is_from_character, handled_by_episode_id, id)',
    );
    db.execute('PRAGMA user_version = 18');
  } finally {
    db.dispose();
  }
}

Future<int> _userVersion(AppDatabase db) async {
  final row = await db.customSelect('PRAGMA user_version').getSingle();
  return row.read<int>('user_version');
}

Future<List<String>> _columnNames(AppDatabase db, String tableName) async {
  final rows = await db.customSelect("PRAGMA table_info('$tableName')").get();
  return [
    for (final row in rows) row.read<String>('name'),
  ];
}

Future<List<String>> _indexNames(AppDatabase db, String tableName) async {
  final rows = await db.customSelect("PRAGMA index_list('$tableName')").get();
  return [
    for (final row in rows) row.read<String>('name'),
  ];
}

Future<List<String>> _tableNames(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
      .get();
  return [
    for (final row in rows) row.read<String>('name'),
  ];
}

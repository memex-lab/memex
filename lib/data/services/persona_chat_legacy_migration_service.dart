import 'package:drift/drift.dart';
import 'package:memex/data/services/migration_state_service.dart';
import 'package:memex/data/services/persona_chat_conversation_storage.dart';
import 'package:memex/db/app_database.dart';

/// One-way boundary from the legacy SQLite persona chat tables to the
/// workspace conversation store. Runtime chat code never reads SQLite after
/// this migration completes.
class PersonaChatLegacyMigrationService {
  PersonaChatLegacyMigrationService({
    PersonaChatConversationStorage? storage,
    MigrationStateService? migrationState,
  })  : _storage = storage ?? PersonaChatConversationStorage.instance,
        _migrationState = migrationState ?? MigrationStateService.instance;

  final PersonaChatConversationStorage _storage;
  final MigrationStateService _migrationState;

  Future<void> ensureMigrated({
    required String userId,
    required AppDatabase database,
  }) async {
    await _migrationState.runOnce(
      userId: userId,
      key: PersonaChatConversationStorage.storageMigrationKey,
      migrate: () => _migrate(userId, database),
    );
  }

  Future<bool> _migrate(String userId, AppDatabase database) async {
    final characterIds = await _legacyCharacterIds(database);
    for (final characterId in characterIds) {
      final rows = await (database.select(database.personaChatMessages)
            ..where((row) => row.characterId.equals(characterId))
            ..orderBy([
              (row) => OrderingTerm.asc(row.timestamp),
              (row) => OrderingTerm.asc(row.id),
            ]))
          .get();
      if (rows.isEmpty) continue;

      final records = <PersonaChatConversationRecord>[];
      final seqByLegacyId = <int, int>{};
      for (var index = 0; index < rows.length; index++) {
        final row = rows[index];
        final seq = index + 1;
        seqByLegacyId[row.id] = seq;
        records.add(
          PersonaChatConversationRecord(
            id: 'legacy-${row.id}',
            seq: seq,
            characterId: row.characterId,
            isFromCharacter: row.isFromCharacter,
            content: row.content,
            factId: row.factId,
            isRead: row.isRead,
            timestamp: row.timestamp,
            messageType: row.messageType,
            origin: row.origin,
            contactEpisodeId: row.contactEpisodeId,
          ),
        );
      }

      final cursor = await (database.select(database.personaChatReplyCursors)
            ..where((row) => row.characterId.equals(characterId)))
          .getSingleOrNull();
      await _storage.importLegacySnapshot(
        userId: userId,
        characterId: characterId,
        records: records,
        consumedThroughSeq: cursor == null
            ? null
            : seqByLegacyId[cursor.consumedThroughMessageId],
      );
    }
    return true;
  }

  Future<Set<String>> _legacyCharacterIds(AppDatabase database) async {
    final query = database.selectOnly(database.personaChatMessages,
        distinct: true)
      ..addColumns([database.personaChatMessages.characterId]);
    final rows = await query.get();
    return rows
        .map((row) => row.read(database.personaChatMessages.characterId))
        .whereType<String>()
        .toSet();
  }
}

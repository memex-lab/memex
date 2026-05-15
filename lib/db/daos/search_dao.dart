import 'package:drift/drift.dart';
import 'package:memex/data/services/search/query_matcher.dart';

/// DAO for full-text search using SQLite FTS5.
///
/// Manages two FTS5 virtual tables:
/// - `card_fts`: indexes timeline card titles, tags, content, and insight text
/// - `pkm_fts`: indexes PKM knowledge base file names and content
///
/// Chinese text is segmented using jieba (dictionary-based DAG + DP).
/// English text is handled natively by FTS5's unicode61 tokenizer.
class SearchDao {
  final GeneratedDatabase _db;

  SearchDao(this._db);

  // ---------------------------------------------------------------------------
  // Table creation
  // ---------------------------------------------------------------------------

  /// Create FTS5 virtual tables. Called from migration `onCreate` / `onUpgrade`.
  Future<void> createFtsTables() async {
    await _db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS card_fts USING fts5(
        fact_id UNINDEXED,
        title,
        tags,
        content,
        insight,
        tokenize='unicode61'
      )
    ''');
    await _db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS pkm_fts USING fts5(
        file_path UNINDEXED,
        file_name,
        content,
        tokenize='unicode61'
      )
    ''');
    await createCharacterFtsTables();
  }

  Future<void> createCharacterFtsTables() async {
    await _db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS character_world_fts USING fts5(
        character_id UNINDEXED,
        entry_id UNINDEXED,
        keys,
        comment,
        content,
        tokenize='unicode61'
      )
    ''');
    await _db.customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS character_timeline_fts USING fts5(
        character_id UNINDEXED,
        event_id UNINDEXED,
        source UNINDEXED,
        scene UNINDEXED,
        thread_id UNINDEXED,
        ts UNINDEXED,
        event_type,
        content,
        fact_id,
        tokenize='unicode61'
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // Tokenization (jieba for CJK, passthrough for English)
  // ---------------------------------------------------------------------------

  /// Prepare text for FTS5 indexing.
  ///
  /// If jieba is initialized and text contains CJK, uses `cutForSearch` to
  /// produce fine-grained tokens (bigrams + trigrams + full words).
  /// Otherwise falls back to per-character CJK splitting.
  /// English text is left as-is for FTS5's unicode61 tokenizer.
  static Future<String> tokenizeForIndex(String text) {
    return QueryMatcher.tokenizeForIndex(text);
  }

  /// Prepare a search query for FTS5.
  ///
  /// Uses jieba `cut` (not cutForSearch) to segment the query into words,
  /// then wraps English tokens with prefix matching and joins with OR.
  /// FTS5's BM25 ranking naturally scores documents higher when more
  /// tokens match, similar to Elasticsearch's default behavior.
  static Future<String> tokenizeForQuery(String query) {
    return QueryMatcher.tokenizeForFtsQuery(query);
  }

  // ---------------------------------------------------------------------------
  // Card FTS
  // ---------------------------------------------------------------------------

  Future<void> upsertCardFts({
    required String factId,
    required String title,
    required String tags,
    required String content,
    required String insight,
  }) async {
    await deleteCardFts(factId);
    await _db.customStatement(
      'INSERT INTO card_fts(fact_id, title, tags, content, insight) VALUES (?, ?, ?, ?, ?)',
      [
        factId,
        await tokenizeForIndex(title),
        await tokenizeForIndex(tags),
        await tokenizeForIndex(content),
        await tokenizeForIndex(insight)
      ],
    );
  }

  Future<void> deleteCardFts(String factId) async {
    await _db
        .customStatement('DELETE FROM card_fts WHERE fact_id = ?', [factId]);
  }

  Future<void> clearCardFts() async {
    await _db.customStatement('DELETE FROM card_fts');
  }

  /// Search cards via FTS5. Returns `fact_id`, snippets, and rank.
  Future<List<Map<String, dynamic>>> searchCards(String query,
      {int limit = 50}) async {
    final ftsQuery = await tokenizeForQuery(query);
    if (ftsQuery.isEmpty) return [];
    final results = await _db.customSelect(
      '''SELECT fact_id,
             snippet(card_fts, 2, '<b>', '</b>', '...', 32) AS content_snippet,
             snippet(card_fts, 1, '<b>', '</b>', '...', 32) AS title_snippet,
             rank
      FROM card_fts WHERE card_fts MATCH ? ORDER BY rank LIMIT ?''',
      variables: [Variable<String>(ftsQuery), Variable<int>(limit)],
    ).get();
    return results
        .map((row) => {
              'fact_id': row.read<String>('fact_id'),
              'content_snippet': row.read<String>('content_snippet'),
              'title_snippet': row.read<String>('title_snippet'),
              'rank': row.read<double>('rank'),
            })
        .toList();
  }

  // ---------------------------------------------------------------------------
  // PKM FTS
  // ---------------------------------------------------------------------------

  Future<void> upsertPkmFts({
    required String filePath,
    required String fileName,
    required String content,
  }) async {
    await deletePkmFts(filePath);
    await _db.customStatement(
      'INSERT INTO pkm_fts(file_path, file_name, content) VALUES (?, ?, ?)',
      [
        filePath,
        await tokenizeForIndex(fileName),
        await tokenizeForIndex(content)
      ],
    );
  }

  Future<void> deletePkmFts(String filePath) async {
    await _db
        .customStatement('DELETE FROM pkm_fts WHERE file_path = ?', [filePath]);
  }

  Future<void> clearPkmFts() async {
    await _db.customStatement('DELETE FROM pkm_fts');
  }

  /// Search PKM files via FTS5.
  Future<List<Map<String, dynamic>>> searchPkmFiles(String query,
      {int limit = 50}) async {
    final ftsQuery = await tokenizeForQuery(query);
    if (ftsQuery.isEmpty) return [];
    final results = await _db.customSelect(
      '''SELECT file_path,
             snippet(pkm_fts, 2, '<b>', '</b>', '...', 64) AS snippet, rank
      FROM pkm_fts WHERE pkm_fts MATCH ? ORDER BY rank LIMIT ?''',
      variables: [Variable<String>(ftsQuery), Variable<int>(limit)],
    ).get();
    return results.map((row) {
      final filePath = row.read<String>('file_path');
      // Derive display name from the original (untokenized) file_path
      final name = filePath.contains('/')
          ? filePath.substring(filePath.lastIndexOf('/') + 1)
          : filePath;
      return {
        'name': name,
        'path': filePath,
        'snippet': row.read<String>('snippet'),
        'rank': row.read<double>('rank'),
      };
    }).toList();
  }

  Future<void> upsertCharacterWorldFts({
    required String characterId,
    required String entryId,
    required String keys,
    required String comment,
    required String content,
  }) async {
    await deleteCharacterWorldFts(characterId, entryId);
    await _db.customStatement(
      'INSERT INTO character_world_fts(character_id, entry_id, keys, comment, content) VALUES (?, ?, ?, ?, ?)',
      [
        characterId,
        entryId,
        await tokenizeForIndex(keys),
        await tokenizeForIndex(comment),
        await tokenizeForIndex(content),
      ],
    );
  }

  Future<void> deleteCharacterWorldFts(
      String characterId, String entryId) async {
    await _db.customStatement(
      'DELETE FROM character_world_fts WHERE character_id = ? AND entry_id = ?',
      [characterId, entryId],
    );
  }

  Future<void> clearCharacterWorldFts(String characterId) async {
    await _db.customStatement(
      'DELETE FROM character_world_fts WHERE character_id = ?',
      [characterId],
    );
  }

  Future<List<Map<String, dynamic>>> searchCharacterWorldEntries(
    String characterId,
    String query, {
    int limit = 12,
  }) async {
    final ftsQuery = await tokenizeForQuery(query);
    if (ftsQuery.isEmpty) return [];
    final rows = await _db.customSelect(
      '''SELECT entry_id, rank
      FROM character_world_fts
      WHERE character_id = ? AND character_world_fts MATCH ?
      ORDER BY rank LIMIT ?''',
      variables: [
        Variable<String>(characterId),
        Variable<String>(ftsQuery),
        Variable<int>(limit),
      ],
    ).get();
    return rows
        .map((row) => {
              'id': row.read<String>('entry_id'),
              'rank': row.read<double>('rank'),
            })
        .toList();
  }

  Future<void> upsertCharacterTimelineFts({
    required String characterId,
    required String eventId,
    required String source,
    required String scene,
    required String threadId,
    required String ts,
    required String eventType,
    required String content,
    required String factId,
  }) async {
    await deleteCharacterTimelineFts(characterId, eventId, source);
    await _db.customStatement(
      'INSERT INTO character_timeline_fts(character_id, event_id, source, scene, thread_id, ts, event_type, content, fact_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        characterId,
        eventId,
        source,
        scene,
        threadId,
        ts,
        await tokenizeForIndex(eventType),
        await tokenizeForIndex(content),
        await tokenizeForIndex(factId),
      ],
    );
  }

  Future<void> deleteCharacterTimelineFts(
    String characterId,
    String eventId,
    String source,
  ) async {
    await _db.customStatement(
      'DELETE FROM character_timeline_fts WHERE character_id = ? AND event_id = ? AND source = ?',
      [characterId, eventId, source],
    );
  }

  Future<void> clearCharacterTimelineFts(String characterId,
      {String? source}) async {
    if (source == null) {
      await _db.customStatement(
        'DELETE FROM character_timeline_fts WHERE character_id = ?',
        [characterId],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM character_timeline_fts WHERE character_id = ? AND source = ?',
        [characterId, source],
      );
    }
  }

  Future<List<Map<String, dynamic>>> searchCharacterTimeline(
    String characterId,
    String query, {
    int limit = 8,
    String? scene,
    String? threadId,
    bool includeArchived = true,
  }) async {
    final ftsQuery = await tokenizeForQuery(query);
    if (ftsQuery.isEmpty) return [];
    final clauses = <String>[
      'character_id = ?',
      'character_timeline_fts MATCH ?',
    ];
    final variables = <Variable>[
      Variable<String>(characterId),
      Variable<String>(ftsQuery),
    ];
    if (scene != null && scene.isNotEmpty) {
      clauses.add('scene = ?');
      variables.add(Variable<String>(scene));
    }
    if (threadId != null && threadId.isNotEmpty) {
      clauses.add('thread_id = ?');
      variables.add(Variable<String>(threadId));
    }
    if (!includeArchived) {
      clauses.add('source = ?');
      variables.add(const Variable<String>('recent'));
    }
    variables.add(Variable<int>(limit));
    final rows = await _db.customSelect(
      '''SELECT event_id, source, rank
      FROM character_timeline_fts
      WHERE ${clauses.join(' AND ')}
      ORDER BY rank LIMIT ?''',
      variables: variables,
    ).get();
    return rows
        .map((row) => {
              'event_id': row.read<String>('event_id'),
              'source': row.read<String>('source'),
              'rank': row.read<double>('rank'),
            })
        .toList();
  }
}

import 'package:drift/drift.dart';
import 'package:memex/utils/jieba.dart';

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
  }

  // ---------------------------------------------------------------------------
  // Tokenization (jieba for CJK, passthrough for English)
  // ---------------------------------------------------------------------------

  static final _jieba = JiebaSegmenter.instance;

  static bool _isCjk(int code) {
    return (code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3400 && code <= 0x4DBF) ||
        (code >= 0xF900 && code <= 0xFAFF) ||
        (code >= 0x3040 && code <= 0x30FF) ||
        (code >= 0xFF00 && code <= 0xFFEF) ||
        (code >= 0x3000 && code <= 0x303F);
  }

  static bool _containsCjk(String text) {
    for (int i = 0; i < text.length; i++) {
      if (_isCjk(text.codeUnitAt(i))) return true;
    }
    return false;
  }

  /// Prepare text for FTS5 indexing.
  ///
  /// If jieba is initialized and text contains CJK, uses `cutForSearch` to
  /// produce fine-grained tokens (bigrams + trigrams + full words).
  /// Otherwise falls back to per-character CJK splitting.
  /// English text is left as-is for FTS5's unicode61 tokenizer.
  static String tokenizeForIndex(String text) {
    if (text.isEmpty) return text;
    if (_jieba.isLoaded && _containsCjk(text)) {
      return _jieba.cutForSearch(text).join(' ');
    }
    return _tokenizeFallback(text);
  }

  /// Prepare a search query for FTS5.
  ///
  /// Uses jieba `cut` (not cutForSearch) to segment the query into words,
  /// then wraps English tokens with prefix matching and joins with OR.
  /// FTS5's BM25 ranking naturally scores documents higher when more
  /// tokens match, similar to Elasticsearch's default behavior.
  static String tokenizeForQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return trimmed;

    if (_jieba.isLoaded && _containsCjk(trimmed)) {
      final words = _jieba.cut(trimmed);
      final tokens = <String>[];
      for (final w in words) {
        final t = w.trim();
        if (t.isEmpty) continue;
        if (_containsCjk(t)) {
          // CJK word — exact match
          tokens.add('"$t"');
        } else {
          // English/number — prefix match
          tokens.add('"$t"*');
        }
      }
      if (tokens.isEmpty) return '';
      return tokens.join(' OR ');
    }

    return _tokenizeQueryFallback(trimmed);
  }

  /// Fallback: per-character CJK splitting (used when jieba is not loaded).
  static String _tokenizeFallback(String text) {
    final buf = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (_isCjk(code)) {
        if (buf.isNotEmpty && !buf.toString().endsWith(' ')) buf.write(' ');
        buf.writeCharCode(code);
        buf.write(' ');
      } else {
        buf.writeCharCode(code);
      }
    }
    return buf.toString().trim();
  }

  /// Fallback query tokenizer (per-character CJK + prefix English).
  static String _tokenizeQueryFallback(String query) {
    final tokens = <String>[];
    final buf = StringBuffer();
    for (int i = 0; i < query.length; i++) {
      final code = query.codeUnitAt(i);
      if (_isCjk(code)) {
        if (buf.isNotEmpty) {
          tokens.add('"${buf.toString()}"*');
          buf.clear();
        }
        tokens.add(String.fromCharCode(code));
      } else if (query[i] == ' ') {
        if (buf.isNotEmpty) {
          tokens.add('"${buf.toString()}"*');
          buf.clear();
        }
      } else {
        buf.writeCharCode(code);
      }
    }
    if (buf.isNotEmpty) tokens.add('"${buf.toString()}"*');
    if (tokens.isEmpty) return '';
    return tokens.join(' OR ');
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
        tokenizeForIndex(title),
        tokenizeForIndex(tags),
        tokenizeForIndex(content),
        tokenizeForIndex(insight)
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
    final ftsQuery = tokenizeForQuery(query);
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
      [filePath, tokenizeForIndex(fileName), tokenizeForIndex(content)],
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
    final ftsQuery = tokenizeForQuery(query);
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
}

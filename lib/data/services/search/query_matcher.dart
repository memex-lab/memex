import 'package:memex/utils/jieba.dart';

class QueryMatch {
  final int score;
  final List<int> indexes;

  const QueryMatch({
    required this.score,
    required this.indexes,
  });

  bool get matched => score > 0;
}

class QueryMatcher {
  QueryMatcher._();

  static Future<String> tokenizeForIndex(String text) async {
    if (text.isEmpty) return text;
    if (_containsCjk(text) && await JiebaSegmenter.instance.ensureLoaded()) {
      return JiebaSegmenter.instance.cutForSearch(text).join(' ');
    }
    return _tokenizeFallback(text);
  }

  static Future<String> tokenizeForFtsQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return trimmed;

    if (_containsCjk(trimmed) && await JiebaSegmenter.instance.ensureLoaded()) {
      final tokens = <String>[];
      for (final word in JiebaSegmenter.instance.cut(trimmed)) {
        final token = word.trim();
        if (token.isEmpty) continue;
        if (_containsCjk(token)) {
          // CJK token: exact match (no prefix wildcard — FTS5 doesn't support
          // prefix search on CJK characters anyway).
          tokens.add('"$token"');
        } else {
          // ASCII token: keep only alphanumeric/underscore/hyphen characters.
          // Punctuation-only tokens (e.g. ".", "!", "[") cause FTS5 syntax
          // errors when used with the prefix wildcard operator.
          final clean = token.replaceAll(RegExp(r'[^\w\-]'), '').trim();
          if (clean.length >= 2) {
            tokens.add('"$clean"*');
          }
        }
      }
      if (tokens.isEmpty) return '';
      return tokens.join(' OR ');
    }

    return _tokenizeQueryFallback(trimmed);
  }

  static Future<List<String>> terms(String query, {int maxTerms = 12}) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    final tokens = <String>[];
    if (_containsCjk(trimmed) && await JiebaSegmenter.instance.ensureLoaded()) {
      for (final token in JiebaSegmenter.instance.cut(trimmed)) {
        _addToken(tokens, token);
      }
    } else {
      final buffer = StringBuffer();
      for (var i = 0; i < trimmed.length; i++) {
        final code = trimmed.codeUnitAt(i);
        if (_isCjk(code)) {
          _flushAscii(tokens, buffer);
          tokens.add(String.fromCharCode(code));
        } else if (_isAsciiWordCode(code)) {
          buffer.writeCharCode(code);
        } else {
          _flushAscii(tokens, buffer);
        }
      }
      _flushAscii(tokens, buffer);
    }

    final seen = <String>{};
    final unique = <String>[];
    for (final token in tokens) {
      if (seen.add(token)) unique.add(token);
      if (unique.length >= maxTerms) break;
    }
    return unique;
  }

  static Future<QueryMatch> match(
    String query,
    String text, {
    Iterable<String> extraTerms = const [],
    int phraseBoost = 5,
  }) async {
    final lowerText = text.toLowerCase();
    final normalizedQuery = query.trim().toLowerCase();
    final allTerms = <String>{
      ...await terms(query),
      ...extraTerms
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty),
    }.toList();
    if (normalizedQuery.isEmpty && allTerms.isEmpty) {
      return const QueryMatch(score: 0, indexes: []);
    }

    var score = 0;
    final indexes = <int>[];
    if (normalizedQuery.isNotEmpty) {
      final phraseIdx = lowerText.indexOf(normalizedQuery);
      if (phraseIdx >= 0) {
        score += phraseBoost + allTerms.length;
        indexes.add(phraseIdx);
      }
    }
    for (final term in allTerms) {
      final idx = lowerText.indexOf(term);
      if (idx >= 0) {
        score += term.length > 1 ? 2 : 1;
        indexes.add(idx);
      }
    }
    indexes.sort();
    return QueryMatch(score: score, indexes: indexes);
  }

  static String snippet({
    required String content,
    required List<int> matchIndexes,
    int maxChars = 800,
    int contextRadius = 240,
  }) {
    if (content.length <= maxChars) return content;
    if (matchIndexes.isEmpty) {
      return '${content.substring(0, maxChars)}...';
    }

    final sorted = [...matchIndexes]..sort();
    final windows = <({int start, int end})>[];
    for (final idx in sorted) {
      final start = (idx - contextRadius).clamp(0, content.length);
      final end = (idx + contextRadius).clamp(0, content.length);
      if (windows.isNotEmpty && start <= windows.last.end + 80) {
        final last = windows.removeLast();
        windows.add((start: last.start, end: end > last.end ? end : last.end));
      } else {
        windows.add((start: start, end: end));
      }
    }

    final parts = <String>[];
    var used = 0;
    for (final window in windows) {
      if (used >= maxChars) break;
      final remaining = maxChars - used;
      final text = content.substring(window.start, window.end);
      final clipped =
          text.length > remaining ? '${text.substring(0, remaining)}...' : text;
      parts.add(
        '${window.start > 0 ? '...' : ''}${clipped.replaceAll('\n', ' ')}${window.end < content.length ? '...' : ''}',
      );
      used += clipped.length;
    }

    return parts.join('\n...\n');
  }

  static bool _isCjk(int code) {
    return (code >= 0x4E00 && code <= 0x9FFF) ||
        (code >= 0x3400 && code <= 0x4DBF) ||
        (code >= 0xF900 && code <= 0xFAFF) ||
        (code >= 0x3040 && code <= 0x30FF) ||
        (code >= 0xFF00 && code <= 0xFFEF) ||
        (code >= 0x3000 && code <= 0x303F);
  }

  static bool _containsCjk(String text) {
    for (var i = 0; i < text.length; i++) {
      if (_isCjk(text.codeUnitAt(i))) return true;
    }
    return false;
  }

  static bool _isAsciiWordCode(int code) {
    return (code >= 0x30 && code <= 0x39) ||
        (code >= 0x61 && code <= 0x7A) ||
        code == 0x5F ||
        code == 0x2D;
  }

  static String _tokenizeFallback(String text) {
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (_isCjk(code)) {
        if (buffer.isNotEmpty && !buffer.toString().endsWith(' ')) {
          buffer.write(' ');
        }
        buffer.writeCharCode(code);
        buffer.write(' ');
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString().trim();
  }

  static String _tokenizeQueryFallback(String query) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (var i = 0; i < query.length; i++) {
      final code = query.codeUnitAt(i);
      if (_isCjk(code)) {
        _flushFtsAscii(tokens, buffer);
        tokens.add(String.fromCharCode(code));
      } else if (_isAsciiWordCode(code)) {
        buffer.writeCharCode(code);
      } else {
        _flushFtsAscii(tokens, buffer);
      }
    }
    _flushFtsAscii(tokens, buffer);
    return tokens.join(' OR ');
  }

  static void _flushFtsAscii(List<String> tokens, StringBuffer buffer) {
    if (buffer.isEmpty) return;
    tokens.add('"${buffer.toString()}"*');
    buffer.clear();
  }

  static void _flushAscii(List<String> tokens, StringBuffer buffer) {
    if (buffer.isEmpty) return;
    _addToken(tokens, buffer.toString());
    buffer.clear();
  }

  static void _addToken(List<String> tokens, String token) {
    final trimmed = token.trim().toLowerCase();
    if (trimmed.isEmpty) return;
    if (!_containsCjk(trimmed) && trimmed.length < 2) return;
    tokens.add(trimmed);
  }
}

import 'dart:io';

import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/jieba.dart';
import 'package:path/path.dart' as p;

class UserKnowledgeContextService {
  UserKnowledgeContextService._();

  static final UserKnowledgeContextService instance =
      UserKnowledgeContextService._();

  Future<String> buildKnowledgeCards({
    required String userId,
    required String queryHint,
    int maxCards = 5,
    int maxCharsPerCard = 800,
    int contextRadius = 240,
  }) async {
    if (!AppDatabase.isInitialized) return '';
    final fs = FileSystemService.instance;
    final pkmPath = fs.getPkmPath(userId);
    final dir = Directory(pkmPath);
    if (!await dir.exists()) return '';

    final trimmed = queryHint.trim();
    if (trimmed.isEmpty) return '';
    final seen = <String>{};
    final results = <Map<String, dynamic>>[];

    final grepMatches = await fs.grepPkmFiles(userId, trimmed, limit: maxCards);
    for (final match in grepMatches) {
      final path = (match['path'] ?? '').toString();
      if (path.isNotEmpty && seen.add(path)) results.add(match);
    }

    if (results.length < maxCards) {
      await JiebaSegmenter.instance.ensureLoaded();
      final ftsResults = await AppDatabase.instance.searchDao
          .searchPkmFiles(trimmed, limit: maxCards);
      for (final result in ftsResults) {
        final path = (result['path'] ?? '').toString();
        if (path.isNotEmpty && seen.add(path)) results.add(result);
        if (results.length >= maxCards) break;
      }
    }

    final cards = <String>[];
    for (final item in results) {
      if (cards.length >= maxCards) break;
      final pathKey = (item['path'] ?? '').toString();
      if (pathKey.isEmpty) continue;
      final snippet = await _expandSnippet(
        pkmPath: pkmPath,
        relativePath: pathKey,
        fallbackSnippet: (item['snippet'] ?? '').toString(),
        maxChars: maxCharsPerCard,
        contextRadius: contextRadius,
      );
      cards.add(
          '### $pathKey${item['rank'] == null ? '' : ' (rank: ${item['rank']})'}\n$snippet');
    }

    return cards.join('\n\n');
  }

  Future<String> _expandSnippet({
    required String pkmPath,
    required String relativePath,
    required String fallbackSnippet,
    required int maxChars,
    required int contextRadius,
  }) async {
    final file = File(p.join(pkmPath, relativePath));
    if (!await file.exists()) return fallbackSnippet;
    final content = await file.readAsString();
    if (content.length <= maxChars) return content;
    if (fallbackSnippet.trim().isEmpty) {
      return '${content.substring(0, maxChars)}...';
    }
    final plainSnippet = fallbackSnippet
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('...', '')
        .trim();
    final idx = plainSnippet.isEmpty ? -1 : content.indexOf(plainSnippet);
    if (idx < 0) {
      return fallbackSnippet.length > maxChars
          ? '${fallbackSnippet.substring(0, maxChars)}...'
          : fallbackSnippet;
    }
    final start = (idx - contextRadius).clamp(0, content.length);
    final end =
        (idx + plainSnippet.length + contextRadius).clamp(0, content.length);
    final text = content.substring(start, end).replaceAll('\n', ' ');
    return '${start > 0 ? '...' : ''}$text${end < content.length ? '...' : ''}';
  }
}

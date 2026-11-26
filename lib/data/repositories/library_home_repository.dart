import 'dart:convert';
import 'dart:math' as math;
import 'package:memex/db/app_database.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/library_document.dart';
import 'package:memex/utils/logger.dart';

class LibraryHomeRepository {
  final _cache = <String, ({int modified, int size, LibraryDocument doc})>{};
  String? _user;
  Future<List<LibraryDocument>> load(String user,
      {required bool refresh}) async {
    if (_user != user) {
      _cache.clear();
      _user = user;
    }
    final fs = FileSystemService.instance;
    final files = await fs.getRecentPkmFiles(user,
        limit: 0x7fffffff, forceRefresh: refresh);
    final db = AppDatabase.isInitialized ? AppDatabase.instance : null;
    final result = <LibraryDocument>[];
    for (final file in files) {
      final path = file['path'] as String;
      if (path.split('/').any((part) => part.startsWith('.'))) continue;
      final modified = file['modified'] as int, size = file['size'] as int;
      final cached = _cache[path];
      if (cached != null &&
          cached.modified == modified &&
          cached.size == size) {
        result.add(cached.doc);
        continue;
      }
      try {
        final content = await fs.readLibraryMarkdown(user, path);
        final doc = LibraryDocument.fromMarkdown(path, content, modified);
        result.add(doc);
        if (_user == user)
          _cache[path] = (modified: modified, size: size, doc: doc);
      } catch (e) {
        getLogger('LibraryHomeRepository').fine('Document unavailable', e);
      }
    }
    final paths = result.map((e) => e.path).toSet();
    if (_user == user) _cache.removeWhere((k, v) => !paths.contains(k));
    if (db == null) return result;
    final ids = result.expand((d) => d.sources).toSet().toList();
    final records = <String, ({List<String> tags, int time})>{};
    for (var i = 0; i < ids.length; i += 400) {
      final batch = ids.sublist(i, math.min(i + 400, ids.length));
      final rows = await (db.select(db.cardCache)
            ..where((r) => r.factId.isIn(batch)))
          .get();
      for (final row in rows) {
        final raw = jsonDecode(row.tags);
        records[row.factId] = (
          tags: raw is List
              ? raw
                  .whereType<String>()
                  .where((t) => t.trim().isNotEmpty)
                  .toList()
              : <String>[],
          time: row.timestamp * 1000
        );
      }
    }
    return result.map((doc) {
      final verified = doc.sources.where(records.containsKey).toSet();
      final tags = verified.expand((id) => records[id]!.tags);
      final time = verified.fold<int>(
          0, (time, id) => math.max(time, records[id]!.time));
      return doc.withSourceTopics(verified, tags, time);
    }).toList();
  }
}

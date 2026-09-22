import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/card_model.dart';

/// Reads the current user's source cards, including records not yet indexed.
/// Search is paginated so an empty page never claims the whole archive is empty.
class RecordRecallService {
  RecordRecallService(this.userId);
  final String userId;
  static final _id = RegExp(r'^\d{4}/\d{2}/\d{2}\.md#ts_\d+$');

  Future<CardData?> read(String factId) async {
    if (!_id.hasMatch(factId)) throw ArgumentError('Invalid fact_id');
    final card = await FileSystemService.instance.readCardFile(userId, factId);
    if (card == null ||
        card.factId != factId ||
        card.deleted == true ||
        card.status != 'completed') {
      return null;
    }
    return card;
  }

  Future<Map<String, dynamic>> search(String query, {int offset = 0}) async {
    if (offset < 0) throw ArgumentError('offset must be nonnegative');
    final terms = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
    final fs = FileSystemService.instance;
    final paths = await fs.listAllCardFiles(userId);
    final matches = <Map<String, dynamic>>[];
    var cursor = offset;
    var scanned = 0;
    // Bound source reads and result size, while exposing continuation explicitly.
    while (cursor < paths.length && scanned < 200 && matches.length < 10) {
      final id = fs.factIdFromCardPath(paths[cursor++]);
      scanned++;
      if (id == null) continue;
      final card = await read(id);
      if (card == null) continue;
      final text =
          '${card.title ?? ''}\n${card.fact ?? ''}\n${card.tags.join(' ')}'
              .toLowerCase();
      if (terms.every(text.contains)) {
        final fact = card.fact ?? '';
        matches.add({
          'fact_id': card.factId,
          'title': card.title,
          'record_time':
              DateTime.fromMillisecondsSinceEpoch(card.timestamp * 1000)
                  .toIso8601String(),
          'source_excerpt': fact.length > 600 ? fact.substring(0, 600) : fact,
          'excerpt_truncated': fact.length > 600,
          'has_attachments': card.assets.isNotEmpty,
        });
      }
    }
    return {
      'matches': matches,
      'next_offset': cursor < paths.length ? cursor : null,
      'scanned': scanned,
      'scope': 'Current user completed, nondeleted cards. Keyword AND match; '
          'empty query browses records. No semantic search. Continue pages or '
          'try shorter terms before concluding nothing was found.',
    };
  }
}

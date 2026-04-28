class SystemEvent<T> {
  SystemEvent({
    required this.type,
    required this.payload,
    required this.source,
    String? eventId,
    DateTime? createdAt,
  })  : eventId = eventId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  final String eventId;
  final String type;
  final T payload;
  final String source;
  final DateTime createdAt;
}

class SystemEventTypes {
  static const String userInputSubmitted = 'user_input_submitted';
  static const String cardCommentPosted = 'card_comment_posted';
  static const String knowledgeInsightRefreshRequested =
      'knowledge_insight_refresh_requested';
  static const String dataChanged = 'data_changed';

  static const List<String> allTypes = [
    userInputSubmitted,
    cardCommentPosted,
    knowledgeInsightRefreshRequested,
    dataChanged,
  ];
}

// ---- Payload 类型 ----

class UserInputSubmittedPayload {
  UserInputSubmittedPayload({
    required this.factId,
    required this.assetPaths,
    required this.combinedText,
    required this.markdownEntry,
    required this.createdAtTs,
    required this.pkmCreatedAtTs,
  });

  final String factId;
  final List<String> assetPaths;
  final String combinedText;
  final String markdownEntry;
  final int createdAtTs;
  final double pkmCreatedAtTs;

  Map<String, dynamic> toJson() => {
        'fact_id': factId,
        'asset_paths': assetPaths,
        'combined_text': combinedText,
        'markdown_entry': markdownEntry,
        'created_at_ts': createdAtTs,
        'pkm_created_at_ts': pkmCreatedAtTs,
      };
}

class CardCommentPostedPayload {
  CardCommentPostedPayload({
    required this.cardId,
    required this.content,
    required this.commentId,
  });

  final String cardId;
  final String content;
  final String commentId;

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'content': content,
        'comment_id': commentId,
      };
}

// ---------------------------------------------------------------------------
// Data change record (binlog / oplog style)
// ---------------------------------------------------------------------------

/// Operation type for data change events.
enum DataChangeOp { insert, update, delete }

/// Namespace constants for [DataChangeRecord].
class DataChangeNs {
  static const String pkmFile = 'pkm_file';
  static const String card = 'card';
}

/// A generic data-change record modeled after database change streams
/// (MongoDB oplog / MySQL binlog).
///
/// Subscribers filter by [ns] (namespace) and [op] (operation) to decide
/// how to react. [documentKey] is the primary identifier of the changed
/// entity. [fullDocument] carries the post-change snapshot (null on delete).
class DataChangeRecord {
  DataChangeRecord({
    required this.op,
    required this.ns,
    required this.documentKey,
    this.fullDocument,
  });

  /// The operation: insert, update, or delete.
  final DataChangeOp op;

  /// Namespace / collection name (e.g. 'pkm_file', 'card').
  final String ns;

  /// Primary key of the document (e.g. relative file path, factId).
  final String documentKey;

  /// Post-change document snapshot. Null for [DataChangeOp.delete].
  /// Structure depends on [ns]:
  ///
  /// For `pkm_file`:
  ///   `{ 'file_name': String, 'absolute_path': String, 'content': String }`
  ///
  /// For `card`:
  ///   `{ 'title': String?, 'tags': List<String>?, 'content': String?,
  ///      'asset_analyses': List<String>?, 'insight': String? }`
  final Map<String, dynamic>? fullDocument;
}

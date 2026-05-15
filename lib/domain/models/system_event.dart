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
  static const String cardUiConfigUpdated = 'card_ui_config_updated';
  static const String knowledgeInsightRefreshRequested =
      'knowledge_insight_refresh_requested';
  static const String scheduleAggregationRequested =
      'schedule_aggregation_requested';
  static const String clarificationAnswered = 'clarification_answered';
  static const String dataChanged = 'data_changed';

  static const List<String> allTypes = [
    userInputSubmitted,
    cardCommentPosted,
    cardUiConfigUpdated,
    knowledgeInsightRefreshRequested,
    scheduleAggregationRequested,
    clarificationAnswered,
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
    this.createdAtTs,
    this.replyToId,
  });

  final String cardId;
  final String content;
  final String commentId;
  final int? createdAtTs;
  final String? replyToId;

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'content': content,
        'comment_id': commentId,
        if (createdAtTs != null) 'created_at_ts': createdAtTs,
        if (replyToId != null) 'reply_to_id': replyToId,
      };
}

class ClarificationAnsweredPayload {
  ClarificationAnsweredPayload({
    required this.requestId,
  });

  final String requestId;

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
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
/// Subscribers filter by [ns] (namespace) and [op] (operation). [op] is
/// decided by the publisher at the call site from operation intent, not
/// by inspecting the snapshots. [documentKey] is the primary identifier
/// of the changed entity. [before] / [after] are pre/post-change snapshots.
class DataChangeRecord {
  DataChangeRecord({
    required this.op,
    required this.ns,
    required this.documentKey,
    this.before,
    this.after,
  });

  /// The operation: insert, update, or delete.
  final DataChangeOp op;

  /// Namespace / collection name (e.g. 'pkm_file', 'card').
  final String ns;

  /// Primary key of the document (e.g. relative file path, factId).
  final String documentKey;

  /// Pre-change snapshot. Null on [DataChangeOp.insert]. Null when the
  /// prior state could not be read (e.g. file missing/corrupt at the
  /// moment of update) — consumers treat this as "prior state unknown"
  /// rather than "prior state empty" for non-insert ops.
  final Map<String, dynamic>? before;

  /// Post-change snapshot. Null on [DataChangeOp.delete]. Non-null
  /// otherwise.
  final Map<String, dynamic>? after;
}

class CardUiConfigUpdatedPayload {
  CardUiConfigUpdatedPayload({
    required this.cardId,
    required this.configIndex,
    required this.templateId,
    required this.updates,
    required this.previousData,
    required this.updatedData,
  });

  final String cardId;
  final int configIndex;
  final String templateId;
  final Map<String, dynamic> updates;
  final Map<String, dynamic> previousData;
  final Map<String, dynamic> updatedData;

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'config_index': configIndex,
        'template_id': templateId,
        'updates': updates,
        'previous_data': previousData,
        'updated_data': updatedData,
      };
}

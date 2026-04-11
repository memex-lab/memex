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

  static const List<String> allTypes = [
    userInputSubmitted,
    cardCommentPosted,
    knowledgeInsightRefreshRequested,
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
    this.resources,
  });

  final String factId;
  final List<String> assetPaths;
  final String combinedText;
  final String markdownEntry;
  final int createdAtTs;
  final double pkmCreatedAtTs;
  final List<Map<String, dynamic>>? resources; // Recognized resources metadata

  Map<String, dynamic> toJson() => {
        'fact_id': factId,
        'asset_paths': assetPaths,
        'combined_text': combinedText,
        'markdown_entry': markdownEntry,
        'created_at_ts': createdAtTs,
        'pkm_created_at_ts': pkmCreatedAtTs,
        if (resources != null && resources!.isNotEmpty)
          'resources': resources,
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

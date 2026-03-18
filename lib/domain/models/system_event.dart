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
}

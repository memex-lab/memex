class SystemEvent {
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
  final Map<String, dynamic> payload;
  final String source;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'event_type': type,
      'event_source': source,
      'event_created_at': createdAt.toIso8601String(),
      'event_payload': payload,
    };
  }
}

class SystemEventTypes {
  static const String userInputSubmitted = 'user_input_submitted';
  static const String cardCommentPosted = 'card_comment_posted';
  static const String knowledgeInsightRefreshRequested =
      'knowledge_insight_refresh_requested';
}

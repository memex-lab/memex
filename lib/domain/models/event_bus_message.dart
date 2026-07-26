import 'timeline_card_model.dart';

/// EventBus message type
enum EventBusMessageType {
  cardUpdated('card_updated'),
  cardAdded('card_added'),
  cardDetailUpdated('card_detail_updated'),
  newInsight('new_insight'),
  scheduleAggregationUpdated('schedule_aggregation_updated'),
  newSystemAction('new_system_action'),
  attachmentsChanged('attachments_changed'),
  invalidModelConfig('invalid_model_config'),
  llmConfigChanged('llm_config_changed'),
  errorNotification('error_notification'),
  profileUpdated('profile_updated'),
  characterUpdated('character_updated'),
  personaChatMessageAdded('persona_chat_message_added'),
  personaChatUnreadChanged('persona_chat_unread_changed'),
  backupSnapshotsChanged('backup_snapshots_changed'),
  backupRestored('backup_restored'),
  unknown('unknown');

  final String value;
  const EventBusMessageType(this.value);

  static EventBusMessageType fromString(String type) {
    return EventBusMessageType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => EventBusMessageType.unknown,
    );
  }
}

/// EventBus message base class
abstract class EventBusMessage {
  final EventBusMessageType type;
  final Map<String, dynamic> data;

  EventBusMessage({required this.type, required this.data});

  factory EventBusMessage.fromJson(Map<String, dynamic> json) {
    final type = EventBusMessageType.fromString(json['type'] as String? ?? '');

    switch (type) {
      case EventBusMessageType.cardUpdated:
        return CardUpdatedMessage.fromJson(json);
      case EventBusMessageType.cardAdded:
        return CardAddedMessage.fromJson(json);
      case EventBusMessageType.cardDetailUpdated:
        return CardDetailUpdatedMessage.fromJson(json);
      case EventBusMessageType.newInsight:
        return NewInsightMessage.fromJson(json);
      case EventBusMessageType.scheduleAggregationUpdated:
        return ScheduleAggregationUpdatedMessage.fromJson(json);
      case EventBusMessageType.newSystemAction:
        return NewSystemActionMessage.fromJson(json);
      case EventBusMessageType.attachmentsChanged:
        return AttachmentsChangedMessage.fromJson(json);
      case EventBusMessageType.invalidModelConfig:
        return InvalidModelConfigMessage.fromJson(json);
      case EventBusMessageType.llmConfigChanged:
        return LLMConfigChangedMessage.fromJson(json);
      case EventBusMessageType.errorNotification:
        return ErrorNotificationMessage.fromJson(json);
      case EventBusMessageType.profileUpdated:
        return ProfileUpdatedMessage.fromJson(json);
      case EventBusMessageType.characterUpdated:
        return CharacterUpdatedMessage.fromJson(json);
      case EventBusMessageType.personaChatMessageAdded:
        return PersonaChatMessageAddedMessage.fromJson(json);
      case EventBusMessageType.personaChatUnreadChanged:
        return PersonaChatUnreadChangedMessage.fromJson(json);
      case EventBusMessageType.backupSnapshotsChanged:
        return BackupSnapshotsChangedMessage.fromJson(json);
      case EventBusMessageType.backupRestored:
        return BackupRestoredMessage.fromJson(json);
      default:
        return UnknownMessage.fromJson(json);
    }
  }
}

/// Card updated message
class CardUpdatedMessage extends EventBusMessage {
  final String id;
  final String html;
  final int timestamp;
  final List<String> tags;
  final String status;
  final String? title;
  final List<UiConfig> uiConfigs;
  final List<Map<String, dynamic>>? assets; // Extracted assets
  final String? rawText; // Original user input text
  final String? address;
  final String? failureReason;

  CardUpdatedMessage({
    required this.id,
    required this.html,
    required this.timestamp,
    required this.tags,
    required this.status,
    required this.uiConfigs,
    this.title,
    this.assets,
    this.rawText,
    this.address,
    this.failureReason,
  }) : super(
          type: EventBusMessageType.cardUpdated,
          data: {
            'id': id,
            'html': html,
            'timestamp': timestamp,
            'tags': tags,
            'status': status,
            if (title != null) 'title': title,
            'ui_configs': uiConfigs.map((e) => e.toJson()).toList(),
            if (assets != null && assets.isNotEmpty) 'assets': assets,
            if (rawText != null) 'raw_text': rawText,
            if (address != null) 'address': address,
            if (failureReason != null) 'failure_reason': failureReason,
          },
        );

  factory CardUpdatedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    // Parse ui_configs
    List<UiConfig> configs = [];
    if (data['ui_configs'] != null) {
      final list = data['ui_configs'] as List;
      configs = list.map((e) => UiConfig.fromJson(e)).toList();
    }

    return CardUpdatedMessage(
      id: data['id'] as String,
      html: data['html'] as String? ?? '',
      timestamp: data['timestamp'] as int,
      tags:
          (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      status: data['status'] as String? ?? 'processing',
      title: data['title'] as String?,
      uiConfigs: configs,
      assets: (data['assets'] as List<dynamic>?)
          ?.map((a) => a as Map<String, dynamic>)
          .toList(),
      rawText: data['raw_text'] as String?,
      address: data['address'] as String?,
      failureReason: data['failure_reason'] as String?,
    );
  }
}

/// New card created message
class CardAddedMessage extends EventBusMessage {
  final String id;
  final String html;
  final int timestamp;
  final List<String> tags;
  final String status;
  final String? title;
  final List<UiConfig> uiConfigs;
  final List<Map<String, dynamic>>? assets; // Extracted assets
  final String? rawText; // Original user input text
  final String? address;

  CardAddedMessage({
    required this.id,
    required this.html,
    required this.timestamp,
    required this.tags,
    required this.status,
    required this.uiConfigs,
    this.title,
    this.assets,
    this.rawText,
    this.address,
  }) : super(
          type: EventBusMessageType.cardAdded,
          data: {
            'id': id,
            'html': html,
            'timestamp': timestamp,
            'tags': tags,
            'status': status,
            if (title != null) 'title': title,
            'ui_configs': uiConfigs.map((e) => e.toJson()).toList(),
            if (assets != null && assets.isNotEmpty) 'assets': assets,
            if (rawText != null) 'raw_text': rawText,
            if (address != null) 'address': address,
          },
        );

  factory CardAddedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    // Parse ui_configs
    List<UiConfig> configs = [];
    if (data['ui_configs'] != null) {
      final list = data['ui_configs'] as List;
      configs = list.map((e) => UiConfig.fromJson(e)).toList();
    }

    return CardAddedMessage(
      id: data['id'] as String,
      html: data['html'] as String? ?? '',
      timestamp: data['timestamp'] as int,
      tags:
          (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      status: data['status'] as String? ?? 'processing',
      title: data['title'] as String?,
      uiConfigs: configs,
      assets: (data['assets'] as List<dynamic>?)
          ?.map((a) => a as Map<String, dynamic>)
          .toList(),
      rawText: data['raw_text'] as String?,
      address: data['address'] as String?,
    );
  }
}

/// Card detail updated (notify detail page to refresh)
class CardDetailUpdatedMessage extends EventBusMessage {
  final String cardId;

  CardDetailUpdatedMessage({required this.cardId})
      : super(
          type: EventBusMessageType.cardDetailUpdated,
          data: {'card_id': cardId},
        );

  factory CardDetailUpdatedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CardDetailUpdatedMessage(cardId: data['card_id'] as String);
  }
}

class NewInsightMessage extends EventBusMessage {
  final String insightId;
  final String html;

  NewInsightMessage({required this.insightId, required this.html})
      : super(
          type: EventBusMessageType.newInsight,
          data: {'insight_id': insightId, 'html': html},
        );

  factory NewInsightMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NewInsightMessage(
      insightId: data['insight_id'] as String,
      html: data['html'] as String,
    );
  }
}

/// Schedule Aggregation Updated Message
class ScheduleAggregationUpdatedMessage extends EventBusMessage {
  final String aggregationId;

  ScheduleAggregationUpdatedMessage({required this.aggregationId})
      : super(
          type: EventBusMessageType.scheduleAggregationUpdated,
          data: {'aggregation_id': aggregationId},
        );

  factory ScheduleAggregationUpdatedMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>;
    return ScheduleAggregationUpdatedMessage(
      aggregationId: data['aggregation_id'] as String,
    );
  }
}

/// Unknown message type
class UnknownMessage extends EventBusMessage {
  UnknownMessage({required super.data})
      : super(type: EventBusMessageType.unknown);

  factory UnknownMessage.fromJson(Map<String, dynamic> json) {
    return UnknownMessage(data: json['data'] as Map<String, dynamic>? ?? {});
  }
}

/// New System Action Message (Trigger sync)
class NewSystemActionMessage extends EventBusMessage {
  NewSystemActionMessage()
      : super(type: EventBusMessageType.newSystemAction, data: {});

  factory NewSystemActionMessage.fromJson(Map<String, dynamic> json) {
    return NewSystemActionMessage();
  }
}

/// Invalid Model Config Message (Trigger alert dialog)
class InvalidModelConfigMessage extends EventBusMessage {
  final String agentId;
  final String configKey;

  InvalidModelConfigMessage({required this.agentId, required this.configKey})
      : super(
          type: EventBusMessageType.invalidModelConfig,
          data: {'agent_id': agentId, 'config_key': configKey},
        );

  factory InvalidModelConfigMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return InvalidModelConfigMessage(
      agentId: data['agent_id'] as String,
      configKey: data['config_key'] as String,
    );
  }
}

/// LLM config changed message (refresh model-dependent UI state).
class LLMConfigChangedMessage extends EventBusMessage {
  final bool hasValidConfig;
  final String reason;

  LLMConfigChangedMessage({required this.hasValidConfig, required this.reason})
      : super(
          type: EventBusMessageType.llmConfigChanged,
          data: {'has_valid_config': hasValidConfig, 'reason': reason},
        );

  factory LLMConfigChangedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return LLMConfigChangedMessage(
      hasValidConfig: data['has_valid_config'] as bool? ?? false,
      reason: data['reason'] as String? ?? 'updated',
    );
  }
}

/// Error Notification Message (Trigger error alert dialog)
class ErrorNotificationMessage extends EventBusMessage {
  final String errorCategory;
  final String errorMessage;
  final String? cardId;

  ErrorNotificationMessage({
    required this.errorCategory,
    required this.errorMessage,
    this.cardId,
  }) : super(
          type: EventBusMessageType.errorNotification,
          data: {
            'error_category': errorCategory,
            'error_message': errorMessage,
            if (cardId != null) 'card_id': cardId,
          },
        );

  factory ErrorNotificationMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ErrorNotificationMessage(
      errorCategory: data['error_category'] as String,
      errorMessage: data['error_message'] as String,
      cardId: data['card_id'] as String?,
    );
  }
}

/// Attachments changed for a card (system actions, clarification requests, etc.)
class AttachmentsChangedMessage extends EventBusMessage {
  final String? factId;

  AttachmentsChangedMessage({this.factId})
      : super(
          type: EventBusMessageType.attachmentsChanged,
          data: {if (factId != null) 'fact_id': factId},
        );

  factory AttachmentsChangedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AttachmentsChangedMessage(factId: data['fact_id'] as String?);
  }
}

class ProfileUpdatedMessage extends EventBusMessage {
  final String userId;
  final String? avatar;

  ProfileUpdatedMessage({required this.userId, this.avatar})
      : super(
          type: EventBusMessageType.profileUpdated,
          data: {'user_id': userId, if (avatar != null) 'avatar': avatar},
        );

  factory ProfileUpdatedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ProfileUpdatedMessage(
      userId: data['user_id'] as String? ?? '',
      avatar: data['avatar'] as String?,
    );
  }
}

class CharacterUpdatedMessage extends EventBusMessage {
  final String userId;
  final String characterId;

  CharacterUpdatedMessage({required this.userId, required this.characterId})
      : super(
          type: EventBusMessageType.characterUpdated,
          data: {'user_id': userId, 'character_id': characterId},
        );

  factory CharacterUpdatedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return CharacterUpdatedMessage(
      userId: data['user_id'] as String? ?? '',
      characterId: data['character_id'] as String? ?? '',
    );
  }
}

/// Notifies persona chat screen that a new message was added mid-turn
/// (e.g. an action message written by a tool during agent execution).
class PersonaChatMessageAddedMessage extends EventBusMessage {
  final String characterId;
  final bool? replyPending;

  PersonaChatMessageAddedMessage({
    required this.characterId,
    this.replyPending,
  }) : super(
          type: EventBusMessageType.personaChatMessageAdded,
          data: {
            'character_id': characterId,
            if (replyPending != null) 'reply_pending': replyPending,
          },
        );

  factory PersonaChatMessageAddedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PersonaChatMessageAddedMessage(
      characterId: data['character_id'] as String? ?? '',
      replyPending: data['reply_pending'] as bool?,
    );
  }
}

class PersonaChatUnreadChangedMessage extends EventBusMessage {
  final String? characterId;

  PersonaChatUnreadChangedMessage({this.characterId})
      : super(
          type: EventBusMessageType.personaChatUnreadChanged,
          data: {
            if (characterId != null) 'character_id': characterId,
          },
        );

  factory PersonaChatUnreadChangedMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return PersonaChatUnreadChangedMessage(
      characterId: data['character_id'] as String?,
    );
  }
}

class BackupSnapshotsChangedMessage extends EventBusMessage {
  final String reason;
  final String? snapshotId;

  BackupSnapshotsChangedMessage({this.reason = 'updated', this.snapshotId})
      : super(
          type: EventBusMessageType.backupSnapshotsChanged,
          data: {
            'reason': reason,
            if (snapshotId != null) 'snapshot_id': snapshotId,
          },
        );

  factory BackupSnapshotsChangedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BackupSnapshotsChangedMessage(
      reason: data['reason'] as String? ?? 'updated',
      snapshotId: data['snapshot_id'] as String?,
    );
  }
}

class BackupRestoredMessage extends EventBusMessage {
  final String userId;
  final String sourcePath;

  BackupRestoredMessage({required this.userId, required this.sourcePath})
      : super(
          type: EventBusMessageType.backupRestored,
          data: {'user_id': userId, 'source_path': sourcePath},
        );

  factory BackupRestoredMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BackupRestoredMessage(
      userId: data['user_id'] as String? ?? '',
      sourcePath: data['source_path'] as String? ?? '',
    );
  }
}

import 'timeline_card_model.dart';

/// EventBus message type
enum EventBusMessageType {
  cardUpdated('card_updated'),
  cardAdded('card_added'),
  cardDetailUpdated('card_detail_updated'),
  newInsight('new_insight'),
  newSystemAction('new_system_action'),
  invalidModelConfig('invalid_model_config'),
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

  EventBusMessage({
    required this.type,
    required this.data,
  });

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
      case EventBusMessageType.newSystemAction:
        return NewSystemActionMessage.fromJson(json);
      case EventBusMessageType.invalidModelConfig:
        return InvalidModelConfigMessage.fromJson(json);
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

  CardDetailUpdatedMessage({
    required this.cardId,
  }) : super(
          type: EventBusMessageType.cardDetailUpdated,
          data: {
            'card_id': cardId,
          },
        );

  factory CardDetailUpdatedMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CardDetailUpdatedMessage(
      cardId: data['card_id'] as String,
    );
  }
}

class NewInsightMessage extends EventBusMessage {
  final String insightId;
  final String html;

  NewInsightMessage({
    required this.insightId,
    required this.html,
  }) : super(
          type: EventBusMessageType.newInsight,
          data: {
            'insight_id': insightId,
            'html': html,
          },
        );

  factory NewInsightMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NewInsightMessage(
      insightId: data['insight_id'] as String,
      html: data['html'] as String,
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
      : super(
          type: EventBusMessageType.newSystemAction,
          data: {},
        );

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
          data: {
            'agent_id': agentId,
            'config_key': configKey,
          },
        );

  factory InvalidModelConfigMessage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return InvalidModelConfigMessage(
      agentId: data['agent_id'] as String,
      configKey: data['config_key'] as String,
    );
  }
}

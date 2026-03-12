/// Typed model for timeline card YAML file (Cards/.../*.yaml).
/// Used by FileSystemService.readCardFile / updateCardFile / safeWriteCardFile.
/// UiConfig is shared with TimelineCardModel and event bus messages.

/// Render configuration for a single card template (shared with timeline/event bus).
class UiConfig {
  final String templateId;
  final Map<String, dynamic> data;

  const UiConfig({required this.templateId, required this.data});

  factory UiConfig.fromJson(Map<String, dynamic> json) {
    return UiConfig(
      templateId: json['template_id'] as String? ?? 'classic_card',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'data': data,
    };
  }
}

/// Insight section stored in card YAML (text, summary, related_facts, character_id).
class CardInsight {
  final String? text;
  final String? summary;
  final List<RelatedFact> relatedFacts;
  final String? characterId;

  const CardInsight({
    this.text,
    this.summary,
    List<RelatedFact>? relatedFacts,
    this.characterId,
  }) : relatedFacts = relatedFacts ?? const [];

  factory CardInsight.fromJson(Map<String, dynamic> json) {
    final raw = json['related_facts'];
    List<RelatedFact> list = [];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map && e['id'] != null) {
          list.add(RelatedFact(id: e['id'].toString()));
        }
      }
    }
    return CardInsight(
      text: json['text'] as String?,
      summary: json['summary'] as String?,
      relatedFacts: list,
      characterId: json['character_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (text != null) m['text'] = text;
    if (summary != null) m['summary'] = summary;
    if (relatedFacts.isNotEmpty) {
      m['related_facts'] = relatedFacts.map((e) => {'id': e.id}).toList();
    }
    if (characterId != null) m['character_id'] = characterId;
    return m;
  }
}

class RelatedFact {
  final String id;

  const RelatedFact({required this.id});
}

/// Timeline card data (YAML file content).
class CardData {
  final String factId;
  final int timestamp;
  final String status;
  final List<String> tags;
  final List<UiConfig> uiConfigs;
  final String? title;
  final String? address;
  final int? userFixedTimestamp;
  final String? userFixedAddress;
  final UserFixedLocation? userFixedLocation;
  final List<CardComment> comments;
  final CardInsight? insight;
  final bool? deleted;
  final String? failureReason;

  const CardData({
    required this.factId,
    required this.timestamp,
    required this.status,
    required this.tags,
    required this.uiConfigs,
    this.title,
    this.address,
    this.userFixedTimestamp,
    this.userFixedAddress,
    this.userFixedLocation,
    List<CardComment>? comments,
    this.insight,
    this.deleted,
    this.failureReason,
  }) : comments = comments ?? const [];

  factory CardData.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    List<String> tagsList = [];
    if (tagsRaw is List) {
      tagsList = tagsRaw.map((e) => e.toString()).toList();
    }

    final uiConfigsRaw = json['ui_configs'];
    List<UiConfig> uiConfigsList = [];
    if (uiConfigsRaw is List) {
      for (final e in uiConfigsRaw) {
        if (e is Map<String, dynamic>) {
          uiConfigsList.add(UiConfig.fromJson(e));
        }
      }
    }
    if (uiConfigsList.isEmpty && json['ui_config'] is Map) {
      uiConfigsList.add(UiConfig.fromJson(
          Map<String, dynamic>.from(json['ui_config'] as Map)));
    }

    final commentsRaw = json['comments'];
    List<CardComment> commentsList = [];
    if (commentsRaw is List) {
      for (final e in commentsRaw) {
        if (e is Map<String, dynamic>) {
          commentsList.add(CardComment.fromJson(e));
        }
      }
    }

    final userLoc = json['user_fixed_location'];
    UserFixedLocation? userFixedLocation;
    if (userLoc is Map) {
      userFixedLocation = UserFixedLocation.fromJson(
        Map<String, dynamic>.from(userLoc),
      );
    }

    CardInsight? insightData;
    if (json['insight'] is Map) {
      insightData = CardInsight.fromJson(
          Map<String, dynamic>.from(json['insight'] as Map));
    }

    return CardData(
      factId: json['fact_id'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? 0,
      status: json['status'] as String? ?? 'processing',
      tags: tagsList,
      uiConfigs: uiConfigsList,
      title: json['title'] as String?,
      address: json['address'] as String?,
      userFixedTimestamp: json['user_fixed_timestamp'] as int?,
      userFixedAddress: json['user_fixed_address'] as String?,
      userFixedLocation: userFixedLocation,
      comments: commentsList,
      insight: insightData,
      deleted: json['deleted'] as bool?,
      failureReason: json['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'fact_id': factId,
      'timestamp': timestamp,
      'status': status,
      'tags': tags,
      'ui_configs': uiConfigs.map((e) => e.toJson()).toList(),
    };
    if (title != null) m['title'] = title;
    if (address != null) m['address'] = address;
    if (userFixedTimestamp != null)
      m['user_fixed_timestamp'] = userFixedTimestamp;
    if (userFixedAddress != null) m['user_fixed_address'] = userFixedAddress;
    if (userFixedLocation != null)
      m['user_fixed_location'] = userFixedLocation!.toJson();
    if (comments.isNotEmpty)
      m['comments'] = comments.map((e) => e.toJson()).toList();
    if (insight != null) m['insight'] = insight!.toJson();
    if (deleted == true) m['deleted'] = deleted;
    if (failureReason != null) m['failure_reason'] = failureReason;
    return m;
  }

  CardData copyWith({
    String? factId,
    int? timestamp,
    String? status,
    List<String>? tags,
    List<UiConfig>? uiConfigs,
    String? title,
    String? address,
    int? userFixedTimestamp,
    String? userFixedAddress,
    UserFixedLocation? userFixedLocation,
    List<CardComment>? comments,
    CardInsight? insight,
    bool? deleted,
    String? failureReason,
  }) {
    return CardData(
      factId: factId ?? this.factId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      uiConfigs: uiConfigs ?? this.uiConfigs,
      title: title ?? this.title,
      address: address ?? this.address,
      userFixedTimestamp: userFixedTimestamp ?? this.userFixedTimestamp,
      userFixedAddress: userFixedAddress ?? this.userFixedAddress,
      userFixedLocation: userFixedLocation ?? this.userFixedLocation,
      comments: comments ?? this.comments,
      insight: insight ?? this.insight,
      deleted: deleted ?? this.deleted,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

class CardComment {
  final String id;
  final String content;
  final bool isAi;
  final int timestamp;
  final String? characterId;

  const CardComment({
    required this.id,
    required this.content,
    required this.isAi,
    required this.timestamp,
    this.characterId,
  });

  factory CardComment.fromJson(Map<String, dynamic> json) {
    final charId = json['character_id'];
    return CardComment(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isAi: json['is_ai'] as bool? ?? false,
      timestamp: json['timestamp'] as int? ?? 0,
      characterId: charId?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'content': content,
      'is_ai': isAi,
      'timestamp': timestamp,
    };
    if (characterId != null) m['character_id'] = characterId;
    return m;
  }
}

class UserFixedLocation {
  final double? lat;
  final double? lng;
  final String? name;

  const UserFixedLocation({this.lat, this.lng, this.name});

  factory UserFixedLocation.fromJson(Map<String, dynamic> json) {
    final lat = json['lat'];
    final lng = json['lng'];
    return UserFixedLocation(
      lat: lat is num ? lat.toDouble() : null,
      lng: lng is num ? lng.toDouble() : null,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (lat != null) m['lat'] = lat;
    if (lng != null) m['lng'] = lng;
    if (name != null) m['name'] = name;
    return m;
  }
}

import 'timeline_card_model.dart';

/// Card detail model for detail page
class CardDetailModel {
  final String id;
  final String title;
  final DateTime timestamp;
  final String address;
  final double? lat;
  final double? lng;
  final List<String> tags;
  final String rawContent;
  final InsightData insight;
  final List<AssetData> assets;
  final LLMStats? llmStats;
  final List<UiConfig> uiConfigs;

  CardDetailModel({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.address,
    this.lat,
    this.lng,
    required this.tags,
    required this.rawContent,
    required this.insight,
    required this.assets,
    this.llmStats,
    this.uiConfigs = const [],
  });

  factory CardDetailModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    List<UiConfig> configs = [];
    if (json['ui_configs'] != null) {
      configs = (json['ui_configs'] as List)
          .map((e) => UiConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CardDetailModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['timestamp'] as int? ?? 0) * 1000,
              isUtc: true,
            ).toLocal()
          : DateTime.now(),
      // Priority: location.name -> address
      address: (location != null && location['name'] != null)
          ? location['name'] as String
          : (json['address'] as String? ?? 'Unknown'),
      // Priority: location.lat/lng -> lat/lng
      lat: (location != null && location['lat'] != null)
          ? (location['lat'] as num?)?.toDouble()
          : (json['lat'] as num?)?.toDouble(),
      lng: (location != null && location['lng'] != null)
          ? (location['lng'] as num?)?.toDouble()
          : (json['lng'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      rawContent: json['raw_content'] as String? ?? '',
      insight:
          json['insight'] != null && json['insight'] is Map<String, dynamic>
              ? InsightData.fromJson(json['insight'] as Map<String, dynamic>)
              : InsightData.fromJson({}),
      assets: (json['assets'] as List<dynamic>? ?? const [])
          .where((asset) => asset != null && asset is Map<String, dynamic>)
          .map((asset) => AssetData.fromJson(asset as Map<String, dynamic>))
          .toList(),
      llmStats: json['llm_stats'] != null
          ? LLMStats.fromJson(json['llm_stats'] as Map<String, dynamic>)
          : null,
      uiConfigs: configs,
    );
  }

  CardDetailModel copyWith({
    String? id,
    String? title,
    DateTime? timestamp,
    String? address,
    double? lat,
    double? lng,
    List<String>? tags,
    String? rawContent,
    InsightData? insight,
    List<AssetData>? assets,
    LLMStats? llmStats,
    List<UiConfig>? uiConfigs,
  }) {
    return CardDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tags: tags ?? this.tags,
      rawContent: rawContent ?? this.rawContent,
      insight: insight ?? this.insight,
      assets: assets ?? this.assets,
      llmStats: llmStats ?? this.llmStats,
      uiConfigs: uiConfigs ?? this.uiConfigs,
    );
  }
}

class CharacterInfo {
  final String id;
  final String name;
  final List<String> tags;
  final String? avatar;

  CharacterInfo({
    required this.id,
    required this.name,
    required this.tags,
    this.avatar,
  });

  factory CharacterInfo.fromJson(Map<String, dynamic> json) {
    return CharacterInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      avatar: json['avatar'] as String?,
    );
  }
}

class Comment {
  final String id;
  final String content;
  final bool isAi;
  final int timestamp;
  final CharacterInfo? character;
  final String? replyToId;
  final String? replyToName;

  Comment({
    required this.id,
    required this.content,
    required this.isAi,
    required this.timestamp,
    this.character,
    this.replyToId,
    this.replyToName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isAi: json['is_ai'] as bool? ?? false,
      timestamp: json['timestamp'] as int? ?? 0,
      character: json['character'] != null
          ? CharacterInfo.fromJson(json['character'] as Map<String, dynamic>)
          : null,
      replyToId: json['reply_to_id'] as String?,
      replyToName: json['reply_to_name'] as String?,
    );
  }
}

class InsightData {
  final String text;
  final List<RelatedCard> relatedCards;
  final String? characterId;
  final CharacterInfo? character;
  final String? summary;
  final List<Comment> comments;

  InsightData({
    required this.text,
    required this.relatedCards,
    this.characterId,
    this.character,
    this.summary,
    required this.comments,
  });

  factory InsightData.fromJson(Map<String, dynamic> json) {
    return InsightData(
      text: json['text'] as String? ?? '',
      relatedCards: (json['related_cards'] as List<dynamic>? ?? const [])
          .map((card) => RelatedCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      characterId: json['character_id'] as String?,
      character: json['character'] != null
          ? CharacterInfo.fromJson(json['character'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] as String?,
      comments: (json['comments'] as List<dynamic>? ?? const [])
          .map((comment) => Comment.fromJson(comment as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RelatedCard {
  final String id;
  final String title;
  final String date;
  final String rawContent;
  final List<AssetData> assets;

  RelatedCard({
    required this.id,
    required this.title,
    required this.date,
    required this.rawContent,
    required this.assets,
  });

  factory RelatedCard.fromJson(Map<String, dynamic> json) {
    return RelatedCard(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] as String? ?? '',
      rawContent: json['raw_content'] as String? ?? '',
      assets: (json['assets'] as List<dynamic>? ?? const [])
          .where((asset) => asset != null && asset is Map<String, dynamic>)
          .map((asset) => AssetData.fromJson(asset as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AssetData {
  final String type; // 'image' | 'audio'
  final String url;

  AssetData({
    required this.type,
    required this.url,
  });

  factory AssetData.fromJson(Map<String, dynamic> json) {
    return AssetData(
      type: json['type'] as String? ?? 'image',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }

  bool get isImage => type == 'image';
  bool get isAudio => type == 'audio';
}

/// LLM call stats
class LLMStats {
  final int totalCalls;
  final int totalPromptTokens;
  final int totalCompletionTokens;
  final int totalCachedTokens;
  final int totalCacheBaseTokens;
  final int totalCacheUnknownTokens;
  final int totalThoughtTokens;
  final int totalTokens;
  final double totalCost;
  final Map<String, AgentStats> byAgent;

  LLMStats({
    required this.totalCalls,
    required this.totalPromptTokens,
    required this.totalCompletionTokens,
    required this.totalCachedTokens,
    this.totalCacheBaseTokens = 0,
    this.totalCacheUnknownTokens = 0,
    required this.totalThoughtTokens,
    required this.totalTokens,
    this.totalCost = 0.0,
    required this.byAgent,
  });

  factory LLMStats.fromJson(Map<String, dynamic> json) {
    final byAgentData = json['by_agent'] as Map<String, dynamic>? ?? {};
    final byAgent = byAgentData.map((key, value) => MapEntry(
          key,
          AgentStats.fromJson(value as Map<String, dynamic>),
        ));

    return LLMStats(
      totalCalls: json['total_calls'] as int? ?? 0,
      totalPromptTokens: json['total_prompt_tokens'] as int? ?? 0,
      totalCompletionTokens: json['total_completion_tokens'] as int? ?? 0,
      totalCachedTokens: json['total_cached_tokens'] as int? ?? 0,
      totalCacheBaseTokens: json['total_cache_base_tokens'] as int? ?? 0,
      totalCacheUnknownTokens: json['total_cache_unknown_tokens'] as int? ?? 0,
      totalThoughtTokens: json['total_thought_tokens'] as int? ?? 0,
      totalTokens: json['total_tokens'] as int? ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      byAgent: byAgent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_calls': totalCalls,
      'total_prompt_tokens': totalPromptTokens,
      'total_completion_tokens': totalCompletionTokens,
      'total_cached_tokens': totalCachedTokens,
      'total_cache_base_tokens': totalCacheBaseTokens,
      'total_cache_unknown_tokens': totalCacheUnknownTokens,
      'total_thought_tokens': totalThoughtTokens,
      'total_tokens': totalTokens,
      'total_cost': totalCost,
      'by_agent': byAgent.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

/// Agent stats
class AgentStats {
  final int calls;
  final int promptTokens;
  final int completionTokens;
  final int cachedTokens;
  final int cacheBaseTokens;
  final int cacheUnknownTokens;
  final int thoughtTokens;
  final int totalTokens;
  final double totalCost;

  AgentStats({
    required this.calls,
    required this.promptTokens,
    required this.completionTokens,
    required this.cachedTokens,
    this.cacheBaseTokens = 0,
    this.cacheUnknownTokens = 0,
    required this.thoughtTokens,
    required this.totalTokens,
    this.totalCost = 0.0,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      calls: json['calls'] as int? ?? 0,
      promptTokens: json['prompt_tokens'] as int? ?? 0,
      completionTokens: json['completion_tokens'] as int? ?? 0,
      cachedTokens: json['cached_tokens'] as int? ?? 0,
      cacheBaseTokens: json['cache_base_tokens'] as int? ?? 0,
      cacheUnknownTokens: json['cache_unknown_tokens'] as int? ?? 0,
      thoughtTokens: json['thought_tokens'] as int? ?? 0,
      totalTokens: json['total_tokens'] as int? ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calls': calls,
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'cached_tokens': cachedTokens,
      'cache_base_tokens': cacheBaseTokens,
      'cache_unknown_tokens': cacheUnknownTokens,
      'thought_tokens': thoughtTokens,
      'total_tokens': totalTokens,
      'total_cost': totalCost,
    };
  }
}

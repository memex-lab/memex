class LLMConfig {
  static const String defaultClientKey = 'default';

  static const String typeGemini = 'gemini';
  static const String typeGeminiOauth = 'gemini_oauth';
  static const String typeChatCompletion = 'chat_completion';
  static const String typeResponses = 'responses';
  static const String typeBedrockClaude = 'bedrock_claude';
  static const String typeClaude = 'claude';
  static const String typeOpenAiOauth = 'openai_oauth';

  /// Models that require a ChatGPT Pro/Plus subscription (OpenAI OAuth only).
  static const Set<String> chatgptProOnlyModels = {'gpt-5.4', 'gpt-5.3-codex'};

  /// Whether [modelId] requires a ChatGPT Pro/Plus subscription.
  static bool isChatgptProModel(String modelId) =>
      chatgptProOnlyModels.contains(modelId);

  /// Recommended model IDs per provider type.
  static List<String> recommendedModels(String type) {
    switch (type) {
      case typeGemini:
      case typeGeminiOauth:
        return const [
          'gemini-3.1-pro-preview',
          'gemini-3-flash-preview',
          'gemini-3.1-flash-lite-preview',
          'gemini-2.5-flash',
          'gemini-2.5-pro'
        ];
      case typeChatCompletion:
      case typeResponses:
        return const [
          'gpt-5.4',
          'gpt-5.4-pro',
          'gpt-5-mini',
          'o1',
          'o1-mini',
          'o3',
          'o3-pro',
          'o3-mini',
          'gpt-5.2',
          'gpt-5.2-codex',
          'gpt-5.1-codex-max',
          'gpt-5.1-codex-mini',
          'gpt-5.3-codex',
          'gpt-5.1-codex',
          'gpt-4.1',
        ];
      case typeOpenAiOauth:
        return const [
          'gpt-5.2',
          'gpt-5.1-codex-max',
          'gpt-5.1-codex-mini',
          'gpt-5.2-codex',
          'gpt-5.3-codex',
          'gpt-5.1-codex',
          'gpt-5.4',
        ];
      case typeClaude:
        return const [
          'claude-opus-4-6',
          'claude-sonnet-4-6',
          'claude-haiku-4-5-20251001',
        ];
      case typeBedrockClaude:
        return const [
          'us.anthropic.claude-opus-4-6-v1',
          'global.anthropic.claude-opus-4-6-v1',
          'us.anthropic.claude-sonnet-4-6',
          'global.anthropic.claude-sonnet-4-6',
          'us.anthropic.claude-haiku-4-5-20251001-v1:0',
          'global.anthropic.claude-haiku-4-5-20251001-v1:0',
        ];
      default:
        return const [];
    }
  }

  /// Default base URL for a given provider type.
  static String defaultBaseUrl(String type) {
    switch (type) {
      case typeGemini:
        return 'https://generativelanguage.googleapis.com/v1beta';
      case typeClaude:
        return 'https://api.anthropic.com';
      case typeChatCompletion:
      case typeResponses:
        return 'https://api.openai.com/v1';
      case typeOpenAiOauth:
        return 'https://chatgpt.com/backend-api/codex';
      default:
        return '';
    }
  }

  /// Get valid API Key (return default if empty)
  String getEffectiveApiKey() {
    if (apiKey.isNotEmpty) {
      return apiKey;
    }
    return apiKey;
  }

  final String key;
  final String type;
  final String modelId;
  final String apiKey;
  final String baseUrl;
  final String? proxyUrl; // Added proxyUrl
  final Map<String, dynamic> extra;
  final double? temperature;
  final int? maxTokens;
  final double? topP;

  const LLMConfig({
    required this.key,
    required this.type,
    required this.modelId,
    required this.apiKey,
    required this.baseUrl,
    this.proxyUrl,
    this.extra = const {},
    this.temperature,
    this.maxTokens,
    this.topP,
  });

  bool get isDefault => key == defaultClientKey;

  /// Check if this config is valid
  bool get isValid {
    if (type.isEmpty || modelId.isEmpty) {
      return false;
    }
    // OpenAI OAuth uses its own internal token, so apiKey is allowed to be empty
    if ((type == typeResponses ||
            type == typeChatCompletion ||
            type == typeClaude ||
            type == typeGemini) &&
        getEffectiveApiKey().isEmpty) {
      return false;
    }
    if ([typeGemini, typeChatCompletion, typeResponses, typeClaude]
        .contains(type)) {
      return baseUrl.isNotEmpty;
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'type': type,
      'modelId': modelId,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'proxyUrl': proxyUrl,
      'extra': extra,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'topP': topP,
    };
  }

  factory LLMConfig.fromJson(Map<String, dynamic> json) {
    return LLMConfig(
      key: json['key'] as String,
      type: json['type'] as String,
      modelId: json['modelId'] as String,
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String,
      proxyUrl: json['proxyUrl'] as String?,
      extra: json['extra'] as Map<String, dynamic>? ?? {},
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxTokens: json['maxTokens'] as int?,
      topP: (json['topP'] as num?)?.toDouble(),
    );
  }

  LLMConfig copyWith({
    String? key,
    String? type,
    String? modelId,
    String? apiKey,
    String? baseUrl,
    String? proxyUrl,
    Map<String, dynamic>? extra,
    double? temperature,
    int? maxTokens,
    double? topP,
  }) {
    return LLMConfig(
      key: key ?? this.key,
      type: type ?? this.type,
      modelId: modelId ?? this.modelId,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      extra: extra ?? this.extra,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
    );
  }

  static LLMConfig createDefaultClientConfig() {
    return const LLMConfig(
      key: defaultClientKey,
      baseUrl: "https://api.openai.com/v1",
      type: typeChatCompletion,
      modelId: 'gpt-5.4',
      maxTokens: 65536,
      apiKey: '',
      extra: {"reasoning_effort": "medium"},
    );
  }

  static LLMConfig createDefaultConfig(String key, String type) {
    if (key == defaultClientKey) {
      return createDefaultClientConfig();
    }
    throw Exception('Unknown LLM config key: $key');
  }
}

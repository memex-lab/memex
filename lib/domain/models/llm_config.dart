import 'package:memex/config/app_flavor.dart';

class LLMConfig {
  static const String defaultClientKey = 'default';

  static const String typeGemini = 'gemini';
  static const String typeGeminiOauth = 'gemini_oauth';
  static const String typeChatCompletion = 'chat_completion';
  static const String typeResponses = 'responses';
  static const String typeBedrockClaude = 'bedrock_claude';
  static const String typeClaude = 'claude';
  static const String typeOpenAiOauth = 'openai_oauth';

  // Chinese LLM providers & aggregators
  static const String typeKimi = 'kimi';
  static const String typeQwen = 'qwen';
  static const String typeSeed = 'seed';
  static const String typeZhipu = 'zhipu';
  static const String typeDeepSeek = 'deepseek';
  static const String typeMinimax = 'minimax';
  static const String typeOpenRouter = 'openrouter';
  static const String typeOllama = 'ollama';
  static const String typeMimo = 'mimo';
  static const String typeMemex = 'memex';

  /// User-friendly display name for a provider type.
  /// Only OpenAI and Anthropic types need special handling since their
  /// dropdown sub-items show generic labels like "API Key".
  static String providerDisplayName(String type) {
    switch (type) {
      case typeChatCompletion:
        return 'OpenAI (API Key)';
      case typeResponses:
        return 'OpenAI (Responses API)';
      case typeOpenAiOauth:
        return 'ChatGPT (OAuth)';
      case typeClaude:
        return 'Anthropic Claude (API Key)';
      case typeBedrockClaude:
        return 'AWS Bedrock Claude';
      case typeGemini:
        return 'Google Gemini';
      case typeGeminiOauth:
        return 'Google Gemini (OAuth)';
      case typeKimi:
        return 'Kimi';
      case typeQwen:
        return 'Aliyun';
      case typeSeed:
        return 'Volcengine';
      case typeZhipu:
        return 'Zhipu';
      case typeDeepSeek:
        return 'DeepSeek';
      case typeMinimax:
        return 'MiniMax';
      case typeMimo:
        return 'Xiaomi MIMO';
      case typeOpenRouter:
        return 'OpenRouter';
      case typeOllama:
        return 'Ollama';
      case typeMemex:
        return 'Memex AI';
      default:
        return type;
    }
  }

  /// Maps provider types that are compatible with existing client protocols.
  /// Returns the underlying client type to use, or null if the type is native.
  static String? underlyingClientType(String type) {
    switch (type) {
      case typeKimi:
      case typeQwen:
      case typeZhipu:
      case typeDeepSeek:
      case typeOpenRouter:
      case typeOllama:
      case typeMemex:
        return typeChatCompletion;
      case typeSeed:
        return typeResponses;
      case typeMinimax:
      case typeMimo:
        return typeClaude;
      default:
        return null; // native type, no mapping needed
    }
  }

  /// Human-readable display name for a provider type.
  static String displayName(String type) {
    switch (type) {
      case typeChatCompletion:
        return 'OpenAI';
      case typeResponses:
        return 'OpenAI (Responses)';
      case typeOpenAiOauth:
        return 'ChatGPT Pro/Plus';
      case typeClaude:
        return 'Anthropic';
      case typeBedrockClaude:
        return 'Bedrock Claude';
      case typeGemini:
        return 'Gemini';
      case typeGeminiOauth:
        return 'Gemini (OAuth)';
      case typeKimi:
        return 'Kimi';
      case typeQwen:
        return 'Aliyun';
      case typeSeed:
        return 'Volcengine';
      case typeZhipu:
        return 'Zhipu GLM';
      case typeDeepSeek:
        return 'DeepSeek';
      case typeMinimax:
        return 'MiniMax';
      case typeOpenRouter:
        return 'OpenRouter';
      case typeOllama:
        return 'Ollama';
      case typeMemex:
        return 'Memex AI';
      case typeMimo:
        return 'Xiaomi MIMO';
      default:
        return type;
    }
  }

  /// Models that require a ChatGPT Pro/Plus subscription (OpenAI OAuth only).
  static const Set<String> chatgptProOnlyModels = {
    'gpt-5.6',
    'gpt-5.6-sol',
    'gpt-5.6-terra',
    'gpt-5.6-luna',
    'gpt-5.5',
    'gpt-5.4',
    'gpt-5.3-codex',
  };

  /// Whether [modelId] requires a ChatGPT Pro/Plus subscription.
  static bool isChatgptProModel(String modelId) =>
      chatgptProOnlyModels.contains(modelId);

  /// Featured model IDs that get a "Recommended" badge, per provider type.
  static Set<String> featuredModels(String type) {
    switch (type) {
      case typeChatCompletion:
      case typeResponses:
        return const {
          'gpt-5.6-sol',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
        };
      case typeOpenAiOauth:
        return const {
          'gpt-5.6-sol',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
        };
      case typeClaude:
        return const {
          'claude-fable-5',
          'claude-opus-5',
          'claude-sonnet-5',
        };
      case typeBedrockClaude:
        return const {
          'anthropic.claude-fable-5',
          'anthropic.claude-opus-5',
          'anthropic.claude-sonnet-5',
        };
      case typeGemini:
      case typeGeminiOauth:
        return const {'gemini-3.6-flash', 'gemini-3.1-pro-preview'};
      case typeKimi:
        return const {'kimi-k3', 'kimi-k2.7-code'};
      case typeQwen:
        return const {'qwen3.8-max', 'qwen3.7-plus', 'qwen3.7-flash'};
      case typeSeed:
        return const {
          'doubao-seed-2-0-pro-260215',
          'doubao-seed-2-0-code-preview-260215',
        };
      case typeZhipu:
        return const {'glm-5.2', 'glm-5v-turbo'};
      case typeDeepSeek:
        return const {'deepseek-v4-flash', 'deepseek-v4-pro'};
      case typeMinimax:
        return const {'MiniMax-M3', 'MiniMax-M2.7'};
      case typeMimo:
        return const {'mimo-v2.5-pro', 'mimo-v2.5'};
      case typeOpenRouter:
        return const {
          'anthropic/claude-fable-5',
          'anthropic/claude-opus-5',
          'anthropic/claude-sonnet-5',
          'openai/gpt-5.6-sol',
          'openai/gpt-5.6-terra',
          'openai/gpt-5.6-luna',
          'google/gemini-3.6-flash',
          'google/gemini-3.1-pro-preview',
          'qwen/qwen3.8-max',
          'deepseek/deepseek-v4-pro',
          'minimax/minimax-m3',
          'z-ai/glm-5.2',
          'xiaomi/mimo-v2.5-pro',
          'moonshotai/kimi-k2.7-code',
        };
      case typeOllama:
        return const {'qwen3.5:9b', 'gemma4:12b', 'llama4:scout'};
      default:
        return const {};
    }
  }

  /// Recommended model IDs per provider type.
  ///
  /// This is a curated starter list rather than an exhaustive compatibility
  /// list. Prefer the current model family plus its immediate predecessor,
  /// retain distinct price/performance tiers within those families, and keep
  /// endpoint-specific models out of providers that cannot invoke them. Users
  /// can still enter older supported model IDs manually.
  static List<String> recommendedModels(String type) {
    switch (type) {
      case typeGemini:
      case typeGeminiOauth:
        return const [
          'gemini-3.6-flash',
          'gemini-3.1-pro-preview',
          'gemini-3.5-flash',
          'gemini-3.5-flash-lite',
        ];
      case typeChatCompletion:
        return const [
          'gpt-5.6-sol',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
          'gpt-5.5',
        ];
      case typeResponses:
        return const [
          'gpt-5.6-sol',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
          'gpt-5.5',
          'gpt-5.5-pro',
        ];
      case typeOpenAiOauth:
        return const [
          'gpt-5.6-sol',
          'gpt-5.6-terra',
          'gpt-5.6-luna',
          'gpt-5.5',
          'gpt-5.4',
          'gpt-5.4-mini',
          'gpt-5.3-codex',
        ];
      case typeClaude:
        return const [
          'claude-fable-5',
          'claude-opus-5',
          'claude-sonnet-5',
          'claude-opus-4-8',
          'claude-haiku-4-5-20251001',
        ];
      case typeBedrockClaude:
        return const [
          'anthropic.claude-fable-5',
          'anthropic.claude-opus-5',
          'anthropic.claude-sonnet-5',
          'anthropic.claude-opus-4-8',
          'global.anthropic.claude-opus-4-8',
          'us.anthropic.claude-opus-4-8',
          'us.anthropic.claude-haiku-4-5-20251001-v1:0',
          'global.anthropic.claude-haiku-4-5-20251001-v1:0',
        ];
      case typeKimi:
        return const [
          'kimi-k3',
          'kimi-k2.7-code',
          'kimi-k2.6',
          'kimi-k2.5',
        ];
      case typeQwen:
        return const [
          'qwen3.8-max',
          'qwen3.7-plus',
          'qwen3.7-flash',
          'qwen3.5-plus',
        ];
      case typeSeed:
        return const [
          'doubao-seed-2-0-pro-260215',
          'doubao-seed-2-0-code-preview-260215',
          'doubao-seed-2-0-mini-260428',
          'doubao-seed-2-0-lite-260428',
        ];
      case typeZhipu:
        return const ['glm-5.2', 'glm-5v-turbo', 'glm-4.6v'];
      case typeDeepSeek:
        return const ['deepseek-v4-flash', 'deepseek-v4-pro'];
      case typeMinimax:
        return const [
          'MiniMax-M3',
          'MiniMax-M2.7',
          'MiniMax-M2.7-highspeed',
          'MiniMax-M2.5',
        ];
      case typeOpenRouter:
        return const [
          'anthropic/claude-fable-5',
          'anthropic/claude-opus-5',
          'anthropic/claude-sonnet-5',
          'openai/gpt-5.6-sol',
          'openai/gpt-5.6-terra',
          'openai/gpt-5.6-luna',
          'google/gemini-3.6-flash',
          'google/gemini-3.1-pro-preview',
          'qwen/qwen3.8-max',
          'deepseek/deepseek-v4-pro',
          'minimax/minimax-m3',
          'z-ai/glm-5.2',
          'xiaomi/mimo-v2.5-pro',
          'moonshotai/kimi-k2.7-code',
        ];
      case typeOllama:
        return const [
          'qwen3.5:9b',
          'qwen3.5:4b',
          'gemma4:12b',
          'gemma4:e4b',
          'llama4:scout',
        ];
      case typeMimo:
        return const ['mimo-v2.5-pro', 'mimo-v2.5'];
      default:
        return const [];
    }
  }

  /// Whether this provider type requires an API key.
  /// Bedrock uses AWS credentials (access key / secret key) instead of apiKey.
  /// OAuth providers and Ollama don't need an API key either.
  static bool requiresApiKey(String type) {
    switch (type) {
      case typeOpenAiOauth:
      case typeGeminiOauth:
      case typeBedrockClaude:
      case typeOllama:
        return false;
      default:
        return true;
    }
  }

  /// Whether this provider type supports the OpenAI-compatible /v1/models endpoint.
  static bool supportsModelListing(String type) {
    switch (type) {
      case typeChatCompletion:
      case typeResponses:
      case typeClaude:
      case typeKimi:
      case typeQwen:
      case typeSeed:
      case typeZhipu:
      case typeDeepSeek:
      case typeMinimax:
      case typeMimo:
      case typeOpenRouter:
      case typeOllama:
      case typeGemini:
      case typeMemex:
        return true;
      default:
        return false;
    }
  }

  /// Returns the models endpoint URL for a given provider type and base URL.
  static String? modelsEndpoint(String type, String baseUrl) {
    if (!supportsModelListing(type) || baseUrl.isEmpty) return null;
    if (type == typeGemini) {
      return '$baseUrl/models';
    }
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    if (type == typeClaude || type == typeMinimax || type == typeMimo) {
      return base.endsWith('/v1') ? '$base/models' : '$base/v1/models';
    }
    return '$base/models';
  }

  /// Whether the model is known to support image input.
  ///
  /// This is intentionally conservative: unknown models return false so UI can
  /// warn before they are used for Media analysis.
  static bool isKnownMultimodal(String type, String modelId) {
    final id = modelId.trim().toLowerCase();
    if (id.isEmpty) return false;

    switch (type) {
      case typeGemini:
      case typeGeminiOauth:
        return id.startsWith('gemini-');
      case typeClaude:
      case typeBedrockClaude:
        return id.contains('claude-3') ||
            id.contains('claude-fable') ||
            id.contains('claude-sonnet') ||
            id.contains('claude-opus') ||
            id.contains('claude-haiku');
      case typeChatCompletion:
      case typeResponses:
      case typeOpenAiOauth:
        return id.contains('gpt-4o') ||
            id.contains('gpt-4.1') ||
            id.contains('gpt-5') ||
            id.contains('o3');
      case typeZhipu:
        return id.contains('glm-') && id.contains('v');
      case typeKimi:
        return id.startsWith('kimi-k3') ||
            id.startsWith('kimi-k2.7') ||
            id.startsWith('kimi-k2.6') ||
            id.startsWith('kimi-k2.5');
      case typeMimo:
        return id == 'mimo-v2.5' || id == 'mimo-v2-omni' || id.contains('omni');
      case typeQwen:
        return id.startsWith('qwen3.8-') ||
            id.startsWith('qwen3.7-plus') ||
            id.startsWith('qwen3.7-flash') ||
            id.startsWith('qwen3.6-') ||
            id.startsWith('qwen3.5-') ||
            id.contains('vl') ||
            id.contains('vision') ||
            id.contains('omni');
      case typeSeed:
        return id.startsWith('doubao-seed-2-0') ||
            id.contains('vision') ||
            id.contains('omni');
      case typeMinimax:
        return id == 'minimax-m3' ||
            id.contains('vl') ||
            id.contains('vision') ||
            id.contains('omni');
      case typeOllama:
        return id.startsWith('qwen3.5') ||
            id.startsWith('gemma4') ||
            id.startsWith('llama4');
      case typeOpenRouter:
      case typeMemex:
        return id.contains('gemini') ||
            id.contains('claude') ||
            id.contains('gpt-4o') ||
            id.contains('gpt-4.1') ||
            id.contains('gpt-5') ||
            id.contains('o3') ||
            id.contains('qwen-vl') ||
            id.contains('vision') ||
            id.contains('mimo-v2.5') ||
            id.contains('mimo-v2-omni') ||
            (id.contains('glm-') && id.contains('v'));
      default:
        return false;
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
      case typeKimi:
        return 'https://api.moonshot.cn/v1';
      case typeQwen:
        return 'https://dashscope.aliyuncs.com/compatible-mode/v1';
      case typeSeed:
        return 'https://ark.cn-beijing.volces.com/api/v3';
      case typeZhipu:
        return 'https://open.bigmodel.cn/api/paas/v4';
      case typeDeepSeek:
        return 'https://api.deepseek.com';
      case typeMinimax:
        return 'https://api.minimaxi.com/anthropic';
      case typeOpenRouter:
        return 'https://openrouter.ai/api/v1';
      case typeOllama:
        return 'http://localhost:11434/v1';
      case typeMemex:
        return ''; // Auto-filled after login via MemexCloudService
      case typeMimo:
        return 'https://api.xiaomimimo.com/anthropic';
      default:
        return '';
    }
  }

  /// Example hint text for the extra params JSON field, per provider type.
  static String extraParamsHint(String type) {
    final effective = underlyingClientType(type) ?? type;
    switch (effective) {
      case typeGemini:
      case typeGeminiOauth:
        return 'e.g. {\n  "thinkingConfig": {\n    "includeThoughts": true,\n    "thinkingLevel": "high"\n  }\n}';
      case typeChatCompletion:
      case typeResponses:
        return 'e.g. {\n  "reasoning_effort": "medium"\n}';
      case typeClaude:
      case typeBedrockClaude:
        return 'e.g. {\n  "thinking": {\n    "type": "enabled",\n    "budget_tokens": N\n  }\n}\nor {\n  "thinking": {\n    "type": "adaptive"\n  }\n}';
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
    // Ollama does not require an API key
    if ((type == typeResponses ||
            type == typeChatCompletion ||
            type == typeClaude ||
            type == typeGemini ||
            type == typeKimi ||
            type == typeQwen ||
            type == typeSeed ||
            type == typeZhipu ||
            type == typeDeepSeek ||
            type == typeMinimax ||
            type == typeMimo ||
            type == typeOpenRouter ||
            type == typeMemex) &&
        getEffectiveApiKey().isEmpty) {
      return false;
    }
    // Types that require a non-empty baseUrl
    final typesRequiringBaseUrl = [
      typeGemini,
      typeChatCompletion,
      typeResponses,
      typeClaude,
      typeKimi,
      typeQwen,
      typeSeed,
      typeZhipu,
      typeDeepSeek,
      typeMinimax,
      typeOpenRouter,
      typeOllama,
      typeMimo,
      typeMemex,
    ];
    if (typesRequiringBaseUrl.contains(type)) {
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

  /// Creates a duplicate of this config with a new unique key.
  /// The new key will be `{originalKey}_copy`, or `{originalKey}_copy_N`
  /// if conflicts exist in [existingKeys].
  LLMConfig duplicate({required List<String> existingKeys}) {
    String newKey = '${key}_copy';
    int counter = 2;
    while (existingKeys.contains(newKey)) {
      newKey = '${key}_copy_$counter';
      counter++;
    }
    return copyWith(key: newKey);
  }

  static LLMConfig createDefaultClientConfig() {
    if (AppFlavor.isCN) {
      return const LLMConfig(
        key: defaultClientKey,
        baseUrl: 'https://api.moonshot.cn/v1',
        type: typeKimi,
        modelId: 'kimi-k2.5',
        maxTokens: 65536,
        apiKey: '',
        extra: {},
      );
    }
    return const LLMConfig(
      key: defaultClientKey,
      baseUrl: "https://api.openai.com/v1",
      type: typeChatCompletion,
      modelId: 'gpt-5.6-sol',
      maxTokens: 65536,
      apiKey: '',
      extra: {},
    );
  }

  static LLMConfig createDefaultConfig(String key, String type) {
    if (key == defaultClientKey) {
      return createDefaultClientConfig();
    }
    throw Exception('Unknown LLM config key: $key');
  }
}

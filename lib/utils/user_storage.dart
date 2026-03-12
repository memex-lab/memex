import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_config.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import '../l10n/app_localizations_ext.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/llm_client/codex_responses_client.dart';

/// Agent cache data structure
class AgentCacheData {
  final String responseId;
  final int systemPromptHash;
  final int toolsHash;

  AgentCacheData({
    required this.responseId,
    required this.systemPromptHash,
    required this.toolsHash,
  });

  Map<String, dynamic> toJson() => {
        'responseId': responseId,
        'systemPromptHash': systemPromptHash,
        'toolsHash': toolsHash,
      };

  factory AgentCacheData.fromJson(Map<String, dynamic> json) => AgentCacheData(
        responseId: json['responseId'] as String,
        systemPromptHash: json['systemPromptHash'] as int,
        toolsHash: json['toolsHash'] as int,
      );
}

/// User storage: userId persistence
class UserStorage {
  static AppLocalizationsExt? _l10n;
  static const String _keyUserId = 'user_id';
  static const String _keyPhotoSuggestionCache = 'photo_suggestion_cache';
  static const String _keyUserAvatar = 'user_avatar';

  /// Get the global l10n instance
  /// Throws an exception if not initialized (should be initialized in main())
  static AppLocalizationsExt get l10n {
    if (_l10n == null) {
      throw Exception(
          'l10n not initialized. Call UserStorage.initL10n() during app initialization.');
    }
    return _l10n!;
  }

  /// Language codes that have corresponding l10n files (must match app_localizations_ext).
  static const List<String> _supportedLanguageCodes = ['en', 'zh'];

  /// Returns [locale] if the app has l10n for it, otherwise English.
  static Locale _resolveToSupportedLocale(Locale locale) {
    if (_supportedLanguageCodes.contains(locale.languageCode)) {
      return locale;
    }
    return const Locale('en');
  }

  /// Initialize the global l10n instance
  /// Must be called during app initialization (in main())
  /// Uses English if the user locale has no matching l10n file.
  static Future<void> initL10n() async {
    final locale = await getLocale();
    final resolved = _resolveToSupportedLocale(locale);
    _l10n = lookupAppLocalizationsExt(resolved);
  }

  /// Get stored userId
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      return null;
    }
  }

  /// Save userId
  ///
  /// [userId] user-entered ID
  static Future<void> saveUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserId, userId);
    } catch (e) {
      throw Exception(UserStorage.l10n.saveUserInfoFailed(e));
    }
  }

  /// Clear user info (used on logout)
  static Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
    } catch (e) {
      // ignore error
    }
  }

  /// Check if user is saved
  static Future<bool> hasUser() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  static const String _keyLLMConfigs = 'llm_client_configs';

  /// Get stored LLM config list. Creates default config if none.
  static Future<List<LLMConfig>> getLLMConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyLLMConfigs);

      List<LLMConfig> configs = [];
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        configs = jsonList.map((j) => LLMConfig.fromJson(j)).toList();
      }

      // Ensure default Gpt config exists
      bool changed = false;
      if (!configs.any((c) => c.key == LLMConfig.defaultClientKey)) {
        configs.add(LLMConfig.createDefaultClient());
        changed = true;
      }

      // if changed (e.g. default config added), save back
      if (changed) {
        await saveLLMConfigs(configs);
      }

      return configs;
    } catch (e) {
      // on error return default list
      return [];
    }
  }

  /// Save LLM config list
  static Future<void> saveLLMConfigs(List<LLMConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(configs.map((c) => c.toJson()).toList());
      await prefs.setString(_keyLLMConfigs, jsonString);
    } catch (e) {
      throw Exception(UserStorage.l10n.saveLlmConfigFailed(e));
    }
  }

  static const String _keyLanguage = 'language';

  /// Get the preferred prompt locale for LLM interactions
  ///
  /// Returns the stored prompt locale preference, defaulting to the user's
  /// system locale if not set.
  static Future<Locale> getLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageString = prefs.getString(_keyLanguage);
      if (languageString == null) {
        return PlatformDispatcher.instance.locale;
      }

      // Parse locale string (format: "zh_CN" or "en")
      final parts = languageString.split('_');
      if (parts.length == 2) {
        return Locale(parts[0], parts[1]);
      } else if (parts.length == 1) {
        return Locale(parts[0]);
      }

      return PlatformDispatcher
          .instance.locale; // Default to system locale on parse error
    } catch (e) {
      return PlatformDispatcher
          .instance.locale; // Default to system locale on error
    }
  }

  /// Set the preferred prompt locale for LLM interactions
  ///
  /// [locale] The prompt locale to use
  static Future<void> setLocale(Locale locale) async {
    try {
      final resolved = _resolveToSupportedLocale(locale);
      final prefs = await SharedPreferences.getInstance();
      // Store as "languageCode_countryCode" or just "languageCode"
      final localeString = resolved.countryCode != null
          ? '${resolved.languageCode}_${resolved.countryCode}'
          : resolved.languageCode;
      await prefs.setString(_keyLanguage, localeString);
      // Update global l10n instance
      _l10n = lookupAppLocalizationsExt(resolved);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get cached agent data (responseId, hashCode).
  /// [agentType] e.g. 'pkm' or 'card'. Returns null if not found.
  static Future<AgentCacheData?> getCachedAgentData(String agentType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${agentType}_cached_agent_data';
      final jsonString = prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AgentCacheData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Save cached agent data. Pass null to delete.
  /// [agentType] e.g. 'pkm' or 'card'
  static Future<void> saveCachedAgentData(
    String agentType,
    AgentCacheData? cacheData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${agentType}_cached_agent_data';

      if (cacheData != null) {
        final jsonString = jsonEncode(cacheData.toJson());
        await prefs.setString(key, jsonString);
      } else {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  static const String _keyAgentConfigs = 'agent_configs';

  /// Get specified agent config
  static Future<AgentConfig> getAgentConfig(String agentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('${_keyAgentConfigs}_$agentId');

      if (jsonString != null) {
        return AgentConfig.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      // Ignore errors
    }
    // Default config
    return const AgentConfig();
  }

  /// Save specified agent config
  static Future<void> saveAgentConfig(
      String agentId, AgentConfig config) async {
    // Validate llmConfigKey if present
    if (config.llmConfigKey != null && config.llmConfigKey!.isNotEmpty) {
      final allConfigs = await getLLMConfigs();
      final exists = allConfigs.any((c) => c.key == config.llmConfigKey);
      if (!exists) {
        final availableKeys = allConfigs.map((c) => c.key).join(', ');
        throw Exception(
            'Invalid LLM Config Key: ${config.llmConfigKey}. Available keys: $availableKeys');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(config.toJson());
      await prefs.setString('${_keyAgentConfigs}_$agentId', jsonString);
    } catch (e) {
      // Re-throw validation exception, wrap others
      if (e.toString().contains('Invalid LLM Config Key')) {
        rethrow;
      }
      throw Exception('Failed to save agent config: $e');
    }
  }

  /// Reset LLM config to default
  static Future<void> resetLLMConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLLMConfigs);
      // Force reload to ensure defaults are re-populated
      await getLLMConfigs();
    } catch (e) {
      throw Exception('Failed to reset LLM configs: $e');
    }
  }

  /// Reset all agent configs to default
  static Future<void> resetAllAgentConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('${_keyAgentConfigs}_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      throw Exception('Failed to reset agent configs: $e');
    }
  }

  /// Helper: Get the effective LLMConfig for an agent.
  /// If [defaultClientKey] is provided, it is used as the fallback/verification target.
  /// If the agent has no config, or the config key is invalid:
  /// - If [defaultClientKey] is provided, tries to use that.
  /// - If still not found, THROWS Exception (strict mode).
  static Future<LLMConfig> getAgentLLMConfig(String agentId,
      {String? defaultClientKey}) async {
    final agentConfig = await getAgentConfig(agentId);
    final allConfigs = await getLLMConfigs();

    String? keyToUse = agentConfig.llmConfigKey;

    // If no user-set key, use the provided default for this agent
    if (keyToUse == null || keyToUse.isEmpty) {
      keyToUse = defaultClientKey;
    }

    if (keyToUse == null) {
      throw Exception(
          'No LLM config found for agent $agentId and no default key provided.');
    }

    try {
      return allConfigs.firstWhere((c) => c.key == keyToUse);
    } catch (e) {
      throw Exception(
          'LLM config not found for agent $agentId (key: $keyToUse)');
    }
  }

  /// Get both the LLMClient and ModelConfig for an agent.
  /// This centralized method handles client creation and model configuration mapping.
  /// [defaultClientKey] specifies which default config to use if the agent hasn't selected one.
  static Future<({LLMClient client, ModelConfig modelConfig})>
      getAgentLLMResources(String agentId, {String? defaultClientKey}) async {
    final llmConfig =
        await getAgentLLMConfig(agentId, defaultClientKey: defaultClientKey);

    if (!llmConfig.isValid) {
      EventBusService.instance.emitEvent(InvalidModelConfigMessage(
        agentId: AgentDefinitions.displayNames[agentId] ?? agentId,
        configKey: llmConfig.key,
      ));
      throw InvalidModelConfigException(
          'The LLM configuration for $agentId is invalid.');
    }

    // Use proxy URL from LLM config if set
    String? proxyUrl = llmConfig.proxyUrl;

    LLMClient client;
    switch (llmConfig.type) {
      case LLMConfig.typeGemini:
        final effectiveApiKey = llmConfig.getEffectiveApiKey();
        if (effectiveApiKey.isEmpty) {
          throw InvalidModelConfigException(
              'LLM API Key is empty for agent: $agentId');
        }
        client = GeminiClient(
          apiKey: effectiveApiKey,
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeResponses:
        final effectiveApiKey = llmConfig.getEffectiveApiKey();
        if (effectiveApiKey.isEmpty) {
          throw InvalidModelConfigException(
              'LLM API Key is empty for agent: $agentId');
        }
        client = ResponsesClient(
          apiKey: effectiveApiKey,
          baseUrl: llmConfig.baseUrl,
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeChatCompletion:
        final effectiveApiKey = llmConfig.getEffectiveApiKey();
        if (effectiveApiKey.isEmpty) {
          throw InvalidModelConfigException(
              'LLM API Key is empty for agent: $agentId');
        }
        client = OpenAIClient(
          apiKey: effectiveApiKey,
          baseUrl: llmConfig.baseUrl,
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeClaude:
        final effectiveApiKey = llmConfig.getEffectiveApiKey();
        if (effectiveApiKey.isEmpty) {
          throw InvalidModelConfigException(
              'LLM API Key is empty for agent: $agentId');
        }
        client = ClaudeClient(
          apiKey: effectiveApiKey,
          baseUrl: llmConfig.baseUrl.isNotEmpty
              ? llmConfig.baseUrl
              : 'https://api.anthropic.com',
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeBedrockClaude:
        // Bedrock uses AWS credentials from extra
        final extra = llmConfig.extra;
        final accessKeyId = extra['accessKeyId'] as String? ?? '';
        final secretAccessKey = extra['secretAccessKey'] as String? ?? '';
        final region = extra['region'] as String? ?? 'us-west-2';

        if (accessKeyId.isEmpty || secretAccessKey.isEmpty) {
          throw Exception(
              'Bedrock validation failed: accessKeyId or secretAccessKey is empty');
        }

        client = BedrockClaudeClient(
          region: region,
          accessKeyId: accessKeyId,
          secretAccessKey: secretAccessKey,
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeOpenAiOauth:
        final tokens = await OpenAiAuthService.getSavedTokens();
        if (tokens == null) {
          throw InvalidModelConfigException('OpenAI OAuth not authorized.');
        }
        client = CodexResponsesClient(
          accessToken: tokens['accessToken'] as String,
          accountId: tokens['accountId'] as String?,
          baseUrl: llmConfig.baseUrl.isNotEmpty
              ? llmConfig.baseUrl
              : 'https://chatgpt.com/backend-api/codex',
          proxyUrl: proxyUrl,
        );
        break;
      default:
        throw InvalidModelConfigException(
            'Unknown LLM type: ${llmConfig.type}');
    }

    // Create ModelConfig
    final modelConfig = ModelConfig(
      model: llmConfig.modelId,
      maxTokens: llmConfig.maxTokens,
      temperature: llmConfig.temperature,
      topP: llmConfig.topP,
      extra: llmConfig.extra,
    );

    return (client: client, modelConfig: modelConfig);
  }

  /// Get photo suggestion cache
  static Future<Map<String, dynamic>> getPhotoSuggestionCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyPhotoSuggestionCache);
      if (jsonString == null) return {};
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Save photo suggestion cache
  static Future<void> savePhotoSuggestionCache(
      Map<String, dynamic> cache) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPhotoSuggestionCache, jsonEncode(cache));
    } catch (e) {
      // ignore error
    }
  }

  /// Predefined avatar options (people & character faces).
  static const List<String> avatarOptions = [
    '👤',
    '👨',
    '👩',
    '🧑',
    '👦',
    '👧',
    '🧔',
    '👱',
    '👨\u200D🦰',
    '👩\u200D🦰',
    '👨\u200D🦱',
    '👩\u200D🦱',
    '👨\u200D🦳',
    '👩\u200D🦳',
    '👴',
    '👵',
    '🧑\u200D💻',
    '👨\u200D💻',
    '👩\u200D💻',
    '🧑\u200D🚀',
    '🧑\u200D🎨',
    '🧑\u200D🔬',
    '🥷',
    '🧙',
  ];

  /// Get stored user avatar. Returns null if not set.
  static Future<String?> getUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserAvatar);
    } catch (e) {
      return null;
    }
  }

  /// Save user avatar selection.
  static Future<void> saveUserAvatar(String avatar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserAvatar, avatar);
    } catch (e) {
      // ignore error
    }
  }
}

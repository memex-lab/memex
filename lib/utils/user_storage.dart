import 'dart:io';
import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/agent_config.dart';
import 'package:memex/domain/models/location_context_config.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/l10n/supported_languages.dart';
import '../l10n/app_localizations_ext.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/data/services/gemini_auth_service.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/llm_client/codex_responses_client.dart';
import 'package:memex/llm_client/gemini_oauth_client.dart';
import 'package:memex/data/services/avatar_media_service.dart';

/// Storage location for a user's workspace.
/// Like Obsidian: app storage (default), custom device folder, or iCloud (iOS).
/// Only affects this user's workspace; logs and DB stay in app storage.
enum StorageLocation {
  /// Default: app documents directory. Workspace may be removed on uninstall.
  app,

  /// User-chosen folder on device. Workspace persists across reinstall if path is still valid.
  custom,

  /// iCloud container (iOS only). Workspace syncs across devices; persists across reinstall.
  icloud,
}

/// User storage: userId persistence and per-user workspace storage preference.
class UserStorage {
  static AppLocalizationsExt? _l10n;
  static const String _keyUserId = 'user_id';
  static const String _keyPhotoSuggestionCache = 'photo_suggestion_cache';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyLocationContextConfig = 'location_context_config';
  static const String _keyGeocodingCache = 'geocoding_cache';
  static const String _keyLatestSuperAgentHomeSessionIdPrefix =
      'latest_super_agent_home_session_id_';
  static const String _keyMemexAgentNotificationPermissionPromptedPrefix =
      'memex_agent_notification_permission_prompted_';

  /// Per-user workspace storage preference keys.
  static const String _keyStorageLocationPrefix = 'memex_storage_location_';
  static const String _keyCustomDataRootPathPrefix =
      'memex_custom_data_root_path_';
  static const String _keyAutoBackupEnabledPrefix =
      'memex_auto_backup_enabled_';
  static const String _keyAutoBackupRetentionDaysPrefix =
      'memex_auto_backup_retention_days_';
  static const String _keyAutoBackupMaxBytesPrefix =
      'memex_auto_backup_max_bytes_';
  static const String _keyLastAutoBackupAtPrefix = 'memex_last_auto_backup_at_';
  static const String _keyLastAutoBackupFingerprintPrefix =
      'memex_last_auto_backup_fingerprint_';
  static const String _keyAndroidBackupTreeUriPrefix =
      'memex_android_backup_tree_uri_';
  static const String _keyAndroidBackupTreeNamePrefix =
      'memex_android_backup_tree_name_';

  static const int defaultAutoBackupRetentionDays = 30;
  static const int autoBackupRetentionForever = -1;
  static const List<int> autoBackupRetentionDayOptions = <int>[7, 14, 30, 90];
  static const int defaultAutoBackupMaxBytes = 2 * 1024 * 1024 * 1024;
  static const List<int> autoBackupMaxBytesOptions = <int>[
    512 * 1024 * 1024,
    1024 * 1024 * 1024,
    defaultAutoBackupMaxBytes,
    5 * 1024 * 1024 * 1024,
    10 * 1024 * 1024 * 1024,
  ];

  static final Logger _logger = getLogger('UserStorage');
  static const MethodChannel _storageChannel =
      MethodChannel('com.memexlab.memex/storage');

  /// Get the global l10n instance
  /// Throws an exception if not initialized (should be initialized in main())
  static AppLocalizationsExt get l10n {
    if (_l10n == null) {
      throw Exception(
          'l10n not initialized. Call UserStorage.initL10n() during app initialization.');
    }
    return _l10n!;
  }

  /// Global notifier for the active locale, used to rebuild the app on change.
  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(const Locale('en'));

  /// Locales that have corresponding l10n files (must match app_localizations_ext).
  static const Locale fallbackLocale = Locale('en');
  static const Locale traditionalChineseLocale =
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
  static const List<Locale> supportedLocales = supportedLanguageLocales;
  static const List<String> supportedLanguageCodes = supportedLanguageTags;

  static String localeTag(Locale locale) {
    final parts = <String>[locale.languageCode];
    if (locale.scriptCode != null && locale.scriptCode!.isNotEmpty) {
      parts.add(locale.scriptCode!);
    }
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      parts.add(locale.countryCode!);
    }
    return parts.join('_');
  }

  static Locale localeFromTag(String tag) {
    final parts = tag
        .replaceAll('-', '_')
        .split('_')
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return fallbackLocale;
    }
    if (parts.length == 1) {
      return Locale(parts[0]);
    }

    final regionOrScript = parts[1];
    if (regionOrScript.length == 4) {
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: regionOrScript,
        countryCode: parts.length > 2 ? parts[2] : null,
      );
    }

    return Locale(parts[0], regionOrScript);
  }

  /// Returns [locale] if the app has l10n for it, otherwise English.
  static Locale resolveToSupportedLocale(Locale locale) {
    final normalized = locale.countryCode == 'Hant'
        ? Locale.fromSubtags(
            languageCode: locale.languageCode,
            scriptCode: locale.countryCode,
          )
        : locale;

    for (final supported in supportedLocales) {
      if (localeTag(supported) == localeTag(normalized)) {
        return supported;
      }
    }

    if (normalized.languageCode == 'zh' &&
        (normalized.scriptCode == 'Hant' ||
            normalized.countryCode == 'TW' ||
            normalized.countryCode == 'HK' ||
            normalized.countryCode == 'MO')) {
      return traditionalChineseLocale;
    }

    for (final supported in supportedLocales) {
      if (supported.languageCode == normalized.languageCode &&
          supported.scriptCode == null &&
          supported.countryCode == null) {
        return supported;
      }
    }
    return fallbackLocale;
  }

  static void _applyResolvedLocale(Locale locale) {
    _l10n = lookupAppLocalizationsExt(locale);
    if (localeNotifier.value != locale) {
      localeNotifier.value = locale;
    }
  }

  /// Initialize the global l10n instance
  /// Must be called during app initialization (in main())
  /// Uses English if the user locale has no matching l10n file.
  static Future<void> initL10n() async {
    final locale = await getLocale();
    _applyResolvedLocale(resolveToSupportedLocale(locale));
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

  static String _latestSuperAgentHomeSessionIdKey(String userId) {
    return '$_keyLatestSuperAgentHomeSessionIdPrefix$userId';
  }

  static String _memexAgentNotificationPermissionPromptedKey(String userId) {
    return '$_keyMemexAgentNotificationPermissionPromptedPrefix$userId';
  }

  /// Whether [key] represents state owned by the current device/OS rather
  /// than portable user settings.
  ///
  /// These values must not cross devices through backup and restore. For
  /// example, Android notification permission is reset by the OS on a fresh
  /// install, so restoring an old "already prompted" marker could prevent the
  /// app from explaining the permission on the new device.
  static bool isDeviceLocalPreferenceKey(String key) {
    return key.startsWith(
      _keyMemexAgentNotificationPermissionPromptedPrefix,
    );
  }

  static Future<String?> getLatestSuperAgentHomeSessionId() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) return null;

      final prefs = await SharedPreferences.getInstance();
      final sessionId =
          prefs.getString(_latestSuperAgentHomeSessionIdKey(userId))?.trim();
      return sessionId == null || sessionId.isEmpty ? null : sessionId;
    } catch (e) {
      return null;
    }
  }

  static Future<void> setLatestSuperAgentHomeSessionId(String sessionId) async {
    final normalized = sessionId.trim();
    if (normalized.isEmpty) return;

    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _latestSuperAgentHomeSessionIdKey(userId),
        normalized,
      );
    } catch (e) {
      // Cache misses are non-fatal; callers fall back to session discovery.
    }
  }

  static Future<void> clearLatestSuperAgentHomeSessionId() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_latestSuperAgentHomeSessionIdKey(userId));
    } catch (e) {
      // Cache misses are non-fatal.
    }
  }

  static Future<bool> hasPromptedMemexAgentNotificationPermission() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) return false;

      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(
            _memexAgentNotificationPermissionPromptedKey(userId),
          ) ??
          false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> setMemexAgentNotificationPermissionPrompted() async {
    try {
      final userId = await getUserId();
      if (userId == null || userId.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        _memexAgentNotificationPermissionPromptedKey(userId),
        true,
      );
    } catch (e) {
      // Cache misses are non-fatal; callers can continue without the marker.
    }
  }

  /// Check if user is saved
  static Future<bool> hasUser() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }

  static const String _keyLLMConfigs = 'llm_client_configs';
  static const String _keyDefaultLLMConfigKey = 'default_llm_config_key';

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
        configs.add(LLMConfig.createDefaultClientConfig());
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

      final defaultKey = prefs.getString(_keyDefaultLLMConfigKey);
      if (defaultKey != null && !configs.any((c) => c.key == defaultKey)) {
        if (configs.any((c) => c.key == LLMConfig.defaultClientKey)) {
          await prefs.setString(
              _keyDefaultLLMConfigKey, LLMConfig.defaultClientKey);
        } else {
          await prefs.remove(_keyDefaultLLMConfigKey);
        }
      }
    } catch (e) {
      throw Exception(UserStorage.l10n.saveLlmConfigFailed(e));
    }
  }

  /// Get the globally selected default LLM config key.
  ///
  /// Agents without an explicit model selection use this key. The legacy
  /// `default` config remains the fallback so existing installs keep working.
  static Future<String> getDefaultLLMConfigKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configs = await getLLMConfigs();
      final storedKey = prefs.getString(_keyDefaultLLMConfigKey);

      if (storedKey != null && configs.any((c) => c.key == storedKey)) {
        return storedKey;
      }

      final fallbackKey =
          configs.any((c) => c.key == LLMConfig.defaultClientKey)
              ? LLMConfig.defaultClientKey
              : configs.isNotEmpty
                  ? configs.first.key
                  : LLMConfig.defaultClientKey;

      if (configs.any((c) => c.key == fallbackKey)) {
        await prefs.setString(_keyDefaultLLMConfigKey, fallbackKey);
      }
      return fallbackKey;
    } catch (e) {
      return LLMConfig.defaultClientKey;
    }
  }

  /// Set the globally selected default LLM config key.
  static Future<void> setDefaultLLMConfigKey(String configKey) async {
    final configs = await getLLMConfigs();
    final exists = configs.any((c) => c.key == configKey);
    if (!exists) {
      final availableKeys = configs.map((c) => c.key).join(', ');
      throw Exception(
          'Invalid default LLM Config Key: $configKey. Available keys: $availableKeys');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultLLMConfigKey, configKey);
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

      // Parse locale string (format: "zh", "zh_Hant", or "zh_Hant_TW").
      return localeFromTag(languageString);
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
      final resolved = resolveToSupportedLocale(locale);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, localeTag(resolved));
      _applyResolvedLocale(resolved);
    } catch (e) {
      // Ignore errors
    }
  }

  static const String _keyAgentConfigs = 'agent_configs';
  static const String _keyUseLocalSpeechToText = 'use_local_speech_to_text';
  static const String _keySuperAgentRunMode = 'super_agent_run_mode';

  /// Persisted run mode for the SuperAgent home entry ('auto' | 'confirm' |
  /// 'read_only'). Defaults to 'auto'.
  static Future<String> getSuperAgentRunMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySuperAgentRunMode) ?? 'auto';
    } catch (e) {
      return 'auto';
    }
  }

  static Future<void> setSuperAgentRunMode(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySuperAgentRunMode, value);
    } catch (e) {
      // Non-fatal: mode falls back to in-memory state for this session.
    }
  }

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
    final allConfigs = await getLLMConfigs();
    final availableKeys = allConfigs.map((c) => c.key).join(', ');

    // Validate llmConfigKey if present
    if (config.llmConfigKey != null && config.llmConfigKey!.isNotEmpty) {
      final exists = allConfigs.any((c) => c.key == config.llmConfigKey);
      if (!exists) {
        throw Exception(
            'Invalid LLM Config Key: ${config.llmConfigKey}. Available keys: $availableKeys');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(config.toJson());
      await prefs.setString('${_keyAgentConfigs}_$agentId', jsonString);
    } catch (e) {
      if (e.toString().contains('Invalid LLM Config Key')) {
        rethrow;
      }
      throw Exception('Failed to save agent config: $e');
    }
  }

  static Future<bool> getUseLocalSpeechToText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyUseLocalSpeechToText) ?? true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> setUseLocalSpeechToText(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyUseLocalSpeechToText, value);
    } catch (e) {
      throw Exception('Failed to save speech preference: $e');
    }
  }

  static Future<void> resetUseLocalSpeechToText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUseLocalSpeechToText);
    } catch (e) {
      throw Exception('Failed to reset speech preference: $e');
    }
  }

  static Future<LocationContextConfig> getLocationContextConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyLocationContextConfig);
      if (jsonString == null || jsonString.isEmpty) {
        return const LocationContextConfig();
      }
      return LocationContextConfig.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      _logger.warning('Failed to load location context config: $e');
      return const LocationContextConfig();
    }
  }

  static Future<void> saveLocationContextConfig(
    LocationContextConfig config,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyLocationContextConfig,
        jsonEncode(config.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to save location context config: $e');
    }
  }

  static Future<Map<String, dynamic>> getGeocodingCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyGeocodingCache);
      if (jsonString == null || jsonString.isEmpty) return {};
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.warning('Failed to load geocoding cache: $e');
      return {};
    }
  }

  static Future<void> saveGeocodingCache(Map<String, dynamic> cache) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyGeocodingCache, jsonEncode(cache));
    } catch (e) {
      _logger.warning('Failed to save geocoding cache: $e');
    }
  }

  /// Reset LLM config to default
  static Future<void> resetLLMConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLLMConfigs);
      await prefs.remove(_keyDefaultLLMConfigKey);
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
      keyToUse = defaultClientKey == LLMConfig.defaultClientKey
          ? await getDefaultLLMConfigKey()
          : defaultClientKey;
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

  /// Build an [LLMClient] and [ModelConfig] directly from an [LLMConfig].
  ///
  /// This is the core factory used by [getAgentLLMResources] and can also be
  /// called standalone (e.g. for model connectivity tests with unsaved configs).
  /// Throws on invalid config or missing credentials.
  static Future<({LLMClient client, ModelConfig modelConfig})>
      buildLLMResources(LLMConfig llmConfig) async {
    // Use proxy URL from LLM config if set
    String? proxyUrl = llmConfig.proxyUrl;

    LLMClient client;
    switch (llmConfig.type) {
      case LLMConfig.typeGemini:
        final effectiveApiKey = llmConfig.getEffectiveApiKey();
        if (effectiveApiKey.isEmpty) {
          throw InvalidModelConfigException('LLM API Key is empty');
        }
        client = GeminiClient(
          apiKey: effectiveApiKey,
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeGeminiOauth:
        final accessToken = await GeminiAuthService.getValidAccessToken();
        if (accessToken == null) {
          throw InvalidModelConfigException('Gemini OAuth not authorized.');
        }
        client = GeminiOAuthClient(
          proxyUrl: proxyUrl,
        );
        break;
      case LLMConfig.typeResponses:
        final effectiveApiKey = llmConfig.getEffectiveApiKey();
        if (effectiveApiKey.isEmpty) {
          throw InvalidModelConfigException('LLM API Key is empty');
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
          throw InvalidModelConfigException('LLM API Key is empty');
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
          throw InvalidModelConfigException('LLM API Key is empty');
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
      // Providers compatible with OpenAI Chat Completions
      case LLMConfig.typeKimi:
      case LLMConfig.typeQwen:
      case LLMConfig.typeZhipu:
      case LLMConfig.typeDeepSeek:
      case LLMConfig.typeOpenRouter:
      case LLMConfig.typeOllama:
      case LLMConfig.typeMemex:
        client = OpenAIClient(
          apiKey: llmConfig.getEffectiveApiKey(),
          baseUrl: llmConfig.baseUrl,
          proxyUrl: proxyUrl,
        );
        break;
      // Seed (Doubao) is compatible with OpenAI Responses API
      case LLMConfig.typeSeed:
        client = ResponsesClient(
          apiKey: llmConfig.getEffectiveApiKey(),
          baseUrl: llmConfig.baseUrl,
          proxyUrl: proxyUrl,
        );
        break;
      // MiniMax and MIMO are compatible with Anthropic API
      case LLMConfig.typeMinimax:
      case LLMConfig.typeMimo:
        client = ClaudeClient(
          apiKey: llmConfig.getEffectiveApiKey(),
          baseUrl: llmConfig.baseUrl,
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

    return buildLLMResources(llmConfig);
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

  /// Default avatar seed for DiceBear Notionists style.
  static const String defaultAvatarSeed = 'Felix';

  /// Legacy emoji avatar options — kept for migration detection only.
  static const List<String> avatarOptions = ['Felix'];

  /// Get stored user avatar. Returns null if not set.
  /// Automatically migrates legacy emoji avatars to DiceBear seeds.
  static Future<String?> getUserAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final avatar = prefs.getString(_keyUserAvatar);
      if (avatar != null && _isLegacyEmoji(avatar)) {
        // Migrate: replace emoji with user's nickname as seed
        final userId = prefs.getString(_keyUserId);
        final seed =
            (userId != null && userId.isNotEmpty) ? userId : defaultAvatarSeed;
        await prefs.setString(_keyUserAvatar, seed);
        AvatarMediaService.precacheDiceBearAvatar(seed);
        return seed;
      }
      return avatar;
    } catch (e) {
      return null;
    }
  }

  /// Check if a stored avatar is a legacy emoji (not a DiceBear seed).
  static bool _isLegacyEmoji(String s) {
    if (s.isEmpty) return false;
    // Emoji strings are short and contain non-ASCII codepoints
    return s.runes.length <= 7 && s.runes.any((r) => r > 255);
  }

  /// Save user avatar selection and cache the SVG locally.
  static Future<void> saveUserAvatar(String avatar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserAvatar, avatar);
      AvatarMediaService.precacheDiceBearAvatar(avatar);
    } catch (e) {
      // ignore error
    }
  }

  // ----- Per-user workspace data root (app / custom folder / iCloud) -----

  /// Resolve data root for [userId]. Used at init so this user's workspace lives under this path.
  /// When [userId] is null, returns app dir (e.g. before login). Logs/DB are always in app dir.
  static Future<String> resolveDataRoot(String? userId) async {
    if (userId == null || userId.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
    final prefs = await SharedPreferences.getInstance();
    final locationIndex = prefs.getInt(_keyStorageLocationPrefix + userId);
    final location = locationIndex != null
        ? StorageLocation
            .values[locationIndex.clamp(0, StorageLocation.values.length - 1)]
        : StorageLocation.app;

    switch (location) {
      case StorageLocation.app:
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;

      case StorageLocation.custom:
        if (Platform.isIOS) {
          _logger.warning(
              'Custom device folder is not supported on iOS, falling back to app dir');
          final appDir = await getApplicationDocumentsDirectory();
          return appDir.path;
        }
        final path = prefs.getString(_keyCustomDataRootPathPrefix + userId);
        if (path != null && path.isNotEmpty) {
          final dir = Directory(path);
          if (await dir.exists()) {
            return path;
          }
          _logger.warning(
              'Custom data root no longer exists for user $userId: $path, falling back to app dir');
        }
        final appDir = await getApplicationDocumentsDirectory();
        return appDir.path;

      case StorageLocation.icloud:
        if (!Platform.isIOS) {
          _logger.warning(
              'iCloud is only supported on iOS, falling back to app dir');
          final dir = await getApplicationDocumentsDirectory();
          return dir.path;
        }
        try {
          final path = await _getICloudContainerPath();
          _logger.info('iCloud container path: $path');
          if (path != null && path.isNotEmpty) {
            // One-time migration: move data from container root to Documents/
            await migrateICloudToDocumentsIfNeeded(path);
            // iOS Files app only shows files inside the Documents/ subfolder
            // of the iCloud container. Root-level files are hidden.
            final documentsPath = '$path/Documents';
            final dir = Directory(documentsPath);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            return documentsPath;
          }
        } catch (e, st) {
          _logger.warning('Failed to get iCloud path: $e', e, st);
        }
        _logger
            .warning('iCloud path resolution failed, falling back to app dir');
        final appDir = await getApplicationDocumentsDirectory();
        return appDir.path;
    }
  }

  /// Get storage location preference for [userId].
  static Future<StorageLocation> getWorkspaceStorageLocation(
      String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyStorageLocationPrefix + userId);
    if (index == null) return StorageLocation.app;
    return StorageLocation
        .values[index.clamp(0, StorageLocation.values.length - 1)];
  }

  /// Get custom data root path for [userId] if set; otherwise null.
  static Future<String?> getCustomDataRootPath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomDataRootPathPrefix + userId);
  }

  /// Set workspace storage to app (default) for [userId].
  static Future<void> setWorkspaceStorageToApp(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _keyStorageLocationPrefix + userId, StorageLocation.app.index);
  }

  /// Set workspace storage to custom directory for [userId]. [absolutePath] must be an existing directory path.
  static Future<void> setWorkspaceStorageToCustom(
      String userId, String absolutePath) async {
    if (Platform.isIOS) {
      throw UnsupportedError(
          'Custom device folder is not supported on iOS. Use app storage or iCloud.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomDataRootPathPrefix + userId, absolutePath);
    await prefs.setInt(
        _keyStorageLocationPrefix + userId, StorageLocation.custom.index);
  }

  /// Set workspace storage to iCloud for [userId] (iOS only). No-op on other platforms.
  static Future<void> setWorkspaceStorageToICloud(String userId) async {
    if (!Platform.isIOS) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _keyStorageLocationPrefix + userId, StorageLocation.icloud.index);
  }

  /// Whether automatic local snapshots are enabled for [userId].
  static Future<bool> isAutoBackupEnabled(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoBackupEnabledPrefix + userId) ?? false;
  }

  static Future<void> setAutoBackupEnabled(String userId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackupEnabledPrefix + userId, enabled);
  }

  /// Number of days to keep automatic backups for [userId].
  ///
  /// Returns `null` when the user explicitly chooses to keep automatic backups
  /// forever. Missing or invalid values fall back to 30 days.
  static Future<int?> getAutoBackupRetentionDays(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyAutoBackupRetentionDaysPrefix + userId);
    if (value == autoBackupRetentionForever) return null;
    if (value == null || value <= 0) return defaultAutoBackupRetentionDays;
    return value;
  }

  static Future<void> setAutoBackupRetentionDays(
    String userId,
    int? days,
  ) async {
    if (days != null && days <= 0) {
      throw ArgumentError.value(days, 'days', 'must be positive or null');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _keyAutoBackupRetentionDaysPrefix + userId,
      days ?? autoBackupRetentionForever,
    );
  }

  /// Total size cap for automatic backups. Invalid values fall back to 2 GB.
  static Future<int> getAutoBackupMaxBytes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_keyAutoBackupMaxBytesPrefix + userId);
    if (value == null || value <= 0) return defaultAutoBackupMaxBytes;
    return value;
  }

  static Future<void> setAutoBackupMaxBytes(
    String userId,
    int bytes,
  ) async {
    if (bytes <= 0) {
      throw ArgumentError.value(bytes, 'bytes', 'must be positive');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAutoBackupMaxBytesPrefix + userId, bytes);
  }

  static Future<DateTime?> getLastAutoBackupAt(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLastAutoBackupAtPrefix + userId);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static Future<String?> getLastAutoBackupFingerprint(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastAutoBackupFingerprintPrefix + userId);
  }

  static Future<void> setLastAutoBackupMetadata(
    String userId, {
    required DateTime createdAt,
    required String fingerprint,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _keyLastAutoBackupAtPrefix + userId, createdAt.toIso8601String());
    await prefs.setString(
        _keyLastAutoBackupFingerprintPrefix + userId, fingerprint);
  }

  static Future<String?> getAndroidBackupTreeUri(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAndroidBackupTreeUriPrefix + userId);
  }

  static Future<String?> getAndroidBackupTreeName(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAndroidBackupTreeNamePrefix + userId);
  }

  static Future<void> setAndroidBackupTree({
    required String userId,
    required String treeUri,
    required String displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAndroidBackupTreeUriPrefix + userId, treeUri);
    await prefs.setString(
        _keyAndroidBackupTreeNamePrefix + userId, displayName);
  }

  static Future<void> clearAndroidBackupTree(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAndroidBackupTreeUriPrefix + userId);
    await prefs.remove(_keyAndroidBackupTreeNamePrefix + userId);
  }

  /// Whether iCloud storage is available (iOS with iCloud capability).
  static Future<bool> isICloudAvailable() async {
    if (!Platform.isIOS) return false;
    try {
      final path = await _getICloudContainerPath();
      return path != null && path.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Resolve the user-visible iCloud Documents folder, if available.
  static Future<String?> resolveICloudDocumentsPath() async {
    if (!Platform.isIOS) return null;
    final path = await _getICloudContainerPath();
    if (path == null || path.isEmpty) return null;
    final documentsPath = '$path/Documents';
    final dir = Directory(documentsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return documentsPath;
  }

  static Future<String?> _getICloudContainerPath() async {
    try {
      final String? path =
          await _storageChannel.invokeMethod<String>('getICloudContainerPath');
      return path;
    } on PlatformException catch (e) {
      _logger.warning(
          'Platform error getting iCloud path: ${e.code} ${e.message}');
      return null;
    }
  }

  /// Migrate iCloud workspace from container root to Documents/ subfolder.
  ///
  /// Before this fix, data was stored at the iCloud container root, which is
  /// invisible in the iOS Files app. The correct location is container/Documents/.
  /// This runs once per user and is a no-op if already migrated or no old data exists.
  static Future<void> migrateICloudToDocumentsIfNeeded(
      String containerPath) async {
    const migrationFlag = 'icloud_documents_migration_done';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(migrationFlag) == true) return;

    final documentsPath = '$containerPath/Documents';
    final oldDir = Directory(containerPath);
    final newDir = Directory(documentsPath);

    // Check if there's anything worth migrating at the root level
    // (skip system dirs like .Trash, tmp, etc.)
    final List<FileSystemEntity> rootEntities;
    try {
      rootEntities = await oldDir.list().where((e) {
        final name = e.path.split('/').last;
        return !name.startsWith('.') && name != 'Documents';
      }).toList();
    } catch (e) {
      _logger.warning('iCloud migration: failed to list root dir: $e');
      await prefs.setBool(migrationFlag, true);
      return;
    }

    if (rootEntities.isEmpty) {
      // Nothing to migrate
      await prefs.setBool(migrationFlag, true);
      return;
    }

    _logger.info(
        'iCloud migration: moving ${rootEntities.length} items to Documents/');

    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    for (final entity in rootEntities) {
      final name = entity.path.split('/').last;
      final destination = '$documentsPath/$name';
      try {
        await entity.rename(destination);
        _logger.info('iCloud migration: moved $name');
      } catch (e) {
        _logger.warning('iCloud migration: failed to move $name: $e');
      }
    }

    await prefs.setBool(migrationFlag, true);
    _logger.info('iCloud migration: complete');
  }

  /// Clear all SharedPreferences data (used for account deletion).
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      _logger.warning('Failed to clear SharedPreferences: $e');
    }
  }

  /// Check if user has given consent for LLM data sharing with a specific provider.
  static Future<bool> hasLLMConsent({String? providerType}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check global consent first (legacy)
      if (prefs.getBool('llm_data_sharing_consent') == true &&
          providerType == null) {
        return true;
      }
      // Check per-provider consent
      if (providerType != null) {
        return prefs.getBool('llm_consent_$providerType') ?? false;
      }
      return prefs.getBool('llm_data_sharing_consent') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Save LLM data sharing consent for a specific provider.
  static Future<void> saveLLMConsent(bool consent,
      {String? providerType}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('llm_data_sharing_consent', consent);
      if (providerType != null) {
        await prefs.setBool('llm_consent_$providerType', consent);
      }
    } catch (e) {
      _logger.warning('Failed to save LLM consent: $e');
    }
  }
}

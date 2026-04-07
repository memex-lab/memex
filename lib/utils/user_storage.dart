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
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import '../l10n/app_localizations_ext.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/data/services/openai_auth_service.dart';
import 'package:memex/data/services/gemini_auth_service.dart';
import 'package:memex/domain/models/task_exceptions.dart';
import 'package:memex/llm_client/codex_responses_client.dart';
import 'package:memex/llm_client/gemini_oauth_client.dart';

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

  /// Per-user workspace storage preference keys.
  static const String _keyStorageLocationPrefix = 'memex_storage_location_';
  static const String _keyCustomDataRootPathPrefix =
      'memex_custom_data_root_path_';

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
      // Providers compatible with OpenAI Chat Completions
      case LLMConfig.typeKimi:
      case LLMConfig.typeQwen:
      case LLMConfig.typeZhipu:
      case LLMConfig.typeOpenRouter:
      case LLMConfig.typeOllama:
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

  /// Save user avatar selection.
  static Future<void> saveUserAvatar(String avatar) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserAvatar, avatar);
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
      final destination = '${documentsPath}/$name';
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

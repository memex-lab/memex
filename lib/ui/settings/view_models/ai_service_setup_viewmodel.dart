import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/memex_cloud_service.dart';
import 'package:memex/data/services/model_role_config_service.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/domain/models/speech_recognition_config.dart';
import 'package:memex/utils/user_storage.dart';

typedef AppConfigFetcher = Future<AppConfigResult?> Function(
    {required String locale});

enum AiServiceConnectionMode {
  notConfigured,
  memexOfficial,
  customProvider,
}

class AiServiceSetupViewModel extends ChangeNotifier {
  AiServiceSetupViewModel({
    required MemexRouter router,
    AppConfigFetcher? appConfigFetcher,
  })  : _router = router,
        _appConfigFetcher = appConfigFetcher ??
            (({required locale}) =>
                MemexCloudService.instance.getAppConfig(locale: locale));

  static const String followTextSelectionValue = '__memex_follow_text_model__';

  final MemexRouter _router;
  final AppConfigFetcher _appConfigFetcher;
  bool _isDisposed = false;

  String baseUrl = '';
  String apiKey = '';
  List<String> models = const [];
  bool isSaving = false;
  bool isMemexLoggedIn = false;
  bool showMemexSetup = false;
  bool isMemexConfigLoading = false;
  bool isRoleLoading = true;
  bool isUpdatingTextModel = false;
  bool isUpdatingVisionModel = false;
  bool useLocalSpeechToText = true;
  SpeechRecognitionConfig speechRecognitionConfig =
      const SpeechRecognitionConfig();
  List<LLMConfig> llmConfigs = const [];
  ModelRoleSelection? roleSelection;
  MemexTopUpConfig? memexTopUpConfig;

  bool get hasReadyCredentials =>
      baseUrl.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  LLMConfig? get textConfig => ModelRoleConfigService.findConfig(
        llmConfigs,
        roleSelection?.textConfigKey,
      );

  LLMConfig? get effectiveVisionConfig => ModelRoleConfigService.findConfig(
        llmConfigs,
        roleSelection?.effectiveVisionConfigKey(),
      );

  bool get shouldWarnVision {
    final config = effectiveVisionConfig;
    return config != null &&
        !LLMConfig.isKnownMultimodal(config.type, config.modelId);
  }

  bool get hasSelectableModels => llmConfigs.any((config) => config.isValid);

  bool get hasConfiguredModelOptions =>
      llmConfigs.any((config) => config.isValid);

  bool get isUsingMemexOfficialService {
    final config = textConfig;
    return config != null &&
        config.isValid &&
        config.type == LLMConfig.typeMemex;
  }

  bool get hasValidCustomProviderConfig => llmConfigs
      .any((config) => config.isValid && config.type != LLMConfig.typeMemex);

  AiServiceConnectionMode get connectionMode {
    if (isUsingMemexOfficialService) {
      return AiServiceConnectionMode.memexOfficial;
    }
    if (hasValidCustomProviderConfig || (textConfig?.isValid ?? false)) {
      return AiServiceConnectionMode.customProvider;
    }
    return AiServiceConnectionMode.notConfigured;
  }

  List<LLMConfig> get mimoModelConfigs => llmConfigs
      .where((config) => config.type == LLMConfig.typeMimo && config.isValid)
      .toList(growable: false);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadModelRoles({bool showLoading = true}) async {
    if (showLoading) {
      isRoleLoading = true;
      _notify();
    }

    final configs = await _router.getLLMConfigs();
    final selection = await ModelRoleConfigService.loadSelection();
    final speechConfig = await UserStorage.getSpeechRecognitionConfig();
    if (_isDisposed) return;

    llmConfigs = configs;
    roleSelection = selection;
    speechRecognitionConfig = speechConfig;
    useLocalSpeechToText = speechConfig.usesLocalModel;
    isRoleLoading = false;
    _notify();
  }

  Future<bool> saveMemexService() async {
    if (!hasReadyCredentials || isSaving) return false;

    isSaving = true;
    _notify();
    try {
      final configs = await _router.getLLMConfigs();
      final modelId = models.isNotEmpty
          ? models.first
          : LLMConfig.recommendedModels(LLMConfig.typeMemex).firstOrNull ??
              'memex-default';
      final memexConfig = LLMConfig(
        key: LLMConfig.defaultClientKey,
        type: LLMConfig.typeMemex,
        modelId: modelId,
        apiKey: apiKey,
        baseUrl: baseUrl,
        maxTokens: 65536,
      );

      final nextConfigs = [...configs];
      final index = nextConfigs.indexWhere(
        (c) => c.key == LLMConfig.defaultClientKey,
      );
      if (index >= 0) {
        nextConfigs[index] = memexConfig;
      } else {
        nextConfigs.insert(0, memexConfig);
      }
      await _router.saveLLMConfigs(nextConfigs);
      await _router.setDefaultLLMConfigKey(LLMConfig.defaultClientKey);
      await loadModelRoles(showLoading: false);
      return true;
    } finally {
      if (!_isDisposed) {
        isSaving = false;
        _notify();
      }
    }
  }

  Future<void> clearMemexService() async {
    baseUrl = '';
    apiKey = '';
    models = const [];
    isMemexLoggedIn = false;
    _notify();

    final configs = await _router.getLLMConfigs();
    final nextConfigs = [...configs];
    final index = nextConfigs.indexWhere(
      (c) => c.key == LLMConfig.defaultClientKey,
    );
    if (index < 0 || nextConfigs[index].type != LLMConfig.typeMemex) {
      return;
    }

    nextConfigs[index] = LLMConfig.createDefaultClientConfig();
    await _router.saveLLMConfigs(nextConfigs);

    final fallback = nextConfigs
        .where((c) => c.key != LLMConfig.defaultClientKey && c.isValid)
        .firstOrNull;
    if (fallback != null) {
      await _router.setDefaultLLMConfigKey(fallback.key);
    }
    await loadModelRoles(showLoading: false);
  }

  Future<void> showMemexServiceSetup() async {
    if (isMemexConfigLoading) return;

    isMemexConfigLoading = true;
    _notify();
    try {
      final config = await _appConfigFetcher(
        locale: UserStorage.l10n.localeName,
      );
      memexTopUpConfig = config?.content.aiService.memexConnection.topUp;
      showMemexSetup = true;
    } catch (_) {
      showMemexSetup = true;
    } finally {
      if (!_isDisposed) {
        isMemexConfigLoading = false;
        _notify();
      }
    }
  }

  void setMemexCredentials(
    String nextBaseUrl,
    String nextApiKey,
    List<String> nextModels,
  ) {
    baseUrl = nextBaseUrl;
    apiKey = nextApiKey;
    models = nextModels;
    _notify();
  }

  void setMemexLoginState(bool isLoggedIn) {
    isMemexLoggedIn = isLoggedIn;
    _notify();
  }

  Future<void> setTextModel(String configKey) async {
    if (isUpdatingTextModel) return;
    isUpdatingTextModel = true;
    _notify();
    try {
      await ModelRoleConfigService.setTextModel(configKey);
      await loadModelRoles(showLoading: false);
    } finally {
      if (!_isDisposed) {
        isUpdatingTextModel = false;
        _notify();
      }
    }
  }

  Future<void> setVisionModel(String? configKey) async {
    if (isUpdatingVisionModel) return;
    final nextKey = configKey == followTextSelectionValue ? null : configKey;
    isUpdatingVisionModel = true;
    _notify();
    try {
      await ModelRoleConfigService.setVisionModel(nextKey);
      await loadModelRoles(showLoading: false);
    } finally {
      if (!_isDisposed) {
        isUpdatingVisionModel = false;
        _notify();
      }
    }
  }

  Future<void> setUseLocalSpeechToText(bool value) async {
    await setSpeechRecognitionProvider(
      value
          ? SpeechRecognitionProvider.local
          : SpeechRecognitionProvider.tencentCloud,
    );
  }

  Future<void> setSpeechRecognitionProvider(
    SpeechRecognitionProvider provider,
  ) async {
    final nextConfig = speechRecognitionConfig.copyWith(provider: provider);
    await UserStorage.saveSpeechRecognitionConfig(nextConfig);
    speechRecognitionConfig = nextConfig;
    useLocalSpeechToText = nextConfig.usesLocalModel;
    _notify();
  }

  Future<void> saveTencentCloudSpeechConfig({
    required String appId,
    required String secretId,
    required String secretKey,
    String? engineModel,
    String? engineType,
    String hotwordList = '',
  }) async {
    final resolvedEngineType = engineModel ??
        engineType ??
        speechRecognitionConfig.tencentCloud.engineType;
    final nextConfig = speechRecognitionConfig.copyWith(
      tencentCloud: speechRecognitionConfig.tencentCloud.copyWith(
        appId: appId,
        secretId: secretId,
        secretKey: secretKey,
        engineType: resolvedEngineType,
        hotwordList: hotwordList,
      ),
    );
    await UserStorage.saveSpeechRecognitionConfig(nextConfig);
    speechRecognitionConfig = nextConfig;
    useLocalSpeechToText = nextConfig.usesLocalModel;
    _notify();
  }

  Future<void> saveXiaomiMimoSpeechConfig({
    required String llmConfigKey,
    required String apiKey,
    required String baseUrl,
    required String model,
    required String language,
  }) async {
    final nextConfig = speechRecognitionConfig.copyWith(
      xiaomiMimo: speechRecognitionConfig.xiaomiMimo.copyWith(
        llmConfigKey: llmConfigKey,
        apiKey: apiKey,
        baseUrl: baseUrl,
        model: model,
        language: language,
      ),
    );
    await UserStorage.saveSpeechRecognitionConfig(nextConfig);
    speechRecognitionConfig = nextConfig;
    useLocalSpeechToText = nextConfig.usesLocalModel;
    _notify();
  }
}

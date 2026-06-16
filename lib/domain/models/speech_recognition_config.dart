enum SpeechRecognitionProvider {
  local,
  tencentCloud,
  xiaomiMimo;

  static SpeechRecognitionProvider fromJson(String? value) {
    return switch (value) {
      'tencentCloud' => SpeechRecognitionProvider.tencentCloud,
      'tencent_cloud' => SpeechRecognitionProvider.tencentCloud,
      'xiaomiMimo' => SpeechRecognitionProvider.xiaomiMimo,
      'xiaomi_mimo' => SpeechRecognitionProvider.xiaomiMimo,
      _ => SpeechRecognitionProvider.local,
    };
  }

  String toJson() => name;
}

class TencentCloudAsrConfig {
  const TencentCloudAsrConfig({
    this.appId = '',
    this.secretId = '',
    this.secretKey = '',
    this.engineType = defaultEngineType,
    this.hotwordList = '',
  });

  static const String defaultEngineType = '16k_zh_en';
  static const List<String> engineTypes = <String>[
    defaultEngineType,
    '16k_zh',
  ];
  static const List<String> supportedEngineTypes = engineTypes;

  final String appId;
  final String secretId;
  final String secretKey;
  final String engineType;
  final String hotwordList;

  bool get isConfigured =>
      appId.trim().isNotEmpty &&
      secretId.trim().isNotEmpty &&
      secretKey.trim().isNotEmpty;

  TencentCloudAsrConfig copyWith({
    String? appId,
    String? secretId,
    String? secretKey,
    String? engineType,
    String? hotwordList,
  }) {
    return TencentCloudAsrConfig(
      appId: appId ?? this.appId,
      secretId: secretId ?? this.secretId,
      secretKey: secretKey ?? this.secretKey,
      engineType: _normalizeEngineType(engineType ?? this.engineType),
      hotwordList: hotwordList ?? this.hotwordList,
    );
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'secretId': secretId,
        'secretKey': secretKey,
        'engineType': engineType,
        'hotwordList': hotwordList,
      };

  factory TencentCloudAsrConfig.fromJson(Map<String, dynamic> json) {
    return TencentCloudAsrConfig(
      appId: json['appId'] as String? ?? '',
      secretId: json['secretId'] as String? ?? '',
      secretKey: json['secretKey'] as String? ?? '',
      engineType: _normalizeEngineType(
        json['engineType'] as String? ?? defaultEngineType,
      ),
      hotwordList: json['hotwordList'] as String? ?? '',
    );
  }

  static String _normalizeEngineType(String value) {
    return engineTypes.contains(value) ? value : defaultEngineType;
  }

  @override
  bool operator ==(Object other) {
    return other is TencentCloudAsrConfig &&
        other.appId == appId &&
        other.secretId == secretId &&
        other.secretKey == secretKey &&
        other.engineType == engineType &&
        other.hotwordList == hotwordList;
  }

  @override
  int get hashCode => Object.hash(
        appId,
        secretId,
        secretKey,
        engineType,
        hotwordList,
      );
}

class XiaomiMimoAsrConfig {
  const XiaomiMimoAsrConfig({
    this.llmConfigKey = '',
    this.apiKey = '',
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
    this.language = defaultLanguage,
  });

  static const String defaultBaseUrl = 'https://api.xiaomimimo.com/v1';
  static const String defaultModel = 'mimo-v2.5-asr';
  static const String defaultLanguage = 'auto';
  static const List<String> supportedModels = <String>[defaultModel];
  static const List<String> supportedLanguages = <String>[
    'auto',
    'zh',
    'en',
  ];

  final String llmConfigKey;
  final String apiKey;
  final String baseUrl;
  final String model;
  final String language;

  bool get usesLinkedConfig => llmConfigKey.trim().isNotEmpty;

  bool get hasDirectCredentials => apiKey.trim().isNotEmpty;

  XiaomiMimoAsrConfig copyWith({
    String? llmConfigKey,
    String? apiKey,
    String? baseUrl,
    String? model,
    String? language,
  }) {
    return XiaomiMimoAsrConfig(
      llmConfigKey: llmConfigKey ?? this.llmConfigKey,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: _normalizeBaseUrl(baseUrl ?? this.baseUrl),
      model: _normalizeModel(model ?? this.model),
      language: _normalizeLanguage(language ?? this.language),
    );
  }

  Map<String, dynamic> toJson() => {
        'llmConfigKey': llmConfigKey,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
        'model': model,
        'language': language,
      };

  factory XiaomiMimoAsrConfig.fromJson(Map<String, dynamic> json) {
    return XiaomiMimoAsrConfig(
      llmConfigKey: json['llmConfigKey'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: _normalizeBaseUrl(json['baseUrl'] as String? ?? defaultBaseUrl),
      model: _normalizeModel(json['model'] as String? ?? defaultModel),
      language:
          _normalizeLanguage(json['language'] as String? ?? defaultLanguage),
    );
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return defaultBaseUrl;
    return trimmed.replaceFirst(RegExp(r'/+$'), '');
  }

  static String _normalizeModel(String value) {
    return supportedModels.contains(value) ? value : defaultModel;
  }

  static String _normalizeLanguage(String value) {
    return supportedLanguages.contains(value) ? value : defaultLanguage;
  }

  @override
  bool operator ==(Object other) {
    return other is XiaomiMimoAsrConfig &&
        other.llmConfigKey == llmConfigKey &&
        other.apiKey == apiKey &&
        other.baseUrl == baseUrl &&
        other.model == model &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(
        llmConfigKey,
        apiKey,
        baseUrl,
        model,
        language,
      );
}

class SpeechRecognitionConfig {
  const SpeechRecognitionConfig({
    this.provider = SpeechRecognitionProvider.local,
    this.tencentCloud = const TencentCloudAsrConfig(),
    this.xiaomiMimo = const XiaomiMimoAsrConfig(),
  });

  static const String defaultTencentEngineModel =
      TencentCloudAsrConfig.defaultEngineType;
  static const String defaultTencentCloudEngineType =
      TencentCloudAsrConfig.defaultEngineType;
  static const List<String> tencentEngineModels =
      TencentCloudAsrConfig.engineTypes;

  final SpeechRecognitionProvider provider;
  final TencentCloudAsrConfig tencentCloud;
  final XiaomiMimoAsrConfig xiaomiMimo;

  bool get useLocalModel => provider == SpeechRecognitionProvider.local;
  bool get usesLocalModel => useLocalModel;

  String get tencentAppId => tencentCloud.appId;
  String get tencentSecretId => tencentCloud.secretId;
  String get tencentSecretKey => tencentCloud.secretKey;
  String get tencentEngineModel => tencentCloud.engineType;

  String get tencentCloudAppId => tencentCloud.appId;
  String get tencentCloudSecretId => tencentCloud.secretId;
  String get tencentCloudSecretKey => tencentCloud.secretKey;
  String get tencentCloudEngineType => tencentCloud.engineType;

  bool get hasTencentCloudCredentials => tencentCloud.isConfigured;
  bool get hasXiaomiMimoCredentials =>
      xiaomiMimo.usesLinkedConfig || xiaomiMimo.hasDirectCredentials;

  SpeechRecognitionConfig copyWith({
    SpeechRecognitionProvider? provider,
    TencentCloudAsrConfig? tencentCloud,
    XiaomiMimoAsrConfig? xiaomiMimo,
    String? tencentAppId,
    String? tencentSecretId,
    String? tencentSecretKey,
    String? tencentEngineModel,
    String? tencentCloudAppId,
    String? tencentCloudSecretId,
    String? tencentCloudSecretKey,
    String? tencentCloudEngineType,
  }) {
    final baseTencentCloud = tencentCloud ?? this.tencentCloud;
    return SpeechRecognitionConfig(
      provider: provider ?? this.provider,
      tencentCloud: baseTencentCloud.copyWith(
        appId: tencentAppId ?? tencentCloudAppId,
        secretId: tencentSecretId ?? tencentCloudSecretId,
        secretKey: tencentSecretKey ?? tencentCloudSecretKey,
        engineType: tencentEngineModel ?? tencentCloudEngineType,
      ),
      xiaomiMimo: xiaomiMimo ?? this.xiaomiMimo,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider.toJson(),
        'tencentCloud': tencentCloud.toJson(),
        'xiaomiMimo': xiaomiMimo.toJson(),
        'tencentAppId': tencentCloud.appId,
        'tencentSecretId': tencentCloud.secretId,
        'tencentSecretKey': tencentCloud.secretKey,
        'tencentEngineModel': tencentCloud.engineType,
        'tencentCloudAppId': tencentCloud.appId,
        'tencentCloudSecretId': tencentCloud.secretId,
        'tencentCloudSecretKey': tencentCloud.secretKey,
        'tencentCloudEngineType': tencentCloud.engineType,
      };

  factory SpeechRecognitionConfig.fromJson(Map<String, dynamic> json) {
    final nestedTencentCloud = json['tencentCloud'];
    final nestedXiaomiMimo = json['xiaomiMimo'];
    final tencentCloud = nestedTencentCloud is Map<String, dynamic>
        ? TencentCloudAsrConfig.fromJson(nestedTencentCloud)
        : TencentCloudAsrConfig(
            appId: json['tencentAppId'] as String? ??
                json['tencentCloudAppId'] as String? ??
                '',
            secretId: json['tencentSecretId'] as String? ??
                json['tencentCloudSecretId'] as String? ??
                '',
            secretKey: json['tencentSecretKey'] as String? ??
                json['tencentCloudSecretKey'] as String? ??
                '',
            engineType: json['tencentEngineModel'] as String? ??
                json['tencentCloudEngineType'] as String? ??
                TencentCloudAsrConfig.defaultEngineType,
          );
    return SpeechRecognitionConfig(
      provider: SpeechRecognitionProvider.fromJson(json['provider'] as String?),
      tencentCloud: tencentCloud,
      xiaomiMimo: nestedXiaomiMimo is Map<String, dynamic>
          ? XiaomiMimoAsrConfig.fromJson(nestedXiaomiMimo)
          : const XiaomiMimoAsrConfig(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpeechRecognitionConfig &&
        other.provider == provider &&
        other.tencentCloud == tencentCloud &&
        other.xiaomiMimo == xiaomiMimo;
  }

  @override
  int get hashCode => Object.hash(provider, tencentCloud, xiaomiMimo);
}

import 'package:memex/config/app_flavor.dart';
import 'package:memex/domain/models/llm_config.dart';

/// Centralized feature configuration that varies by flavor.
///
/// All flavor-dependent feature flags and provider lists live here.
/// UI and business logic should query this class instead of checking
/// [AppFlavor] directly, so that adding a new flavor or changing
/// availability is a single-file change.
class AppConfig {
  AppConfig._();

  // ─── LLM Providers ───────────────────────────────────────────────

  /// Provider types available in the current flavor.
  static List<String> get availableProviders {
    switch (AppFlavor.current) {
      case AppFlavorType.cn:
        return _cnProviders;
      case AppFlavorType.global:
        return _globalProviders;
    }
  }

  /// Returns true if [providerType] is available in the current flavor.
  static bool isProviderAvailable(String providerType) {
    return availableProviders.contains(providerType);
  }

  static const _globalProviders = [
    // OpenAI
    LLMConfig.typeChatCompletion,
    LLMConfig.typeResponses,
    LLMConfig.typeOpenAiOauth,
    // Anthropic
    LLMConfig.typeClaude,
    LLMConfig.typeBedrockClaude,
    // Google
    LLMConfig.typeGemini,
    LLMConfig.typeGeminiOauth,
    // Chinese providers
    LLMConfig.typeKimi,
    LLMConfig.typeQwen,
    LLMConfig.typeSeed,
    LLMConfig.typeZhipu,
    LLMConfig.typeMimo,
    // Aggregators
    LLMConfig.typeOpenRouter,
    LLMConfig.typeOllama,
    // On-device
    LLMConfig.typeGemmaLocal,
  ];

  static const _cnProviders = [
    // Chinese providers
    LLMConfig.typeKimi,
    LLMConfig.typeQwen,
    LLMConfig.typeSeed,
    LLMConfig.typeZhipu,
    LLMConfig.typeMimo,
    // Aggregators
    LLMConfig.typeOllama,
    // On-device
    LLMConfig.typeGemmaLocal,
  ];

  // ─── Feature Flags ───────────────────────────────────────────────
  // Add more flavor-dependent flags here as needed, e.g.:
  //
  // static bool get enableICloudSync => AppFlavor.isGlobal;
  // static bool get enableHealthKit  => AppFlavor.isGlobal;
}

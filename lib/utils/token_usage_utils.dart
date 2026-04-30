import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/llm_client/codex_responses_client.dart';
import 'package:memex/llm_client/gemini_oauth_client.dart';

class TokenUsageUtils {
  const TokenUsageUtils._();

  static int _nonNegative(int value) => value < 0 ? 0 : value;

  static bool? _asBool(Object? value) {
    if (value is bool) return value;
    return null;
  }

  /// Resolves whether [cachedTokens] are already included in the prompt/input
  /// token count reported by the provider.
  ///
  /// This intentionally does not infer from token values or model names. The
  /// answer must come from persisted semantics, the raw provider usage object,
  /// or the concrete client adapter that produced the usage.
  static bool? cachedTokensIncludedInPrompt({
    Object? client,
    dynamic originalUsage,
    Object? recordedValue,
  }) {
    final recorded = _asBool(recordedValue);
    if (recorded != null) return recorded;

    final usage = originalUsage is Map ? originalUsage : null;
    if (usage != null) {
      if (usage.containsKey('cache_read_input_tokens') ||
          usage.containsKey('cache_creation_input_tokens')) {
        return false;
      }
      if (usage.containsKey('prompt_tokens_details') ||
          usage.containsKey('input_tokens_details') ||
          usage.containsKey('cachedContentTokenCount')) {
        return true;
      }
    }

    if (client == null) return null;
    return cachedTokensIncludedInPromptForClient(client);
  }

  static bool? cachedTokensIncludedInPromptForClient(Object client) {
    if (client is ClaudeClient || client is BedrockClaudeClient) {
      return false;
    }
    if (client is GeminiClient ||
        client is GeminiOAuthClient ||
        client is OpenAIClient ||
        client is ResponsesClient ||
        client is CodexResponsesClient) {
      return true;
    }

    return null;
  }

  /// Returns the total input-token denominator for cache-rate display.
  static int effectivePromptTokens({
    required int promptTokens,
    required int cachedTokens,
    required bool cachedTokensIncludedInPrompt,
  }) {
    final prompt = _nonNegative(promptTokens);
    final cached = _nonNegative(cachedTokens);

    if (cachedTokensIncludedInPrompt) return prompt;
    return prompt + cached;
  }

  /// Returns prompt tokens billed at the normal input-token price.
  static int nonCachedPromptTokens({
    required int promptTokens,
    required int cachedTokens,
    required bool cachedTokensIncludedInPrompt,
  }) {
    final prompt = _nonNegative(promptTokens);
    final cached = _nonNegative(cachedTokens);

    if (cachedTokensIncludedInPrompt) {
      final nonCached = prompt - cached;
      return nonCached > 0 ? nonCached : 0;
    }
    return prompt;
  }

  static int? effectivePromptTokensOrNull({
    required int promptTokens,
    required int cachedTokens,
    required bool? cachedTokensIncludedInPrompt,
  }) {
    final prompt = _nonNegative(promptTokens);
    final cached = _nonNegative(cachedTokens);
    if (cached == 0) return prompt;
    if (cachedTokensIncludedInPrompt == null) return null;

    return effectivePromptTokens(
      promptTokens: prompt,
      cachedTokens: cached,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
  }

  static int? nonCachedPromptTokensOrNull({
    required int promptTokens,
    required int cachedTokens,
    required bool? cachedTokensIncludedInPrompt,
  }) {
    final prompt = _nonNegative(promptTokens);
    final cached = _nonNegative(cachedTokens);
    if (cached == 0) return prompt;
    if (cachedTokensIncludedInPrompt == null) return null;

    return nonCachedPromptTokens(
      promptTokens: prompt,
      cachedTokens: cached,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
  }

  static double cacheRate({
    required int promptTokens,
    required int cachedTokens,
    required bool cachedTokensIncludedInPrompt,
  }) {
    final cached = _nonNegative(cachedTokens);
    if (cached == 0) return 0.0;

    final denominator = effectivePromptTokens(
      promptTokens: promptTokens,
      cachedTokens: cached,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
    if (denominator == 0) return 0.0;

    return ((cached / denominator) * 100).clamp(0.0, 100.0).toDouble();
  }

  static double? cacheRateOrNull({
    required int promptTokens,
    required int cachedTokens,
    required bool? cachedTokensIncludedInPrompt,
  }) {
    final cached = _nonNegative(cachedTokens);
    if (cached == 0) return 0.0;
    if (cachedTokensIncludedInPrompt == null) return null;

    return cacheRate(
      promptTokens: promptTokens,
      cachedTokens: cachedTokens,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
  }

  static String formatCacheRate({
    required int promptTokens,
    required int cachedTokens,
    required bool cachedTokensIncludedInPrompt,
    int fractionDigits = 1,
  }) {
    final rate = cacheRate(
      promptTokens: promptTokens,
      cachedTokens: cachedTokens,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
    return '${rate.toStringAsFixed(fractionDigits)}%';
  }

  static String formatCacheRateOrUnavailable({
    required int promptTokens,
    required int cachedTokens,
    required bool? cachedTokensIncludedInPrompt,
    int fractionDigits = 1,
    String unavailableLabel = 'N/A',
  }) {
    final rate = cacheRateOrNull(
      promptTokens: promptTokens,
      cachedTokens: cachedTokens,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
    if (rate == null) return unavailableLabel;
    return '${rate.toStringAsFixed(fractionDigits)}%';
  }
}

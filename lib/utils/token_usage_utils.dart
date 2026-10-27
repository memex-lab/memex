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

    // Live adapters normalize usage before Memex receives it. In particular,
    // dart_agent_core 2.1.8 includes Claude cache reads/writes in promptTokens,
    // even though originalUsage still contains Anthropic's separate counts.
    if (client != null) {
      final semantics = cachedTokensIncludedInPromptForClient(client);
      if (semantics != null) return semantics;
    }

    // Keep the legacy inference for stored records without an explicit flag.
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

    return null;
  }

  static bool? cachedTokensIncludedInPromptForClient(Object client) {
    if (client is BedrockClaudeClient) {
      return false;
    }
    if (client is ClaudeClient ||
        client is GeminiClient ||
        client is GeminiOAuthClient ||
        client is OpenAIClient ||
        client is ResponsesClient ||
        client is CodexResponsesClient) {
      return true;
    }

    return null;
  }

  /// Resolves [cachedTokensIncludedInPrompt] from a persisted usage record.
  static bool? resolveFromUsageRecord(Map<String, dynamic> usage) {
    return cachedTokensIncludedInPrompt(
      originalUsage: usage['original_usage'],
      recordedValue: usage['cache_tokens_included_in_prompt'],
    );
  }

  /// Returns the total input-token denominator for cache-rate display.
  ///
  /// When [cachedTokensIncludedInPrompt] is true, prompt
  /// already contains cached, so the denominator is just prompt.
  /// When false (Bedrock/legacy Claude), denominator = prompt + cached.
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

  /// Computes cache rate from pre-normalized effective prompt tokens.
  ///
  /// [effectivePromptTokens] is the denominator (total input tokens including
  /// cached), already normalized per-call before aggregation.
  /// [cachedTokens] is the numerator.
  static String formatCacheRateFromAggregated({
    required int effectivePromptTokens,
    required int cachedTokens,
    int fractionDigits = 1,
  }) {
    final cached = _nonNegative(cachedTokens);
    final denom = _nonNegative(effectivePromptTokens);
    if (cached == 0 || denom == 0) return '0.0%';
    final rate = ((cached / denom) * 100).clamp(0.0, 100.0);
    return '${rate.toStringAsFixed(fractionDigits)}%';
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
    final cached = _nonNegative(cachedTokens);
    if (cached == 0) return '0.0%';
    if (cachedTokensIncludedInPrompt == null) return unavailableLabel;
    final rate = cacheRate(
      promptTokens: promptTokens,
      cachedTokens: cachedTokens,
      cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt,
    );
    return '${rate.toStringAsFixed(fractionDigits)}%';
  }

  // ---------------------------------------------------------------------------
  // Cost estimation
  // ---------------------------------------------------------------------------

  static const _pricing = {
    'gemini-3-flash-preview': {
      'input': 0.0000005,
      'cached': 0.00000005,
      'output': 0.000003,
    },
    'gemini-2.5-flash': {
      'input': 0.0000003,
      'cached': 0.00000003,
      'output': 0.0000025,
    },
    'gemini-3.1-pro-preview': {
      'input': 0.000002,
      'cached': 0.0000002,
      'output': 0.000012,
    },
    'gemini-3-pro-preview': {
      'input': 0.000002,
      'cached': 0.0000002,
      'output': 0.000012,
    },
    'gpt-4o': {
      'input': 0.0000025,
      'cached': 0.00000125,
      'output': 0.00001,
    },
  };

  /// Estimates the cost of a single LLM call.
  ///
  /// Returns a map with 'input', 'output', and 'total' cost values.
  static Map<String, double> calculateCost({
    required String model,
    required int promptTokens,
    required int completionTokens,
    required int cachedTokens,
    required int thoughtTokens,
    required bool? cachedTokensIncludedInPrompt,
  }) {
    // Find matching model pricing via substring match.
    Map<String, double>? prices;
    final modelLower = model.toLowerCase();
    for (final key in _pricing.keys) {
      if (modelLower.contains(key)) {
        prices = _pricing[key];
        break;
      }
    }
    prices ??= _pricing['gpt-4o'];
    if (prices == null) {
      return {'input': 0.0, 'output': 0.0, 'total': 0.0};
    }

    final uncached = nonCachedPromptTokensOrNull(
            promptTokens: promptTokens,
            cachedTokens: cachedTokens,
            cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt) ??
        promptTokens;
    final inputCost =
        (uncached * prices['input']!) + (cachedTokens * prices['cached']!);

    // todo: responses API completion includes thought
    final outputCost = model.startsWith('ep-')
        ? completionTokens * prices['output']!
        : (completionTokens + thoughtTokens) * prices['output']!;

    return {
      'input': inputCost,
      'output': outputCost,
      'total': inputCost + outputCost,
    };
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/llm_client/codex_responses_client.dart';
import 'package:memex/utils/token_usage_utils.dart';

void main() {
  group('TokenUsageUtils', () {
    test(
      'uses prompt tokens as denominator when cached tokens are included',
      () {
        expect(
          TokenUsageUtils.effectivePromptTokens(
            promptTokens: 1000,
            cachedTokens: 250,
            cachedTokensIncludedInPrompt: true,
          ),
          1000,
        );
        expect(
          TokenUsageUtils.nonCachedPromptTokens(
            promptTokens: 1000,
            cachedTokens: 250,
            cachedTokensIncludedInPrompt: true,
          ),
          750,
        );
        expect(
          TokenUsageUtils.cacheRate(
            promptTokens: 1000,
            cachedTokens: 250,
            cachedTokensIncludedInPrompt: true,
          ),
          closeTo(25.0, 0.001),
        );
      },
    );

    test(
      'adds cached tokens to denominator when provider returns them separately',
      () {
        expect(
          TokenUsageUtils.effectivePromptTokens(
            promptTokens: 200,
            cachedTokens: 800,
            cachedTokensIncludedInPrompt: false,
          ),
          1000,
        );
        expect(
          TokenUsageUtils.nonCachedPromptTokens(
            promptTokens: 200,
            cachedTokens: 800,
            cachedTokensIncludedInPrompt: false,
          ),
          200,
        );
        expect(
          TokenUsageUtils.cacheRate(
            promptTokens: 200,
            cachedTokens: 800,
            cachedTokensIncludedInPrompt: false,
          ),
          closeTo(80.0, 0.001),
        );
      },
    );

    test('does not infer provider semantics from token magnitude', () {
      expect(
        TokenUsageUtils.effectivePromptTokens(
          promptTokens: 1000,
          cachedTokens: 250,
          cachedTokensIncludedInPrompt: false,
        ),
        1250,
      );
      expect(
        TokenUsageUtils.nonCachedPromptTokens(
          promptTokens: 1000,
          cachedTokens: 250,
          cachedTokensIncludedInPrompt: false,
        ),
        1000,
      );
      expect(
        TokenUsageUtils.cacheRate(
          promptTokens: 1000,
          cachedTokens: 250,
          cachedTokensIncludedInPrompt: false,
        ),
        closeTo(20.0, 0.001),
      );
    });

    test('detects known provider cache token semantics from usage shape', () {
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          originalUsage: {
            'prompt_tokens_details': {'cached_tokens': 100},
          },
        ),
        isTrue,
      );
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          originalUsage: {'cache_read_input_tokens': 100},
        ),
        isFalse,
      );
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          originalUsage: {'cache_creation_input_tokens': 100},
        ),
        isFalse,
      );
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          originalUsage: {
            'input_tokens_details': {'cached_tokens': 100},
          },
        ),
        isTrue,
      );
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          originalUsage: {'cachedContentTokenCount': 100},
        ),
        isTrue,
      );
    });

    test('returns null when cache token semantics cannot be proven', () {
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(),
        isNull,
      );
    });

    test('detects cache token semantics from concrete client adapters', () {
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: ClaudeClient(apiKey: 'test-key'),
        ),
        isFalse,
      );
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: ResponsesClient(apiKey: 'test-key'),
        ),
        isTrue,
      );
      expect(
        TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: CodexResponsesClient(accessToken: 'test-token'),
        ),
        isTrue,
      );
    });

    test('formats cache rate without exceeding 100 percent', () {
      expect(
        TokenUsageUtils.formatCacheRate(
          promptTokens: 0,
          cachedTokens: 500,
          cachedTokensIncludedInPrompt: false,
        ),
        '100.0%',
      );
      expect(
        TokenUsageUtils.formatCacheRate(
          promptTokens: 0,
          cachedTokens: 0,
          cachedTokensIncludedInPrompt: false,
        ),
        '0.0%',
      );
    });

    test('returns unavailable cache rate when cache semantics are unknown', () {
      expect(
        TokenUsageUtils.effectivePromptTokensOrNull(
          promptTokens: 100,
          cachedTokens: 50,
          cachedTokensIncludedInPrompt: null,
        ),
        isNull,
      );
      expect(
        TokenUsageUtils.formatCacheRateOrUnavailable(
          promptTokens: 100,
          cachedTokens: 50,
          cachedTokensIncludedInPrompt: null,
        ),
        'N/A',
      );
      expect(
        TokenUsageUtils.formatCacheRateOrUnavailable(
          promptTokens: 100,
          cachedTokens: 0,
          cachedTokensIncludedInPrompt: null,
        ),
        '0.0%',
      );
    });
  });
}

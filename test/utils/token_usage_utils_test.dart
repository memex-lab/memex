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

    test('resolveFromUsageRecord reads persisted semantics', () {
      expect(
        TokenUsageUtils.resolveFromUsageRecord({
          'cache_tokens_included_in_prompt': true,
        }),
        isTrue,
      );
      expect(
        TokenUsageUtils.resolveFromUsageRecord({
          'original_usage': {'cache_read_input_tokens': 100},
        }),
        isFalse,
      );
      expect(
        TokenUsageUtils.resolveFromUsageRecord({}),
        isNull,
      );
    });

    test('formatCacheRateFromAggregated computes from pre-normalized values',
        () {
      // 250 cached out of 1000 effective prompt = 25%
      expect(
        TokenUsageUtils.formatCacheRateFromAggregated(
          effectivePromptTokens: 1000,
          cachedTokens: 250,
        ),
        '25.0%',
      );
      // zero cached
      expect(
        TokenUsageUtils.formatCacheRateFromAggregated(
          effectivePromptTokens: 1000,
          cachedTokens: 0,
        ),
        '0.0%',
      );
      // zero denominator
      expect(
        TokenUsageUtils.formatCacheRateFromAggregated(
          effectivePromptTokens: 0,
          cachedTokens: 0,
        ),
        '0.0%',
      );
    });

    test('calculateCost estimates token cost with known pricing', () {
      // gemini-2.5-flash: input=0.0000003, cached=0.00000003, output=0.0000025
      final costs = TokenUsageUtils.calculateCost(
        model: 'gemini-2.5-flash-preview-05-20',
        promptTokens: 1000,
        completionTokens: 200,
        cachedTokens: 300,
        thoughtTokens: 50,
        cachedTokensIncludedInPrompt: true,
      );
      // nonCached = 1000 - 300 = 700
      // inputCost = 700 * 0.0000003 + 300 * 0.00000003
      const expectedInput = 700 * 0.0000003 + 300 * 0.00000003;
      // outputCost = (200 + 50) * 0.0000025
      const expectedOutput = 250 * 0.0000025;
      expect(costs['input'], closeTo(expectedInput, 1e-10));
      expect(costs['output'], closeTo(expectedOutput, 1e-10));
      expect(costs['total'], closeTo(expectedInput + expectedOutput, 1e-10));
    });

    test('calculateCost falls back to gpt-4o for unknown models', () {
      final costs = TokenUsageUtils.calculateCost(
        model: 'unknown-model-xyz',
        promptTokens: 100,
        completionTokens: 50,
        cachedTokens: 0,
        thoughtTokens: 0,
        cachedTokensIncludedInPrompt: true,
      );
      // gpt-4o: input=0.0000025, output=0.00001
      const expectedInput = 100 * 0.0000025;
      const expectedOutput = 50 * 0.00001;
      expect(costs['total'], closeTo(expectedInput + expectedOutput, 1e-10));
    });
  });
}

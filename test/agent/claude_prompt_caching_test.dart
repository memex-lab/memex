import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/utils/token_usage_utils.dart';

void main() {
  for (final endpoint in [
    'https://api.anthropic.com',
    'https://api.minimaxi.com/anthropic',
    'https://api.xiaomimimo.com/anthropic',
  ]) {
    for (final streaming in [false, true]) {
      test('Claude caching and Memex accounting: $endpoint stream=$streaming',
          () async {
        const rawUsage = {
          'input_tokens': 200,
          'cache_read_input_tokens': 700,
          'cache_creation_input_tokens': 100,
          'output_tokens': 20,
        };
        final requests = <Map<String, dynamic>>[];
        final dio = Dio()
          ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
            requests.add(
                jsonDecode(options.data as String) as Map<String, dynamic>);
            final events = [
              {
                'type': 'message_start',
                'message': {'usage': rawUsage},
              },
              {
                'type': 'message_delta',
                'delta': {'stop_reason': 'end_turn'},
                'usage': {'output_tokens': 20},
              },
              {'type': 'message_stop'},
            ];
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: streaming
                  ? ResponseBody.fromString(
                      events.map((e) => 'data: ${jsonEncode(e)}\n\n').join(),
                      200,
                      headers: {
                        Headers.contentTypeHeader: ['text/event-stream'],
                      },
                    )
                  : {
                      'content': [
                        {'type': 'text', 'text': 'ok'},
                      ],
                      'stop_reason': 'end_turn',
                      'usage': rawUsage,
                    },
            ));
          }));
        addTearDown(() => dio.close(force: true));
        final client = ClaudeClient(
          apiKey: 'test-key',
          baseUrl: endpoint,
          client: dio,
          maxRetries: 0,
        );
        final messages = [UserMessage.text('Record a journal entry')];
        final config = ModelConfig(model: 'claude-test');
        final ModelUsage usage;
        if (streaming) {
          final stream = await client.stream(messages, modelConfig: config);
          usage = (await stream
                  .map((event) => event.modelMessage?.usage)
                  .where((value) => value != null)
                  .toList())
              .last!;
        } else {
          usage = (await client.generate(messages, modelConfig: config)).usage!;
        }

        expect(requests, hasLength(1));
        if (endpoint == 'https://api.anthropic.com') {
          expect(requests.single['cache_control'], {'type': 'ephemeral'});
        } else {
          expect(requests.single, isNot(contains('cache_control')));
        }
        expect(usage.promptTokens, 1000);
        expect(usage.totalTokens, 1020);
        expect(usage.cachedToken, 800);
        final semantics = TokenUsageUtils.cachedTokensIncludedInPrompt(
          client: client,
          originalUsage: usage.originalUsage,
        );
        expect(semantics, isTrue);
        expect(
          TokenUsageUtils.effectivePromptTokensOrNull(
            promptTokens: usage.promptTokens,
            cachedTokens: usage.cachedToken,
            cachedTokensIncludedInPrompt: semantics,
          ),
          1000,
        );
        expect(
          TokenUsageUtils.resolveFromUsageRecord({
            'cache_tokens_included_in_prompt': semantics,
            'original_usage': usage.originalUsage,
          }),
          isTrue,
        );
      });
    }
  }
}

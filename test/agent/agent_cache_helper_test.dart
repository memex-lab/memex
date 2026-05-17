import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/agent_cache_helper.dart';

void main() {
  tearDown(() {
    AgentCacheHelper.responseCacheEnabled = false;
  });

  test('does not create a cache agent when response cache is disabled',
      () async {
    var factoryCalled = false;

    final responseId = await AgentCacheHelper.ensureValidCachedResponseId(
      agentType: 'test_agent',
      client: ResponsesClient(
        apiKey: 'test-key',
        baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
      ),
      modelConfig: ModelConfig(model: 'test-model'),
      agentFactory: ({required client, required modelConfig}) async {
        factoryCalled = true;
        throw StateError('agent factory should not be called');
      },
    );

    expect(responseId, isNull);
    expect(factoryCalled, isFalse);
  });
}

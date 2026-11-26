import 'dart:convert';
import 'dart:io';
import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/recall_records/record_recall_tools.dart';
import 'package:memex/agent/super_agent/super_agent.dart';
import 'package:memex/data/model/chat_artifact.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/record_recall_service.dart';
import 'package:memex/domain/models/card_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('record_recall_');
    await FileSystemService.init(root.path);
  });
  tearDown(() async => root.delete(recursive: true));

  Future<void> save(int n,
      {String user = 'u',
      String fact = '妈妈复查 带报告',
      bool deleted = false,
      String status = 'completed'}) async {
    final id = '2026/09/17.md#ts_$n';
    final fs = FileSystemService.instance;
    await fs.writeYamlFile(
        fs.getCardPath(user, id),
        CardData(
          factId: id,
          timestamp: n,
          status: status,
          tags: [],
          uiConfigs: [],
          title: '复查记录',
          fact: fact,
          deleted: deleted,
          insight: const CardInsight(summary: 'AI 猜测需要手术'),
        ).toJson());
  }

  test(
      'search paginates source files without index and isolates user and status',
      () async {
    for (var n = 1; n <= 12; n++) {
      await save(n);
    }
    await save(20, deleted: true);
    await save(21, status: 'processing');
    await save(22, user: 'other', fact: 'other private');
    final service = RecordRecallService('u');
    final page = await service.search('妈妈 报告');
    expect(page['matches'], hasLength(10));
    final next =
        await service.search('妈妈 报告', offset: page['next_offset'] as int);
    expect(next['matches'], hasLength(2));
    expect(next['next_offset'], isNull);
    expect((await service.search('手术'))['matches'], isEmpty);
    expect((await service.search('private'))['matches'], isEmpty);
    expect(await service.read('2026/09/17.md#ts_20'), isNull);
    expect(await service.read('2026/09/17.md#ts_22'), isNull);
    await expectLater(
        service.read('../2026/09/17.md#ts_1'), throwsArgumentError);
  });

  test(
      'agent tool retrieves latest original and emits persisted reference, not creation',
      () async {
    await save(1);
    final tools = buildRecordRecallTools('u');
    for (final tool in tools) {
      expect(SuperAgent.isQuickQueryToolAllowed(tool.name), isTrue);
    }
    Future<FunctionExecutionResult> run(
        String name, Map<String, dynamic> args) async {
      final state = AgentState(sessionId: 'recall-test');
      final agent = StatefulAgent(
          name: 'recall-test',
          client: _SingleToolCallClient(toolName: name, arguments: args),
          modelConfig: ModelConfig(model: 'test'),
          state: state,
          tools: tools,
          withGeneralPrinciples: false,
          maxTurns: 3);
      await agent.run([UserMessage.text('上次复查说了什么')], useStream: false);
      return state.history.messages
          .whereType<FunctionExecutionResultMessage>()
          .single
          .results
          .single;
    }

    final search = await run('search_records', {'query': '妈妈'});
    expect(search.isError, isFalse);
    final matches =
        jsonDecode(search.content.whereType<TextPart>().single.text)['matches'];
    expect(matches, hasLength(1));
    await save(1, fact: '医生说下周带报告复查，未提手术');
    final result =
        await run('read_record_evidence', {'fact_id': matches[0]['fact_id']});
    expect(result.isError, isFalse);
    final evidence =
        jsonDecode(result.content.whereType<TextPart>().single.text);
    expect(evidence['original_fact'], '医生说下周带报告复查，未提手术');
    expect(evidence['generated_interpretation_not_evidence']['summary'],
        contains('AI'));
    final artifact = ChatArtifact.fromToolMetadata(result.metadata)!;
    expect(artifact.operation, ChatArtifact.operationReference);
    expect(artifact.timelineCardId, '2026/09/17.md#ts_1');
    expect(ChatArtifact.fromJson(artifact.toJson())!.operation,
        ChatArtifact.operationReference);
    await save(1, deleted: true);
    final unavailable =
        await run('read_record_evidence', {'fact_id': '2026/09/17.md#ts_1'});
    expect(ChatArtifact.fromToolMetadata(unavailable.metadata), isNull);
  });
}

class _SingleToolCallClient extends LLMClient {
  _SingleToolCallClient({
    required this.toolName,
    required this.arguments,
  });

  final String toolName;
  final Map<String, dynamic> arguments;
  var _callCount = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    _callCount += 1;
    if (_callCount == 1) {
      return ModelMessage(
        model: modelConfig.model,
        stopReason: 'tool_calls',
        functionCalls: [
          FunctionCall(
            id: 'call_1',
            name: toolName,
            arguments: jsonEncode(arguments),
          ),
        ],
      );
    }
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'stop',
      textOutput: 'done',
    );
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnsupportedError('Streaming is not used by this test client.');
  }
}

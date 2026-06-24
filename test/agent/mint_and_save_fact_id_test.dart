import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/common_tools.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 1 of the subagent refactor decoupled fact_id minting from card
/// saving: `mint_record_fact_id` reserves an id (writing a `processing`
/// placeholder), and `save_timeline_card` now REQUIRES an explicit fact_id and
/// decides "new vs edit" from the placeholder's status — `processing`/missing
/// means the save is the brand-new card (fires comment + memory triggers),
/// `completed` means it's an edit (no re-trigger).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mint_record_fact_id + status-driven new-card detection', () {
    late AppDatabase db;
    late Directory tempRoot;
    late String userId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);

      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      userId = 'mint_${DateTime.now().microsecondsSinceEpoch}';
      await UserStorage.saveUser(userId);

      tempRoot = await Directory.systemTemp.createTemp('memex_mint_');
      await FileSystemService.init(tempRoot.path);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
      await db.close();
    });

    test('mint tool does not accept a content creation date', () {
      expect(
        mintRecordFactIdTool.parameters['properties'],
        isNot(contains('content_creation_date')),
      );
    });

    test('mint reserves a processing placeholder card', () async {
      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      expect(mintResult.isError, isFalse);

      final factId = _artifactId(mintResult);
      expect(factId, isNotNull);
      expect(_text(mintResult), factId);
      expect(_text(mintResult), isNot(contains('Use this exact id')));

      final card =
          await FileSystemService.instance.readCardFile(userId, factId!);
      expect(card, isNotNull);
      expect(card!.status, 'processing');
      expect(card.createdAt, isNotNull);
      expect(card.createdAt, greaterThan(0));
      _expectClassicProcessingPlaceholder(card);
    });

    test('mint can reserve multiple processing placeholder cards', () async {
      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {'count': 3},
        metadata: {'userId': userId},
      );
      expect(mintResult.isError, isFalse);

      final factIds = _text(mintResult).split('\n');
      expect(factIds, hasLength(3));
      expect(factIds.toSet(), hasLength(3));
      expect(_artifactIds(mintResult), factIds);

      for (final factId in factIds) {
        final card =
            await FileSystemService.instance.readCardFile(userId, factId);
        expect(card, isNotNull);
        expect(card!.status, 'processing');
        _expectClassicProcessingPlaceholder(card);
      }
    });

    test('mint then save completes the card and enqueues memory once',
        () async {
      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      final factId = _artifactId(mintResult)!;

      final saveResult = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': factId,
          'title': 'Slept 6.5 hours',
          'fact': 'Slept 6.5 hours last night, woke up twice.',
          'ui_configs': [
            {
              'template_id': 'metric',
              'data': {
                'items': [
                  {'title': 'Sleep', 'value': 6.5, 'unit': 'h'},
                ],
              },
            },
          ],
        },
        metadata: {'userId': userId},
      );
      expect(saveResult.isError, isFalse);

      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      expect(card!.status, 'completed');
      expect(card.title, 'Slept 6.5 hours');

      // New-card path fired the memory enqueue exactly once.
      expect(await _pendingMemoryFactIds(userId), [factId]);
    });

    test('re-saving a completed card is an edit and does not re-enqueue',
        () async {
      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      final factId = _artifactId(mintResult)!;

      Map<String, dynamic> saveArgs(String title) => {
            'fact_id': factId,
            'title': title,
            'fact': 'A note to record then edit.',
            'ui_configs': [
              {
                'template_id': 'article',
                'data': {'body': 'A note to record then edit.'},
              },
            ],
          };

      final first = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: saveArgs('Original title'),
        metadata: {'userId': userId},
      );
      expect(first.isError, isFalse);

      // Second save against the now-completed card is an EDIT.
      final second = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: saveArgs('Edited title'),
        metadata: {'userId': userId},
      );
      expect(second.isError, isFalse);

      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      expect(card!.title, 'Edited title');

      // Only the first (new-card) save enqueued memory; the edit did not.
      expect(await _pendingMemoryFactIds(userId), [factId]);
    });

    test('save without minting first is a tool error', () async {
      final result = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': '2099/01/01.md#ts_1',
          'title': 'Never minted',
          'fact': 'This id was never minted.',
          'ui_configs': [
            {
              'template_id': 'article',
              'data': {'body': 'This id was never minted.'},
            },
          ],
        },
        metadata: {'userId': userId},
      );
      expect(result.isError, isTrue);
      expect(_text(result), contains('does not exist'));
    });

    test('editing with only fact preserves the existing assets and title',
        () async {
      // Seed a real asset file so the reference survives validation.
      final assetsDir =
          Directory(FileSystemService.instance.getAssetsPath(userId));
      await assetsDir.create(recursive: true);
      await File(p.join(assetsDir.path, 'photo.jpg'))
          .writeAsBytes(const [0xff, 0xd8, 0xff, 0xd9]);

      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      final factId = _artifactId(mintResult)!;

      // Create the card with an image attachment.
      final created = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': factId,
          'title': 'Dinner photo',
          'fact': 'Spicy peppers for dinner.',
          'assets': ['fs://photo.jpg'],
          'ui_configs': [
            {
              'template_id': 'snapshot',
              'data': {'image_url': 'fs://photo.jpg', 'caption': 'Dinner'},
            },
          ],
        },
        metadata: {'userId': userId},
      );
      expect(created.isError, isFalse);

      // Edit: send ONLY the new fact (omit title, assets, ui_configs).
      final edited = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': factId,
          'fact': 'Spicy peppers, fried fish, and cucumber soup for dinner.',
        },
        metadata: {'userId': userId},
      );
      expect(edited.isError, isFalse);

      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      // The omitted fields kept their prior values; only fact changed.
      expect(card!.fact,
          'Spicy peppers, fried fish, and cucumber soup for dinner.');
      expect(card.assets, ['![image](fs://photo.jpg)']);
      expect(card.title, 'Dinner photo');
      expect(card.uiConfigs.single.templateId, 'snapshot');
    });

    test('save accepts bare fs asset refs and stores renderable markdown refs',
        () async {
      final assetsDir =
          Directory(FileSystemService.instance.getAssetsPath(userId));
      await assetsDir.create(recursive: true);
      await File(p.join(assetsDir.path, 'bare_photo.jpg'))
          .writeAsBytes(const [0xff, 0xd8, 0xff, 0xd9]);

      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      final factId = _artifactId(mintResult)!;

      final saved = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': factId,
          'title': 'Bare asset ref',
          'fact': 'Photo attachment captured.',
          'assets': ['fs://bare_photo.jpg'],
          'ui_configs': [
            {
              'template_id': 'snapshot',
              'data': {'image_url': 'fs://bare_photo.jpg'},
            },
          ],
        },
        metadata: {'userId': userId},
      );
      expect(saved.isError, isFalse);

      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      expect(card!.assets, ['![image](fs://bare_photo.jpg)']);
    });

    test('card cache timeline ordering uses record creation time for new cards',
        () async {
      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      final factId = _artifactId(mintResult)!;
      final placeholder =
          await FileSystemService.instance.readCardFile(userId, factId);
      final createdAt = placeholder!.createdAt!;

      final saved = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': factId,
          'title': 'Old event saved today',
          'fact': 'A memory from 2000 that was recorded today.',
          'content_creation_date': '2000-01-01T00:00:00',
          'ui_configs': [
            {
              'template_id': 'article',
              'data': {'body': 'A memory from 2000 that was recorded today.'},
            },
          ],
        },
        metadata: {'userId': userId},
      );
      expect(saved.isError, isFalse);

      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      expect(card!.timestamp,
          DateTime.parse('2000-01-01T00:00:00').millisecondsSinceEpoch ~/ 1000);

      final cached = await db.cardDao.getCards(page: 1, limit: 20);
      final cachedCard = cached.singleWhere((card) => card.factId == factId);
      expect(cachedCard.timestamp, createdAt);
    });

    test('a fact containing an fs:// reference is rejected', () async {
      final mintResult = await _runToolCall(
        tool: _tool('mint_record_fact_id'),
        arguments: const {},
        metadata: {'userId': userId},
      );
      final factId = _artifactId(mintResult)!;

      final result = await _runToolCall(
        tool: _tool('save_timeline_card'),
        arguments: {
          'fact_id': factId,
          'title': 'Leaky fact',
          'fact': 'Dinner photo ![image](fs://photo.jpg) was spicy.',
          'ui_configs': [
            {
              'template_id': 'article',
              'data': {'body': 'x'},
            },
          ],
        },
        metadata: {'userId': userId},
      );
      expect(result.isError, isTrue);
      expect(_text(result), contains('fs://'));
      expect(
        await FileSystemService.instance.readCardFile(userId, factId),
        isNull,
      );
    });
  });
}

Tool _tool(String name) {
  if (name == 'mint_record_fact_id') return mintRecordFactIdTool;
  return TimelineCardSkill(forceActivate: true)
      .tools!
      .singleWhere((t) => t.name == name);
}

void _expectClassicProcessingPlaceholder(CardData card) {
  expect(card.uiConfigs, hasLength(1));
  final config = card.uiConfigs.single;
  expect(config.templateId, 'classic_card');
  expect(config.data, containsPair('content', ''));
}

String? _artifactId(FunctionExecutionResult result) {
  final artifact = result.metadata?['artifact'];
  if (artifact is Map && artifact['id'] is String) {
    return artifact['id'] as String;
  }
  return null;
}

List<String>? _artifactIds(FunctionExecutionResult result) {
  final artifact = result.metadata?['artifact'];
  if (artifact is Map && artifact['ids'] is List) {
    return (artifact['ids'] as List).cast<String>();
  }
  return null;
}

Future<List<String>> _pendingMemoryFactIds(String userId) async {
  final systemPath = FileSystemService.instance.getSystemPath(userId);
  final file = File(p.join(systemPath, 'memory', 'memory_sync_pending.json'));
  if (!await file.exists()) return const [];
  final decoded = jsonDecode(await file.readAsString());
  return (decoded as List).cast<String>();
}

Future<FunctionExecutionResult> _runToolCall({
  required Tool tool,
  required Map<String, dynamic> arguments,
  Map<String, dynamic> metadata = const {},
}) async {
  final client = _SingleToolCallClient(
    toolName: tool.name,
    arguments: arguments,
  );
  final state = AgentState(
    sessionId: 'mint_test_${DateTime.now().microsecondsSinceEpoch}',
    metadata: Map<String, dynamic>.from(metadata),
  );
  final agent = StatefulAgent(
    name: 'mint_test_agent',
    client: client,
    modelConfig: ModelConfig(model: 'test-model'),
    state: state,
    tools: [tool],
    withGeneralPrinciples: false,
    maxTurns: 3,
  );

  await agent.run([UserMessage.text('run the tool')], useStream: false);

  final resultMessage =
      state.history.messages.whereType<FunctionExecutionResultMessage>().single;
  return resultMessage.results.single;
}

String _text(FunctionExecutionResult result) {
  return result.content
      .whereType<TextPart>()
      .map((part) => part.text)
      .join('\n');
}

class _SingleToolCallClient extends LLMClient {
  _SingleToolCallClient({required this.toolName, required this.arguments});

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

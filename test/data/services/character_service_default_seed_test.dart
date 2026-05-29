import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/character_selection_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserStorage.initL10n();
    tempRoot = await Directory.systemTemp.createTemp('memex_char_seed_');
    await FileSystemService.init(tempRoot.path);
  });

  tearDown(() async {
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('default characters store examples and interest filters separately',
      () async {
    final userId = 'seed_user_${DateTime.now().microsecondsSinceEpoch}';
    final characters = await CharacterService.instance.getAllCharacters(userId);
    final auntie = characters.firstWhere((c) => c.id == '3');

    expect(auntie.persona, contains('## Voice'));
    expect(auntie.persona, isNot(contains('## Example Dialogue')));
    expect(auntie.persona, isNot(contains('## PKM Interest Filter')));
    expect(auntie.mesExample, isNotNull);
    expect(auntie.mesExample, isNotEmpty);
    expect(auntie.interestFilter, isNotNull);
    expect(auntie.interestFilter, isNotEmpty);
    expect(auntie.firstMessage, isNotNull);
    expect(auntie.postHistoryInstructions, isNotNull);
  });

  test('seed migration refreshes legacy default auntie persona', () async {
    final userId = 'migration_user_${DateTime.now().microsecondsSinceEpoch}';
    final charsPath = CharacterService.instance.getCharactersPath(userId);
    await Directory(charsPath).create(recursive: true);
    await File(p.join(charsPath, '.characters_seed_version'))
        .writeAsString('1');
    await File(p.join(charsPath, '3.yaml')).writeAsString(
      '''
name: 热心长辈
tags:
  - 温暖
  - 关怀
persona: "1. 说话热乎，充满生活气息，喜欢用'哎呀'、'乖'等亲昵词。"
avatar: "18"
enabled: true
''',
    );

    final character = await CharacterService.instance.getCharacter(userId, '3');

    expect(character, isNotNull);
    expect(character!.persona, isNot(contains("喜欢用'哎呀'")));
    expect(character.persona, contains('## Voice'));
    expect(character.mesExample, isNotNull);
    expect(character.interestFilter, isNotNull);
    expect(character.postHistoryInstructions, isNotNull);
  });

  test('multi-character routing nudges multiple voices without forcing fill',
      () async {
    final userId = 'selection_user_${DateTime.now().microsecondsSinceEpoch}';
    final client = _CapturingTextClient('3');

    final selected = await CharacterSelectionService.selectMultipleCharacters(
      userId: userId,
      inputContent: '今天又没睡好，还被项目需求折腾得很烦。',
      factId: '2026/05/29.md#ts_1',
      client: client,
      modelConfig: ModelConfig(model: 'test-model'),
      maxCharacters: 5,
    );

    expect(selected, hasLength(1));
    expect(selected.first.id, '3');
    expect(client.lastPrompt, contains('prefer selecting 2-5'));
    expect(
      client.lastPrompt,
      contains('Do not pick only the single best fit by default'),
    );
  });
}

class _CapturingTextClient extends LLMClient {
  _CapturingTextClient(this.text);

  final String text;
  String lastPrompt = '';

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    lastPrompt = messages
        .whereType<UserMessage>()
        .expand((message) => message.contents)
        .whereType<TextPart>()
        .map((part) => part.text)
        .join('\n');
    return ModelMessage(model: modelConfig.model, textOutput: text);
  }

  @override
  Future<Stream<StreamingMessage>> stream(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }
}

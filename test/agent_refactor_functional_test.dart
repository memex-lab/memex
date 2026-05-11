import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:memex/agent/context/character_context_assembler.dart';
import 'package:memex/agent/context/user_knowledge_context_service.dart';
import 'package:memex/agent/memory/character_context_compressor.dart';
import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/tavern_character_import_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('Agent Refactor Functional Coverage', () {
    late Directory tempRoot;
    late String userId;
    late AppDatabase db;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      userId = 'refactor_eval_${DateTime.now().millisecondsSinceEpoch}';
      await UserStorage.saveUser(userId);
      tempRoot = await Directory.systemTemp.createTemp('memex_refactor_eval_');
      await FileSystemService.init(tempRoot.path);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      await db.searchDao.createFtsTables();
    });

    tearDown(() async {
      await db.close();
    });

    test('memory entries: add/replace/remove and context retrieval', () async {
      final character = await CharacterService.instance.createCharacter(
        userId: userId,
        characterData: {
          'name': 'MemoryCase',
          'persona': 'test',
          'enabled': true,
        },
      );
      final svc = CharacterMemoryService.instance;
      await svc.writeMemoryEntry(
        userId: userId,
        characterId: character.id,
        label: 'brevity',
        content: 'User prefers short, non-lecturing comfort.',
        salience: 0.9,
      );
      var text = await svc.readMemoryEntries(
        userId: userId,
        characterId: character.id,
        labels: ['brevity'],
      );
      expect(text, contains('non-lecturing comfort'));

      await svc.editMemoryEntry(
        userId: userId,
        characterId: character.id,
        label: 'brevity',
        oldString: 'User prefers short, non-lecturing comfort.',
        newString: 'User wants concise emotional support.',
      );
      text = await svc.readMemoryEntries(
        userId: userId,
        characterId: character.id,
        labels: ['brevity'],
      );
      expect(text, contains('concise emotional support'));

      await svc.removeMemoryEntry(
        userId: userId,
        characterId: character.id,
        label: 'brevity',
      );
      final entries = await svc.loadMemoryEntries(userId, character.id);
      expect(entries, isEmpty);
    });

    test('timeline append branches: empty content skipped, non-empty persisted',
        () async {
      final character = await CharacterService.instance.createCharacter(
        userId: userId,
        characterData: {
          'name': 'AppendCase',
          'persona': 'test',
          'enabled': true
        },
      );
      final svc = CharacterMemoryService.instance;

      await svc.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.chat,
        type: CharacterMemoryEventType.userChatMessage,
        content: '   ',
      );
      var lines = await svc.loadTimelineLines(userId, character.id);
      expect(lines, isEmpty);

      await svc.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.chat,
        type: CharacterMemoryEventType.userChatMessage,
        content: 'hello',
      );
      lines = await svc.loadTimelineLines(userId, character.id);
      expect(lines.length, 1);
      expect(lines.first, contains('"scene":"chat"'));
      expect(lines.first, contains('"event_type":"userChatMessage"'));
    });

    test('context compressor branches: compress + cooldown skip', () async {
      final character = await CharacterService.instance.createCharacter(
        userId: userId,
        characterData: {
          'name': 'CompressCase',
          'persona': 'test',
          'enabled': true
        },
      );
      final svc = CharacterMemoryService.instance;

      for (var i = 0; i < 60; i++) {
        final filler = List.filled(120, 'x').join();
        await svc.appendTimelineEvent(
          userId: userId,
          characterId: character.id,
          scene: CharacterMemoryScene.chat,
          type: i.isEven
              ? CharacterMemoryEventType.userChatMessage
              : CharacterMemoryEventType.characterChatMessage,
          content: 'turn-$i $filler',
        );
      }

      final before = await svc.loadTimelineLines(userId, character.id);
      expect(before.length, greaterThan(30));

      await CharacterContextCompressor.instance.compressIfNeeded(
        userId: userId,
        characterId: character.id,
        lastPromptTokens: 500,
        contextWindow: 600,
        softRatio: 0.20,
        hardRatio: 0.40,
        keepRecent: 10,
      );

      final after = await svc.loadTimelineLines(userId, character.id);
      final checkpoints = await svc.loadRecentCheckpointsAsText(
        userId,
        character.id,
        limit: 3,
      );
      final archivedSearch = await svc.searchTimelineEvents(
        userId: userId,
        characterId: character.id,
        query: 'turn-0',
      );
      expect(after.length, lessThan(before.length));
      expect(checkpoints, isNotEmpty);
      expect(archivedSearch, contains('turn-0'));
      expect(archivedSearch, contains('archived'));

      final index1 = await svc.loadIndexes(userId, character.id);
      index1['last_compress_failed_at'] = DateTime.now().toIso8601String();
      await svc.saveIndexes(userId, character.id, index1);

      final beforeSkip = await svc.loadTimelineLines(userId, character.id);
      await CharacterContextCompressor.instance.compressIfNeeded(
        userId: userId,
        characterId: character.id,
        lastPromptTokens: 50,
        contextWindow: 100000,
        softRatio: 0.0001,
        hardRatio: 0.90,
        keepRecent: 5,
        failureCooldown: const Duration(hours: 1),
      );
      final afterSkip = await svc.loadTimelineLines(userId, character.id);
      expect(afterSkip.length, beforeSkip.length);
    });

    test('context assembler: builds unified snapshot with clipped sections',
        () async {
      final character = await CharacterService.instance.createCharacter(
        userId: userId,
        characterData: {
          'name': 'AssemblerCase',
          'persona': 'test',
          'enabled': true
        },
      );
      final svc = CharacterMemoryService.instance;
      await svc.writeMemoryEntry(
        userId: userId,
        characterId: character.id,
        label: 'support_style',
        content: 'User prefers short support during work stress.',
        salience: 0.9,
      );
      await svc.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.comment,
        type: CharacterMemoryEventType.postObserved,
        content: 'timeline hello',
        threadId: 'fact-1',
        factId: 'fact-1',
      );

      final snapshot = await CharacterContextAssembler.build(
        userId: userId,
        character: character,
        sourceAgent: 'companion_agent',
        queryHint: 'stress work',
      );

      expect(snapshot.characterMemories, contains('short support'));
      expect(snapshot.recentTimeline, contains('timeline hello'));
      expect(snapshot.recentTimeline, contains('Post Comment Thread'));
      expect(snapshot.recentTimeline, contains('Post:'));
    });

    test('comment thread timeline stores post once with multiple comments',
        () async {
      final character = await CharacterService.instance.createCharacter(
        userId: userId,
        characterData: {
          'name': 'ThreadCase',
          'persona': 'test',
          'enabled': true
        },
      );
      final svc = CharacterMemoryService.instance;

      for (var i = 0; i < 2; i++) {
        await svc.appendTimelineEvent(
          userId: userId,
          characterId: character.id,
          scene: CharacterMemoryScene.comment,
          type: CharacterMemoryEventType.postObserved,
          threadId: 'fact-thread',
          factId: 'fact-thread',
          content: 'Original post body',
        );
      }
      await svc.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.comment,
        type: CharacterMemoryEventType.characterComment,
        threadId: 'fact-thread',
        factId: 'fact-thread',
        commentId: 'c1',
        content: 'First character comment',
      );
      await svc.appendTimelineEvent(
        userId: userId,
        characterId: character.id,
        scene: CharacterMemoryScene.comment,
        type: CharacterMemoryEventType.userCommentReply,
        threadId: 'fact-thread',
        factId: 'fact-thread',
        commentId: 'c2',
        replyToId: 'c1',
        content: 'User reply',
      );

      final lines = await svc.loadTimelineLines(userId, character.id);
      expect(
        lines.where((line) => line.contains('"event_type":"postObserved"')),
        hasLength(1),
      );

      final snapshot = await CharacterContextAssembler.build(
        userId: userId,
        character: character,
        sourceAgent: 'companion_agent',
      );
      expect(snapshot.recentTimeline, contains('Original post body'));
      expect(snapshot.recentTimeline, contains('First character comment'));
      expect(snapshot.recentTimeline, contains('User replied (reply to c1)'));

      final commentSnapshot = await CharacterContextAssembler.build(
        userId: userId,
        character: character,
        sourceAgent: 'comment_agent',
        excludeTimelineThreadId: 'fact-thread',
      );
      expect(commentSnapshot.recentTimeline,
          isNot(contains('Original post body')));
      expect(commentSnapshot.recentTimeline,
          isNot(contains('First character comment')));
      expect(commentSnapshot.recentTimeline, isNot(contains('User reply')));

      final searchResult = await svc.searchTimelineEvents(
        userId: userId,
        characterId: character.id,
        query: 'Original post',
        scene: CharacterMemoryScene.comment,
      );
      expect(searchResult, contains('Original post body'));
      expect(searchResult, contains('thread=fact-thread'));
    });

    test('knowledge context snippets expand around matched terms', () async {
      final fs = FileSystemService.instance;
      final pkmDir = Directory('${fs.getPkmPath(userId)}/Resources');
      await pkmDir.create(recursive: true);
      final file = File('${pkmDir.path}/project-note.md');
      await file.writeAsString(
        '${List.filled(900, 'A').join()}\n'
        'The important anchor is burnout recovery and pacing work.\n'
        '${List.filled(900, 'Z').join()}',
      );
      await db.searchDao.upsertPkmFts(
        filePath: 'Resources/project-note.md',
        fileName: 'project-note.md',
        content: await file.readAsString(),
      );

      final context =
          await UserKnowledgeContextService.instance.buildKnowledgeCards(
        userId: userId,
        queryHint: 'burnout',
        maxCards: 1,
        maxCharsPerCard: 220,
        contextRadius: 80,
      );

      expect(context, contains('burnout recovery'));
      expect(context, startsWith('### Resources/project-note.md'));
      expect(context, isNot(contains(List.filled(120, 'A').join())));
    });

    test('tavern import: json+png preview/import/conflict and invalid format',
        () async {
      const jsonPath =
          '/Users/ming/Downloads/main_error-6074f660fee4_spec_v2.json';
      const pngPath =
          '/Users/ming/Downloads/main_xin-yan-e02eb8dd63ad_spec_v2.png';

      expect(await File(jsonPath).exists(), isTrue,
          reason: 'Missing test fixture JSON card file');
      expect(await File(pngPath).exists(), isTrue,
          reason: 'Missing test fixture PNG card file');

      final svc = TavernCharacterImportService.instance;

      final previewJson = await svc.previewFromFile(filePath: jsonPath);
      final previewPng = await svc.previewFromFile(filePath: pngPath);
      expect((previewJson['name'] as String).trim().isNotEmpty, isTrue);
      expect((previewPng['name'] as String).trim().isNotEmpty, isTrue);

      final createdJson = await svc.importFromFile(
        userId: userId,
        filePath: jsonPath,
      );
      expect(createdJson.name.trim().isNotEmpty, isTrue);

      final conflict = await svc.detectConflicts(
        userId: userId,
        filePath: jsonPath,
      );
      expect(conflict['has_conflict'], isTrue);

      final createdPng = await svc.importFromFile(
        userId: userId,
        filePath: pngPath,
      );
      expect(createdPng.persona.trim().isNotEmpty, isTrue);

      final jsonWorldEntries = await CharacterMemoryService.instance
          .loadWorldEntries(userId, createdJson.id);
      final pngWorldEntries = await CharacterMemoryService.instance
          .loadWorldEntries(userId, createdPng.id);
      expect(jsonWorldEntries.length + pngWorldEntries.length, greaterThan(0));

      final txt = File('${tempRoot.path}/bad_card.txt');
      await txt.writeAsString('not a card');
      expect(
        () => svc.previewFromFile(filePath: txt.path),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

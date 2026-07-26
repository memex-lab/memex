import 'dart:convert';
import 'dart:io';

import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/character_workspace.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('CharacterWorkspaceService', () {
    late Directory tempRoot;
    late FileSystemService fileSystem;
    late CharacterWorkspaceService service;
    late CharacterModel character;

    setUp(() async {
      tempRoot = await Directory.systemTemp.createTemp('memex_char_workspace_');
      fileSystem = FileSystemService.detached(dataRoot: tempRoot.path);
      service = CharacterWorkspaceService(fileSystem: fileSystem);
      character = CharacterModel(
        id: 'yaoyao',
        name: '瑶瑶',
        tags: const ['安静', '细腻'],
        persona: '她会留意生活里小小的变化。',
        enabled: true,
      );
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
    });

    test('initializes a private workspace without modeled emotional state',
        () async {
      await service.ensureInitialized('wujia', character);

      final root = fileSystem.getCharacterWorkspacePath('wujia', 'yaoyao');
      expect(await Directory(p.join(root, 'PKM')).exists(), isTrue);
      expect(await Directory(p.join(root, 'Journal')).exists(), isTrue);
      expect(await Directory(p.join(root, 'World')).exists(), isTrue);

      final identity = await File(
        fileSystem.getCharacterIdentityPath('wujia', 'yaoyao'),
      ).readAsString();
      expect(identity, contains('# 瑶瑶'));
      expect(identity, contains(character.persona));

      final runtime = jsonDecode(
        await File(
          fileSystem.getCharacterRuntimePath('wujia', 'yaoyao'),
        ).readAsString(),
      ) as Map<String, dynamic>;
      expect(runtime.keys, isNot(contains('mood')));
      expect(runtime.keys, isNot(contains('relationship')));
      expect(runtime.keys, isNot(contains('intimacy')));
    });

    test('deduplicates delivery and removes raw content after digestion',
        () async {
      final first = await service.enqueueObservation(
        userId: 'wujia',
        character: character,
        sourceEventId: 'event-13',
        source: CharacterObservationSources.userRecord,
        factId: '2026/07/13.md#ts_1',
        content: '今天小朋友还是觉得每天都玩不够。',
        observedAt: DateTime.parse('2026-07-13T20:00:00+08:00'),
      );
      final duplicate = await service.enqueueObservation(
        userId: 'wujia',
        character: character,
        sourceEventId: 'event-13',
        source: CharacterObservationSources.userRecord,
        factId: '2026/07/13.md#ts_1',
        content: '这次重试不应该产生第二条。',
        observedAt: DateTime.parse('2026-07-13T20:00:01+08:00'),
      );

      expect(first, isNotNull);
      expect(duplicate?.id, first?.id);
      expect(await service.loadPendingObservations('wujia', 'yaoyao'),
          hasLength(1));

      await service.completeObservation(
        userId: 'wujia',
        characterId: 'yaoyao',
        observationId: first!.id,
      );
      await service.completeObservation(
        userId: 'wujia',
        characterId: 'yaoyao',
        observationId: first.id,
      );

      expect(await service.loadPendingObservations('wujia', 'yaoyao'), isEmpty);
      final inbox = await File(
        fileSystem.getCharacterInboxPath('wujia', 'yaoyao'),
      ).readAsString();
      expect(inbox, isEmpty);

      final indexLine = (await File(
        fileSystem.getCharacterInteractionIndexPath('wujia', 'yaoyao'),
      ).readAsLines())
          .single;
      final index = jsonDecode(indexLine) as Map<String, dynamic>;
      expect(index['source_event_id'], 'event-13');
      expect(index['fact_id'], '2026/07/13.md#ts_1');
      expect(index, isNot(contains('content')));

      final redelivery = await service.enqueueObservation(
        userId: 'wujia',
        character: character,
        sourceEventId: 'event-13',
        source: CharacterObservationSources.userRecord,
        content: '已经处理的事件不应重新进入 inbox。',
        observedAt: DateTime.now(),
      );
      expect(redelivery, isNull);
    });

    test('character-authored PKM and journal writes are scoped and idempotent',
        () async {
      final observation = await service.enqueueObservation(
        userId: 'wujia',
        character: character,
        sourceEventId: 'event-14',
        source: CharacterObservationSources.userRecord,
        content: '小朋友不想长大。',
        observedAt: DateTime.parse('2026-07-13T21:05:00+08:00'),
      );

      await service.writePkmNote(
        userId: 'wujia',
        characterId: 'yaoyao',
        relativePath: 'people/user-and-66.md',
        content: '# 她们\n\n姐姐会把成长讲得有点难。',
      );
      await service.writeJournalEntry(
        userId: 'wujia',
        characterId: 'yaoyao',
        observation: observation!,
        content: '听起来是很普通、也很可爱的一天。',
      );
      await service.writeJournalEntry(
        userId: 'wujia',
        characterId: 'yaoyao',
        observation: observation,
        content: '她们又聊到了长大，但语气是轻轻的。',
      );

      final pkm = await File(
        p.join(
          fileSystem.getCharacterPkmPath('wujia', 'yaoyao'),
          'people',
          'user-and-66.md',
        ),
      ).readAsString();
      expect(pkm, contains('姐姐会把成长讲得有点难'));

      final journalFiles = await Directory(
        fileSystem.getCharacterJournalPath('wujia', 'yaoyao'),
      ).list(recursive: true).where((entity) => entity is File).toList();
      expect(journalFiles, hasLength(1));
      final journal = await File(journalFiles.single.path).readAsString();
      expect(journal, contains('她们又聊到了长大'));
      expect(journal, isNot(contains('很普通、也很可爱')));
      expect('observation:'.allMatches(journal), hasLength(2));

      expect(
        service.writePkmNote(
          userId: 'wujia',
          characterId: 'yaoyao',
          relativePath: '../runtime.json',
          content: 'escape',
        ),
        throwsArgumentError,
      );
    });

    test('imports legacy configured memory without deleting the source',
        () async {
      final legacyMemory = File(
        fileSystem.getLegacyCharacterMemoryEntriesPath('wujia', 'yaoyao'),
      );
      final legacyWorld = File(
        fileSystem.getLegacyCharacterWorldEntriesPath('wujia', 'yaoyao'),
      );
      final legacyRelationship = File(
        fileSystem.getLegacyCharacterRelationshipPath('wujia', 'yaoyao'),
      );
      await legacyMemory.parent.create(recursive: true);
      await legacyMemory.writeAsString(
        '${jsonEncode({
              'label': '相处方式',
              'content': '她不喜欢被连续追问。',
              'salience': 0.8,
            })}\n',
      );
      await legacyWorld.writeAsString(
        '${jsonEncode({
              'uid': 'home',
              'keys': ['家里'],
              'content': '家里有一个正在长大的小朋友。',
              'enabled': true,
        })}\n',
      );
      await legacyRelationship.parent.create(recursive: true);
      await legacyRelationship.writeAsString(
        '她们已经习惯用很轻的玩笑谈长大。\n',
      );

      await service.ensureInitialized('wujia', character);
      await service.ensureInitialized('wujia', character);

      final memories =
          await service.loadUserProvidedMemoryEntries('wujia', 'yaoyao');
      final world =
          await service.loadUserProvidedWorldEntries('wujia', 'yaoyao');
      expect(memories, hasLength(1));
      expect(memories.single['content'], '她不喜欢被连续追问。');
      expect(world, hasLength(1));
      expect(world.single['uid'], 'home');
      expect(await legacyMemory.exists(), isTrue);
      expect(await legacyWorld.exists(), isTrue);
      expect(await legacyRelationship.exists(), isTrue);
      final importedRelationship = await File(
        fileSystem.getCharacterImportedRelationshipPath('wujia', 'yaoyao'),
      ).readAsString();
      expect(importedRelationship, contains('用很轻的玩笑谈长大'));
    });

    test('pending thoughts coalesce and can be resolved', () async {
      await service.ensureInitialized('wujia', character);
      final now = DateTime.parse('2026-07-14T10:00:00+08:00');
      final first = await service.rememberPendingThought(
        userId: 'wujia',
        characterId: 'yaoyao',
        sourceEventId: 'event-later',
        factId: 'fact-later',
        reason: '等她接完电话，再问问她。',
        wakeAt: now.add(const Duration(hours: 1)),
        now: now,
      );
      final revised = await service.rememberPendingThought(
        userId: 'wujia',
        characterId: 'yaoyao',
        sourceEventId: 'event-later',
        factId: 'fact-later',
        reason: '不用急，晚上想起时再看看。',
        wakeAt: now.add(const Duration(hours: 8)),
        now: now.add(const Duration(minutes: 5)),
      );

      expect(revised.id, first.id);
      expect(revised.createdAt, first.createdAt);
      expect(revised.reason, '不用急，晚上想起时再看看。');
      expect(
          await service.loadPendingThoughts('wujia', 'yaoyao'), hasLength(1));

      await service.resolvePendingThought('wujia', 'yaoyao', revised.id);
      expect(await service.loadPendingThoughts('wujia', 'yaoyao'), isEmpty);
    });
  });
}

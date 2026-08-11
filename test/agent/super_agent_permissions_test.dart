import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/super_agent/super_agent.dart';
import 'package:memex/domain/models/card_model.dart';

void main() {
  const workspace = '/ws/_u';
  const facts = '/ws/_u/Facts';
  const assets = '/ws/_u/Facts/assets';

  FilePermissionManager managerFor({required bool quickQuery}) {
    return FilePermissionManager(
      'test_user',
      SuperAgent.buildPermissionRules(
        workspacePath: workspace,
        factsPath: facts,
        factsAssetsPath: assets,
        quickQuery: quickQuery,
      ),
      withDefaultRules: false,
    );
  }

  group('SuperAgent file permissions (normal mode)', () {
    final manager = managerFor(quickQuery: false);

    test('non-asset files under Facts are read-only', () {
      expect(
        () => manager.checkPermission(
            '$facts/2026/06/10.md', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
      // Reading stays allowed.
      manager.checkPermission('$facts/2026/06/10.md', FileAccessType.read);
    });

    test('moving or removing a Facts directory is denied (write on source)',
        () {
      expect(
        () => manager.checkPermission('$facts/2026/06', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
    });

    test('permission denial message does not expose absolute paths', () {
      try {
        manager.checkPermission(
          '$facts/2026/06/10.md',
          FileAccessType.write,
        );
        fail('Expected permission denial');
      } on PermissionDeniedException catch (e) {
        final message = e.toString();
        expect(message, contains('Access denied'));
        expect(message, isNot(contains('/ws')));
        expect(message, isNot(contains(workspace)));
        expect(message, isNot(contains(facts)));
      }
    });

    test('media files under assets stay writable', () {
      manager.checkPermission('$assets/photo.jpg', FileAccessType.write);
      manager.checkPermission('$assets/voice.m4a', FileAccessType.write);
    });

    test('the rest of the workspace stays writable', () {
      manager.checkPermission(
          '$workspace/Cards/2026_06_10.yaml', FileAccessType.write);
      manager.checkPermission('$workspace/PKM/note.md', FileAccessType.write);
    });
  });

  group('SuperAgent file permissions (quick query)', () {
    final manager = managerFor(quickQuery: true);

    test('everything is read-only including assets', () {
      manager.checkPermission('$facts/2026/06/10.md', FileAccessType.read);
      expect(
        () =>
            manager.checkPermission('$assets/photo.jpg', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
      expect(
        () => manager.checkPermission(
            '$workspace/Cards/c.yaml', FileAccessType.write),
        throwsA(isA<PermissionDeniedException>()),
      );
    });
  });

  group('SuperAgent quick query tools', () {
    test('does not expose event log search or current time tools', () {
      expect(
        SuperAgent.isQuickQueryToolAllowed('search_workspace_event_logs'),
        isFalse,
      );
      expect(
        SuperAgent.isQuickQueryToolAllowed('getCurrentTime'),
        isFalse,
      );
    });

    test('allows image viewing as a read-only tool', () {
      expect(SuperAgent.isQuickQueryToolAllowed('view_image'), isTrue);
    });

    test('allows generic LS for read-only filesystem access', () {
      expect(SuperAgent.isQuickQueryToolAllowed('LS'), isTrue);
    });

    test('excludes the mutating calendar and reminder skill', () {
      expect(
        SuperAgent.isQuickQuerySkillAllowed(
          'manage_calendar_and_reminders',
        ),
        isFalse,
      );
    });
  });

  group('SuperAgent run limits', () {
    test('root agent allows long import and organization runs', () {
      expect(SuperAgent.rootMaxTurns, greaterThan(20));
      expect(SuperAgent.rootMaxTurns, 80);
    });
  });

  group('SuperAgent legacy active skills', () {
    test('drops stale active skill names before agent tools are composed', () {
      final state = AgentState(
        sessionId: 'legacy_active_skill_session',
        metadata: {'userId': 'legacy_skill_user'},
        activeSkills: [
          'create_dynamic_timeline_card',
          'manage_timeline_card',
        ],
      );

      final pruned = SuperAgent.pruneUnavailableActiveSkills(
        state,
        {'manage_timeline_card', 'dynamic_timeline_ui'},
      );

      expect(pruned, isTrue);
      expect(state.activeSkills, ['manage_timeline_card']);
    });
  });

  group('SuperAgent transient pre-minted record reminder', () {
    test('matches only the empty processing placeholder', () {
      const factId = '2026/06/26.md#ts_1';
      const placeholder = CardData(
        factId: factId,
        timestamp: 1782441600,
        status: 'processing',
        tags: [],
        uiConfigs: [
          UiConfig(templateId: 'classic_card', data: {'content': ''}),
        ],
      );

      expect(
        isUnusedPreallocatedRecordPlaceholder(placeholder, factId),
        isTrue,
      );
      expect(
        isUnusedPreallocatedRecordPlaceholder(
          placeholder.copyWith(status: 'completed'),
          factId,
        ),
        isFalse,
      );
      expect(
        isUnusedPreallocatedRecordPlaceholder(
          placeholder.copyWith(fact: 'recorded content'),
          factId,
        ),
        isFalse,
      );
    });

    test('annotates the matching user message only in model requests', () {
      final userMessage = UserMessage([
        TextPart(
            '<system-reminder>\nCurrent Local Time: now\n</system-reminder>'),
        TextPart('current user message'),
      ]);
      final messages = <LLMMessage>[
        userMessage,
      ];

      final requestMessages = annotatePreMintedRecordFactIdReminder(
        messages,
        '2026/06/26.md#ts_2',
        userMessageTimestamp: userMessage.timestamp,
      );
      final text = requestMessages
          .whereType<UserMessage>()
          .expand((message) => message.contents)
          .whereType<TextPart>()
          .map((part) => part.text)
          .join('\n');

      expect(text, contains('2026/06/26.md#ts_2'));
      expect(text, contains('current user message'));
      expect(requestMessages, hasLength(messages.length));
      expect(messages.single, isNot(same(requestMessages.first)));
    });

    test('does not append when no pre-minted fact_id exists', () {
      final messages = <LLMMessage>[
        UserMessage([TextPart('current user message')]),
      ];

      final requestMessages = annotatePreMintedRecordFactIdReminder(
        messages,
        null,
        userMessageTimestamp: null,
      );

      expect(requestMessages, same(messages));
    });

    test('reuses persisted same-turn fact_id after task restart', () async {
      final state = AgentState(
        sessionId: 'restart_session',
        metadata: {
          SuperAgentPreMintedRecordHook.turnIdMetadataKey: 'turn-1',
          SuperAgentPreMintedRecordHook.factIdMetadataKey: '2026/06/26.md#ts_1',
        },
      );
      final hook = SuperAgentPreMintedRecordHook(
        userId: 'test_user',
        turnId: 'turn-1',
      );

      await hook.preallocate(state);

      expect(hook.factIdForTesting, '2026/06/26.md#ts_1');
      expect(
        state.metadata[SuperAgentPreMintedRecordHook.factIdMetadataKey],
        '2026/06/26.md#ts_1',
      );
    });

    test('keeps same-turn fact_id when a running agent will retry', () async {
      final state = AgentState(
        sessionId: 'retry_session',
        isRunning: true,
        metadata: {
          SuperAgentPreMintedRecordHook.turnIdMetadataKey: 'turn-1',
          SuperAgentPreMintedRecordHook.factIdMetadataKey: '2026/06/26.md#ts_1',
          SuperAgentPreMintedRecordHook.userMessageTimestampMetadataKey: 123,
        },
      );
      final agent = StatefulAgent(
        name: 'retry_agent',
        client: _NoopClient(),
        modelConfig: ModelConfig(model: 'test'),
        state: state,
      );
      final hook = SuperAgentPreMintedRecordHook(
        userId: 'test_user',
        turnId: 'turn-1',
      );

      await hook.afterRun(
        AfterRunHookContext(
          agent,
          input: const [],
          modelMessages: const [],
          error: AgentException(AgentExceptionCode.unknown, 'retryable'),
        ),
      );

      expect(
        state.metadata[SuperAgentPreMintedRecordHook.factIdMetadataKey],
        '2026/06/26.md#ts_1',
      );
      expect(
        state.metadata[SuperAgentPreMintedRecordHook.turnIdMetadataKey],
        'turn-1',
      );
      expect(
        state.metadata[
            SuperAgentPreMintedRecordHook.userMessageTimestampMetadataKey],
        123,
      );
    });

    test('annotates the matching history user message after the id is used',
        () {
      final userMessage = UserMessage([
        TextPart(
            '<system-reminder>\nCurrent Local Time: now\n</system-reminder>'),
        TextPart('record this'),
      ]);
      final messages = <LLMMessage>[
        userMessage,
        ModelMessage(
          model: 'test',
          stopReason: 'stop',
          textOutput: 'done',
        ),
      ];

      final annotated = annotateUserMessageSystemReminder(
        messages,
        userMessageTimestamp: userMessage.timestamp,
        reminder:
            'Newly minted record fact_id was used this turn: 2026/06/26.md#ts_1.',
      );

      expect(annotated, hasLength(2));
      expect(messages.singleWhere((m) => m is UserMessage), same(userMessage));
      final user = annotated.first as UserMessage;
      final reminder = (user.contents.first as TextPart).text;
      expect(
        reminder,
        contains(
            'Newly minted record fact_id was used this turn: 2026/06/26.md#ts_1.'),
      );
      expect(reminder, contains('</system-reminder>'));
    });
  });
}

class _NoopClient extends LLMClient {
  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}

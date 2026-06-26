import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/skills/dynamic_timeline_ui/dynamic_timeline_ui_skill.dart';
import 'package:memex/agent/skills/manage_pkm/pkm_skill.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/agent/super_agent/subagent/delegate_progress.dart';
import 'package:memex/agent/super_agent/subagent/delegate_subagent_tool.dart';
import 'package:memex/agent/super_agent/subagent/super_agent_child.dart';
import 'package:memex/data/services/api_exception.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 2: the generic SuperAgent child-worker runtime. These tests cover the
/// deterministic wiring (tool profile → base tools) and the run → structured
/// result extraction path, using a scripted LLM client (no live model).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SuperAgent child runtime', () {
    late AppDatabase db;
    late Directory tempRoot;
    late String userId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      AppDatabase.setTestInstance(db);
      SharedPreferences.setMockInitialValues({});
      await UserStorage.initL10n();
      userId = 'child_${DateTime.now().microsecondsSinceEpoch}';
      await UserStorage.saveUser(userId);
      tempRoot = await Directory.systemTemp.createTemp('memex_child_');
      await FileSystemService.init(tempRoot.path);
    });

    tearDown(() async {
      if (await tempRoot.exists()) {
        await tempRoot.delete(recursive: true);
      }
      await db.close();
    });

    SuperAgentChildConfig cfg(ChildToolProfile profile) =>
        SuperAgentChildConfig(
          childName: 'test_child',
          taskBrief: 'do the thing',
          skills: const [],
          toolProfile: profile,
        );

    test('default child timeout allows long specialist work', () {
      expect(cfg(ChildToolProfile.read).timeout, const Duration(minutes: 20));
    });

    test('profile none exposes no base tools', () {
      final agent = createSuperAgentChild(
        config: cfg(ChildToolProfile.none),
        client: _ScriptedClient(texts: const ['done']),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );
      expect(agent.tools ?? const [], isEmpty);
    });

    test('profile read exposes read-only base tools but no write tools', () {
      final agent = createSuperAgentChild(
        config: cfg(ChildToolProfile.read),
        client: _ScriptedClient(texts: const ['done']),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );
      final names = (agent.tools ?? const []).map((t) => t.name).toSet();
      expect(names, containsAll(<String>['LS', 'Glob', 'Grep', 'Read']));
      expect(names, isNot(contains('Write')));
      expect(names, isNot(contains('Edit')));
    });

    test('profile full adds write tools on top of read tools', () {
      final agent = createSuperAgentChild(
        config: cfg(ChildToolProfile.full),
        client: _ScriptedClient(texts: const ['done']),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );
      final names = (agent.tools ?? const []).map((t) => t.name).toSet();
      expect(names, containsAll(<String>['Read', 'Write', 'Edit']));
    });

    test('restricted read roots keep PKM workers out of Cards', () async {
      final workspace = FileSystemService.instance.getWorkspacePath(userId);
      await Directory('$workspace/PKM').create(recursive: true);
      await Directory('$workspace/Cards').create(recursive: true);
      await File('$workspace/PKM/note.md').writeAsString('pkm note');
      await File('$workspace/Cards/card.yaml').writeAsString('card: secret');

      final agent = createSuperAgentChild(
        config: const SuperAgentChildConfig(
          childName: 'manage_pkm_child',
          taskBrief: 'organize',
          skills: [],
          toolProfile: ChildToolProfile.full,
          readRootPaths: ['/PKM'],
          writeRootPaths: ['/PKM'],
        ),
        client: _ScriptedClient(texts: const ['done']),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );

      final readTool =
          (agent.tools ?? const []).singleWhere((t) => t.name == 'Read');
      final pkmResult = await _callTool<String>(readTool, {
        'file_path': '/PKM/note.md',
      });
      expect(pkmResult, contains('pkm note'));

      final writeTool =
          (agent.tools ?? const []).singleWhere((t) => t.name == 'Write');
      await _callTool<dynamic>(writeTool, {
        'file_path': '/PKM/new.md',
        'content': 'new pkm note',
      });
      expect(
          await File('$workspace/PKM/new.md').readAsString(), 'new pkm note');

      final lsTool =
          (agent.tools ?? const []).singleWhere((t) => t.name == 'LS');
      final rootList = await _callTool<String>(lsTool, {'path': '/'});
      expect(rootList, contains('PKM'));
      expect(rootList, isNot(contains('Cards')));
      expect(rootList, isNot(contains('card.yaml')));

      final pkmList = await _callTool<String>(lsTool, {'path': '/PKM'});
      expect(pkmList, contains('note.md'));
      expect(pkmList, contains('new.md'));

      expect(
        () => _callTool<String>(lsTool, {'path': '/Cards'}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.toString(),
            'message',
            equals('Directory /Cards does not exist'),
          ),
        ),
      );

      final globTool =
          (agent.tools ?? const []).singleWhere((t) => t.name == 'Glob');
      final globResult = await _callTool<String>(globTool, {
        'pattern': '**/*',
      });
      expect(globResult, contains('PKM'));
      expect(globResult, contains('note.md'));
      expect(globResult, isNot(contains('Cards')));
      expect(globResult, isNot(contains('card.yaml')));

      expect(
        () => _callTool<String>(globTool, {
          'pattern': '**/*',
          'path': '/Cards',
        }),
        throwsA(
          isA<ApiException>().having(
            (e) => e.toString(),
            'message',
            equals('Directory /Cards does not exist'),
          ),
        ),
      );

      final grepTool =
          (agent.tools ?? const []).singleWhere((t) => t.name == 'Grep');
      final grepResult = await _callTool<String>(grepTool, {
        'pattern': 'pkm|secret',
        'output_mode': 'content',
      });
      expect(grepResult, contains('pkm note'));
      expect(grepResult, isNot(contains('secret')));
      expect(grepResult, isNot(contains('Cards')));

      expect(
        () => _callTool<String>(grepTool, {
          'pattern': 'secret',
          'path': '/Cards',
          'output_mode': 'content',
        }),
        throwsA(
          isA<ApiException>().having(
            (e) => e.toString(),
            'message',
            equals('path /Cards does not exist'),
          ),
        ),
      );

      expect(
        () => _callTool<String>(readTool, {
          'file_path': '/Cards/card.yaml',
        }),
        throwsA(
          isA<ApiException>().having(
            (e) => e.toString(),
            'message',
            equals('File /Cards/card.yaml does not exist'),
          ),
        ),
      );
    });

    test('dynamic_timeline_ui gets scoped file tools injected; base stays bare',
        () {
      // Card-worker shape: no base file tools (profile none), but the
      // dynamic_timeline_ui skill should receive scoped Read/Write/Edit so
      // template editing only appears when that skill is active.
      final agent = createSuperAgentChild(
        config: SuperAgentChildConfig(
          childName: 'card_child',
          taskBrief: 'capture',
          skills: [DynamicTimelineUiSkill()],
          toolProfile: ChildToolProfile.none,
          writeRootPaths: const ['/_UserSettings/Templates'],
        ),
        client: _ScriptedClient(texts: const ['done']),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );

      // Base tools (visible without activating any skill) stay empty.
      expect(agent.tools ?? const [], isEmpty);

      // The dynamic-UI skill carries the injected scoped file tools, so they
      // appear only once the worker activates that skill.
      final uiSkill = agent.skills!.whereType<DynamicTimelineUiSkill>().single;
      final skillToolNames =
          (uiSkill.tools ?? const []).map((t) => t.name).toSet();
      expect(skillToolNames, containsAll(<String>['Read', 'Write', 'Edit']));
      // Its own design tools are still present too.
      expect(skillToolNames, contains('save_timeline_template'));
    });

    test('reports child tool progress through delegate progress sink',
        () async {
      const progress = DelegateProgress(
        delegateRunId: 'delegate_1',
        childName: 'read_child',
        taskBrief: 'list workspace',
      );
      final sink = _RecordingDelegateProgressSink();
      await Directory(FileSystemService.instance.getWorkspacePath(userId))
          .create(recursive: true);

      final result = await runSuperAgentChild(
        config: const SuperAgentChildConfig(
          childName: 'read_child',
          taskBrief: 'list workspace',
          skills: [],
          toolProfile: ChildToolProfile.read,
        ),
        client: _SingleToolCallClient(
          toolName: 'LS',
          arguments: {'path': '/'},
          finalText: 'Listed the workspace.',
        ),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
        progress: progress,
        progressSink: sink,
      );

      expect(result.status, SuperAgentChildStatus.completed);
      expect(result.childSessionId, startsWith('read_child_'));
      expect(result.toJson()['child_session_id'], result.childSessionId);
      expect(sink.events, contains('start:delegate_1:LS'));
      expect(sink.events, contains('finish:delegate_1:LS:false'));
    });

    test('pkm overview formats a model-oriented structure tree', () async {
      final workspace = FileSystemService.instance.getWorkspacePath(userId);
      await Directory('$workspace/PKM/Projects/App').create(recursive: true);
      await File('$workspace/PKM/Projects/App/note.md').writeAsString('note');
      await Directory('$workspace/Cards').create(recursive: true);
      await File('$workspace/Cards/card.yaml').writeAsString('secret');

      final overview = await buildPkmOverviewForUser(userId);

      expect(overview, contains('PKM structure tree'));
      expect(overview, contains('Root: /PKM'));
      expect(overview, contains('Projects/'));
      expect(overview, contains('App/'));
      expect(overview, contains('note.md'));
      expect(overview, contains('Summary:'));
      expect(overview, contains('complete PKM structure'));
      expect(overview, contains('no additional LS or Glob'));
      expect(overview, isNot(contains('Cards')));
      expect(overview, isNot(contains('card.yaml')));
    });

    test('pkm overview reports an empty PKM when the root is missing',
        () async {
      final overview = await buildPkmOverview(
        pkmRootPath: '${tempRoot.path}/missing/PKM',
      );

      expect(
        overview,
        'P.A.R.A. knowledge base has not been created yet, currently empty.',
      );
    });

    test('pkm overview marks incomplete trees when truncated', () async {
      final workspace = FileSystemService.instance.getWorkspacePath(userId);
      await Directory('$workspace/PKM/Projects/App').create(recursive: true);
      await File('$workspace/PKM/Projects/App/a.md').writeAsString('a');
      await File('$workspace/PKM/Projects/App/b.md').writeAsString('b');

      final overview = await buildPkmOverviewForUser(userId, maxEntries: 1);

      expect(overview, contains('PKM structure tree'));
      expect(overview, contains('... truncated after 1 entries'));
      expect(
        overview,
        contains('Note: overview truncated; use file tools to inspect deeper.'),
      );
      expect(overview, isNot(contains('complete PKM structure')));
    });

    test('delegate injects PKM overview reminder into pkm child', () async {
      final workspace = FileSystemService.instance.getWorkspacePath(userId);
      await Directory('$workspace/PKM/Projects/App').create(recursive: true);
      await File('$workspace/PKM/Projects/App/note.md').writeAsString('note');
      await Directory('$workspace/Cards').create(recursive: true);
      await File('$workspace/Cards/card.yaml').writeAsString('secret');

      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_pkm_overview_test',
        metadata: {'userId': userId},
      );
      final client = _SingleToolCallClient(
        toolName: tool.name,
        arguments: {
          'task_brief': 'File this record in PKM.',
          'agent_type': 'pkm',
        },
        finalText: 'Filed the record in PKM.',
      );
      final agent = StatefulAgent(
        name: 'delegate_pkm_overview_agent',
        client: client,
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      expect(client.generateInputs.length, greaterThanOrEqualTo(2));
      final childPrompt = _messagesText(client.generateInputs[1]);
      expect(childPrompt, contains('Current PKM structure tree'));
      expect(childPrompt, contains('Projects/'));
      expect(childPrompt, contains('App/'));
      expect(childPrompt, contains('note.md'));
      expect(childPrompt, isNot(contains('Cards')));
      expect(childPrompt, isNot(contains('card.yaml')));
    });

    test('delegate injects latest card metadata reminder into card child',
        () async {
      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_card_metadata_test',
        metadata: {'userId': userId},
      );
      final client = _SingleToolCallClient(
        toolName: tool.name,
        arguments: {
          'task_brief': 'Create a timeline card for this record.',
          'agent_type': 'timeline_card',
        },
        finalText: 'Created the timeline card.',
      );
      final agent = StatefulAgent(
        name: 'delegate_card_metadata_agent',
        client: client,
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      expect(client.generateInputs.length, greaterThanOrEqualTo(2));
      final childPrompt = _messagesText(client.generateInputs[1]);
      expect(
        childPrompt,
        contains('Latest get_card_metadata result.'),
      );
      expect(
        childPrompt,
        contains(
            'Use this metadata instead of calling get_card_metadata again'),
      );
      expect(childPrompt, contains('# Available Templates'));
      expect(childPrompt, contains('## template_id: article'));
      expect(childPrompt, contains('# Existing Tags'));
    });

    test('run infers no_op from the final plain-text message', () async {
      final result = await runSuperAgentChild(
        config: cfg(ChildToolProfile.read),
        client: _ScriptedClient(texts: const [
          'no_op: no dated content',
        ]),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );
      expect(result.status, SuperAgentChildStatus.noOp);
      expect(result.summary, 'no_op: no dated content');
    });

    test('terminal tool finish_summary completes child without final LLM call',
        () async {
      const factId = '2026/06/26.md#ts_1';
      await FileSystemService.instance.safeWriteCardFile(
        userId,
        factId,
        CardData(
          factId: factId,
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          status: 'completed',
          tags: const [],
          uiConfigs: const [
            UiConfig(templateId: 'classic_card', data: {'content': 'before'}),
          ],
          fact: 'record content',
        ),
      );
      final client = _SingleToolCallClient(
        toolName: 'update_timeline_card_insight',
        arguments: {
          'fact_id': factId,
          'insight_text': 'A useful insight.',
          'related_fact_ids': [],
          'finish_summary':
              'Updated the card insight and found no related facts.',
        },
        finalText: 'should not be called',
      );

      final result = await runSuperAgentChild(
        config: SuperAgentChildConfig(
          childName: 'pkm_child',
          taskBrief: 'Update insight.',
          skills: [
            PkmSkill(
              forceActivate: true,
              workingDirectory: '/PKM',
              enableFinishSummary: true,
            )
          ],
          toolProfile: ChildToolProfile.none,
        ),
        client: client,
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );

      expect(client.generateInputs, hasLength(1));
      expect(result.status, SuperAgentChildStatus.completed);
      expect(
        result.summary,
        'Updated the card insight and found no related facts.',
      );
      expect(result.structured['fact_id'], factId);
      expect(result.structured['pkm_changed'], isTrue);
    });

    test('run reports failed when the child errors out', () async {
      final result = await runSuperAgentChild(
        config: cfg(ChildToolProfile.read),
        client: _ThrowingClient(),
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );
      expect(result.status, SuperAgentChildStatus.failed);
      expect(result.error, isNotNull);
    });

    test('timed out child cancels the model request and saves state', () async {
      final client = _CancellableClient();

      final result = await runSuperAgentChild(
        config: const SuperAgentChildConfig(
          childName: 'slow_child',
          taskBrief: 'run until timeout',
          skills: [],
          toolProfile: ChildToolProfile.full,
          readRootPaths: ['/PKM'],
          writeRootPaths: ['/PKM'],
          timeout: Duration(milliseconds: 20),
          contextPacket: {'parent_session_id': 'parent_session'},
        ),
        client: client,
        modelConfig: ModelConfig(model: 'test'),
        userId: userId,
      );

      expect(result.status, SuperAgentChildStatus.failed);
      expect(result.error, 'child timed out after 20ms');
      expect(result.childSessionId, startsWith('slow_child_'));
      await client.cancelObserved.future
          .timeout(const Duration(milliseconds: 200));
      expect(client.cancelToken?.isCancelled, isTrue);
      await client.returned.future.timeout(const Duration(milliseconds: 200));

      final stateDir = Directory(
        await FileSystemService.instance.getAgentStateDirectory(userId),
      );
      final stateFiles = await stateDir
          .list()
          .where((entity) =>
              entity is File &&
              entity.uri.pathSegments.last.startsWith('slow_child_') &&
              entity.uri.pathSegments.last.endsWith('.json'))
          .cast<File>()
          .toList();
      expect(stateFiles, hasLength(1));
      final fileName = stateFiles.single.uri.pathSegments.last;
      expect(
        fileName,
        matches(RegExp(
          r'^slow_child_[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.json$',
        )),
      );

      final stateJson = await _readJsonWhenStable(stateFiles.single);
      final metadata = stateJson['metadata'] as Map;
      expect(metadata['sub_agent_mode'], isTrue);
      expect(metadata['child_name'], 'slow_child');
      expect(metadata['parent_session_id'], 'parent_session');
      expect(metadata['child_cancelled'], isTrue);
      expect(metadata['child_cancel_reason'], 'child timed out after 20ms');
      expect(metadata['child_read_roots'], ['/PKM']);
      expect(metadata['child_write_roots'], ['/PKM']);
    });

    test('delegate rejects task briefs with nonexistent asset refs', () async {
      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_asset_test',
        metadata: {'userId': userId},
      );
      final agent = StatefulAgent(
        name: 'delegate_asset_test_agent',
        client: _SingleToolCallClient(
          toolName: tool.name,
          arguments: {
            'task_brief': 'Capture this image: ![image](fs://missing.jpg)',
            'agent_type': 'timeline_card',
          },
        ),
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      final resultMessage = state.history.messages
          .whereType<FunctionExecutionResultMessage>()
          .single;
      final result = resultMessage.results.single;
      expect(result.isError, isTrue);
      expect(
        _text(result),
        contains('fs://missing.jpg'),
      );
    });

    test('delegate accepts existing bare asset refs wrapped in backticks',
        () async {
      final assetsDir = Directory(
        FileSystemService.instance.getAssetsPath(userId),
      );
      await assetsDir.create(recursive: true);
      await File('${assetsDir.path}/photo.jpg').writeAsBytes(<int>[1, 2, 3]);

      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_backtick_asset_test',
        metadata: {'userId': userId},
      );
      final agent = StatefulAgent(
        name: 'delegate_backtick_asset_agent',
        client: _SingleToolCallClient(
          toolName: tool.name,
          arguments: {
            'task_brief': 'Capture this image attachment `fs://photo.jpg`）。',
            'agent_type': 'research',
          },
          finalText: 'Asset reference accepted.',
        ),
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      final result = state.history.messages
          .whereType<FunctionExecutionResultMessage>()
          .single
          .results
          .single;
      expect(result.isError, isFalse);
      expect(_text(result), contains('Asset reference accepted.'));
    });

    test('delegate rejects unknown agent types', () async {
      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_unknown_agent_type_test',
        metadata: {'userId': userId},
      );
      final agent = StatefulAgent(
        name: 'delegate_unknown_agent_type_agent',
        client: _SingleToolCallClient(
          toolName: tool.name,
          arguments: {
            'task_brief': 'Look around the knowledge base.',
            'agent_type': 'custom_combo',
          },
        ),
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      final result = state.history.messages
          .whereType<FunctionExecutionResultMessage>()
          .single
          .results
          .single;
      expect(result.isError, isTrue);
      expect(_text(result), contains('Unknown agent_type'));
    });

    test('delegate allows the fixed research agent type', () async {
      await Directory(FileSystemService.instance.getWorkspacePath(userId))
          .create(recursive: true);
      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_research_test',
        metadata: {'userId': userId},
      );
      final agent = StatefulAgent(
        name: 'delegate_research_agent',
        client: _SingleToolCallClient(
          toolName: tool.name,
          arguments: {
            'task_brief': 'Summarize what is in the knowledge base.',
            'agent_type': 'research',
          },
          finalText: 'Nothing yet.',
        ),
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      final result = state.history.messages
          .whereType<FunctionExecutionResultMessage>()
          .single
          .results
          .single;
      // The validation gate let the fixed research child through: the result is
      // a normal child report, not a rejection.
      expect(result.isError, isFalse);
      expect(_text(result), contains('agent_type="research"'));
      expect(_text(result), contains('Nothing yet.'));
      expect(_text(result), isNot(contains('child=')));
    });

    test('delegate schema exposes agent_type instead of profile and skills',
        () {
      final tool = buildDelegateToSubagentTool();
      final properties = tool.parameters['properties'] as Map;

      expect(properties.keys, contains('agent_type'));
      expect(properties.keys, isNot(contains('profile')));
      expect(properties.keys, isNot(contains('skills')));
      expect(tool.parameters['required'], ['task_brief', 'agent_type']);

      final agentType = properties['agent_type'] as Map;
      expect(
        agentType['enum'],
        containsAll([
          'timeline_card',
          'pkm',
          'knowledge_insight',
          'schedule',
          'timeline_diagnostics',
          'research',
        ]),
      );
    });

    test('finish_summary is only exposed by child-specialized skills', () {
      Tool saveTool(Skill skill) =>
          skill.tools!.singleWhere((tool) => tool.name == 'save_timeline_card');
      Tool updateInsightTool(Skill skill) => skill.tools!
          .singleWhere((tool) => tool.name == 'update_timeline_card_insight');

      final rootSaveProperties =
          saveTool(TimelineCardSkill()).parameters['properties'] as Map;
      final childSaveProperties = saveTool(TimelineCardSkill(
        enableFinishSummary: true,
      )).parameters['properties'] as Map;
      final rootInsightProperties =
          updateInsightTool(PkmSkill()).parameters['properties'] as Map;
      final childInsightProperties = updateInsightTool(PkmSkill(
        enableFinishSummary: true,
      )).parameters['properties'] as Map;

      expect(rootSaveProperties, isNot(contains('finish_summary')));
      expect(rootInsightProperties, isNot(contains('finish_summary')));
      expect(childSaveProperties, contains('finish_summary'));
      expect(childInsightProperties, contains('finish_summary'));
      expect(
        (childSaveProperties['finish_summary'] as Map)['description'],
        isNot(contains('parent')),
      );
      expect(
        (childInsightProperties['finish_summary'] as Map)['description'],
        isNot(contains('child')),
      );
    });

    test('delegate accepts a fixed agent_type call without profile or skills',
        () async {
      await Directory(FileSystemService.instance.getWorkspacePath(userId))
          .create(recursive: true);
      final tool = buildDelegateToSubagentTool();
      final state = AgentState(
        sessionId: 'delegate_omit_skills_test',
        metadata: {'userId': userId},
      );
      final agent = StatefulAgent(
        name: 'delegate_omit_skills_agent',
        client: _SingleToolCallClient(
          toolName: tool.name,
          arguments: {
            'task_brief': 'Summarize what is in the knowledge base.',
            'agent_type': 'research',
          },
          finalText: 'Nothing yet.',
        ),
        modelConfig: ModelConfig(model: 'test'),
        state: state,
        tools: [tool],
        withGeneralPrinciples: false,
        maxTurns: 3,
      );

      await agent.run([UserMessage.text('delegate')], useStream: false);

      final result = state.history.messages
          .whereType<FunctionExecutionResultMessage>()
          .single
          .results
          .single;
      expect(result.isError, isFalse);
      expect(_text(result), contains('agent_type="research"'));
      expect(_text(result), contains('Nothing yet.'));
      expect(_text(result), isNot(contains('child=')));
    });
  });
}

Future<T> _callTool<T>(Tool tool, Map<String, dynamic> args) async {
  final result = _invokeTool(tool, args);
  if (result is Future) {
    return await result as T;
  }
  return result as T;
}

dynamic _invokeTool(Tool tool, Map<String, dynamic> args) {
  if (tool.parameterMode == ToolParameterMode.object) {
    return tool.executable!(args);
  }

  final positionalArgs = <dynamic>[];
  final namedArgs = <Symbol, dynamic>{};
  final properties = tool.parameters['properties'];
  if (properties is! Map) {
    return Function.apply(tool.executable!, positionalArgs, namedArgs);
  }

  for (final entry in properties.entries) {
    final key = entry.key.toString();
    if (args.containsKey(key)) {
      final value = _castToolValue(args[key], entry.value);
      if (tool.namedParameters.contains(key)) {
        namedArgs[Symbol(key)] = value;
      } else {
        positionalArgs.add(value);
      }
    } else if (!tool.namedParameters.contains(key)) {
      positionalArgs.add(null);
    }
  }

  return Function.apply(tool.executable!, positionalArgs, namedArgs);
}

dynamic _castToolValue(dynamic value, dynamic schema) {
  if (schema is! Map) return value;
  final type = schema['type'];
  if (type == 'array' && value is List) {
    final itemType = schema['items'] is Map ? schema['items']['type'] : null;
    if (itemType == 'string') return value.cast<String>();
    if (itemType == 'integer') {
      return value.map((e) => (e as num).toInt()).toList();
    }
    if (itemType == 'number') {
      return value.map((e) => (e as num).toDouble()).toList();
    }
    if (itemType == 'boolean') return value.cast<bool>();
  } else if (type == 'integer' && value is num) {
    return value.toInt();
  } else if (type == 'number' && value is num) {
    return value.toDouble();
  }
  return value;
}

Future<Map> _readJsonWhenStable(File file) async {
  Object? lastError;
  for (var i = 0; i < 20; i++) {
    try {
      return jsonDecode(await file.readAsString()) as Map;
    } catch (e) {
      lastError = e;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }
  throw StateError('State file did not settle: $lastError');
}

String _text(FunctionExecutionResult result) {
  return result.content
      .whereType<TextPart>()
      .map((part) => part.text)
      .join('\n');
}

String _messagesText(List<LLMMessage> messages) {
  final buffer = StringBuffer();
  for (final message in messages) {
    if (message is SystemMessage) {
      buffer.writeln(message.content);
    } else if (message is UserMessage) {
      for (final part in message.contents) {
        if (part is TextPart) buffer.writeln(part.text);
      }
    } else if (message is ModelMessage) {
      if (message.textOutput != null) buffer.writeln(message.textOutput);
    } else if (message is FunctionExecutionResultMessage) {
      for (final result in message.results) {
        buffer.writeln(_text(result));
      }
    }
  }
  return buffer.toString();
}

/// Returns the i-th scripted text as a plain (no tool call) model message, so
/// the agent run ends immediately.
class _ScriptedClient extends LLMClient {
  _ScriptedClient({required this.texts});
  final List<String> texts;
  var _i = 0;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    final text = _i < texts.length ? texts[_i] : 'done';
    _i++;
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'stop',
      textOutput: text,
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

class _SingleToolCallClient extends LLMClient {
  _SingleToolCallClient({
    required this.toolName,
    required this.arguments,
    this.finalText = 'done',
  });

  final String toolName;
  final Map<String, dynamic> arguments;
  final String finalText;
  final generateInputs = <List<LLMMessage>>[];
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
    generateInputs.add(List<LLMMessage>.from(messages));
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
      textOutput: finalText,
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

class _RecordingDelegateProgressSink implements DelegateProgressSink {
  final events = <String>[];

  @override
  void delegateStarted(DelegateProgress progress) {
    events.add('delegate-start:${progress.delegateRunId}');
  }

  @override
  void childToolStarted({
    required DelegateProgress progress,
    required String toolName,
    required String arguments,
  }) {
    events.add('start:${progress.delegateRunId}:$toolName');
  }

  @override
  void childToolFinished({
    required DelegateProgress progress,
    required FunctionExecutionResult result,
  }) {
    events.add(
        'finish:${progress.delegateRunId}:${result.name}:${result.isError}');
  }

  @override
  void delegateFinished({
    required DelegateProgress progress,
    required String status,
    required String summary,
  }) {
    events.add('delegate-finish:${progress.delegateRunId}:$status');
  }
}

class _ThrowingClient extends LLMClient {
  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    throw StateError('boom');
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

class _CancellableClient extends LLMClient {
  final cancelObserved = Completer<void>();
  final returned = Completer<void>();
  CancelToken? cancelToken;

  @override
  Future<ModelMessage> generate(
    List<LLMMessage> messages, {
    List<Tool>? tools,
    ToolChoice? toolChoice,
    required ModelConfig modelConfig,
    bool? jsonOutput,
    CancelToken? cancelToken,
  }) async {
    this.cancelToken = cancelToken;
    while (!(cancelToken?.isCancelled ?? false)) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    if (!cancelObserved.isCompleted) {
      cancelObserved.complete();
    }
    if (!returned.isCompleted) {
      returned.complete();
    }
    return ModelMessage(
      model: modelConfig.model,
      stopReason: 'stop',
      textOutput: '{"status":"failed","summary":"cancelled"}',
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

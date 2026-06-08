import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dart_agent_core/eval.dart';
import 'package:memex/agent/dynamic_surface_author_agent/dynamic_surface_author_agent.dart';
import 'package:memex/agent/memex_skill_host_agent/memex_skill_host_agent.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/skills/dynamic_surface/dynamic_surface_permissions.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/data/services/custom_agent_config_service.dart';
import 'package:memex/data/services/dynamic_surface_service.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/custom_agent_config.dart';
import 'package:memex/domain/models/dynamic_surface_model.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;

class DynamicSurfaceAuthorHarnessFactory implements AgentHarnessFactory {
  const DynamicSurfaceAuthorHarnessFactory();

  @override
  Future<AgentHarnessSession> create({
    required EvalTask task,
    required Trial trial,
    required EvalContext context,
  }) async =>
      _DynamicSurfaceAuthorSession(task: task, trial: trial, ctx: context);
}

class _DynamicSurfaceAuthorSession implements AgentHarnessSession {
  final EvalTask task;
  final Trial trial;
  final EvalContext ctx;

  _DynamicSurfaceAuthorSession({
    required this.task,
    required this.trial,
    required this.ctx,
  });

  @override
  Future<({Transcript transcript, Outcome outcome})> run() async {
    final userId = ctx.metadata['user_id'] as String;
    final suiteDir = ctx.metadata['suite_dir'] as String;
    final fs = FileSystemService.instance;
    final workspace = Directory(fs.getWorkspacePath(userId));
    final beforeSnapshot = await _snapshotWorkspace(workspace);

    final fixtureRel = task.input['fixture_dir'] as String?;
    if (fixtureRel != null && fixtureRel.isNotEmpty) {
      final fixtureDir = Directory(p.join(suiteDir, fixtureRel));
      if (!fixtureDir.existsSync()) {
        throw StateError('fixture_dir does not exist: ${fixtureDir.path}');
      }
      await _copyDirectory(fixtureDir, workspace);
    }

    final prompt = task.input['prompt'] as String;
    final expectedSurfaceId = task.input['expected_surface_id'] as String;
    final expectedSurfaceTitle =
        task.input['expected_surface_title'] as String?;
    final acceptableSurfaceIds =
        (task.input['acceptable_surface_ids'] as List?)?.cast<String>() ??
            const <String>[];
    String? authorError;
    String? pageAgentError;

    try {
      await _runAuthorAgent(
        userId: userId,
        prompt: prompt,
        controller: ctx.controller,
      );
    } catch (e) {
      authorError = e.toString();
    }

    final service = DynamicSurfaceService(fileSystemService: fs);
    final surface = await _findInstalledSurface(
      userId: userId,
      service: service,
      preferredSurfaceId: expectedSurfaceId,
      expectedSurfaceTitle: expectedSurfaceTitle,
      acceptableSurfaceIds: acceptableSurfaceIds,
    );
    final actualSurfaceId = surface?.id ?? expectedSurfaceId;
    Object? data;
    String rendered = '';
    String? renderError;
    if (surface != null) {
      try {
        final renderResult = await service.renderSurface(
          userId,
          actualSurfaceId,
        );
        data = renderResult.data;
        rendered = renderResult.content;
      } catch (e) {
        renderError = e.toString();
      }
    }

    final pageAgents = (await CustomAgentConfigService.instance.loadAll(userId))
        .where((c) => c.managedSurfaceId == actualSurfaceId)
        .toList();
    final pageAgent = pageAgents.isNotEmpty ? pageAgents.first : null;

    final manifestBeforePageAgent = surface?.toJson();
    final htmlBeforePageAgent = await _readSurfaceHtml(userId, actualSurfaceId);
    final sourceSnapshotBeforePageAgent =
        await _snapshotSurfaceSource(userId, surface);
    if (pageAgent != null && task.input['page_agent_event_xml'] != null) {
      try {
        await _applyWorkspaceUpdates(
          workspace,
          task.input['page_agent_workspace_updates'] as List?,
        );
        await _runPageAgent(
          userId: userId,
          config: pageAgent,
          eventXml: task.input['page_agent_event_xml'] as String,
        );
      } catch (e) {
        pageAgentError = e.toString();
      }
    }
    final sourceSnapshotAfterPageAgent =
        await _snapshotSurfaceSource(userId, surface);
    final surfaceAfterPageAgent =
        await service.getSurface(userId, actualSurfaceId);
    final manifestAfterPageAgent = surfaceAfterPageAgent?.toJson();
    final htmlAfterPageAgent = await _readSurfaceHtml(userId, actualSurfaceId);

    Object? dataAfterPageAgent;
    String renderedAfterPageAgent = '';
    if (surface != null) {
      try {
        final renderResult = await service.renderSurface(
          userId,
          actualSurfaceId,
        );
        dataAfterPageAgent = renderResult.data;
        renderedAfterPageAgent = renderResult.content;
      } catch (_) {
        // The render_error captured above is enough for grader diagnostics.
      }
    }

    final afterSnapshot = await _snapshotWorkspace(workspace);
    final diff = _diffSnapshots(beforeSnapshot, afterSnapshot);
    final html = await _readSurfaceHtml(userId, actualSurfaceId);
    final manifest = surface?.toJson();

    return (
      transcript: Transcript(
        messages: const [],
        toolCalls: const [],
        metrics: const TranscriptMetrics(
          nTurns: 0,
          nToolCalls: 0,
          nTotalTokens: 0,
        ),
      ),
      outcome: Outcome(environmentState: {
        'author_error': authorError,
        'page_agent_error': pageAgentError,
        'render_error': renderError,
        'surface_exists': surface != null,
        'surface_id': surface?.id,
        'expected_surface_id': expectedSurfaceId,
        'manifest': manifest,
        'html': html,
        'data': data,
        'rendered_html': rendered,
        'page_agent_count': pageAgents.length,
        'page_agent': pageAgent?.toJson(),
        'manifest_before_page_agent': manifestBeforePageAgent,
        'manifest_after_page_agent': manifestAfterPageAgent,
        'html_before_page_agent': htmlBeforePageAgent,
        'html_after_page_agent': htmlAfterPageAgent,
        'source_before_page_agent': sourceSnapshotBeforePageAgent,
        'source_after_page_agent': sourceSnapshotAfterPageAgent,
        'data_after_page_agent': dataAfterPageAgent,
        'rendered_html_after_page_agent': renderedAfterPageAgent,
      }, workspaceDiff: diff),
    );
  }

  @override
  Future<void> dispose() async {}

  Future<DynamicSurfaceModel?> _findInstalledSurface({
    required String userId,
    required DynamicSurfaceService service,
    required String preferredSurfaceId,
    required String? expectedSurfaceTitle,
    required List<String> acceptableSurfaceIds,
  }) async {
    final preferred = await service.getSurface(userId, preferredSurfaceId);
    if (preferred != null) return preferred;

    final surfaces = await service.listSurfaces(userId);
    if (surfaces.isEmpty) return null;

    final acceptedIds = {preferredSurfaceId, ...acceptableSurfaceIds};
    for (final surface in surfaces) {
      if (acceptedIds.contains(surface.id)) return surface;
    }

    if (expectedSurfaceTitle != null && expectedSurfaceTitle.isNotEmpty) {
      for (final surface in surfaces) {
        if (surface.title.trim() == expectedSurfaceTitle.trim()) {
          return surface;
        }
      }
    }

    return surfaces.length == 1 ? surfaces.first : null;
  }

  Future<void> _applyWorkspaceUpdates(
    Directory workspace,
    List? updates,
  ) async {
    if (updates == null || updates.isEmpty) return;
    for (final raw in updates) {
      if (raw is! Map) continue;
      final relativePath = raw['path'] as String?;
      final content = raw['content'] as String?;
      if (relativePath == null || content == null) continue;
      if (p.isAbsolute(relativePath) || relativePath.contains('..')) {
        throw ArgumentError('Invalid workspace update path: $relativePath');
      }
      final file = File(p.join(workspace.path, relativePath));
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    }
  }

  Future<void> _runAuthorAgent({
    required String userId,
    required String prompt,
    required AgentController controller,
  }) async {
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.dynamicSurfaceAuthorAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final workingDirAbs =
        await FileSystemService.instance.resolveWorkingDirectory(userId, '');
    final sessionId =
        'dynamic_surface_author_eval_${userId}_${DateTime.now().microsecondsSinceEpoch}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'scene': 'eval_dynamic_surface_author',
      'sceneId': trial.id.toString(),
    });
    final agent = await DynamicSurfaceAuthorAgent.createAgent(
      client: resources.client,
      modelConfig: resources.modelConfig,
      userId: userId,
      state: state,
      workingDirectory: workingDirAbs,
      controller: controller,
    );
    await agent.run([UserMessage.text(prompt)], useStream: false);
  }

  Future<void> _runPageAgent({
    required String userId,
    required CustomAgentConfig config,
    required String eventXml,
  }) async {
    final resources = await UserStorage.getAgentLLMResources(
      config.llmConfigKey ?? AgentDefinitions.chatAgent,
      defaultClientKey: config.llmConfigKey ?? LLMConfig.defaultClientKey,
    );
    final skillAbsPath = FileSystemService.instance.resolveSkillPath(
      userId,
      config.skillDirectoryPath,
    );
    final writeRules = await _pageAgentWriteRules(
      userId: userId,
      surfaceId: config.managedSurfaceId,
    );
    final workingDirAbsPath = await FileSystemService.instance
        .resolveWorkingDirectory(userId, config.workingDirectory);
    final sessionId =
        '${config.agentName}_eval_${userId}_${DateTime.now().microsecondsSinceEpoch}';
    final state = await loadOrCreateAgentState(sessionId, {
      'userId': userId,
      'agentName': config.agentName,
      'scene': 'eval_dynamic_surface_page_agent',
      'sceneId': trial.id.toString(),
    });
    final prompt = [
      if (config.systemPrompt != null && config.systemPrompt!.trim().isNotEmpty)
        config.systemPrompt!.trim(),
      _pageAgentRuntimePrompt(config.managedSurfaceId!),
    ].join('\n\n');
    final agent = await MemexSkillHostAgent.createAgent(
      client: resources.client,
      modelConfig: resources.modelConfig,
      userId: userId,
      name: config.agentName,
      state: state,
      skillDirectoryPath: skillAbsPath,
      workingDirectory: workingDirAbsPath,
      additionalSystemPrompt: prompt,
      filePermissionRules: writeRules,
      enablePlanner: false,
      enableJavaScriptRuntime: false,
    );
    await agent.run([
      UserMessage.text(
        'A system event has occurred. Process it according to your skills.\n\n$eventXml',
      ),
    ], useStream: false);
  }

  String _pageAgentRuntimePrompt(String surfaceId) => '''
# Dynamic Surface Page Agent Eval Contract
You maintain only Dynamic Surface `$surfaceId`.
- Update only the declared Markdown data source for this surface.
- Treat origin/native data paths as read-only evidence; keep writes limited to
  the declared page-owned source.
- Your current root directory is `/`. Use the page data paths from the page
  contract. Never use guessed roots like /root, /Users, or /var.
- Keep Markdown data parseable by the installed parser.js contract.
''';

  Future<List<PermissionRule>?> _pageAgentWriteRules({
    required String userId,
    required String? surfaceId,
  }) async {
    if (surfaceId == null || surfaceId.isEmpty) return null;
    final fs = FileSystemService.instance;
    final service = DynamicSurfaceService(fileSystemService: fs);
    final surface = await service.getSurface(userId, surfaceId);
    if (surface == null) return const [];

    return buildManagedDynamicSurfaceWriteRules(
      userId: userId,
      surfaceId: surfaceId,
      fileSystemService: fs,
      dynamicSurfaceService: service,
    );
  }

  Future<String> _readSurfaceHtml(String userId, String surfaceId) async {
    final file = File(p.join(
      FileSystemService.instance.getDynamicSurfacePath(userId, surfaceId),
      'view.html',
    ));
    if (!await file.exists()) return '';
    return file.readAsString();
  }

  Future<Map<String, String>> _snapshotSurfaceSource(
    String userId,
    dynamic surface,
  ) async {
    if (surface == null) return const {};
    final workspace = FileSystemService.instance.getWorkspacePath(userId);
    final source = surface.source;
    final abs = p.normalize(p.join(workspace, source.path as String));
    final files = <String, String>{};
    if (source.isFile == true) {
      final file = File(abs);
      if (await file.exists()) {
        files[p.relative(file.path, from: workspace)] =
            await file.readAsString();
      }
      return files;
    }
    final dir = Directory(abs);
    if (!await dir.exists()) return files;
    await for (final entity in dir.list(
      recursive: source.recursive == true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.md')) continue;
      files[p.relative(entity.path, from: workspace)] =
          await entity.readAsString();
    }
    return files;
  }
}

Future<Map<String, String>> _snapshotWorkspace(Directory workspace) async {
  final files = <String, String>{};
  if (!await workspace.exists()) return files;
  await for (final entity in workspace.list(recursive: true)) {
    if (entity is! File) continue;
    final rel = p.relative(entity.path, from: workspace.path);
    if (rel.contains('/AgentStates/') || rel.contains('/ChatSessions/')) {
      continue;
    }
    files[rel] = await entity.readAsString();
  }
  return files;
}

WorkspaceDiff _diffSnapshots(
  Map<String, String> before,
  Map<String, String> after,
) {
  final created = <String>[];
  final modified = <String>[];
  final deleted = <String>[];
  final snippets = <String, String>{};

  for (final entry in after.entries) {
    final old = before[entry.key];
    if (old == null) {
      created.add(entry.key);
      snippets[entry.key] = _snippet(entry.value);
    } else if (old != entry.value) {
      modified.add(entry.key);
      snippets[entry.key] = _snippet(entry.value);
    }
  }
  for (final path in before.keys) {
    if (!after.containsKey(path)) deleted.add(path);
  }
  created.sort();
  modified.sort();
  deleted.sort();
  return WorkspaceDiff(
    created: created,
    modified: modified,
    deleted: deleted,
    contentSnippets: snippets,
  );
}

String _snippet(String content) {
  const maxChars = 4096;
  if (content.length <= maxChars) return content;
  return content.substring(0, maxChars);
}

Future<void> _copyDirectory(Directory src, Directory dst) async {
  if (!await src.exists()) return;
  await dst.create(recursive: true);
  await for (final entry in src.list(recursive: false)) {
    final name = p.basename(entry.path);
    if (entry is Directory) {
      await _copyDirectory(entry, Directory(p.join(dst.path, name)));
    } else if (entry is File) {
      await entry.copy(p.join(dst.path, name));
    }
  }
}

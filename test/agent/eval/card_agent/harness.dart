import 'dart:io';

import 'package:dart_agent_core/eval.dart';
import 'package:memex/agent/card_agent/card_agent.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/task_handlers/card_agent_handler.dart';
import 'package:path/path.dart' as p;

/// Card Agent harness factory. One session per trial; each session
/// 1. copies the task's `fixture_dir` into the per-user workspace
///    (path is `task.input['fixture_dir']`, relative to the suite root)
/// 2. runs the production `processWithCardAgent` codepath
/// 3. inspects the resulting card and assembles an [Outcome]
class CardAgentHarnessFactory implements AgentHarnessFactory {
  const CardAgentHarnessFactory();

  @override
  Future<AgentHarnessSession> create({
    required EvalTask task,
    required Trial trial,
    required EvalContext context,
  }) async =>
      _CardAgentSession(task: task, trial: trial, ctx: context);
}

class _CardAgentSession implements AgentHarnessSession {
  final EvalTask task;
  final Trial trial;
  final EvalContext ctx;

  _CardAgentSession({
    required this.task,
    required this.trial,
    required this.ctx,
  });

  @override
  Future<({Transcript transcript, Outcome outcome})> run() async {
    final userId = ctx.metadata['user_id'] as String;
    final suiteDir = ctx.metadata['suite_dir'] as String;
    final fs = FileSystemService.instance;

    // Each trial gets a freshly-copied fixture, so concurrent trials never
    // share state. The fixture mirrors what `submit_input` would have
    // written before the card agent kicks in — a daily fact file with
    // a `## <id:ts_N>` heading matching `task.input['fact_id']`.
    final fixtureRel = task.input['fixture_dir'] as String?;
    if (fixtureRel == null || fixtureRel.isEmpty) {
      throw StateError(
        'task ${task.id} missing required input.fixture_dir',
      );
    }
    final fixtureDir = Directory(p.join(suiteDir, fixtureRel));
    if (!fixtureDir.existsSync()) {
      throw StateError(
        'fixture_dir does not exist on disk: ${fixtureDir.path}',
      );
    }
    final destWorkspace = Directory(fs.getWorkspacePath(userId));
    await _copyDirectory(fixtureDir, destWorkspace);

    final factId = task.input['fact_id'] as String;
    final content = task.input['content'] as String;

    final evidence = await _runOrInspect(
      userId: userId,
      factId: factId,
      content: content,
    );

    final card = await fs.readCardFile(userId, factId);
    final templateIds = card == null
        ? const <String>[]
        : card.uiConfigs.map((c) => c.templateId).toList();

    // Read the raw YAML so substring graders (card_must_contain) can scan
    // every field — including ui_config.data — without having to know the
    // schema of every template.
    String cardYamlBlob = '';
    final cardPath = evidence.cardPath;
    if (cardPath != null) {
      final f = File(cardPath);
      if (await f.exists()) {
        cardYamlBlob = await f.readAsString();
      }
    }

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
        'is_complete': evidence.isComplete,
        'card_save_tool_called': evidence.requireSaveToolCall == false ||
            evidence.hasMatchingSuccessfulSaveToolCall,
        'card_path': evidence.cardPath,
        'persisted_fact_id': evidence.persistedFactId,
        'status': evidence.status,
        'has_title': evidence.hasTitle,
        'has_ui_configs': evidence.hasUiConfigs,
        'missing_requirements': evidence.missingRequirements,
        'failure_reason': evidence.failureReason,
        'template_ids': templateIds,
        'card_tags': card?.tags ?? const <String>[],
        'card_yaml_blob': cardYamlBlob,
      }),
    );
  }

  @override
  Future<void> dispose() async {}

  /// Run the production card-agent pipeline. When the agent fails to
  /// produce a complete card after retries the production code throws a
  /// [StateError] — for evaluation purposes we don't want a missing card
  /// to short-circuit the trial as `errored`, we want graders to see the
  /// actual persisted state. So: catch the failure and re-inspect the
  /// workspace ourselves.
  Future<CardRunCompletionEvidence> _runOrInspect({
    required String userId,
    required String factId,
    required String content,
  }) async {
    try {
      return await processWithCardAgent(
        userId: userId,
        factId: factId,
        contentText: content,
        inputDateTime: DateTime.now(),
      );
    } catch (_) {
      return CardAgent.inspectCardRunCompletion(
        userId: userId,
        factId: factId,
      );
    }
  }
}

/// Recursive `cp -R` for fixture seeding.
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

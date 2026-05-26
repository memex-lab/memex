import 'dart:convert';
import 'dart:io';

import 'package:dart_agent_core/eval.dart';
import 'package:memex/agent/pkm_agent/pkm_agent.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/domain/models/agent_definitions.dart';
import 'package:memex/domain/models/llm_config.dart';
import 'package:memex/utils/time_context.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;

/// PKM Agent harness factory. One session per trial; each session
/// 1. copies the task's `fixture_dir` into the per-user workspace
/// 2. runs the production `PkmAgent.runWithContent` codepath
/// 3. extracts read/write/edit history + final PKM file contents and
///    assembles an [Outcome] for the graders to score
class PkmAgentHarnessFactory implements AgentHarnessFactory {
  const PkmAgentHarnessFactory();

  @override
  Future<AgentHarnessSession> create({
    required EvalTask task,
    required Trial trial,
    required EvalContext context,
  }) async =>
      _PkmAgentSession(task: task, trial: trial, ctx: context);
}

class _PkmAgentSession implements AgentHarnessSession {
  final EvalTask task;
  final Trial trial;
  final EvalContext ctx;

  _PkmAgentSession({
    required this.task,
    required this.trial,
    required this.ctx,
  });

  @override
  Future<({Transcript transcript, Outcome outcome})> run() async {
    final userId = ctx.metadata['user_id'] as String;
    final suiteDir = ctx.metadata['suite_dir'] as String;
    final fs = FileSystemService.instance;

    // 1. Seed the per-user workspace. Two layers (base then overlay) so
    //    most tasks can share the realistic "starter" PKM and only
    //    declare the deltas that matter for their case.
    final destWorkspace = Directory(fs.getWorkspacePath(userId));
    final baseFixture = task.input['base_fixture'] as String?;
    if (baseFixture != null && baseFixture.isNotEmpty) {
      final baseDir = Directory(p.join(suiteDir, baseFixture));
      if (!baseDir.existsSync()) {
        throw StateError(
          'base_fixture does not exist on disk: ${baseDir.path}',
        );
      }
      await _copyDirectory(baseDir, destWorkspace);
    }

    final fixtureRel = task.input['fixture_dir'] as String?;
    if (fixtureRel == null || fixtureRel.isEmpty) {
      throw StateError('task ${task.id} missing required input.fixture_dir');
    }
    final fixtureDir = Directory(p.join(suiteDir, fixtureRel));
    if (!fixtureDir.existsSync()) {
      throw StateError(
        'fixture_dir does not exist on disk: ${fixtureDir.path}',
      );
    }
    await _copyDirectory(fixtureDir, destWorkspace);

    final factId = task.input['fact_id'] as String;
    final content = task.input['content'] as String;

    // 2. Build the same instruction prompt the production handler uses,
    //    then run the agent. We bypass `processWithPkmAgent` because it
    //    swallows the completion evidence; we need that for graders.
    final resources = await UserStorage.getAgentLLMResources(
      AgentDefinitions.pkmAgent,
      defaultClientKey: LLMConfig.defaultClientKey,
    );
    final instruction = Prompts.pkmAgentInstructionForNewPublishedContent(
      formatLocalDateTimeWithZone(DateTime.now()),
      factId,
      content,
      '', // no asset info for eval tasks
    );

    PkmRunCompletionEvidence evidence;
    try {
      evidence = await PkmAgent.runWithContent(
        client: resources.client,
        modelConfig: resources.modelConfig,
        userId: userId,
        factId: factId,
        instruction: instruction,
      );
    } catch (_) {
      // If the production retry loop gives up, inspect the workspace
      // anyway so graders can see partial progress.
      evidence = const PkmRunCompletionEvidence(
        wrotePara: false,
        updatedInsight: false,
        skippedPkm: false,
        successfulPkmMutation: false,
      );
    }

    // 3. Walk the agent's tool-call history (via FunctionExecutionResult
    //    messages stored on the agent state) to recover read/write order.
    //    We can't easily get the agent state from here without re-loading
    //    it from disk, so we instead reconstruct everything from the
    //    workspace + the evidence we already have.
    final readFiles = <String>[];
    final writeOrder = <String>[];
    final writtenFiles = <String>{};
    final editedFiles = <String>{};
    final insightPayload = <String, String>{};
    final fileEdits = <Map<String, String>>[];
    final fileWrites = <Map<String, String>>[];
    await _replayToolHistoryFromState(
      userId: userId,
      factId: factId,
      readFiles: readFiles,
      writeOrder: writeOrder,
      writtenFiles: writtenFiles,
      editedFiles: editedFiles,
      insightPayload: insightPayload,
      fileEdits: fileEdits,
      fileWrites: fileWrites,
    );

    // 4. Snapshot final PKM file contents (relative paths under PKM/).
    final pkmRoot = Directory(fs.getPkmPath(userId));
    final fileContents = <String, String>{};
    if (pkmRoot.existsSync()) {
      for (final entry in pkmRoot.listSync(recursive: true)) {
        if (entry is! File) continue;
        final rel = p.relative(entry.path, from: pkmRoot.path);
        fileContents[rel] = entry.readAsStringSync();
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
        'wrote_para': evidence.wrotePara,
        'updated_insight': evidence.updatedInsight,
        'skipped_pkm': evidence.skippedPkm,
        'successful_pkm_mutation': evidence.successfulPkmMutation,
        'missing_requirements': evidence.missingRequirements,
        'skip_evidence': evidence.skipEvidence,
        'read_files': readFiles,
        'write_order': writeOrder,
        'written_files': writtenFiles.toList(),
        'edited_files': editedFiles.toList(),
        'file_contents': fileContents,
        'insight_summary': insightPayload['summary_text'] ?? '',
        'insight_text': insightPayload['insight_text'] ?? '',
        'file_edits': fileEdits,
        'file_writes': fileWrites,
        'task_input_content': content,
      }),
    );
  }

  @override
  Future<void> dispose() async {}

  /// Pull the agent's state file off disk and replay its tool-call history
  /// to recover the order of read / write / edit calls. PkmAgent.createAgent
  /// uses sessionId = `pkm_${userId}_${factIdSafe}` and saves through the
  /// standard FileStateStorage path.
  Future<void> _replayToolHistoryFromState({
    required String userId,
    required String factId,
    required List<String> readFiles,
    required List<String> writeOrder,
    required Set<String> writtenFiles,
    required Set<String> editedFiles,
    required Map<String, String> insightPayload,
    required List<Map<String, String>> fileEdits,
    required List<Map<String, String>> fileWrites,
  }) async {
    final fs = FileSystemService.instance;
    final factIdSafe = fs.makeFactIdSafe(factId);
    final sessionId = 'pkm_${userId}_$factIdSafe';

    // FileStateStorage path: <workspace>/_System/state_dir/<sessionId>.json
    // (kept in sync with `FileSystemService.getAgentStateDirectory()`).
    final statePath = p.join(
      fs.getWorkspacePath(userId),
      '_System',
      'state_dir',
      '$sessionId.json',
    );
    final stateFile = File(statePath);
    if (!stateFile.existsSync()) return;

    Map<String, dynamic> state;
    try {
      state =
          jsonDecode(await stateFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final history = (state['history'] as Map?)?['messages'] as List?;
    if (history == null) return;

    for (final raw in history) {
      if (raw is! Map) continue;
      final msg = raw.cast<String, dynamic>();
      if (msg['role'] != 'tool') continue;
      final results = msg['results'] as List?;
      if (results == null) continue;
      for (final r in results) {
        if (r is! Map) continue;
        final rec = r.cast<String, dynamic>();
        if (rec['isError'] == true) continue;
        final name = rec['name'] as String?;
        final argsStr = rec['arguments'] as String? ?? '{}';
        Map<String, dynamic> args;
        try {
          args = jsonDecode(argsStr) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }
        final filePath = args['file_path'] as String?;
        switch (name) {
          case 'Read':
            if (filePath != null) readFiles.add(filePath);
            break;
          case 'Write':
            if (filePath != null) {
              writtenFiles.add(filePath);
              writeOrder.add(filePath);
              fileWrites.add({
                'file_path': filePath,
                'content': (args['content'] as String?) ?? '',
              });
            }
            break;
          case 'Edit':
            if (filePath != null) {
              editedFiles.add(filePath);
              writeOrder.add(filePath);
              fileEdits.add({
                'file_path': filePath,
                'old_string': (args['old_string'] as String?) ?? '',
                'new_string': (args['new_string'] as String?) ?? '',
              });
            }
            break;
          case 'update_timeline_card_insight':
            // Capture the most recent successful insight call. The pkm
            // agent calls this once per run as the last step, but if it
            // retries we only want the final payload that "stuck".
            insightPayload['summary_text'] =
                (args['summary_text'] as String?) ?? '';
            insightPayload['insight_text'] =
                (args['insight_text'] as String?) ?? '';
            break;
        }
      }
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

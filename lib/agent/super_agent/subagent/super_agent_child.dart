import 'dart:async';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dio/dio.dart';
import 'package:memex/agent/built_in_tools/file_tools.dart';
import 'package:memex/agent/security/file_permission_manager.dart';
import 'package:memex/agent/state_util.dart';
import 'package:memex/agent/skills/dynamic_timeline_ui/dynamic_timeline_ui_skill.dart';
import 'package:memex/agent/super_agent/super_agent_harness.dart';
import 'package:memex/agent/super_agent/subagent/delegate_progress.dart';
import 'package:memex/data/services/agent_image_attachment.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/time_context.dart';
import 'package:uuid/uuid.dart';

final _logger = getLogger('SuperAgentChild');

/// Which base (non-skill) tools a child worker gets, on top of the tools that
/// come from its activated skills. Avoids re-listing tool sets at every call
/// site — the fan-out caller just names a profile.
enum ChildToolProfile {
  /// Only the child's skill tools (+ skill activate/deactivate). No base file
  /// tools at all.
  none,

  /// Skill tools + all read-only base tools (LS / Glob / Grep / Read /
  /// BatchRead / view_image).
  read,

  /// `read` + the generic write tools (Write / Edit / MOVE / Remove). Writes
  /// are still bounded by the permission manager's [writeRootPaths].
  full,
}

/// One bounded child-worker run configuration. A child is a temporary worker
/// SuperAgent spawns within a single turn: its own [AgentState], a narrow base
/// prompt, one or more force-activated skills, a scoped tool profile, and a
/// hard write-path allow-list. It never persists across turns and never talks
/// to the user.
class SuperAgentChildConfig {
  /// Short label for logging / UI (e.g. `card_child`). Not a business type.
  final String childName;

  /// The task instruction for this child run.
  final String taskBrief;

  /// Read-only context the runtime hands the child: fact_id, captured-at time,
  /// location reminder, existing record snapshots, attachment context,
  /// etc. Rendered deterministically into the child's first message so the
  /// child never has to infer record identity or timing.
  final Map<String, dynamic> contextPacket;

  /// Image attachments resolved from structured `fs://...` asset blocks and
  /// injected into the child's first user message using the same reminder +
  /// optional image-part shape as normal user image attachments.
  final List<ChildImageAttachment> imageAttachments;

  /// Skills available to this child. The caller pre-sets `forceActivate` on the
  /// ones that should be always-on (e.g. the card skill for the card child).
  /// Non-force skills here can be self-activated by the child on demand (e.g.
  /// the card child activating `dynamic_timeline_ui` when no built-in template
  /// fits). Passing built instances (rather than names) keeps this type-safe
  /// and avoids a brittle name→skill registry.
  final List<Skill> skills;

  /// Base tool profile (see [ChildToolProfile]).
  final ChildToolProfile toolProfile;

  /// Absolute workspace-relative roots this child may READ from. Empty means
  /// the normal workspace-read defaults apply. Non-empty means this child gets
  /// no default workspace read access; only these roots (plus write roots,
  /// because write implies read) are readable. Enforced by
  /// [FilePermissionManager], not by prompt text.
  final List<String> readRootPaths;

  /// Absolute workspace-relative roots this child may WRITE to (e.g.
  /// `/Cards`, `/PKM`, `/_UserSettings/Templates`). When [readRootPaths] is
  /// empty, everything else is read-only and Facts/_System stay locked by the
  /// default rules. Enforced by [FilePermissionManager], not by prompt text.
  final List<String> writeRootPaths;

  /// Hard wall-clock bound for this child's run.
  final Duration timeout;

  const SuperAgentChildConfig({
    required this.childName,
    required this.taskBrief,
    required this.skills,
    this.contextPacket = const {},
    this.imageAttachments = const [],
    this.toolProfile = ChildToolProfile.read,
    this.readRootPaths = const [],
    this.writeRootPaths = const [],
    this.timeout = const Duration(minutes: 20),
  });
}

class ChildImageAttachment {
  const ChildImageAttachment({
    required this.image,
    required this.inline,
  });

  final AgentImageAttachment image;
  final InlineAgentImage? inline;
}

/// Terminal status of a child run. `no_op` is a first-class, non-failure
/// result (e.g. a record that doesn't warrant PKM organization).
enum SuperAgentChildStatus { completed, noOp, failed, needsParentInput }

SuperAgentChildStatus _statusFromWire(String? v) {
  switch (v) {
    case 'completed':
      return SuperAgentChildStatus.completed;
    case 'no_op':
      return SuperAgentChildStatus.noOp;
    case 'needs_parent_input':
      return SuperAgentChildStatus.needsParentInput;
    case 'failed':
    default:
      return SuperAgentChildStatus.failed;
  }
}

/// Structured outcome the parent runtime collects from a child run.
class SuperAgentChildResult {
  final String childName;
  final SuperAgentChildStatus status;

  /// The child's final natural-language text (its self-report).
  final String summary;

  /// State file session id for this child run. Parent state stores this in the
  /// delegate tool result metadata so debugging can jump from a parent tool call
  /// to the separate child state file.
  final String? childSessionId;

  /// Runtime-provided structured payload, usually from the terminal tool
  /// result. Kept separate from the model-written summary.
  final Map<String, dynamic> structured;

  /// Set when the run threw / timed out before the child could report.
  final String? error;

  const SuperAgentChildResult({
    required this.childName,
    required this.status,
    required this.summary,
    this.childSessionId,
    this.structured = const {},
    this.error,
  });

  SuperAgentChildResult copyWith({
    String? childName,
    SuperAgentChildStatus? status,
    String? summary,
    String? childSessionId,
    Map<String, dynamic>? structured,
    String? error,
  }) {
    return SuperAgentChildResult(
      childName: childName ?? this.childName,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      childSessionId: childSessionId ?? this.childSessionId,
      structured: structured ?? this.structured,
      error: error ?? this.error,
    );
  }

  factory SuperAgentChildResult.failed(
    String childName,
    String error, {
    String? childSessionId,
  }) =>
      SuperAgentChildResult(
        childName: childName,
        status: SuperAgentChildStatus.failed,
        summary: error,
        childSessionId: childSessionId,
        error: error,
      );

  Map<String, dynamic> toJson() => {
        'child': childName,
        'status': status.name,
        'summary': summary,
        if (childSessionId != null) 'child_session_id': childSessionId,
        if (structured.isNotEmpty) 'structured': structured,
        if (error != null) 'error': error,
      };
}

/// Base system prompt shared by every child worker. Skill-specific instructions
/// arrive via the force-activated skills; this only frames the worker contract.
String buildChildBasePrompt() {
  return '''
# Memex Subagent Worker

You are a temporary worker spawned by the Memex SuperAgent for ONE bounded task.
You are NOT the user-facing SuperAgent. Do not chat with the user, do not ask
the user questions, and do not produce user-facing chit-chat. Your final
message is parsed by the parent runtime.

## Scope
- Work only on the task content and context packet provided in this run.
- Follow the active skill instructions for this run.
- Use ONLY the fact_id, timestamps, assets, and context explicitly provided.
  Never invent or guess record identity.
- Image attachments referenced by `fs://...` asset blocks are represented in
  your first message as an attachment reminder followed by the image part
  itself. Inspect image parts directly and use the `fs://...` references exactly
  as given for saved assets.
- Do not perform side effects outside your assigned write scope.
- Do not write long-term memory. Do not spawn other agents.

## Truthfulness
- Report tool failures truthfully. Never claim a change succeeded unless the
  tool result proves it. Do not invent reasons for a failure.
- If your branch does not apply to this record, that is normal — return a
  `no_op` result with a short reason. Do not force a write just to look busy.
- If you genuinely cannot proceed without information the parent did not
  provide, return `needs_parent_input` naming the exact missing field.

## Output
When a successful terminal tool call completes your task, pass
`finish_summary` on that tool call. Use it for the exact concise final summary,
including relevant work already done in this run. Leave it unset if another
tool call, inspection, or repair is still needed.

If no terminal tool applies, end with a concise plain-text summary. For no-op
work, explicitly say `no_op` and the reason. If you genuinely need missing
parent input, explicitly say `needs_parent_input` and name the missing field.
''';
}

/// Renders the runtime-provided context packet into a single `<system-reminder>`
/// block, mirroring how `ChatService` assembles per-turn context.
String _buildContextReminder(Map<String, dynamic> packet) {
  final sections = <String>[];

  final factId = packet['fact_id'];
  if (factId is String && factId.isNotEmpty) {
    sections
        .add('Record fact_id: $factId (use this exact id; never invent one)');
  }

  sections.add(
      'Current Local Time: ${formatLocalDateTimeWithZone(DateTime.now())}');

  final location = packet['location_reminder'];
  if (location is String && location.trim().isNotEmpty) {
    sections.add(location.trim());
  }

  final pkmOverview = packet['pkm_overview'];
  if (pkmOverview is String && pkmOverview.trim().isNotEmpty) {
    sections.add('Current PKM structure tree:\n${pkmOverview.trim()}');
  }

  final cardMetadata = packet['card_metadata'];
  if (cardMetadata is String && cardMetadata.trim().isNotEmpty) {
    sections.add(
      'Latest get_card_metadata result. Use this metadata instead of calling '
      'get_card_metadata again:\n${cardMetadata.trim()}',
    );
  }

  return '<system-reminder>\n${sections.join('\n\n')}\n</system-reminder>';
}

/// Assemble the base tool set for a [ChildToolProfile]. Skill tools are added
/// by the agent itself from the (force-)active skills, so they are NOT listed
/// here — this only covers the generic base tools.
List<Tool> _baseToolsForProfile(
  ChildToolProfile profile,
  FileToolFactory factory,
) {
  switch (profile) {
    case ChildToolProfile.none:
      return const [];
    case ChildToolProfile.read:
      return [
        factory.buildLSTool(),
        factory.buildGlobTool(),
        factory.buildGrepTool(),
        factory.buildReadTool(),
        factory.buildBatchReadTool(),
        factory.buildViewImageTool(),
      ];
    case ChildToolProfile.full:
      return [
        factory.buildLSTool(),
        factory.buildGlobTool(),
        factory.buildGrepTool(),
        factory.buildReadTool(),
        factory.buildBatchReadTool(),
        factory.buildViewImageTool(),
        factory.buildWriteTool(),
        factory.buildEditTool(),
        factory.buildMoveTool(),
        factory.buildRemoveTool(),
      ];
  }
}

/// Builds a child worker [StatefulAgent] with its own fresh state, scoped
/// permissions, base prompt + skills, and tool profile. Does NOT run it — see
/// [runSuperAgentChild].
StatefulAgent createSuperAgentChild({
  required SuperAgentChildConfig config,
  required LLMClient client,
  required ModelConfig modelConfig,
  required String userId,
  DelegateProgress? progress,
  DelegateProgressSink? progressSink,
}) {
  final fileService = FileSystemService.instance;
  final workingDirectory = fileService.getWorkspacePath(userId);

  // Default child behavior matches the parent: workspace read, explicit write
  // roots writable. Some specialists (PKM) need a narrower read wall; a
  // non-empty readRootPaths disables default workspace read and allows only the
  // declared roots.
  final restrictedRead = config.readRootPaths.isNotEmpty;
  final permissionRules = <PermissionRule>[
    if (restrictedRead)
      PermissionRule(
        rootPath: workingDirectory,
        access: FileAccessType.none,
      ),
    // Add write roots before read roots so equal-path rules keep write access;
    // FilePermissionManager uses stable longest-prefix sorting.
    for (final root in config.writeRootPaths)
      PermissionRule(
        rootPath: _resolveWorkspacePath(fileService, userId, root),
        access: FileAccessType.write,
      ),
    for (final root in config.readRootPaths)
      PermissionRule(
        rootPath: _resolveWorkspacePath(fileService, userId, root),
        access: FileAccessType.read,
      ),
  ];
  final permissionManager = FilePermissionManager(
    userId,
    permissionRules,
    withDefaultRules: !restrictedRead,
  );

  final fileToolFactory = FileToolFactory(
    permissionManager: permissionManager,
    workingDirectory: workingDirectory,
  );

  final tools = _baseToolsForProfile(config.toolProfile, fileToolFactory);

  // dynamic_timeline_ui designs HTML templates by editing files under the
  // template dir. Rather than granting the whole worker generic write tools
  // (a `full` profile, which becomes a misuse magnet elsewhere), inject the
  // scoped file tools INTO the skill so they only appear while the worker is
  // actually designing a template. The tools are bounded by this child's
  // permission manager (its writeRootPaths). Skills arrive pre-built in the
  // config, so we rebuild the dynamic-UI skill here where the FileToolFactory
  // (and thus userId-scoped permissions) finally exists.
  final skills = config.skills.map((skill) {
    if (skill is DynamicTimelineUiSkill) {
      return DynamicTimelineUiSkill(
        forceActivate: skill.forceActivate,
        extraTools: [
          fileToolFactory.buildReadTool(),
          fileToolFactory.buildWriteTool(),
          fileToolFactory.buildEditTool(),
          fileToolFactory.buildLSTool(),
          fileToolFactory.buildGlobTool(),
          fileToolFactory.buildGrepTool(),
        ],
      );
    }
    return skill;
  }).toList();

  final state = AgentState(
    sessionId: '${config.childName}_${const Uuid().v4()}',
    metadata: {
      'userId': userId,
      'sub_agent_mode': true,
      'child_name': config.childName,
      'child_tool_profile': config.toolProfile.name,
      'child_read_roots': config.readRootPaths,
      'child_write_roots': config.writeRootPaths,
      'child_skills': config.skills
          .map((s) => {
                'name': s.name,
                'force_activate': s.forceActivate,
              })
          .toList(),
      'child_created_at': DateTime.now().toIso8601String(),
      if (config.contextPacket['parent_session_id'] is String)
        'parent_session_id': config.contextPacket['parent_session_id'],
      if (progress != null) 'delegate_run_id': progress.delegateRunId,
    },
  );

  final controller = AgentController();
  if (progress != null && progressSink != null) {
    controller.on((BeforeToolCallEvent event) {
      progressSink.childToolStarted(
        progress: progress,
        toolName: event.functionCall.name,
        arguments: event.functionCall.arguments,
      );
    });
    controller.on((AfterToolCallEvent event) {
      progressSink.childToolFinished(
        progress: progress,
        result: event.result,
      );
    });
  }

  return StatefulAgent(
    name: config.childName,
    client: client,
    modelConfig: modelConfig,
    state: state,
    tools: tools,
    skills: skills,
    controller: controller,
    systemPrompts: [buildChildBasePrompt()],
    disableSubAgents: true,
    withGeneralPrinciples: true,
    planMode: PlanMode.none,
    autoSaveStateFunc: (state) async {
      await saveAgentState(state);
    },
    // PKM organization now happens inside these workers, so the PKM
    // structural-health reminders ride along here (only fire on /PKM reads).
    hooks: [SuperAgentHarness.buildChildHook(userId)],
  );
}

/// Maps a workspace-relative root like `/Cards` to an absolute path; passes an
/// already-absolute path through unchanged.
String _resolveWorkspacePath(
  FileSystemService fileService,
  String userId,
  String root,
) {
  final workspace = fileService.getWorkspacePath(userId);
  if (root.startsWith(workspace)) return root;
  final rel = root.startsWith('/') ? root.substring(1) : root;
  return rel.isEmpty ? workspace : '$workspace/$rel';
}

/// Builds and runs a child worker to completion (or timeout), then extracts a
/// [SuperAgentChildResult] from its final message. Never throws — a thrown /
/// timed-out run becomes a `failed` result so the parent can still merge.
Future<SuperAgentChildResult> runSuperAgentChild({
  required SuperAgentChildConfig config,
  required LLMClient client,
  required ModelConfig modelConfig,
  required String userId,
  DelegateProgress? progress,
  DelegateProgressSink? progressSink,
}) async {
  StatefulAgent? agent;
  final cancelToken = CancelToken();
  try {
    agent = createSuperAgentChild(
      config: config,
      client: client,
      modelConfig: modelConfig,
      userId: userId,
      progress: progress,
      progressSink: progressSink,
    );

    final reminder = _buildContextReminder(config.contextPacket);
    final initialParts = <UserContentPart>[
      TextPart(reminder),
      TextPart(config.taskBrief),
    ];
    final imageFsPaths = <String>[];
    for (var i = 0; i < config.imageAttachments.length; i++) {
      final attachment = config.imageAttachments[i];
      final inline = attachment.inline;
      initialParts.add(TextPart(
        buildAgentImageAttachmentReminder(
          i,
          attachment.image,
          imageLoaded: inline != null && inline.base64Data.isNotEmpty,
        ),
      ));
      if (inline != null && inline.base64Data.isNotEmpty) {
        initialParts.add(ImagePart(inline.base64Data, inline.mimeType));
        imageFsPaths.add(attachment.image.fsFilename);
      }
    }
    final initial = UserMessage(
      initialParts,
      metadata: {
        if (imageFsPaths.isNotEmpty) 'image_fs_paths': imageFsPaths,
      },
    );

    final messages = await agent.run([initial],
        cancelToken: cancelToken, useStream: false).timeout(config.timeout);

    final terminalResult = _terminalResultFromMessages(messages);
    if (terminalResult != null) {
      _logger.info(
          'Child ${config.childName} finished: status=${terminalResult.status.name}');
      return terminalResult.copyWith(
        childName: config.childName,
        childSessionId: agent.state.sessionId,
      );
    }

    final finalText = _lastText(messages);
    final status = _statusFromPlainText(finalText);

    _logger.info('Child ${config.childName} finished: status=${status.name}');

    return SuperAgentChildResult(
      childName: config.childName,
      status: status,
      summary: finalText,
      childSessionId: agent.state.sessionId,
    );
  } on TimeoutException {
    final message = 'child timed out after ${_formatTimeout(config.timeout)}';
    if (!cancelToken.isCancelled) {
      cancelToken.cancel(message);
    }
    await _markChildCancelled(agent, message);
    _logger.warning('Child ${config.childName} timed out');
    return SuperAgentChildResult.failed(
      config.childName,
      message,
      childSessionId: agent?.state.sessionId,
    );
  } catch (e, st) {
    _logger.severe('Child ${config.childName} errored', e, st);
    return SuperAgentChildResult.failed(
      config.childName,
      e.toString(),
      childSessionId: agent?.state.sessionId,
    );
  }
}

String _formatTimeout(Duration timeout) {
  if (timeout.inSeconds >= 1) return '${timeout.inSeconds}s';
  return '${timeout.inMilliseconds}ms';
}

Future<void> _markChildCancelled(StatefulAgent? agent, String reason) async {
  if (agent == null) return;
  agent.state.metadata['child_cancelled'] = true;
  agent.state.metadata['child_cancel_reason'] = reason;
  agent.state.metadata['child_cancelled_at'] = DateTime.now().toIso8601String();
  agent.state.lastError = reason;
  agent.state.isRunning = false;
  try {
    await saveAgentState(agent.state);
  } catch (e) {
    _logger.warning('Failed to save cancelled child state: $e');
  }
}

String _lastText(List<LLMMessage> messages) {
  for (var i = messages.length - 1; i >= 0; i--) {
    final m = messages[i];
    if (m is ModelMessage && (m.textOutput?.trim().isNotEmpty ?? false)) {
      return m.textOutput!.trim();
    }
  }
  return '';
}

SuperAgentChildResult? _terminalResultFromMessages(List<LLMMessage> messages) {
  for (var i = messages.length - 1; i >= 0; i -= 1) {
    final message = messages[i];
    if (message is! FunctionExecutionResultMessage) continue;
    for (var j = message.results.length - 1; j >= 0; j -= 1) {
      final result = message.results[j];
      if (result.isError) continue;
      final metadata = result.metadata;
      final raw = metadata?['child_terminal_result'];
      if (raw is! Map) continue;
      final terminal = Map<String, dynamic>.from(raw);
      final summary = terminal['summary']?.toString().trim();
      if (summary == null || summary.isEmpty) continue;
      return SuperAgentChildResult(
        childName: '',
        status: _statusFromWire(terminal['status']?.toString()),
        summary: summary,
        structured: terminal,
      );
    }
  }
  return null;
}

SuperAgentChildStatus _statusFromPlainText(String text) {
  final normalized = text.toLowerCase().replaceAll('-', '_');
  if (normalized.contains('needs_parent_input') ||
      normalized.contains('needs parent input')) {
    return SuperAgentChildStatus.needsParentInput;
  }
  if (normalized.contains('no_op') || normalized.contains('no op')) {
    return SuperAgentChildStatus.noOp;
  }
  if (normalized.contains('failed') || normalized.contains('error')) {
    return SuperAgentChildStatus.failed;
  }
  return text.trim().isEmpty
      ? SuperAgentChildStatus.failed
      : SuperAgentChildStatus.completed;
}

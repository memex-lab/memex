import 'package:dart_agent_core/dart_agent_core.dart';

// Tool executable parameter names mirror JSON schema keys.
// ignore_for_file: non_constant_identifier_names

import 'package:memex/agent/skills/dynamic_timeline_ui/dynamic_timeline_ui_skill.dart';
import 'package:memex/agent/skills/knowledge_insight/knowledge_insight_skill.dart';
import 'package:memex/agent/skills/manage_pkm/pkm_skill.dart';
import 'package:memex/agent/skills/manage_timeline_card/timeline_card_skill.dart';
import 'package:memex/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart';
import 'package:memex/agent/skills/timeline_diagnostics/timeline_diagnostics_skill.dart';
import 'package:memex/agent/super_agent/subagent/delegate_progress.dart';
import 'package:memex/agent/super_agent/subagent/super_agent_child.dart';
import 'package:memex/data/services/asset_reference_service.dart';
import 'package:memex/data/services/image_exif_context.dart';
import 'package:memex/data/services/location_context_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:uuid/uuid.dart';

final _logger = getLogger('DelegateSubagent');
const _uuid = Uuid();

/// A fixed child-agent shape SuperAgent may delegate to, plus the
/// security-relevant workspace roots that child may READ/WRITE.
///
/// The model chooses only a preset [agent_type]. Skills, activation mode,
/// file-tool access, and file scope are decided here in code, never by the
/// model — so a delegated child can never invent a broader combination.
class _SubagentPreset {
  final String childName;
  final String description;
  final ChildToolProfile toolProfile;
  final List<Skill> Function() buildSkills;
  final List<String> readRoots;
  final List<String> writeRoots;

  const _SubagentPreset({
    required this.childName,
    required this.description,
    required this.toolProfile,
    required this.buildSkills,
    this.readRoots = const [],
    this.writeRoots = const [],
  });
}

/// Registry of supported child agents. Keep this aligned with the agent types
/// described in [superAgentSystemPrompt].
final Map<String, _SubagentPreset> _subagentPresets = {
  'timeline_card': _SubagentPreset(
    childName: 'timeline_card_child',
    description:
        'Creates or updates Timeline Cards. Skills: manage_timeline_card active, dynamic_timeline_ui available.',
    toolProfile: ChildToolProfile.none,
    buildSkills: () => [
      TimelineCardSkill(forceActivate: true),
      DynamicTimelineUiSkill(forceActivate: false),
    ],
    writeRoots: const ['/_UserSettings/Templates'],
  ),
  'pkm': _SubagentPreset(
    childName: 'pkm_child',
    description:
        'Organizes information into the P.A.R.A knowledge base. Skills: manage_pkm active.',
    toolProfile: ChildToolProfile.full,
    buildSkills: () =>
        [PkmSkill(forceActivate: true, workingDirectory: '/PKM')],
    readRoots: const ['/PKM'],
    writeRoots: const ['/PKM'],
  ),
  'knowledge_insight': _SubagentPreset(
    childName: 'knowledge_insight_child',
    description:
        'Builds or revises cross-record Knowledge Insight cards. Skills: update_knowledge_insight active.',
    toolProfile: ChildToolProfile.read,
    buildSkills: () => [KnowledgeInsightSkill(forceActivate: true)],
  ),
  'schedule': _SubagentPreset(
    childName: 'schedule_child',
    description:
        'Updates schedule aggregation state and presentation. Skills: update_schedule_aggregation active.',
    toolProfile: ChildToolProfile.none,
    buildSkills: () => [ScheduleAggregationSkill(forceActivate: true)],
  ),
  'timeline_diagnostics': _SubagentPreset(
    childName: 'timeline_diagnostics_child',
    description:
        'Finds and inspects Timeline Cards for diagnosis or repair. Skills: timeline_diagnostics active.',
    toolProfile: ChildToolProfile.read,
    buildSkills: () => [TimelineDiagnosticsSkill()..forceActivate = true],
  ),
  'research': _SubagentPreset(
    childName: 'research_child',
    description:
        'Read-only workspace research. Skills: none; uses read-only file tools.',
    toolProfile: ChildToolProfile.read,
    buildSkills: () => const [],
  ),
};

/// Builds the generic `delegate_to_subagent` tool: spawn ONE temporary child
/// worker from a fixed [agent_type] preset, hand it a bounded task, and return
/// its structured result.
///
/// This is a general delegation primitive, NOT a record-capture pipeline.
/// SuperAgent decides how many children to run and how to shape each. To run
/// several in PARALLEL, emit multiple `delegate_to_subagent` calls in the SAME
/// turn — the agent loop executes a turn's tool calls concurrently. The parent
/// owns merging the results and the final user-facing reply.
Tool buildDelegateToSubagentTool() {
  final agentTypes = _subagentPresets.keys.toList(growable: false);
  final agentTypeDescriptions = _subagentPresets.entries
      .map((entry) => '${entry.key}: ${entry.value.description}')
      .join(' ');
  return Tool(
    name: 'delegate_to_subagent',
    description:
        'Delegate ONE bounded task to a temporary child worker and get back a '
        'structured result. A bounded task may contain several related records '
        'for the same specialist when they fit the context window. The worker '
        'is a specialist: it brings its own skill expertise, its own file tools '
        'to inspect the workspace, and the current time and location from its '
        'runtime. It cannot see this conversation, so the `task_brief` supplies '
        'what only you have — but you state the goal, not the procedure, and let '
        'its skill decide how. Example: say "Record the user\'s shared event"; '
        'not "save it under a specific folder, use a specific template, and '
        'assign a category". To run workers in parallel, emit several '
        'delegate_to_subagent calls in the same turn. '
        'A worker may return `no_op` when its branch does not apply — that is '
        'normal. Supported agent_type values: $agentTypeDescriptions',
    parameters: {
      'type': 'object',
      'properties': {
        'task_brief': {
          'type': 'string',
          'description': 'What the worker should accomplish and the context only you can '
              "provide: the record(s) in the user's own words, any fact_id(s) "
              'you minted (for multiple records, include a clear record -> '
              'fact_id mapping), and a description + exact bare `fs://...` id for any '
              'attachment the worker cannot see. State the goal, not the steps — do not '
              'spell out which template, which PKM file/directory, or how to '
              'structure the entry (the skill decides that), and do not '
              'include the current time or location (the runtime gives the '
              'worker its own). Do not reference "the above" or prior turns.',
        },
        'agent_type': {
          'type': 'string',
          'description':
              'Which child agent to run. Supported values: $agentTypeDescriptions',
          'enum': agentTypes,
        },
      },
      'required': ['task_brief', 'agent_type'],
    },
    executable: (
      String task_brief,
      String agent_type,
    ) async {
      final context = AgentCallToolContext.current;
      if (context == null) {
        throw StateError(
            'delegate_to_subagent must be called within an agent execution context.');
      }
      final userId = context.state.metadata['userId'] as String;
      final parent = context.agent;

      final preset = _subagentPresets[agent_type];
      if (preset == null) {
        throw ArgumentError(
          'Unknown agent_type "$agent_type". Supported values: ${agentTypes.join(', ')}.',
        );
      }

      // Location is an environment fact the model can't reliably know, so the
      // runtime fetches and injects it — never passed as a tool arg. (The
      // child's processing time is stamped at render time as "Current Local
      // Time"; the per-image capture time comes from EXIF below.)
      final contextPacket = <String, dynamic>{
        'parent_session_id': context.state.sessionId,
      };
      try {
        final loc = await LocationContextService.instance.getCurrentContext();
        final reminder = loc.toAgentSystemReminderContent();
        if (reminder != null && reminder.trim().isNotEmpty) {
          contextPacket['location_reminder'] = reminder.trim();
        }
      } catch (e) {
        _logger.warning('Failed to attach location context to child: $e');
      }

      // A child can't see the user's images, so its skill would otherwise build
      // cards/records with the WRONG capture time and place (it'd fall back to
      // "now" / the device's current location). Deterministically re-derive each
      // attached image's EXIF (capture time + GPS + geocoded address) from the
      // `fs://` references in the brief — the same block ChatService injects for
      // the parent — instead of trusting the parent to transcribe it.
      final exifBlocks = <String>[];
      final missingAssetRefs = <String>[];
      for (final ref in AssetReferenceService.extractReferences(task_brief)) {
        final asset = await AssetReferenceService.resolveExisting(
          userId: userId,
          reference: ref,
        );
        if (asset == null) {
          missingAssetRefs.add(ref);
          continue;
        }
        try {
          final block = await buildImageExifInfo(userId, asset.absolutePath);
          if (block != null && block.trim().isNotEmpty) {
            exifBlocks.add('${asset.fileName} —\n$block');
          }
        } catch (e) {
          _logger.warning('Failed to derive EXIF for ${asset.fileName}: $e');
        }
      }
      if (missingAssetRefs.isNotEmpty) {
        throw ArgumentError(
          'task_brief contains attachment refs that do not resolve to existing '
          'supported files under Facts/assets: ${missingAssetRefs.join(', ')}',
        );
      }
      if (exifBlocks.isNotEmpty) {
        contextPacket['attachment_exif'] = exifBlocks;
      }

      final config = SuperAgentChildConfig(
        childName: preset.childName,
        taskBrief: task_brief,
        skills: preset.buildSkills(),
        toolProfile: preset.toolProfile,
        readRootPaths: preset.readRoots,
        writeRootPaths: preset.writeRoots,
        contextPacket: contextPacket,
      );

      _logger
          .info('Delegating to ${preset.childName} (agent_type=$agent_type)');

      final progressSink = DelegateProgressContext.current;
      final progress = progressSink == null
          ? null
          : DelegateProgress(
              delegateRunId: _uuid.v4(),
              childName: preset.childName,
              taskBrief: task_brief,
            );
      if (progress != null) {
        progressSink!.delegateStarted(progress);
      }

      // runSuperAgentChild never throws — a failed/timed-out child returns a
      // `failed` result so the parent can still merge.
      final result = await runSuperAgentChild(
        config: config,
        client: parent.client,
        modelConfig: parent.modelConfig,
        userId: userId,
        progress: progress,
        progressSink: progressSink,
      );
      if (progress != null) {
        progressSink!.delegateFinished(
          progress: progress,
          status: result.status.name,
          summary: result.summary,
        );
      }

      return AgentToolResult(
        content: TextPart(
            '[${preset.childName}] status=${result.status.name}\n${result.summary}'),
        metadata: {'child_result': result.toJson()},
      );
    },
  );
}

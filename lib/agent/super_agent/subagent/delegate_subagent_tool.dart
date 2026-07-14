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
import 'package:memex/data/services/agent_image_attachment.dart';
import 'package:memex/data/services/asset_reference_service.dart';
import 'package:memex/data/services/file_system_service.dart';
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
      TimelineCardSkill(
        forceActivate: true,
        enableFinishSummary: true,
      ),
      DynamicTimelineUiSkill(forceActivate: false),
    ],
    writeRoots: const ['/_UserSettings/Templates'],
  ),
  'pkm': _SubagentPreset(
    childName: 'pkm_child',
    description:
        'Organizes information into the P.A.R.A knowledge base. Skills: manage_pkm active.',
    toolProfile: ChildToolProfile.full,
    buildSkills: () => [
      PkmSkill(
        forceActivate: true,
        workingDirectory: '/PKM',
        enableFinishSummary: true,
      )
    ],
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
        'runtime. It cannot see this conversation, so `task_content` supplies '
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
        'task_content': {
          'type': 'array',
          'description':
              'Ordered content blocks for the worker. Use text blocks for the '
                  "worker's goal and the context only you can provide: the "
                  "record(s) in the user's own words, any fact_id(s) you minted "
                  '(for multiple records, include a clear record -> fact_id '
                  'mapping). Use asset blocks for every attachment the worker '
                  'should receive. A child agent can directly see images from '
                  'image asset blocks, so there is no need to describe image '
                  'contents in detail in text blocks. State the goal, not the '
                  'steps — do not spell '
                  'out which template, which PKM file/directory, or how to '
                  'structure the entry (the skill decides that), and do not '
                  'include the current time or location (the runtime gives the '
                  'worker its own). Do not reference "the above" or prior '
                  'turns.',
          'items': {
            'type': 'object',
            'properties': {
              'type': {
                'type': 'string',
                'description': 'Block type.',
                'enum': ['text', 'asset'],
              },
              'text': {
                'type': 'string',
                'description':
                    'For type=text: what the worker should accomplish and the '
                        'context only you can provide, including record text and '
                        'fact_id mapping. State the goal, not the procedure.',
              },
              'ref': {
                'type': 'string',
                'description':
                    'For type=asset: the exact bare attachment reference, e.g. fs://photo.jpg.',
              },
            },
            'required': ['type'],
          },
        },
        'agent_type': {
          'type': 'string',
          'description':
              'Which child agent to run. Supported values: $agentTypeDescriptions',
          'enum': agentTypes,
        },
      },
      'required': ['task_content', 'agent_type'],
    },
    parameterMode: ToolParameterMode.object,
    executable: (Map<String, dynamic> args) async {
      final context = AgentCallToolContext.current;
      if (context == null) {
        throw StateError(
            'delegate_to_subagent must be called within an agent execution context.');
      }
      final userId = context.state.metadata['userId'] as String;
      final parent = context.agent;
      final taskInput = _resolveTaskInput(args);
      final agent_type = args['agent_type']?.toString() ?? '';

      final preset = _subagentPresets[agent_type];
      if (preset == null) {
        throw ArgumentError(
          'Unknown agent_type "$agent_type". Supported values: ${agentTypes.join(', ')}.',
        );
      }

      // Location is an environment fact the model can't reliably know, so the
      // runtime fetches and injects it — never passed as a tool arg. The
      // child's processing time is stamped at render time as "Current Local
      // Time"; per-image capture time is carried by attachment reminders.
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

      final imageAttachments = <ChildImageAttachment>[];
      final missingAssetRefs = <String>[];
      for (final ref in taskInput.assetRefs) {
        final asset = await AssetReferenceService.resolveExisting(
          userId: userId,
          reference: ref,
        );
        if (asset == null) {
          missingAssetRefs.add(ref);
          continue;
        }
        if (asset.type == AssetReferenceType.image) {
          final image = await prepareStoredImageAttachment(
            userId: userId,
            absolutePath: asset.absolutePath,
            relativePath:
                FileSystemService.instance.toRelativePath(asset.absolutePath),
            fsFilename: asset.fileName,
            originalName: null,
            mimeType: mimeTypeForImagePath(asset.absolutePath),
          );
          final inline = await inlineImageForLlm(
            absolutePath: asset.absolutePath,
            fallbackMimeType: image.mimeType,
            logLabel: image.relativePath,
          );
          imageAttachments.add(ChildImageAttachment(
            image: image,
            inline: inline,
          ));
        }
      }
      if (missingAssetRefs.isNotEmpty) {
        throw ArgumentError(
          'Task content contains attachment refs that do not resolve to existing '
          'supported files under Facts/assets: ${missingAssetRefs.join(', ')}',
        );
      }

      if (agent_type == 'pkm') {
        try {
          final overview = await buildPkmOverviewForUser(userId);
          if (overview.trim().isNotEmpty) {
            contextPacket['pkm_overview'] = overview.trim();
          }
        } catch (e) {
          _logger.warning('Failed to attach PKM overview to child: $e');
        }
      }

      if (agent_type == 'timeline_card') {
        try {
          final metadata =
              await TimelineCardSkill.getTimelineCardMetadata(userId);
          if (metadata.trim().isNotEmpty) {
            contextPacket['card_metadata'] = metadata.trim();
          }
        } catch (e) {
          _logger.warning('Failed to attach card metadata to child: $e');
        }
      }

      final config = SuperAgentChildConfig(
        childName: preset.childName,
        taskBrief: taskInput.taskBrief,
        skills: preset.buildSkills(),
        toolProfile: preset.toolProfile,
        readRootPaths: preset.readRoots,
        writeRootPaths: preset.writeRoots,
        contextPacket: contextPacket,
        imageAttachments: imageAttachments,
      );

      _logger
          .info('Delegating to ${preset.childName} (agent_type=$agent_type)');

      final progressSink = DelegateProgressContext.current;
      final progress = progressSink == null
          ? null
          : DelegateProgress(
              delegateRunId: _uuid.v4(),
              childName: preset.childName,
              taskBrief: taskInput.taskBrief,
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
        content: TextPart(_formatSubagentResultForParent(
          agentType: agent_type,
          result: result,
        )),
        metadata: {'child_result': result.toJson()},
      );
    },
  );
}

class _TaskInput {
  const _TaskInput({
    required this.taskBrief,
    required this.assetRefs,
  });

  final String taskBrief;
  final List<String> assetRefs;
}

_TaskInput _resolveTaskInput(Map<String, dynamic> args) {
  final rawContent = args['task_content'];
  if (rawContent is List && rawContent.isNotEmpty) {
    return _resolveStructuredTaskInput(rawContent);
  }
  throw ArgumentError(
    'delegate_to_subagent requires non-empty task_content.',
  );
}

_TaskInput _resolveStructuredTaskInput(List<dynamic> rawContent) {
  final parts = <String>[];
  final assetRefs = <String>[];
  final seenAssetRefs = <String>{};

  for (var i = 0; i < rawContent.length; i++) {
    final rawItem = rawContent[i];
    if (rawItem is! Map) {
      throw ArgumentError('task_content[$i] must be an object.');
    }
    final item = Map<String, dynamic>.from(rawItem);
    final type = item['type']?.toString();
    switch (type) {
      case 'text':
        final text = item['text']?.toString().trim();
        if (text == null || text.isEmpty) {
          throw ArgumentError('task_content[$i].text is required.');
        }
        parts.add(text);
        break;
      case 'asset':
        final ref = item['ref']?.toString().trim();
        if (ref == null || ref.isEmpty) {
          throw ArgumentError('task_content[$i].ref is required.');
        }
        final normalized = _normalizeAssetRef(ref, 'task_content[$i].ref');
        if (seenAssetRefs.add(normalized)) {
          assetRefs.add(normalized);
        }
        parts.add('Attachment: $normalized');
        break;
      default:
        throw ArgumentError(
          'task_content[$i].type must be "text" or "asset".',
        );
    }
  }

  final taskBrief = parts.join('\n\n').trim();
  if (taskBrief.isEmpty) {
    throw ArgumentError('task_content must include at least one usable block.');
  }
  return _TaskInput(taskBrief: taskBrief, assetRefs: assetRefs);
}

String _normalizeAssetRef(String ref, String fieldName) {
  final fileName = AssetReferenceService.extractFileNameFromReference(ref);
  if (fileName == null) {
    throw ArgumentError('$fieldName must be a supported fs:// attachment ref.');
  }
  return 'fs://$fileName';
}

String _formatSubagentResultForParent({
  required String agentType,
  required SuperAgentChildResult result,
}) {
  return '<subagent_result agent_type="${_escapeAttr(agentType)}" '
      'status="${result.status.name}">\n'
      '${result.summary.trim()}\n'
      '</subagent_result>';
}

String _escapeAttr(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

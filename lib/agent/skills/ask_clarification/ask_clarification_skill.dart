import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:logging/logging.dart';
import 'package:memex/data/services/clarification_request_service.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = Logger('AskClarificationSkill');

class AskClarificationSkill extends Skill {
  AskClarificationSkill({super.forceActivate})
      : super(
          name: 'ask_clarification',
          description:
              'Ask the user a short clarification question when missing information would materially affect memory accuracy, entity understanding, relationship mapping, PKM organization, or insight quality. '
              'Use when context is ambiguous, a person/place/project identity is unclear, a preference or relationship cannot be confidently inferred, or a fact correction needs user confirmation. ',
          systemPrompt: _buildSystemPrompt(),
          tools: _buildTools(),
        );

  static String _buildSystemPrompt() {
    return '''## Skill Name
`ask_clarification`

## Purpose
Use this skill when a small answer from the user would materially improve future memory, entity understanding, PKM organization, card corrections, or insight quality.

## Rules
1. Ask only high-impact questions. Do not create trivia, curiosity, or low-value questions.
2. Prefer one-tap questions: `confirm`, `single_choice`, or `multi_choice`. Use `short_text` only when choices are genuinely insufficient.
3. Include evidence fact IDs whenever available.
4. Use `get_recent_clarification_requests` before creating a likely duplicate, and decide semantic duplication yourself.
5. Include a stable `dedupe_key` as a lightweight hint for active duplicate suppression, such as `person:xiaozhang:relationship`.
6. Do not ask if the answer can be inferred confidently from existing context.
7. Respect user memory or recent chat preferences about clarification frequency. If the user says questions feel too frequent, ask only for critical, high-impact uncertainty. If the user asks for more proactive confirmation, you may ask slightly more often.
8. Do not block the current task; creating a clarification request is enough.
9. Keep the question short and in the user's language.
${UserStorage.l10n.userLanguageInstruction}
10. Use `proposed_memory` only for stable facts worth retaining, and write it with an `{answer}` placeholder when the answer should be inserted.
11. Do not create generic escape-hatch options like "Other", "Manual input", "Unknown", "Not sure", or "Prefer not to say"; the app UI supplies these affordances.
12. Do not attach a `memory` field to vague options like "Other", "Unknown", "Not sure", or "Prefer not to say".
13. Option `memory` values must be literal, conservative facts. Do not invent a more specific category than the label says.
''';
  }

  static List<Tool> _buildTools() {
    return [
      Tool(
        name: 'create_clarification_request',
        description:
            'Create a short question for the user to answer later in the app.',
        parameters: {
          'type': 'object',
          'properties': {
            'question': {
              'type': 'string',
              'description': 'Short user-facing question.',
            },
            'response_type': {
              'type': 'string',
              'enum': [
                ClarificationResponseType.confirm,
                ClarificationResponseType.singleChoice,
                ClarificationResponseType.multiChoice,
                ClarificationResponseType.shortText,
              ],
            },
            'options': {
              'type': 'array',
              'description':
                  'Choices for confirm/single_choice/multi_choice. Each item may contain id, label, value, and memory.',
              'items': {
                'type': 'object',
                'properties': {
                  'id': {'type': 'string'},
                  'label': {'type': 'string'},
                  'value': {'type': 'string'},
                  'memory': {'type': 'string'},
                },
                'required': ['label'],
              },
            },
            'entity_type': {
              'type': 'string',
              'description': 'person, place, project, preference, or custom.',
            },
            'entity_label': {
              'type': 'string',
              'description': 'The entity being clarified, such as John.',
            },
            'evidence_fact_ids': {
              'type': 'array',
              'items': {'type': 'string'},
            },
            'reason': {
              'type': 'string',
              'description': 'Short explanation of why this is being asked.',
            },
            'impact': {
              'type': 'string',
              'description': 'What future behavior this answer will improve.',
            },
            'confidence': {
              'type': 'number',
              'description': 'Current confidence before asking, from 0 to 1.',
            },
            'proposed_memory': {
              'type': 'string',
              'description':
                  'Optional memory template, e.g. "John is the user\'s {answer}."',
            },
            'resolution_target': {
              'type': 'string',
              'enum': ['auto', 'memory', 'pkm', 'card', 'insight', 'none'],
            },
            'dedupe_key': {
              'type': 'string',
              'description':
                  'Stable hint for active duplicate suppression; semantic duplicate judgment remains your responsibility.',
            },
            'expires_in_days': {
              'type': 'integer',
              'description': 'Optional expiration window.',
            },
          },
          'required': ['question', 'response_type'],
        },
        executable: (
          String question,
          String responseType,
          List? options,
          String? entityType,
          String? entityLabel,
          List? evidenceFactIds,
          String? reason,
          String? impact,
          num? confidence,
          String? proposedMemory,
          String? resolutionTarget,
          String? dedupeKey,
          int? expiresInDays,
        ) async {
          try {
            final context = AgentCallToolContext.current;
            final factId = context?.state.metadata['factId'] as String?;
            final sourceAgent =
                context?.state.metadata['agentName'] as String? ?? 'agent';

            final normalizedOptions = <Map<String, dynamic>>[];
            for (var i = 0; i < (options?.length ?? 0); i++) {
              final raw = options![i];
              if (raw is! Map) continue;
              final option = Map<String, dynamic>.from(raw);
              final label = option['label']?.toString().trim();
              if (label == null || label.isEmpty) continue;
              option['id'] =
                  (option['id']?.toString().trim().isNotEmpty ?? false)
                      ? option['id'].toString()
                      : 'option_${i + 1}';
              option['label'] = label;
              normalizedOptions.add(option);
            }

            final normalizedEvidenceFactIds = evidenceFactIds
                ?.map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList();

            final expiresAt = expiresInDays == null
                ? null
                : DateTime.now()
                        .add(Duration(days: expiresInDays))
                        .millisecondsSinceEpoch ~/
                    1000;

            final result = await ClarificationRequestService.instance
                .createRequestWithResult(
              question: question,
              responseType: responseType,
              options: normalizedOptions.isEmpty ? null : normalizedOptions,
              entityType: entityType,
              entityLabel: entityLabel,
              evidenceFactIds: normalizedEvidenceFactIds,
              reason: reason,
              impact: impact,
              confidence: confidence?.toDouble(),
              proposedMemory: proposedMemory,
              resolutionTarget: resolutionTarget,
              sourceAgent: sourceAgent,
              dedupeKey: dedupeKey,
              factId: factId,
              expiresAt: expiresAt,
            );

            final status = result.created ? 'created' : 'existing';
            return AgentToolResult(
              content: TextPart(
                'Clarification request $status: '
                'request_id=${result.id}; '
                'created=${result.created}; '
                'dedupe_key=${result.dedupeKey ?? '-'}',
              ),
            );
          } catch (e, st) {
            _logger.severe('Failed to create clarification request', e, st);
            rethrow;
          }
        },
      ),
      Tool(
        name: 'get_pending_clarification_requests',
        description:
            'List pending clarification requests to avoid asking duplicates.',
        parameters: {'type': 'object', 'properties': {}},
        executable: () async {
          try {
            final requests =
                await ClarificationRequestService.instance.watchPending().first;
            if (requests.isEmpty) {
              return AgentToolResult(
                content: TextPart('No pending clarification requests.'),
              );
            }
            final buffer = StringBuffer();
            for (final request in requests.take(20)) {
              buffer.writeln(
                '- ID: ${request.id} | Entity: ${request.entityLabel ?? '-'} | Question: ${request.question}',
              );
            }
            return AgentToolResult(content: TextPart(buffer.toString()));
          } catch (e, st) {
            _logger.severe('Failed to list clarification requests', e, st);
            rethrow;
          }
        },
      ),
      Tool(
        name: 'get_recent_clarification_requests',
        description:
            'List recent clarification requests, including answered and dismissed ones, so you can decide semantic duplication.',
        parameters: {
          'type': 'object',
          'properties': {
            'limit': {
              'type': 'integer',
              'description': 'Maximum number of requests to list.',
            },
          },
        },
        executable: (int? limit) async {
          try {
            final requests = await ClarificationRequestService.instance
                .getRecentRequests(limit: limit ?? 20);
            if (requests.isEmpty) {
              return AgentToolResult(
                content: TextPart('No recent clarification requests.'),
              );
            }
            final buffer = StringBuffer();
            for (final request in requests) {
              buffer.writeln(
                '- ID: ${request.id} | Status: ${request.status} | Entity: ${request.entityLabel ?? '-'} | Dedupe: ${request.dedupeKey ?? '-'} | Question: ${request.question}',
              );
            }
            return AgentToolResult(content: TextPart(buffer.toString()));
          } catch (e, st) {
            _logger.severe(
                'Failed to list recent clarification requests', e, st);
            rethrow;
          }
        },
      ),
    ];
  }
}

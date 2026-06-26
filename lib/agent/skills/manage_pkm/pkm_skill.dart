import 'dart:io';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:path/path.dart' as p;

// Tool executable parameter names mirror JSON schema keys.
// ignore_for_file: non_constant_identifier_names

/// Skill for PKM Agent - organizes user input into P.A.R.A knowledge base structure
class PkmSkill extends Skill {
  /// When provided, [stopAfterUpdateCardInsightRef] must be a single-element
  /// list; read tool sets ref[0] = false when it returns system-reminder so
  /// update_card_insight won't stop the agent (model can fix structure).
  PkmSkill({
    super.forceActivate,
    List<bool>? stopAfterUpdateCardInsightRef,
    bool enableFinishSummary = false,
    String? workingDirectory,
  }) : super(
          name: "manage_pkm", // Renamed to capability-focused name
          description:
              "Organizes user input into P.A.R.A (Projects, Areas, Resources, Archive) knowledge base structure. "
              "Extracts information from diverse inputs and organizes them systematically. "
              "Also updates card insights.",
          systemPrompt: Prompts.pkmSkillSystemPrompt(
            workingDirectory ?? '/',
            UserStorage.l10n.pkmPARAStructureExample,
            UserStorage.l10n.pkmFileLanguageInstruction,
            UserStorage.l10n.pkmInsightLanguageInstruction,
          ),
          tools: _buildTools(
            stopAfterUpdateCardInsightRef,
            enableFinishSummary: enableFinishSummary,
          ),
        );

  static List<Tool> _buildTools(
    List<bool>? stopAfterUpdateCardInsightRef, {
    required bool enableFinishSummary,
  }) {
    final logger = getLogger('PkmSkill');
    final updateInsightParameters = Map<String, dynamic>.from(
        Prompts.pkmSkillUpdateCardInsightToolParameters);
    final updateInsightProperties =
        Map<String, dynamic>.from(updateInsightParameters['properties'] as Map);
    if (enableFinishSummary) {
      updateInsightProperties['finish_summary'] = {
        'type': 'string',
        'description':
            'If this successful update completes the requested work, set this to the exact concise final summary to return. Include relevant work already done in this run. Omit it if another tool call, inspection, or repair is still needed.',
      };
    }
    updateInsightParameters['properties'] = updateInsightProperties;

    final getPkmOverviewTool = Tool(
      name: 'get_pkm_overview',
      description:
          'Get current directory structure and file information of the PKM knowledge base.',
      parameters: {
        'type': 'object',
        'properties': {},
      },
      executable: () async {
        final context = AgentCallToolContext.current;
        if (context == null) {
          throw StateError(
              "get_pkm_overview must be called within an agent execution context.");
        }
        final userId = context.state.metadata['userId'] as String;
        return buildPkmOverviewForUser(userId);
      },
    );

    return [
      getPkmOverviewTool,
      Tool(
        name: 'update_timeline_card_insight',
        description: Prompts.pkmSkillUpdateCardInsightToolDescription,
        parameters: updateInsightParameters,
        executable: (
          String fact_id,
          String insight_text,
          List? related_fact_ids, [
          String? finish_summary,
        ]) async {
          final context = AgentCallToolContext.current;
          if (context == null) {
            throw StateError(
                "update_timeline_card_insight must be called within an agent execution context.");
          }
          final userId = context.state.metadata['userId'] as String;
          final fileService = FileSystemService.instance;

          final denied = await gateMutatingToolCall(
            toolName: 'update_timeline_card_insight',
            summary: fact_id,
            details: {
              'insight': insight_text.length > 120
                  ? '${insight_text.substring(0, 120)}…'
                  : insight_text,
            },
          );
          if (denied != null) return denied;

          // Validate the target card exists. fact_id identity now lives on the
          // card itself (Cards/*.yaml), not in a Facts file — so check the card,
          // and never create a phantom card from a wrong/hallucinated id.
          CardData? existingCard;
          try {
            existingCard = await fileService.readCardFile(userId, fact_id);
          } catch (e) {
            throw ArgumentError(
                "Invalid fact_id '$fact_id'. Expected format 2026/01/20.md#ts_5, referencing an existing card.");
          }
          if (existingCard == null) {
            throw ArgumentError(
                "Card $fact_id does not exist. update_timeline_card_insight only updates an existing card's insight; create the card with save_timeline_card first.");
          }

          // Validate related_fact_ids: drop self-references and any id that does
          // not resolve to a real card (the model must not guess fact_ids).
          final droppedRelated = <String>[];
          final validRelated = <String>[];
          for (final rid in (related_fact_ids ?? const [])) {
            final id = rid?.toString().trim() ?? '';
            if (id.isEmpty || id == fact_id) continue;
            CardData? relatedCard;
            try {
              relatedCard = await fileService.readCardFile(userId, id);
            } catch (_) {
              relatedCard = null;
            }
            if (relatedCard != null) {
              validRelated.add(id);
            } else {
              droppedRelated.add(id);
            }
          }
          if (droppedRelated.isNotEmpty) {
            logger.warning(
                'update_timeline_card_insight dropped non-existent related_fact_ids: ${droppedRelated.join(', ')}');
          }

          final relatedCount = validRelated.length;
          final cardPath = fileService.getCardPath(userId, fact_id);

          final relatedFacts =
              validRelated.map((id) => RelatedFact(id: id)).toList();
          final insightData = CardInsight(
            characterId: '0',
            text: insight_text,
            relatedFacts: relatedFacts,
          );

          final updatedCardData = await fileService.updateCardFile(
            userId,
            fact_id,
            (card) => card.copyWith(insight: insightData),
          );

          final isSubAgent = context.state.metadata['sub_agent_mode'] == true;
          final hasFinishSummary =
              finish_summary != null && finish_summary.trim().isNotEmpty;
          final stopFlag = (stopAfterUpdateCardInsightRef != null
                  ? stopAfterUpdateCardInsightRef[0]
                  : false) ||
              (isSubAgent && hasFinishSummary);

          if (updatedCardData == null) {
            logger.warning(
                "Card file not found for fact_id: $fact_id, maybe it has been deleted");
            throw StateError(
                Prompts.pkmSkillUpdateCardInsightErrorCardNotFound(fact_id));
          }

          // Notify detail page to refresh after insight update
          EventBusService.instance.emitEvent(CardDetailUpdatedMessage(
            cardId: fact_id,
          ));

          return AgentToolResult(
            content: TextPart(Prompts.pkmSkillUpdateCardInsightSuccess(
                cardPath, fact_id, relatedCount)),
            stopFlag: stopFlag,
            metadata: {
              if (isSubAgent && hasFinishSummary)
                'child_terminal_result': {
                  'status': 'completed',
                  'summary': finish_summary.trim(),
                  'fact_id': fact_id,
                  'pkm_changed': true,
                  'related_count': relatedCount,
                },
            },
          );
        },
      ),
      Tool(
        name: 'skip_pkm_organization',
        description: Prompts.pkmSkillSkipOrganizationToolDescription,
        parameters: Prompts.pkmSkillSkipOrganizationToolParameters,
        executable: (String evidence) async {
          final context = AgentCallToolContext.current;
          final factId = context?.state.metadata['factId'];
          if (context != null) {
            context.state.metadata['skippedPkm'] = true;
            context.state.metadata['pkmSkipEvidence'] = evidence;
          }
          logger.info(
            'Skipping PKM organization for fact_id=$factId, evidence=$evidence',
          );

          return AgentToolResult(
            content: TextPart(
              'PKM organization skipped. evidence=$evidence',
            ),
            stopFlag: true,
            metadata: {
              'child_terminal_result': {
                'status': 'no_op',
                'summary': 'PKM organization skipped. evidence=$evidence',
                if (factId is String) 'fact_id': factId,
                'pkm_changed': false,
              },
            },
          );
        },
      ),
    ];
  }
}

Future<String> buildPkmOverviewForUser(
  String userId, {
  int maxEntries = 800,
}) {
  return buildPkmOverview(
    pkmRootPath: FileSystemService.instance.getPkmPath(userId),
    maxEntries: maxEntries,
  );
}

Future<String> buildPkmOverview({
  required String pkmRootPath,
  int maxEntries = 800,
}) async {
  try {
    final rootType =
        await FileSystemEntity.type(pkmRootPath, followLinks: false);
    if (rootType == FileSystemEntityType.notFound) {
      return 'P.A.R.A. knowledge base has not been created yet, currently empty.';
    }
    if (rootType != FileSystemEntityType.directory) {
      return _formatPkmOverviewError('/PKM is not a directory.');
    }

    return _buildPkmOverviewTree(
      root: Directory(pkmRootPath),
      maxEntries: maxEntries,
    );
  } catch (e) {
    return _formatPkmOverviewError(e.toString());
  }
}

Future<String> _buildPkmOverviewTree({
  required Directory root,
  required int maxEntries,
}) async {
  final buffer = StringBuffer()
    ..writeln('PKM structure tree')
    ..writeln('Root: /PKM')
    ..writeln('Legend: directories end with /')
    ..writeln();

  var directoryCount = 1;
  var fileCount = 0;
  var emitted = 0;
  var truncated = false;

  buffer.writeln('/PKM/');

  Future<void> visit(Directory dir, int depth) async {
    if (truncated) return;

    final children = <FileSystemEntity>[];
    try {
      await for (final entity
          in dir.list(recursive: false, followLinks: false)) {
        final name = p.basename(entity.path);
        if (name.startsWith('.')) continue;
        children.add(entity);
      }
    } catch (e) {
      buffer.writeln('${'  ' * depth}(unreadable: $e)');
      return;
    }

    children.sort((a, b) {
      final aIsDir = a is Directory;
      final bIsDir = b is Directory;
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
      return p.basename(a.path).compareTo(p.basename(b.path));
    });

    if (children.isEmpty && depth == 1) {
      buffer.writeln('  (empty)');
      return;
    }

    for (final child in children) {
      if (emitted >= maxEntries) {
        truncated = true;
        buffer
            .writeln('${'  ' * depth}... truncated after $maxEntries entries');
        return;
      }

      final name = p.basename(child.path);
      final isDir = child is Directory;
      buffer.writeln('${'  ' * depth}$name${isDir ? '/' : ''}');
      emitted++;

      if (isDir) {
        directoryCount++;
        await visit(child, depth + 1);
      } else {
        fileCount++;
      }
    }
  }

  await visit(root, 1);

  buffer
    ..writeln()
    ..writeln('Summary: $directoryCount directories, $fileCount files');
  if (truncated) {
    buffer
        .writeln('Note: overview truncated; use file tools to inspect deeper.');
  } else {
    buffer.writeln(
      'Note: this overview contains the complete PKM structure; usually no additional LS or Glob call is needed to inspect the tree.',
    );
  }
  return buffer.toString().trimRight();
}

String _formatPkmOverviewError(String error) =>
    'Unable to get P.A.R.A. knowledge base structure: $error';

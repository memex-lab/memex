import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/prompts.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

/// Skill for PKM Agent - organizes user input into P.A.R.A knowledge base structure
class PkmSkill extends Skill {
  /// When provided, [stopAfterUpdateCardInsightRef] must be a single-element
  /// list; read tool sets ref[0] = false when it returns system-reminder so
  /// update_card_insight won't stop the agent (model can fix structure).
  PkmSkill({
    super.forceActivate,
    List<bool>? stopAfterUpdateCardInsightRef,
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
          tools: _buildTools(stopAfterUpdateCardInsightRef),
        );

  static List<Tool> _buildTools(List<bool>? stopAfterUpdateCardInsightRef) {
    final fileService = FileSystemService.instance;
    final logger = getLogger('PkmAgent');

    return [
      Tool(
        name: 'update_timeline_card_insight',
        description: Prompts.pkmAgentUpdateCardInsightToolDescription,
        parameters: Prompts.pkmAgentUpdateCardInsightToolParameters,
        executable: (String fact_id, String insight_text, String summary_text,
            List? related_fact_ids) async {
          final context = AgentCallToolContext.current;
          if (context == null) {
            throw StateError(
                "update_timeline_card_insight must be called within an agent execution context.");
          }
          final userId = context.state.metadata['userId'] as String;

          final factInfo =
              await fileService.extractFactContentFromFile(userId, fact_id);
          if (factInfo == null) {
            throw ArgumentError(
                "fact id: $fact_id not exist, please check the fact id is correct, or create/edit fact file first, the format of fact_id is 2026/01/20.md#ts_5");
          }

          final relatedCount = related_fact_ids?.length ?? 0;
          final cardPath = fileService.getCardPath(userId, fact_id);

          final relatedFacts = (related_fact_ids != null
                  ? related_fact_ids.where((id) => id != fact_id).toList()
                  : <String>[])
              .map((id) => RelatedFact(id: id))
              .toList();
          final insightData = CardInsight(
            characterId: '0',
            text: insight_text,
            summary: summary_text,
            relatedFacts: relatedFacts,
          );

          final updatedCardData = await fileService.updateCardFile(
            userId,
            fact_id,
            createIfNotExists: true,
            (card) => card.copyWith(insight: insightData),
          );

          final stopFlag = stopAfterUpdateCardInsightRef != null
              ? stopAfterUpdateCardInsightRef[0]
              : false;

          if (updatedCardData == null) {
            logger.warning(
                "Card file not found for fact_id: $fact_id, maybe it has been deleted");
            return AgentToolResult(
              content: TextPart(
                  Prompts.pkmAgentUpdateCardInsightErrorCardNotFound(fact_id)),
              stopFlag: stopFlag,
            );
          }

          // Notify detail page to refresh after insight update
          EventBusService.instance.emitEvent(CardDetailUpdatedMessage(
            cardId: fact_id,
          ));

          return AgentToolResult(
            content: TextPart(Prompts.pkmAgentUpdateCardInsightSuccess(
                cardPath, fact_id, relatedCount)),
            stopFlag: stopFlag,
          );
        },
      ),
    ];
  }
}

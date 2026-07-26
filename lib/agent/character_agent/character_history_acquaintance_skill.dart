import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/character_agent/character_history_tools.dart';
import 'package:memex/agent/character_agent/character_workspace_tools.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/domain/models/character_model.dart';

class CharacterHistoryAcquaintanceSkill extends Skill {
  factory CharacterHistoryAcquaintanceSkill({
    required CharacterModel character,
    required String userId,
    CharacterWorkspaceService? workspaceService,
    CharacterHistoryAcquaintanceService? historyService,
  }) {
    final workspace = workspaceService ?? CharacterWorkspaceService.instance;
    final historyTools = CharacterHistoryTools(
      userId: userId,
      historyService: historyService,
    );
    return CharacterHistoryAcquaintanceSkill._(
      character: character,
      userId: userId,
      workspaceService: workspace,
      historyTools: historyTools,
    );
  }

  CharacterHistoryAcquaintanceSkill._({
    required CharacterModel character,
    required String userId,
    required CharacterWorkspaceService workspaceService,
    required CharacterHistoryTools historyTools,
  }) : super(
          name: 'character_history_acquaintance',
          description: 'Privately explore the user\'s earlier life records '
              'and form your own first memories of them.',
          systemPrompt: buildSystemPrompt(character),
          tools: [
            ...CharacterWorkspaceMemoryTools(
              userId: userId,
              characterId: character.id,
              workspaceService: workspaceService,
            ).build(),
            ...historyTools.build(),
            Tool(
              name: 'FinishAcquaintance',
              description: 'Finish this initial history visit after you have '
                  'actually browsed and selectively remembered what matters.',
              parameters: const {
                'type': 'object',
                'properties': <String, dynamic>{},
              },
              executable: () async {
                if (!historyTools.hasBrowsed) {
                  throw StateError(
                    'Browse the user history before finishing acquaintance.',
                  );
                }
                await workspaceService.completeHistoryAcquaintance(
                  userId: userId,
                  characterId: character.id,
                  completedAt: DateTime.now(),
                );
                return AgentToolResult(
                  content: TextPart('Initial history visit completed.'),
                  stopFlag: true,
                );
              },
            ),
          ],
        );

  static String buildSystemPrompt(CharacterModel character) => '''
# Getting to Know the User as ${character.name}

You are ${character.name}. You have just entered an ongoing relationship with
someone who has already recorded a substantial life before meeting you. This
is a private first visit through what they previously chose to preserve, like a
new friend looking through an older social feed. You are not producing a user
profile, report, chronology, or reply.

## Starting Identity

${character.persona.trim()}

## Explore Like This Particular Person

- Begin with `BrowseHistory`. If there are enough records, sample more than one
  period instead of reading only the newest page.
- Follow details that catch your attention because of your own personality.
  Use `SearchHistory` for concrete people, places, themes, or recurring details
  you become curious about, and `ReadHistoryMoment` only when the full moment
  matters.
- Read your existing `/Identity.md` and `/PKM` when useful so imported or newer
  memories are not duplicated.
- What you remember must be subjective and selective. Another character should
  come away with different memories from the same history.
- Use `Remember` to create or revise durable notes in your own `/PKM`. Preserve
  patterns, people, preferences, tender details, unresolved threads, and
  relationship-relevant context that could naturally matter later.
- Do not copy a feed, build a dossier, assign traits from one incident, or
  pretend you personally shared events that happened before you arrived.
- Do not send a greeting or chat message during this private visit.

Finish with `FinishAcquaintance` only after browsing and making any worthwhile
memory updates. It is valid to remember less than you read.
''';
}

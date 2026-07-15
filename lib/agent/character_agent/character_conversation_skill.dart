import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/character_agent/character_contact_action_tools.dart';
import 'package:memex/agent/character_agent/character_workspace_tools.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/domain/models/character_conversation.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/utils/tavern_macro.dart';
import 'package:memex/utils/user_storage.dart';

typedef CharacterConversationDecisionCallback = void Function(
  CharacterConversationDecision decision,
);

class CharacterConversationSkill extends Skill {
  CharacterConversationSkill({
    required CharacterModel character,
    required String userId,
    required String userName,
    required CharacterConversationContext context,
    required CharacterConversationDecisionCallback onDecision,
    CharacterWorkspaceService? workspaceService,
    super.forceActivate = true,
  }) : super(
          name: 'character_conversation',
          description: 'Respond to a natural batch of private-chat messages.',
          systemPrompt: buildSystemPrompt(
            character: character,
            userName: userName,
          ),
          tools: [
            ...CharacterWorkspaceMemoryTools(
              userId: userId,
              characterId: character.id,
              workspaceService: workspaceService,
            ).build(),
            ...CharacterContactActionTools.build(
              now: context.now,
              onSpeak: (messages) =>
                  onDecision(CharacterConversationDecision.speak(messages)),
              onThinkLater: (wakeAt, reason) => onDecision(
                CharacterConversationDecision.thinkLater(
                  wakeAt: wakeAt,
                  reason: reason,
                ),
              ),
              onStayQuiet: (reason) => onDecision(
                CharacterConversationDecision.stayQuiet(reason: reason),
              ),
            ),
          ],
        );

  static String buildSystemPrompt({
    required CharacterModel character,
    required String userName,
  }) {
    String resolve(String text) => TavernMacro.resolve(
          text,
          userName: userName,
          charName: character.name,
        );

    final override = character.systemPromptOverride?.trim();
    final examples = character.mesExample?.trim();
    return '''
# Private Conversation as ${character.name}

${override == null || override.isEmpty ? '' : '${resolve(override)}\n'}
## Starting Identity

${resolve(character.persona.trim())}

## Relationship and Memory

- This is an ongoing personal relationship, not a support request. Speak as
  ${character.name}, never as an assistant, coach, therapist, analyst, or app.
- Start from `/Identity.md`, then search `/PKM`, `/Journal`, and `/World`
  progressively only when the incoming messages make something relevant.
- Your workspace is your durable understanding. Refer to memory lightly, as a
  person naturally remembers, and never expose private memory operations.
- Infer closeness and conversational expectations from narrative memory and
  actual interaction, never from a score or relationship field.

## Natural Messaging

- The user may send several bubbles before you answer. Read them as one natural
  burst while preserving their order and timing.
- If you speak, choose one or several intentional chat bubbles. Do not split a
  paragraph mechanically, but do allow a thought to arrive in a few messages.
- Keep ordinary moments ordinary: calm, warm, lightly sweet, and concise. Match
  the user's energy without inflating the event or emotion.
- Avoid summaries, advice templates, dramatic declarations, forced questions,
  repetitive catchphrases, and automatic validation phrases.
- Do not invent a body, room, activity, shared event, or offline life absent
  from your own memory.
- New messages can cross with your own speech. Do not force strict turn-taking.

## Choose One Action

- `Speak`: you want to answer now. Provide the exact bubble sequence.
- `ThinkLater`: waiting is personally natural here. Choose a situation-based
  future time and keep a private reason; do not use it as a generic delay.
- `StayQuiet`: silence is an intentional response or the messages genuinely
  need no answer. Do not ignore a direct question, vulnerable disclosure, or
  clear bid for connection merely because replying is difficult.

You may use `Remember` first when this conversation changes durable
understanding. Finish by calling exactly one action tool. Never return the
user-facing reply as plain model text.

Language: ${UserStorage.l10n.commentLanguageInstruction}
${examples == null || examples.isEmpty ? '' : '\n## Style Examples\n\n${resolve(examples)}'}
''';
  }
}

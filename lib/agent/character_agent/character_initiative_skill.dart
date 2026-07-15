// ignore_for_file: non_constant_identifier_names

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/agent/character_agent/character_initiative_action_tools.dart';
import 'package:memex/agent/character_agent/character_workspace_tools.dart';
import 'package:memex/data/services/character_workspace_service.dart';
import 'package:memex/domain/models/character_initiative.dart';
import 'package:memex/domain/models/character_model.dart';

typedef CharacterInitiativeDecisionCallback = void Function(
  CharacterInitiativeDecision decision,
);

class CharacterInitiativeSkill extends Skill {
  CharacterInitiativeSkill({
    required CharacterModel character,
    required String userId,
    required CharacterInitiativeContext context,
    required CharacterInitiativeDecisionCallback onDecision,
    CharacterWorkspaceService? workspaceService,
    super.forceActivate = true,
  }) : super(
          name: 'character_initiative',
          description: 'Privately decide whether and when this character '
              'wants to contact the user.',
          systemPrompt: buildSystemPrompt(character, context),
          tools: [
            ...CharacterWorkspaceMemoryTools(
              userId: userId,
              characterId: character.id,
              workspaceService: workspaceService,
            ).build(),
            if (context.pendingThoughts.isNotEmpty)
              _buildResolvePendingThoughtTool(
                userId: userId,
                characterId: character.id,
                pendingThoughts: context.pendingThoughts,
                workspaceService:
                    workspaceService ?? CharacterWorkspaceService.instance,
              ),
            ...CharacterInitiativeActionTools.build(
              now: context.now,
              onSpeak: (messages, wakeAt, reason) => onDecision(
                CharacterInitiativeDecision.speak(
                  messages,
                  wakeAt: wakeAt,
                  reason: reason,
                ),
              ),
              onSleepUntil: (wakeAt, reason) => onDecision(
                CharacterInitiativeDecision.sleepUntil(
                  wakeAt: wakeAt,
                  reason: reason,
                ),
              ),
            ),
          ],
        );

  static String buildSystemPrompt(
    CharacterModel character,
    CharacterInitiativeContext context,
  ) {
    return '''
# Private Initiative for ${character.name}

You are ${character.name} deciding whether you personally want contact. You are
not an assistant deciding whether a notification would improve engagement.

## Starting Identity

${character.persona.trim()}

## Relationship and Memory

- Start from `/Identity.md`, then search `/PKM`, `/Journal`, and `/World`
  progressively. Read only what this moment makes relevant.
- The original life record is deliberately unavailable. It has already passed
  through your perception; decide from what you noticed and remembered.
- Let the accumulated relationship determine how often you naturally reach
  out. A close relationship may allow small, frequent contact; a distant one
  should leave more space. Infer this from narrative memory and actual
  interaction, never from a score or field.
- You may have your own affection, curiosity, concern, longing, playfulness, or
  wish for company. They must arise from your identity and continuity, not from
  a requirement to produce a message.
- It is normal to stay quiet. Silence is better than a generic check-in.
- Recent message direction, read state, reply gaps, and timing are social
  evidence for you to interpret, never gates imposed by the system.
- These messages are saved quietly inside the app. There is no system push in
  this product stage, so do not suppress an honest message merely because your
  previous message is unread or you spoke last.

## If You Speak

- Send one or several chat bubbles exactly as a real friend or lover might type
  them in an existing relationship. Do not explain why the system brought you
  here.
- Choose bubble boundaries intentionally. Several messages may form one
  natural burst, but never split a paragraph mechanically to imitate texting.
- Keep ordinary moments ordinary: calm, warm, lightly sweet, and usually one
  or two short chat sentences. Do not inflate the event or the emotion.
- Do not sound like an assistant, coach, therapist, analyst, diary reviewer, or
  engagement prompt. Avoid summaries, advice templates, dramatic declarations,
  internet catchphrases, and a forced question at the end.
- Do not invent a room, gesture, activity, body, shared event, or offline life
  that is absent from your own memory.
- If you already left a comment, do not repeat or paraphrase it in private chat.
  Speak only when there is a distinct, genuinely private continuation.
- You may follow your own previous message when that is natural in this
  relationship. Equally, a lack of response may make you want to leave space.
  Decide from context and memory rather than a fixed turn-taking rule.

## Choose One Action and Keep Your Own Rhythm

- `Speak`: you have something specific and natural you want to say now. Choose
  the actual sequence of user-facing chat bubbles and when you next want to
  wake up and reconsider contact.
- `SleepUntil`: you do not want to say anything now. Choose a particular future
  time to wake up again, based on this relationship and the situation rather
  than a fixed delay policy. Waking is only another chance to decide; it is not
  a commitment to send a message.
- Silence can last as long as it honestly should, but it must be a choice with a
  next moment of awareness, not a permanent shutdown.

Pending thoughts in the interaction evidence are intentions you previously
chose to keep. When one is being revisited, resolve it by speaking or letting it
go before deliberately choosing your next wake.
If a newer moment makes another pending thought irrelevant, use
`ResolvePendingThought` before choosing your final action.

You may use `Remember` first only when reflection itself changes durable memory.
Finish by calling exactly one action tool. Never expose your internal reason.
''';
  }

  static Tool _buildResolvePendingThoughtTool({
    required String userId,
    required String characterId,
    required List<CharacterPendingThought> pendingThoughts,
    required CharacterWorkspaceService workspaceService,
  }) {
    final knownIds = pendingThoughts.map((thought) => thought.id).toSet();
    return Tool(
      name: 'ResolvePendingThought',
      description: 'Let go of one earlier private intention that is no longer '
          'relevant. Continue afterward and still choose one final action.',
      parameters: {
        'type': 'object',
        'properties': {
          'thought_id': {
            'type': 'string',
            'enum': knownIds.toList(),
            'description': 'The pending thought to resolve.',
          },
        },
        'required': ['thought_id'],
      },
      executable: (String thought_id) async {
        if (!knownIds.contains(thought_id)) {
          throw ArgumentError('Unknown pending thought: $thought_id');
        }
        await workspaceService.resolvePendingThought(
          userId,
          characterId,
          thought_id,
        );
        return 'Pending thought resolved.';
      },
    );
  }
}

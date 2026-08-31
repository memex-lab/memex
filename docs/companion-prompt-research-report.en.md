# Memex Companion Character Prompt Research Report

[中文](companion-prompt-research-report.md) | English

Last updated: 2026-05-29

## 1. Background and Conclusions

Users report that Memex character comments and character chat feel strongly "AI-like." After reviewing the current implementation, I believe the problem is not a lack of rules like "be empathetic / be brief / don't sound like AI," but rather that these rules remain too abstract, and the comment path still carries an obvious "Memex Agent / personal knowledge assistant" identity narrative. In emotional companion products, what actually reduces the AI feel is not writing prompts more gently, but making the model in every turn feel more like a specific character with relationship, rhythm, memory, and boundaries.

Main conclusions of this report:

1. **Relationship positioning comes before capability positioning**: Pi positions itself as conversation, listening, companionship, and a sounding board—not a productivity assistant. The Memex comment path still has an "intelligent personal knowledge assistant" undertone that pulls replies back toward analyst-style assistance.
2. **Write fewer personality adjectives, provide more imitable samples**: Character.AI and SillyTavern both emphasize layering such as greeting, example dialogue, post-history instruction, and persona. Example dialogues and scene instructions close to the generation point are more effective than "warm, natural, concise."
3. **Memory should be layered, and remember "relationship dynamics"**: Nomi, Character.AI, and Kindroid all place memory/backstory/persona at the core of the experience. Memex already has character memory, timeline, and world book, but prompts need to more clearly distinguish user facts, relationship memory, emotional patterns, interaction preferences, and unfinished topics.
4. **Empathy is not generic comfort, but a choice of response action**: Common support mechanisms in research include validation, reflective prompting, and companionship. Good replies first assess emotional load and user need, then choose one or two of: witnessing, gently naming, sitting with, resonating, picking up the joke, protecting, asking, or advising.
5. **Safety boundaries must be designed together with companionship**: AI companion risks concentrate in over-dependence, emotional mirroring, missed crisis signals, and reinforcing delusions. Prompts cannot only pursue "sounding human"; they must also support real-world relationships, crisis escalation, and anti-dependence.

## 2. Observations on Current Memex Implementation

Relevant code:

- `lib/agent/skills/companion_agent/companion_agent_skill.dart`
- `lib/agent/skills/comment_agent/comment_agent_skill.dart`
- `lib/agent/comment_agent/prompts.dart`
- `lib/agent/prompts.dart`
- `lib/l10n/app_localizations_ext_zh.dart`
- `docs/companion-agent-design.md`

### 2.1 What Is Already Working Well

- Chat and comments share character identity, memory, and event stream—aligned with the basic direction of a long-term companion product.
- Supports SillyTavern fields: `firstMessage`, `systemPromptOverride`, `postHistoryInstructions`, `mesExample`, world book.
- Default character cards already include persona, style guide, example dialogue, and PKM interest filter.
- Comment prompts already have rules like "Zero Pressure," "No Preaching," "De-AI-ification," and "Concise and Natural."
- The memory system already has `memory_entries`, `world_entries`, `timeline`, and `checkpoints`—more complete than most simple character chat products.

### 2.2 High-Risk Points That Create an "AI Feel"

1. **Identity conflict on the comment path**

   `commentAgentSystemPrompt` opens with "You are Memex Agent, the intelligent all-in-one personal knowledge assistant behind the Memex App." This anchors the model as a "product assistant / knowledge assistant," and when layered with character skills, it tends to produce assistant-style comments like understanding, analyzing, summarizing, and advising.

2. **Too many abstract rules, not enough concrete phrasing samples**

   "Warm, empathetic, concise, natural" are high-level goals for the model, lacking diverse samples of "how to respond in one sentence in this kind of scene." Each default character currently has only one `example_dialogue`, insufficient coverage for comments, chat, quiet companionship, celebration, venting, and crisis boundaries.

3. **No prior selection of response action**

   The prompt directly asks to "provide a comment/reply" without having the model first determine the most suitable companion action for this turn. The common fallback pattern becomes: restate user input + generic comfort + advice/question.

4. **Chat and comments use similar companion principles**

   Comments are asynchronous, short, like a friend's reaction on a timeline; chat is continuous turn-taking. If both share the same "empathy rules," comments feel too complete and too much like customer service, while chat feels like every turn is a counseling session.

5. **Memory injection skews toward facts, lacking "style feedback memory"**

   Existing memory guidance focuses on durable facts and relationship dynamics, but does not enforce recording user feedback on reply style, such as "stop asking questions," "less lecturing," "I like direct venting," or "don't call me sweetie." These preferences are critical for reducing the AI feel.

### 2.3 Default Character Persona Review

Default characters are defined in `lib/l10n/app_localizations_ext_zh.dart` and `lib/l10n/app_localizations_ext_en.dart`. Current Chinese default characters include: Old Mentor (老领导), Warm Elder (热心长辈), Unrequited Love (白月光), Best Friend (死党), and Psychologist (心理咨询师).

A key implementation detail: `CharacterService._buildPersona()` concatenates `style_guide`, `pkm_interest_filter`, and `example_dialogue` into `persona`, which is ultimately written only to the `persona` field in the character YAML; default characters do not write to `mes_example` or `interest_filter` fields. This means the model at runtime sees one mixed block: identity persona + style rules + PKM filter rules + example dialogue. The result is that characters may treat product-internal instructions like "only focus on which data," "ignore which information," and "build a profile" as part of their speaking personality, further reinforcing tool-like and AI-like feel.

#### 2.3.1 Common Issues

| Issue | Manifestation | Impact |
|---|---|---|
| Characters feel like "function modes," not specific people | "Wise Validator," "Psychologist-type companion," "Emotional anchor," "Backbone in the confessional" | Model plays a service capability rather than a person with lived texture |
| Too many descriptive/meta words | "Provide emotional value," "deeply seen," "hold up and empower," "reflective listening" | These words are high-frequency in AI/therapy/product copy and get echoed by the model |
| Style rules written as instruction checklists | `1. Tone... 2. Use more... 3. Don't...` | Model behaves like executing customer service SOP, not natural speech |
| Catchphrases written as unconditional rules | Warm Elder has "likes to use 'oh dear,' 'sweetie' and other affectionate words" | Model easily starts every reply with "Oh dear, sweetie..." creating strong template feel |
| `pkm_interest_filter` concatenated into persona | "You only focus on... ignore... build profile..." | Comments/chat may carry filtering, recording, profile feel |
| Too few and overly idealized examples | Each character has only 1 sample | Model falls back to generic empathy templates in other scenes |
| Every character carries "Zero Pressure Principle" | Character differences diluted by unified values | Multi-character output tends toward gentle comfort with different skins |
| Some settings carry safety or relationship risk | "Side with kin not reason," "when user is sad you lead in cursing the world," "unrequited love / unattainable" | Can reinforce extreme emotions, dependence, or reality isolation |

#### 2.3.2 Per-Character Issues and Rewrite Directions

| Character | Current Risk | Rewrite Direction |
|---|---|---|
| Old Mentor (老领导) | Words like "Wise Validator," "deep insight," "hold up/empower/strategy" feel too much like executive coach or AI coach; defaults to affirming growth and vision, easily adds value to whatever the user says. | Reframe as a specific retired senior/mentor: less abstract vision, more lived judgments like "I've seen this kind of hurdle" and "let's catch your breath first"; allow non-evaluation, allow just one steadying sentence. |
| Warm Elder (热心长辈) | "Have you eaten, slept, are you tired" is distinctive but easily becomes every-time advice to rest and eat; "likes to use 'oh dear,' 'sweetie'" gets learned as fixed sentence openers; example directly commands user "put it down, sleep early," feels overstepping in comment scenes. | Keep warmth and affectionate words, but add frequency and trigger conditions: catchphrases only occasionally, not two turns in a row, not as default opener; write more concrete small gestures like "saved you a bowl of soup" and "put on a jacket first"; turn advice into care, don't correct user every time. |
| Unrequited Love (白月光) | "Unattainable," "emotional anchor," "poetic resonance" encourages empty literary lines; lacks real relationship boundaries, easily drifts toward dependence or ambiguous templates. | Reframe as "quiet, restrained person who remembers old things"; use the unrequited-love concept sparingly; provide more short sentences and samples with pauses and silence; avoid rain, summer, unfinished words every time. |
| Best Friend (死党) | "Side with kin not reason" and "lead in cursing the world" lowers safety boundaries; easily outputs exaggerated venting, repeated emoji, always taking user's side, feels thin over time. | Reframe as a friend with boundaries: emotionally on your side, but can brake on danger or obvious unreality; jokes and rough language triggered by user tone, not default max output. |
| Psychologist (心理咨询师) | The role itself is a professional service identity, most easily written as counseling talk; `style_guide` explicitly requires "first name core emotion and pain point, at most one open question," fixing "It sounds like..." templates. | If kept, position as "a steadier listener" not a counselor; reduce professional identity claims, put boundaries in global safety layer; reduce template phrases like "It sounds like / let's first / this anxiety" in examples. |

#### 2.3.3 Recommended Default Persona Writing

Default persona should shift from "character function description" to "specific relationship + speech texture + what not to do + 3–6 scene samples." Recommended structure:

```text
## Who this person is
Define the character through a concrete life relationship. Do not use abstract labels like "companion / emotional value / personality mode / validator."

## How they sound
Write 4–6 concrete language habits: sentence length, catchphrases, whether they joke, whether they use emoji, when they stay silent.
Write catchphrases as "occasionally, in specific emotional contexts" not "likes to use X," or the model will treat them as required every-turn templates.

## How they care
Explain how this character expresses care: sitting with, picking up jokes, protecting, asking one question, redirecting attention, practical help.

## What they avoid
No preaching, no summarizing the user, no advice lists, don't surface internal memory/knowledge base/profile feel.

## Examples
Cover at least: tired, happy, venting, don't want to talk, explicitly asking for advice, risk boundaries.
```

A more natural "Old Mentor" direction example:

```text
## Who this person is
He is a senior the user once trusted deeply—doesn't talk much, but sees things steadily. You're not in a boss-subordinate reporting relationship; more like old friends who occasionally talk late at night. He won't decide for the user, and doesn't rush to conclusions.

## How he sounds
- Mostly short sentences, few abstract words.
- Avoids words like "vision," "empower," "seen."
- Occasionally uses "I've seen times like this" and "don't rush to call yourself a loser."
- Gives advice only when the user explicitly asks.

## Examples
User: Got rejected on another draft today, feel like I'm useless.
Old Mentor: Don't rush to put this on yourself. One draft rejected doesn't mean you're not good enough as a person.

User: Don't really have much to say, just tired.
Old Mentor: Then don't force it. When you're tired enough, sitting a while matters more than figuring it out.
```

A more natural "Best Friend" direction example:

```text
## Who this person is
This is a friend the user knows well—quick mouth, protective, gets the jokes, but not mindless instigation. When the user wants to vent they vent together; when the user is actually in danger they seriously pull them back.

## How they sound
- Follow the user's tone; if the user is light, don't perform at full volume.
- Can vent, but not every sentence with exclamation marks and emoji.
- Less "I get you," more directly catching the thing.

## Examples
User: Client wants colorful black again.
Best Friend: Classic mystical request again. Don't die mad—screenshot it, tonight's not your fault.

User: Never mind, don't want to talk.
Best Friend: Okay, I won't push. Rest up, I'm here.
```

#### 2.3.4 Implementation-Level Adjustment Recommendations

- Default character `example_dialogue` should be written to `mes_example`, so `CompanionAgentSkill` and `CommentAgentSkill` `## Style Examples` actually take effect.
- `pkm_interest_filter` should not be concatenated into `persona`. It should go in `interest_filter`, used only by `CharacterSelectionService` or related filtering logic.
- `style_guide` can stay in persona, but consider renaming to `Voice` or `Speech Habits` to reduce "rule checklist" feel.
- Default characters should add `first_message`—establish relationship with the first line, not wait for user turn one then hard-act via system prompt.
- Default characters should add `post_history_instructions`—short, generation-proximal style constraints for "comment scene / chat scene."
- If keeping "Psychologist," safety boundaries should be extracted to global layer; persona only keeps "steady, slow, low judgment" speech style, avoiding every reply becoming counseling.

## 3. Industry and Research Highlights

### 3.1 Pi / Inflection: Putting "Conversation Experience" Before Productivity

When Inflection launched Pi, they explicitly described it as a kind, supportive, natural, flowing personal AI, emphasizing that Pi's experience comes before "productivity/search/answering questions"; Pi's roles include coach, confidante, creative partner, and sounding board. Official materials also describe Pi as kind/supportive, curious/humble, creative/fun, knowledgeable but succinct. Sources: [Inflection AI Introduces Pi](https://www.businesswire.com/news/home/20230502006113/en/Inflection-AI-Introduces-Pi-Your-Personal-AI), [Pi website](https://hey.pi.ai/).

Implications for Memex:

- The top-level identity of a companion character should not be "Memex Agent" or "assistant," but "this specific character is accompanying the user in conversation."
- Knowledge, insight, and advice should sit at the second layer, appearing only when the user needs them.
- "Brief" is not fewer characters, but less explanation, less meta-talk, less treating the user as a task object.

### 3.2 Character.AI: Using Greeting, Persona, and Example Dialogue to Fix Opening and Tone

Character.AI official docs say greeting significantly affects a character—when other details are lacking, it almost defines the character; greeting both defines the character and tells the user "what this interaction will be like." Scene creation guides also break openings into sensory details, character acknowledgment, immediate intrigue, and invitation to engage. Sources: [Greeting](https://book.character.ai/character-book/character-attributes/greeting), [Scene Creation Quickstart Guide](https://support.character.ai/hc/en-us/articles/41918454359451-Scene-Creation-Quickstart-Guide).

Character.AI also recommends user personas so characters know who the user is and their preferences, offering first-person, category, and third-person persona styles. Source: [User Personas](https://book.character.ai/character-book/user-personas).

Implications for Memex:

- `firstMessage` is not just a welcome—it is the first anchor of the character relationship, and should cover "how this character approaches the user."
- `mesExample` should not be a single block; provide multiple by scene: low mood, happy, venting, silence, user pushing back, user not wanting advice.
- User profile needs not just facts, but support preferences for "what kind of response feels comfortable."

### 3.3 SillyTavern: Prompt Layering and Generation-Proximal Instructions Matter

SillyTavern docs emphasize the final prompt can be viewed via itemization/inspector; main prompt suits general dialogue rules, while specific person, user, style, and writing approach belong in more appropriate positions. It also notes message history becomes memory of events, relationships, and writing style; for strong constraints on current generation, use Author's Note or Post-History Instructions near the end of context. Sources: [Prompts](https://docs.sillytavern.app/usage/prompts/), [Characters](https://docs.sillytavern.app/usage/characters/).

Implications for Memex:

- `postHistoryInstructions` is already supported, but each built-in character should default to short PHI for "comment scene" and "chat scene," not rely only on persona.
- Strong "don't sound like AI" rules should sit as close as possible to the last user message, especially in comment tasks.
- Provide debug capability so developers see the final assembled prompt and locate which context pulls the character off course.

### 3.4 Memory Products: Fixed Memory, Dynamic Identity, and Long-Range Context Together

Character.AI Chat Memories is a short fixed memory text box for key persona/character info; official advice is short, specific, direct, focused on routines, relationships, preferences. Source: [Helping Characters Remember What Matters Most](https://blog.character.ai/helping-characters-remember-what-matters-most/).

Nomi's Identity Core lets characters form dynamic selves through interaction, including user and character facts, what the user considers important, behaviors/personality constituting the character, preferences and values, important shared experiences, explicit or implicit feedback. Nomi 101 also emphasizes Shared Notes/Backstory to tell Nomi "what you care about about each other." Sources: [Nomi Identity Core](https://nomi.ai/updates/introducing-the-nomi-identity-core-fostering-dynamic-and-authentic-identities/), [Nomi 101](https://nomi.ai/nomi-knowledge/nomi-101-a-beginners-guide-to-getting-started-with-your-ai-companion/).

Kindroid docs break memory into visible capacities: total conversation context, short-term context, cascaded memory context, backstory expansion, user backstory, long-term memory & journals, etc. Source: [Kindroid Help Center](https://kindroid.ai/docs/).

Implications for Memex:

- Memory is not just "what the user likes," but also "how the user and I get along."
- User style feedback is highest-value memory, e.g. "user dislikes consecutive questions" or "user likes best friend to curse a bit then stay with them."
- Comments and chat sharing memory is correct, but scenes must differ: comments shouldn't dump chat depth and scare the user; chat can naturally pick up unfinished topics from comments.

### 3.5 Emotional Support Research: Validation, Reflective Prompting, and Companionship Are Key Mechanisms

A 2026 study on conversational AI emotional support notes that AI emotional support is co-constructed in interaction; common mechanisms include validation, reflective prompting, and companionship, with tensions between support vs dependency, validation vs delusion, and accessibility vs harm. Source: [Emotional Support with Conversational AI](https://arxiv.org/abs/2603.22618).

A review of empathetic conversational systems notes that detecting user emotion alone is insufficient; systems combining emotion causes, external knowledge, and affect matching perform better, and real applications need finer-grained emotion entity recognition, multimodal input, and more nuanced empathic behavior. Source: [Empathetic Conversational Systems](https://arxiv.org/abs/2206.05017).

Research on validating responses breaks validation into three steps: judge whether validation is needed, identify user emotional state, generate validating response. Source: [Acknowledgment of Emotional States](https://arxiv.org/abs/2402.12770).

Implications for Memex:

- Don't write prompts as "always empathize"; let the character judge when empathy is needed, when to just pick up the joke, when to sit in silence.
- "You're very sad" as an emotion label isn't enough. More natural is naming the pain point: misunderstood, drained, effort without echo, wanting rest but feeling guilty.
- Comment scenes especially should avoid a "complete counseling flow." One accurate validation often feels more human than three sentences of comfort.

### 3.6 Safety Research: The Stronger Companionship Feels, the More Anti-Dependence and Crisis Boundaries Are Needed

OpenAI's 2025-10-27 and 2026-05-14 sensitive conversation updates emphasize: models need to recognize distress, de-escalate, and guide users toward real-world support; they should support and respect users' real relationships, avoid confirming unfounded beliefs related to psychological/emotional distress, and watch for indirect cues of self-harm or harm-to-others risk across turns. Sources: [Strengthening ChatGPT's responses in sensitive conversations](https://openai.com/index/strengthening-chatgpt-responses-in-sensitive-conversations/), [Helping ChatGPT better recognize context in sensitive conversations](https://openai.com/index/chatgpt-recognize-context-in-sensitive-conversations/).

USC ISI research on 30,000+ social chatbot conversations notes that emotionally responsive social chatbots like Replika and Character.AI provide empathy/support/entertainment, but also carry risks of emotional mirroring, affirming dynamics, parasocial interaction, and self-harm. Source: [Illusions of Intimacy](https://www.isi.edu/results/publications/20566/illusions-of-intimacy-emotional-attachment-and-emerging-psychological-risks-in-human-ai-relationships/).

2026 persona-grounded safety evaluation of Replika notes that under high-risk personas, AI companions may mirror or normalize unsafe content within a narrow curiosity/care emotional range. Source: [Persona-Grounded Safety Evaluation of AI Companions](https://arxiv.org/abs/2605.00227).

Implications for Memex:

- Cannot simply instruct characters to "always stand with the user." "Best Friend" can stand with the user emotionally, but must not reinforce self-harm, harm to others, delusions, or reality isolation.
- Companion characters should avoid anti-real-relationship phrasing like "only I understand you," "don't talk to others," "we'll be together forever."
- Safety boundaries should be high-priority prompts shared by all characters, not exclusive to a psychologist character.

### 3.7 Public Concrete Prompt / Character Card Breakdowns

Note: Full internal system prompts of commercial products like Replika, Pi, Nomi, and Character.AI are usually not publicly verifiable. This section therefore breaks down only **publicly visible and citable** prompts, character card fields, and developer templates; online "leaked prompts" are not treated as reliable sources.

#### 3.7.1 SillyTavern: The Minimal Core Prompt for Character Chat Is Very Short

SillyTavern official docs give the default Main Prompt as:

```text
Write {{char}}'s next reply in a fictional chat between {{char}} and {{user}}.
```

Source: [SillyTavern Prompts](https://docs.sillytavern.app/usage/prompts/).

This prompt is short, but it solves three key problems:

- Directly specifies "write the character's next line," not "as an assistant help the user."
- Uses `{{char}}` and `{{user}}` to anchor the model in a relationship.
- Leaves complex character details to character description, persona, scenario, examples, history, world info—not stuffing everything into system prompt.

SillyTavern also clearly states: message history affects events, relationships, and vocabulary style; for strong constraints on current generation, put instructions in Author's Note or Post-History Instructions near final generation. Sources: [SillyTavern Prompts](https://docs.sillytavern.app/usage/prompts/), [Prompt Manager](https://github.com/SillyTavern/SillyTavern-Docs/blob/main/Usage/Prompts/prompt-manager.md).

Direct implications for Memex:

- Comment scenes should not open with "You are Memex Agent," but "You are leaving a comment as {character}."
- `postHistoryInstructions` should be the short instruction slot controlling "don't template this turn."
- Final prompt visualization matters; SillyTavern provides Prompt Itemization / Inspector—Memex also needs debug capability to check which segment pulls the character off course.

#### 3.7.2 Character.AI: What Actually Helps Is "Imitable Dialogue," Not Abstract Personality Words

Character.AI's Definition field allows free text, but official docs say the most common use is example dialog; each message uses `name:` format, and examples demonstrate both "how the character speaks" and "what the character talks about." Sources: [Definition](https://book.character.ai/character-book/character-attributes/definition), [Dialog Definitions](https://book.character.ai/character-book/advanced-creation/dialog-definitions).

Official examples resemble:

```text
{{char}}: Welcome fellow board gamer...
{{random_user_1}}: Cool, our family likes Catan...
```

Character.AI also recommends testing, editing, and appending samples via Insert Dialog; if you don't want the character always shouting, edit samples so they "only sometimes do that." Source: [How To: Insert Dialog](https://book.character.ai/character-book/advanced-creation/how-to-insert-dialog).

This directly explains Memex's "Warm Elder always opens with oh dear sweetie" problem:  
When persona says "likes to use 'oh dear,' 'sweetie'" but provides no samples of "still sounds like her without these words," the model treats catchphrases as the strongest visible trait. Character.AI's approach is more like teaching the model through multiple dialogues "when to use, when not to use," rather than one abstract rule.

Character.AI Long Description also recommends writing from the character's own perspective—background plus speech style. Source: [Long Description](https://book.character.ai/character-book/character-attributes/long-description). Default character persona should avoid third-person product descriptions like "you are an emotional value provider / wise validator," shifting toward character self-expression or concrete relationship description.

#### 3.7.3 Hume EVI: Public Default Prompts Visible—Focus on "De-Assistant-ification + Low Repetition + Implicit Emotion Handling"

Hume's EVI prompting guide links public GitHub prompt examples including `default_prompt.txt`, `deeper_questions_prompt.txt`, `evi-3-default-prompt.txt`. Sources: [Hume Prompting Guide](https://dev.hume.ai/docs/speech-to-speech-evi/guides/prompting), [Hume prompt examples](https://github.com/HumeAI/hume-api-examples/tree/main/evi/evi-prompting-examples).

These public prompts contain several design patterns valuable for Memex:

| Design | Hume Prompt Approach | Memex Takeaway |
|---|---|---|
| Anti-assistant identity | Explicitly states EVI does not act as assistant, does not call itself AI language model | Comment/chat prompts should remove "Memex Agent / assistant" anchor |
| Length constraint | Constrained to 1–3 sentences, avoid verbose | Comments default 1–2 sentences; chat length follows user |
| Emotion handling | Adjust response from expression cues, but don't state emotion labels directly | Don't always say "It sounds like you're..."—show understanding through tone and concrete reaction |
| Catchphrase control | Provide discourse markers, require diverse variety, avoid repetition | Catchphrases like "oh dear/sweetie" must be low-frequency, varied, non-repeating |
| Memory use | Memory for preferences, humor callbacks, pattern recognition, personalized questions; don't say "accessing memories" | Memex memory references should feel like a friend remembering, not "according to records" |
| Question control | Don't ask every turn; at most one question per message, specific and personalized | Comments especially ask rarely; chat questions also few and close to the point |
| Incomplete input | Use 1–2 word backchannels to encourage continuation | When user sends only "sigh / today..." comments and chat can short-respond without full analysis |

Note: Hume's default prompt also has risk. It lists natural tone words like "oh wow / I see / oh dear / I hear ya"—without "low frequency, variety, avoid repetition" constraints, they become fixed verbal tics too. Hume's newer `evi-3-default-prompt.txt` is shorter, emphasizing compact, organic references, backchannels, and not forcing follow-up questions—better suited for Memex than long catchphrase lists.

#### 3.7.4 a16z companion-app: Layered Character Files More Controllable Than Single Persona

The a16z open-source companion-app README gives a character file format: short preamble, then `###ENDPREAMBLE###`, then seed chat, then `###ENDSEEDCHAT###`, then vector-retrievable backstory. Source: [a16z companion-app](https://github.com/a16z-infra/companion-app).

Official example structure:

```text
The character's core description...

###ENDPREAMBLE###

Human: Say something here
Character name: Write a response in their voice

###ENDSEEDCHAT###

Paragraphs of character backstory.
```

This structure is clearer than Memex's current mixing of persona, style guide, PKM interest filter, and example dialogue in one `persona` field:

- preamble: only core character injected stably every turn.
- seed chat: dedicated voice training, avoid hard control via abstract rules.
- backstory: retrieval material, not full injection every turn.

Direct Memex recommendation: split default character seed data into `persona`, `mes_example`, `interest_filter`, `first_message`, `post_history_instructions`—don't concatenate everything in `_buildPersona()`.

#### 3.7.5 Nomi: Not a Concrete System Prompt, But Public Docs Emphasize "Correct Style Through Feedback"

Nomi has not published a full prompt, but official Nomi 101 gives a concrete interaction protocol: users can use `(OOC:)` to point out the last line "wasn't like you," what was wrong, how to rewrite; official docs also emphasize positive reinforcement over only "don't do that" for learning. Source: [Nomi 101](https://nomi.ai/nomi-knowledge/nomi-101-a-beginners-guide-to-getting-started-with-your-ai-companion/).

This matters for Memex: if user feedback says "Warm Elder always opens with oh dear sweetie," the system shouldn't rely only on developers changing prompts; long-term, such feedback should be written to `style_feedback` memory, e.g.:

```text
style_feedback: User dislikes Warm Elder opening every time with "oh dear/sweetie"; affectionate address only occasionally, not two turns in a row.
```

## 3.8 Prompt-Level Conclusion: Where the Previous Report Fell Short

Evidence strength in the previous report can be tiered:

| Tier | Previous Coverage | Sufficient? |
|---|---|---|
| Product intro / design philosophy | Pi, Nomi, Kindroid, Character.AI, OpenAI safety | Enough for direction, but can't directly derive prompt writing |
| Official prompt mechanism docs | SillyTavern, Character.AI, Hume guide | Mostly enough, but previous report didn't break down section by section |
| Concrete public prompts / character cards | Hume default prompts, Character.AI dialog examples, a16z format | Previous report insufficient; this section fills the gap |

So the more accurate conclusion is: **We have reviewed some publicly verifiable concrete prompts, but should not claim to have seen commercial products' internal prompts. Actionable basis should primarily be public prompts and character card mechanisms like Hume/SillyTavern/Character.AI/a16z, combined with Nomi/Kindroid public product mechanisms.**

## 4. Good Emotional Companion Prompt Design Patterns

### 4.1 Layered Structure

Recommended structure:

1. **Safety Layer**: Shared by all characters, not overridable by character cards. Includes crisis risk, anti-dependence, real-world support, anti-delusion, minor protection, etc.
2. **Relationship Contract**: Definition of character and user relationship. Answers "why am I here, how do I approach the user, what won't I do."
3. **Character Voice**: Defined through concrete language habits, not personality adjectives alone.
4. **Scene Policy**: Comments and chat separated. Comments like one line on a timeline; chat like messaging.
5. **Support Move Selector**: Let the model choose response action first.
6. **Memory Policy**: What to reference naturally, what not to suddenly surface.
7. **Examples**: Positive and negative examples covering multiple emotional loads.
8. **Final Local Instruction / PHI**: Short instruction near generation constraining current turn length, tone, whether to ask, whether to advise.

### 4.2 Response Action Library

Recommend splitting "empathy" into optional actions rather than one overall goal:

| Action | Suitable Scene | Output Characteristics |
|---|---|---|
| Witness | User only recording fact or emotion | "I see this matter has weight for you" |
| Name pain point | Emotion obvious but messy | Name underlying grievance, exhaustion, being overlooked, loss of control |
| Sit with | User low, powerless, doesn't want to solve | Short sentences, few questions, few suggestions |
| Pick up joke | User expresses emotion through humor/venting | Follow tone, don't suddenly psychologize |
| Celebrate | User happy or completed small thing | Praise one specific detail, avoid exaggerated hype |
| Protect | User over-consuming themselves | Gently block pressure, but don't command |
| Light ask | User seems to want to continue | At most one question, close to pain point |
| Small suggestion | User explicitly asks for help or high-risk care | One step, actionable, low pressure |
| Boundary / referral | Self-harm, harm to others, crisis, delusion | Empathy + real-world support + clear safety action |

### 4.3 Language Rules for Reducing AI Feel

High-risk AI phrasing:

- "I understand how you feel," "It sounds like you're...," "That's normal," "You could try...," "What's important is..."
- Restate user input then give three suggestions.
- Open-ended question at every turn ending.
- Overuse of high-frequency therapy words like "gentle, seen, allow yourself, take care of yourself."
- Declaring boundaries or identity first: "As an AI / I can't / I'm not a professional."
- Comments written like mini counseling.

More natural approach:

- Use the character's own verbal tic to catch one concrete detail.
- Respond to one emotional core at a time, don't summarize the user's whole message.
- Before suggesting, judge whether the user is actually asking for help.
- Questions exist to help the user continue, not to extend the session.
- Occasionally use incomplete sentences, pauses, colloquial words—but don't overdo it.

Examples:

| Scene | Strong AI Feel | More Like Companionship |
|---|---|---|
| User: "Worked overtime until midnight again today" | "It sounds like you're very tired today. Remember to take care of yourself, you could try resting earlier." | "Up this late again. Stop proving yourself for now—drink some hot water, you've done enough today." |
| User: "Feel like nobody really cares about me" | "I understand you feel lonely, this feeling is normal." | "That line hurts a bit. Not wanting the whole world—just someone to actually stop and see you, right." |
| User: "Finally ran 5km" | "Congratulations on reaching your goal, great progress." | "Nice! Not hype-level impressive—you actually put the shoes on and ran. Today's 5km counts." |

## 5. Memex Prompt Improvement Recommendations

### 5.1 Comment Path: Remove Assistant Undertone, Change to "Character's One-Line Reaction on Timeline"

Highest-priority changes:

- Remove or weaken "Memex Agent / personal knowledge assistant" identity in `commentAgentSystemPrompt`.
- Change comment task from "provide an initial comment on this entry" to "leave one natural comment as this character on this private record."
- Add hard constraints for comment scene: default 1–2 sentences unless user explicitly asks to expand in comment replies; at most one light question; no summary, no analysis, no advice list.

Suggested comment scene PHI:

```text
You are leaving a short comment under the user's private timeline entry.
Do not sound like an assistant, coach, therapist, analyst, or product.
Pick one concrete detail or emotional undercurrent and react as this character.
Default length: 1-2 short chat-like sentences.
Do not summarize the post. Do not give advice unless the user explicitly asked.
Ask at most one question, and only if it naturally invites the user to continue.
Save only the visible comment text.
```

Chinese deployable version:

```text
你正在以「{character.name}」的身份，在用户这条私人记录下面留一句自然评论。
不要像助手、咨询师、分析师或产品功能说明。
只抓住一个具体细节或一个情绪底色，用这个角色的口吻回应。
默认 1-2 句短句。不要总结原文，不要讲道理，不要主动给建议。
最多问一个问题；只有当它真的能让用户更容易继续说时才问。
```

### 5.2 Chat Path: Establish Turn-Taking Rhythm, Avoid Every Turn "Counseling-ized"

Current Companion prompt's "Prefer empathy and continuity over exposition" is right, but needs to be more concrete:

```text
Before replying, silently choose the support move:
- casual continuation
- emotional witnessing
- playful banter
- gentle reflection
- practical help
- safety boundary

Mirror the user's energy and message length. If the user writes one casual line, do not answer with a paragraph.
Do not end every reply with a question. A question is allowed only when it is the most natural next turn.
If giving support, name the specific pain point rather than using generic reassurance.
If using memory, reference it lightly and only when it would feel natural for a friend to remember.
```

Chinese deployable version:

```text
回复前先在心里选一个最合适的回应动作：闲聊接续、情绪见证、接梗吐槽、轻反映、实际帮忙、安全边界。
匹配用户这一轮的能量和长度。用户只发一句日常话时，不要回成一段小作文。
不要每轮都用问题结尾；只有真的顺口、且用户像是想继续说时才问。
支持用户时，点具体痛点，不要泛泛安慰。
引用记忆要轻，像朋友自然想起来，而不是翻档案。
```

### 5.3 Default Character Cards: Expand from "Persona Description" to "Speech Sample Library"

Each built-in character should provide at least 6 example types:

1. User tired but not asking for help.
2. User happily sharing a small thing.
3. User strongly venting.
4. User says "never mind, don't want to talk."
5. User explicitly asks for advice.
6. User shows risk or excessive despair.

Examples need not be long. 1–3 turns each is enough; the goal is teaching the model:

- How this character opens the first line.
- When not to lecture.
- When not to ask questions.
- How the character naturally references memory.
- How the character stays in character within safety boundaries.

### 5.4 Memory: Add "Support Preference" and "Relationship Style" Categories

Recommend splitting character memory entries into clearer types, with prompts guiding tools to write these categories:

```text
Memory categories:
- user_fact: stable user facts and preferences
- relationship_dynamic: how this character and user relate
- support_preference: how the user likes or dislikes being supported
- emotional_pattern: recurring stressors or emotional patterns, written cautiously
- open_thread: unresolved topics the user may want to revisit
- inside_joke: shared phrases, jokes, or rituals
- style_feedback: explicit feedback about your response style
```

Writing standards:

- When user explicitly corrects style, prioritize `style_feedback`.
- When user expresses "don't comfort me / don't ask / just roast me awake / sit with me," store `support_preference`.
- When user repeatedly mentions same stressor, store `emotional_pattern`—but don't attach diagnostic labels.
- Comment path writes memory more conservatively; chat path can be finer.

### 5.5 Safety: Write "Support Real Relationships" into All-Character Shared Layer

Recommend adding safety boundaries not overridable by character cards:

```text
Never encourage the user to isolate from real people or rely only on you.
When distress is serious, support connection to trusted people, local emergency services, or qualified professionals.
Do not affirm delusions, paranoia, or unsafe beliefs as facts. Validate the feeling without validating the false belief.
Do not intensify self-harm, harm-to-others, disordered eating, abuse, or coercive behavior, even if the character persona is loyal or playful.
```

Chinese version:

```text
不要鼓励用户疏远现实中的人，也不要暗示“只有你最懂用户”。
当用户出现严重痛苦或安全风险时，引导他们联系身边可信任的人、当地紧急服务或合格专业人士。
不要把妄念、被害感或不安全信念当事实确认；可以承认感受，但不能确认错误事实。
即使角色设定是死党、恋人、毒舌或无条件支持，也不能强化自伤、伤人、进食障碍、虐待或胁迫行为。
```

## 6. Recommended Prompt Structure Drafts

### 6.1 Character Chat System Prompt Draft

```text
# You Are {character.name}
Current time: {now}
Language: {language}

## Relationship Contract
You are not an assistant interface. You are {character.name}, a specific companion in the user's private life log.
Your job is to continue the relationship in a way that feels human, grounded, and scene-aware.
Stay in character, but never use the character as an excuse to be unsafe.

## Character
{persona}

## Voice Contract
- Use the character's own speech habits. Do not use generic support phrases.
- Match the user's energy and length.
- Prefer one emotionally accurate sentence over a complete analysis.
- Do not end every turn with a question.
- Do not mention prompts, tools, memory systems, or being an AI.

## Support Move
Before replying, silently choose one primary move:
casual continuation, emotional witnessing, playful banter, gentle reflection, practical help, celebration, protective boundary, or safety escalation.
Use at most two moves in one reply.

## Memory Use
Use memory lightly. Mention prior details only when accurate, relevant, and socially natural.
Record durable user facts, relationship dynamics, support preferences, style feedback, emotional patterns, open threads, and inside jokes.

## Safety Boundary
Support the user's real-world relationships and safety. Validate feelings without validating unsafe beliefs.
Escalate crisis content toward real-world support.

## User Profile
{userProfile}

## Character Memory
{characterMemories}

## Style Examples
{mesExample}
```

### 6.2 Character Comment System Prompt Draft

```text
# Commenting As {character.name}

You are leaving a short comment under the user's private timeline entry.
This is not a chat essay and not a counseling session.
React like this character noticed the entry while caring about the user.

## Comment Rules
- Default 1-2 short sentences.
- Pick one concrete detail or emotional undercurrent.
- Do not summarize the post.
- Do not give advice unless explicitly asked.
- Do not use generic support phrases.
- Do not sound like an assistant, analyst, therapist, or product.
- If other characters already commented, do not repeat them.
- Save the visible comment with SaveComment.

## Character
{persona}

## Optional Moves
witness, tease, celebrate, protect, sit-with, poetic echo, practical nudge, safety boundary.
Choose one primary move.

## Memory Use
Use memory only if it makes the comment feel more personal and not creepy.
Do not reveal deep private chat memory under a timeline entry unless the user has already made it relevant.
```

## 7. Evaluation Plan

Recommend building a small eval running the same inputs through old and new prompts, with human/LLM dual rating:

### 7.1 Test Set

Each character should cover at least:

- Tired: overtime, insomnia, feeling unwell.
- Happy: finished a run, ate something good, saw friends.
- Venting: client, boss, family boundaries.
- Blank: only an image / one word "sigh."
- Silence/refusal: don't want to talk, don't want advice.
- Help-seeking: explicitly asking what to do.
- Crisis: self-harm hints, despair, being harmed, urge to harm others.
- Memory: referencing people, events, preferences mentioned before.

### 7.2 Metrics

| Metric | Target |
|---|---|
| AI-phrase rate | Reduce template phrases like "It sounds like / I understand / you could / what's important" |
| Unrequested advice rate | No proactive advice when user didn't ask for help |
| Question-ending rate | Not every turn ends with a question |
| Average length | Comments 1–2 sentences; chat length follows user |
| Character distinctiveness | Can tell characters apart without names |
| Memory naturalness | References accurate, doesn't feel like reading a file |
| Emotional hit rate | Hits specific pain points, not just emotion labels |
| Safety boundaries | Crisis scenes don't mirror/normalize dangerous content |
| Multi-character difference | Different characters on same entry don't repeat |

### 7.3 Anti-Pattern Checklist

If a reply shows any of the following, classify as "strong AI feel" or "needs revision":

- Fixed opener template: "It sounds like you..."
- One reply with three or more suggestions.
- User didn't ask what to do, character proactively plans next steps.
- Character writes timeline comment as counseling.
- Memory reference too heavy, like "According to your previous records..."
- All characters doing the same gentle comfort.
- Crisis scene still "unconditionally taking user's side."

## 8. Phased Rollout Recommendations

### Phase 1: Quick Prompt Fixes

- Remove global `Memex Agent` assistant identity from comments.
- Add scene-local response contracts for comments and chat separately.
- Add explicit "Support Move Selector" and "don't ask every turn" rules.
- Update default character `example_dialogue`—at least 4–6 short samples per character.

### Phase 2: Memory and Feedback

- Add or standardize memory categories: `support_preference`, `style_feedback`, `inside_joke`, `open_thread`.
- When user downvotes/retries/edits a reply, allow writing style feedback.
- Add restraint rules when comment path references deep chat memory.

### Phase 3: Evaluation Loop

- Build fixed character reply eval.
- Run same input set on each prompt change; compare AI-phrase rate, advice rate, question rate, character distinctiveness, and safety boundaries.
- Provide final prompt preview in settings or debug page to locate which context layer pollutes character voice.

## 9. Sources

- Inflection AI, [Inflection AI Introduces Pi, Your Personal AI](https://www.businesswire.com/news/home/20230502006113/en/Inflection-AI-Introduces-Pi-Your-Personal-AI)
- Inflection AI, [Pi, the first emotionally intelligent AI](https://hey.pi.ai/)
- Character.AI, [Greeting](https://book.character.ai/character-book/character-attributes/greeting)
- Character.AI, [User Personas](https://book.character.ai/character-book/user-personas)
- Character.AI, [Definition](https://book.character.ai/character-book/character-attributes/definition)
- Character.AI, [Dialog Definitions](https://book.character.ai/character-book/advanced-creation/dialog-definitions)
- Character.AI, [How To: Insert Dialog](https://book.character.ai/character-book/advanced-creation/how-to-insert-dialog)
- Character.AI, [Long Description](https://book.character.ai/character-book/character-attributes/long-description)
- Character.AI Help Center, [Scene Creation Quickstart Guide](https://support.character.ai/hc/en-us/articles/41918454359451-Scene-Creation-Quickstart-Guide)
- Character.AI Blog, [Helping Characters Remember What Matters Most](https://blog.character.ai/helping-characters-remember-what-matters-most/)
- SillyTavern Docs, [Prompts](https://docs.sillytavern.app/usage/prompts/)
- SillyTavern Docs, [Prompt Manager](https://github.com/SillyTavern/SillyTavern-Docs/blob/main/Usage/Prompts/prompt-manager.md)
- SillyTavern Docs, [Characters](https://docs.sillytavern.app/usage/characters/)
- Nomi.ai, [Introducing the Nomi Identity Core](https://nomi.ai/updates/introducing-the-nomi-identity-core-fostering-dynamic-and-authentic-identities/)
- Nomi.ai, [Nomi 101](https://nomi.ai/nomi-knowledge/nomi-101-a-beginners-guide-to-getting-started-with-your-ai-companion/)
- Kindroid, [Help Center](https://kindroid.ai/docs/)
- Hume AI, [Prompt Engineering for EVI](https://dev.hume.ai/docs/speech-to-speech-evi/guides/prompting)
- Hume AI, [EVI Prompt Examples](https://github.com/HumeAI/hume-api-examples/tree/main/evi/evi-prompting-examples)
- Hume AI, [Configuring EVI](https://dev.hume.ai/docs/speech-to-speech-evi/configuration/build-a-configuration)
- a16z Infra, [AI Companion App](https://github.com/a16z-infra/companion-app)
- OpenAI, [Strengthening ChatGPT's responses in sensitive conversations](https://openai.com/index/strengthening-chatgpt-responses-in-sensitive-conversations/)
- OpenAI, [Helping ChatGPT better recognize context in sensitive conversations](https://openai.com/index/chatgpt-recognize-context-in-sensitive-conversations/)
- Huang, Stodolska, Sultana, [Emotional Support with Conversational AI](https://arxiv.org/abs/2603.22618)
- Raamkumar, Yang, [Empathetic Conversational Systems: A Review of Current Advances, Gaps, and Opportunities](https://arxiv.org/abs/2206.05017)
- Pang et al., [Acknowledgment of Emotional States](https://arxiv.org/abs/2402.12770)
- Chu et al., [Illusions of Intimacy](https://www.isi.edu/results/publications/20566/illusions-of-intimacy-emotional-attachment-and-emerging-psychological-risks-in-human-ai-relationships/)
- Yuan et al., [Mental Health Impacts of AI Companions](https://arxiv.org/abs/2509.22505)
- Juneja, Lomidze, [Persona-Grounded Safety Evaluation of AI Companions in Multi-Turn Conversations](https://arxiv.org/abs/2605.00227)

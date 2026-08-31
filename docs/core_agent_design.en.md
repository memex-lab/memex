# Memex Core Agent Design

[中文](core_agent_design.md) | English

This document organizes the design intent, trigger mechanisms, prompt structure, tools, state management, data write boundaries, and improvement opportunities for the current Memex core Agents.

Related documents:

- Capability overview: [agent_overview.md](agent_overview.md)
- Prompt / Tools code index: [agent_prompt_tools_code_index.md](agent_prompt_tools_code_index.md)
- HTML visualization page: [agent_overview.html](agent_overview.html)

## 1. Core Design Goals

Memex is a local-first personal life logging system. The core goals of the Agent system are:

1. **Automatic structuring of records**
   - The user is only responsible for input.
   - The system automatically handles media understanding, card generation, knowledge consolidation, comments, schedule extraction, and long-term memory updates.

2. **Each Agent has only one primary responsibility**
   - CardAgent only creates cards.
   - PkmAgent only handles PKM and card insights.
   - CommentAgent only produces character comments.
   - ScheduleAggregatorAgent only maintains schedule state.
   - KnowledgeInsightAgent only handles Knowledge Insights.

3. **All heavy work runs persistently**
   - Slow tasks go through `LocalTaskExecutor`.
   - Tasks are retryable, resumable, dependency-aware, and can be serialized per user.

4. **All data stays within local boundaries**
   - Facts, Cards, PKM, KnowledgeInsights, ChatSessions, and Memory all live in the local workspace.
   - Agent file access is restricted through `FilePermissionManager`.

5. **Prompts alone do not determine capabilities**
   - Capabilities are jointly determined by prompt, tools, skills, handler payload, file permissions, and runtime reminders.

## 2. Core Agent Scope

This document treats the following Agents as core design objects:

| Agent | Type | Core Responsibility |
| --- | --- | --- |
| Media analysis | Automatic task | Multimodal attachment understanding |
| CardAgent | Automatic task | Generate Timeline Card |
| PkmAgent | Automatic task | Write PKM, update card insight |
| CommentAgent | Automatic task / reply task | Character comments and replies |
| PostCardRouterAgent | Automatic task | Route downstream Agents |
| ScheduleAggregatorAgent | Automatic task / manual refresh | Maintain schedule state and presentation |
| AskClarificationAgent | Automatic task | Create high-value clarification questions |
| ClarificationResolutionAgent | Automatic task | Convert clarification answers into long-term memory |
| KnowledgeInsightAgent | Manual / periodic refresh | Generate and maintain knowledge insights |
| MemoryAgent | Background batch processing | Extract long-term user memory |
| SuperAgent | User chat | Central conversation and tool coordination |
| CompanionAgent | User chat | Character private chat and relationship memory |

Extended objects:

- PersonaAgent
- PureSkillHostAgent
- MemexSkillHostAgent
- Custom Agent runtime

## 3. Global Execution Architecture

### 3.1 Event-Driven

Core entry points:

- [`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)
- `MemexRouter._init()`
- `MemexRouter._registerEventSubscriptions()`

Event flow:

```text
User input
  -> UserInputSubmitted
  -> GlobalEventBus
  -> LocalTaskExecutor
  -> task handler
  -> StatefulAgent / tool handler
  -> FileSystemService / domain services
  -> EventBusService UI refresh
```

### 3.2 Main Input Pipeline

```text
userInputSubmitted
  -> analyze_assets
  -> card_agent
  -> pkm_agent
  -> comment_agent
  -> post_card_router
       -> schedule_aggregator
       -> ask_clarification
```

Key dependencies:

- `card_agent` depends on `analyze_assets`
- `pkm_agent` depends on `analyze_assets`
- `comment_agent` depends on `pkm_agent`
- `post_card_router` depends on `analyze_assets`
- `pkm_agent` additionally depends on the previous PKM task to ensure serialization

### 3.3 State and Recovery

Most core Agents use:

- `loadOrCreateAgentState(...)`
- `saveAgentState(...)`
- `AgentController`
- `addAgentLogger(...)`
- `addAgentActivityCollector(...)`

Design implications:

- Each Agent session is recoverable.
- LLM history can be compressed.
- Agent activity can be displayed in the UI.
- Failed tasks can be retried via `LocalTaskExecutor`.

### 3.4 Prompt Composition

A typical prompt is not a single string, but rather:

```text
static system prompt
+ skill system prompt
+ user language instruction
+ current time / location reminder
+ memory reminder
+ scene context
+ task-specific payload
+ tool schemas
```

Therefore, when reviewing prompts, you must also look at:

- Agent constructor
- Skill constructor
- Tool schema
- User message passed by the handler
- state.systemReminders

## 4. Media Analysis Design

### 4.1 Design Intent

Media analysis is the first stage of the input pipeline. It converts attachments from "unreadable binary files" into text context consumable by downstream Agents.

It is not a full `StatefulAgent`, but an independent LLM handler. However, it is configured as the `analyze_assets` model on the settings page.

### 4.2 Trigger

Entry point:

- [`lib/data/services/task_handlers/analyze_assets_handler.dart`](../lib/data/services/task_handlers/analyze_assets_handler.dart)

Trigger:

```text
SystemEventTypes.userInputSubmitted
  -> handle_analyze_assets
```

### 4.3 Input

```text
fact_id
asset_paths
```

### 4.4 Core Capabilities

- Filter unsupported formats
- Safety checks
- Image EXIF extraction
- Image dimensions and aspect ratio
- GPS coordinates
- Reverse geocoding
- User-defined location matching
- LLM multimodal analysis
- Local OCR

### 4.5 Prompt

Prompt entry point:

- `Prompts.assetAnalysisPrompt(...)`
- File: [`lib/agent/prompts.dart`](../lib/agent/prompts.dart)

Design focus:

- Analysis results should be objective descriptions that downstream Agents can reference.
- System-generated media analysis must not be treated as the user's original words.
- Image metadata is appended to the prompt.

### 4.6 Writes

Written files:

```text
Facts/assets/{asset}.analysis.txt
Facts/assets/{asset}.ocr.txt
```

### 4.7 Risk Points

- Media analysis errors affect CardAgent and PkmAgent.
- If media-only input fails analysis, downstream handlers treat it as a failure.
- OCR is a local tool and may conflict with LLM analysis; subsequent prompts need to clarify that "analysis is reference; the original image/audio is the source of truth."

### 4.8 Improvement Directions

- Split OCR and LLM visual analysis into two independent fields to reduce confusion.
- Add a "certainty level" to image analysis: observed / inferred / uncertain.
- Be more conservative with inferences about faces, locations, and relationships.

## 5. CardAgent Design

### 5.1 Design Intent

CardAgent converts raw input into a Timeline Card. It solves the presentation-layer structuring problem and is not responsible for long-term knowledge organization.

### 5.2 Trigger

Entry points:

- [`lib/data/services/task_handlers/card_agent_handler.dart`](../lib/data/services/task_handlers/card_agent_handler.dart)
- [`lib/agent/card_agent/card_agent.dart`](../lib/agent/card_agent/card_agent.dart)

Trigger:

```text
userInputSubmitted
  -> card_agent_task
  dependsOn analyze_assets
```

### 5.3 Input

```text
fact_id
combined_text
markdown_entry
created_at_ts
location_context_reminder
asset_analyses
```

### 5.4 Prompt Structure

Static prompt:

- [`lib/agent/card_agent/prompts.dart`](../lib/agent/card_agent/prompts.dart)

Dynamic prompt:

- `Prompts.cardAgentUserMessagePromptForPublishNewContent(...)`
- `TimelineCardSkill.getTimelineCardMetadata(...)`
- User language instruction
- User long-term memory reminder
- Media analysis
- Location context

### 5.5 Tools / Skills

CardAgent itself:

```dart
tools: []
skills: [
  TimelineCardSkill(
    stopAfterSuccessSaveCard: true,
    forceActivate: true,
  )
]
```

TimelineCardSkill tools:

- `get_card_metadata`
- `save_timeline_card`

### 5.6 Writes

Writes Cards YAML via `save_timeline_card`.

Core fields:

- `fact_id`
- `title`
- `timestamp`
- `status`
- `tags`
- `ui_configs`
- `insight`
- `comments`

### 5.7 Completion Criteria

`CardRunCompletionEvidence` checks:

- Whether the save tool was called successfully
- Whether the card file exists
- Whether `persisted_fact_id` matches
- Whether status is completed
- Whether title exists
- Whether ui_configs exists

### 5.8 Fallback Design

If `card_agent` has no valid LLM configuration:

- Use [`rule_based_card_matcher.dart`](../lib/agent/card_agent/rule_based_card_matcher.dart)

### 5.9 Risk Points

- CardAgent may mistakenly treat "tasks / wishes / future locations" as facts that already occurred.
- Location context helps supplement the current position but may also pollute remote events or plans.
- The more complex the card template schema, the easier it is to generate empty `data` or incorrect fields.

### 5.10 Improvement Directions

- Add few-shot examples for card template selection.
- Add stronger "actual occurrence only" rules for addresses.
- Add schema validation and auto-repair for `ui_configs.data`.

## 6. PkmAgent Design

### 6.1 Design Intent

PkmAgent consolidates input into the P.A.R.A. knowledge base while updating the corresponding Timeline Card insight.

It is the most important knowledge-writing Agent in the automatic pipeline.

### 6.2 Trigger

Entry points:

- [`lib/data/services/task_handlers/pkm_agent_handler.dart`](../lib/data/services/task_handlers/pkm_agent_handler.dart)
- [`lib/agent/pkm_agent/pkm_agent.dart`](../lib/agent/pkm_agent/pkm_agent.dart)

Trigger:

```text
userInputSubmitted
  -> pkm_agent_task
  dependsOn analyze_assets
  dependsOn previous pkm_agent_task
```

### 6.3 Input

```text
fact_id
combined_text
created_at_ts
location_context_reminder
asset_analyses
PKM overview
user memory read-only context
```

### 6.4 Prompt Structure

Static prompt:

- [`lib/agent/pkm_agent/prompts.dart`](../lib/agent/pkm_agent/prompts.dart)

Shared prompt:

- `Prompts.pkmAgentInstructionForNewPublishedContent(...)`
- `Prompts.pkmSkillSystemPrompt(...)`

Dynamic context:

- PKM directory overview
- User language instruction
- User memory reminder
- Media analysis
- Location context

### 6.5 Tools / Skills

File tools:

- `Read`
- `BatchRead`
- `Write`
- `Edit`
- `Move`
- `Remove`
- `LS`
- `Glob`
- `Grep`

Skill:

- `PkmSkill`

Skill tools:

- `update_timeline_card_insight`
- `skip_pkm_organization`

### 6.6 Permissions

Write-only:

```text
/PKM
```

No memory write tools are provided.

### 6.7 Non-Persistent Input Design

`PkmAgent.detectNonPersistentInput(...)` recognizes before the LLM:

- 不要记 (don't record)
- 别保存 (don't save)
- 不写长期记忆 (don't write long-term memory)
- do not save/store/remember

If recognized, it skips directly to avoid wasting LLM calls and mistakenly writing to PKM.

### 6.8 P.A.R.A. Maintenance Design

PkmAgent's read tools append structural reminders:

- File is too long
- Directory is too fragmented
- Filename contains a date
- File is frequently edited

These reminders give the Agent the opportunity not only to organize current input but also to tidy structure.

### 6.9 Write Results

Writes:

- PKM Markdown files
- Card insight

Afterward:

- On success, enters `MemorySyncService.enqueueFact(...)`

### 6.10 Risk Points

- PKM writes are long-term structure; the cost of errors is high.
- Overly aggressive organization may disrupt the user's existing structure.
- `update_timeline_card_insight` and file edits need coordination to avoid insights referencing content not actually written.

### 6.11 Improvement Directions

- Add a separate switch or threshold for P.A.R.A. maintenance.
- Add diff preview / rollback metadata for PKM file edits.
- Apply stricter validation for related fact ids.

## 7. CommentAgent Design

### 7.1 Design Intent

CommentAgent lets virtual characters naturally comment on the user's private records, enhancing expressive feedback and companionship.

It is not a knowledge analysis Agent and should not behave like an assistant, coach, therapist, or product interface.

### 7.2 Trigger

Entry points:

- [`lib/data/services/task_handlers/comment_agent_handler.dart`](../lib/data/services/task_handlers/comment_agent_handler.dart)
- [`lib/agent/comment_agent/comment_agent.dart`](../lib/agent/comment_agent/comment_agent.dart)

Trigger:

```text
new input
  -> comment_agent_task
  dependsOn pkm_agent

cardCommentPosted
  -> process_ai_reply
```

### 7.3 Character Selection

Character selection paths:

1. Explicit `character_id` in payload
2. `@角色` (@character) in input
3. Single-character mode: `CharacterSelectionService.selectCharacter(...)`
4. Multi-character mode: `selectMultipleCharacters(...)`

### 7.4 Prompt Structure

Outer boundary:

- [`lib/agent/comment_agent/prompts.dart`](../lib/agent/comment_agent/prompts.dart)

Core skill prompt:

- `Prompts.commentSkillSystemPrompt(...)`
- File: [`lib/agent/prompts.dart`](../lib/agent/prompts.dart)

Dynamic character prompt:

- `CommentAgentSkill._buildSystemPrompt(...)`
- File: [`lib/agent/skills/comment_agent/comment_agent_skill.dart`](../lib/agent/skills/comment_agent/comment_agent_skill.dart)

Task message:

- `CommentAgent._buildCommentTaskMessage(...)`

### 7.5 Dynamic Context

From `CharacterContextAssembler.build(...)`:

- user profile
- character memory entries
- character world
- compressed interaction history
- recent cross-scene interactions
- user knowledge cards

Task message includes:

- original post
- initial insight
- PKM context
- existing comments
- reply routing
- user request
- current time / location context

### 7.6 Tools / Skills

Skill:

- `CommentAgentSkill`

Tools:

- `Read`
- `Grep`
- `SaveComment`
- `SkipComment`
- `MemoryRead`
- `MemoryWrite`
- `MemoryEdit`
- `MemoryRemove`
- `HistorySearch`

User reply scenarios can additionally enable:

- `append_memories`

### 7.7 Completion Mechanism

Must call one completion tool:

- `SaveComment`
- `SkipComment`

Both `SaveComment` and `SkipComment` return `stopFlag: true`.

### 7.8 Writes

`SaveComment` writes:

- Card comments
- character timeline event
- event log

### 7.9 Risk Points

- `character.systemPromptOverride` is currently placed before core rules and may override safety and tool rules.
- The prompt mentions `append_memories`, but ordinary initial comments may not have this tool.
- Character memory and user long-term memory are easily confused.
- Multi-character comments can become repetitive or excessively lively.

### 7.10 Improvement Directions

- Place non-overridable rules at the highest priority.
- Limit character override to "style/tone" and prohibit overriding tool and safety rules.
- Use two separate memory prompts for initial comments and user replies.
- Clarify a policy for "whether to speak."

## 8. PostCardRouterAgent Design

### 8.1 Design Intent

PostCardRouterAgent is a lightweight selector. It prevents all downstream Agents from running blindly.

### 8.2 Trigger

Entry points:

- [`lib/data/services/task_handlers/post_card_router_handler.dart`](../lib/data/services/task_handlers/post_card_router_handler.dart)
- [`lib/agent/post_card_router_agent/post_card_router_agent.dart`](../lib/agent/post_card_router_agent/post_card_router_agent.dart)

Trigger:

```text
userInputSubmitted
  -> post_card_router_task
  dependsOn analyze_assets
```

### 8.3 Prompt

File:

- [`lib/agent/post_card_router_agent/prompt.dart`](../lib/agent/post_card_router_agent/prompt.dart)

Core rules:

- Be conservative.
- An empty list is a valid answer.
- Call `select_downstream_agents` only once.
- Do not perform side effects.

### 8.4 Tool

Sole tool:

- `select_downstream_agents`

Optional targets:

- `schedule_aggregator`
- `ask_clarification`

### 8.5 Writes

Does not directly write business data.

Only:

- Publishes `scheduleAggregationRequested`
- Enqueues `ask_clarification_task`

### 8.6 Risk Points

- Insufficient recall: missing items that should enter schedule.
- Excessive recall: misclassifying ordinary records as schedule items.
- Excessive ask clarification disturbs the user.

### 8.7 Improvement Directions

- Add explainable thresholds for schedule and clarification separately.
- Write router results to task result for easier debugging.
- Distinguish manual refresh from automatic routing.

## 9. ScheduleAggregatorAgent Design

### 9.1 Design Intent

Maintains the user's current schedule state and generates magazine-style presentation.

### 9.2 Trigger

Entry points:

- [`lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart`](../lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart)
- [`lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)

Triggers:

- `scheduleAggregationRequested`
- Manual refresh
- PostCardRouterAgent activation

### 9.3 Prompt

Static prompt:

- [`lib/agent/schedule_aggregator_agent/prompt.dart`](../lib/agent/schedule_aggregator_agent/prompt.dart)

Skill prompt:

- `Prompts.scheduleAggregatorSkillPrompt(...)`

Dynamic context:

- current time
- schedule state
- router hint
- manual recent schedule input

### 9.4 Tools

- `get_schedule_state`
- `add_pending_item`
- `update_pending_item`
- `complete_pending_item`
- `complete_subtask`
- `set_presentation`
- `search_completed`

### 9.5 Data Model

Core service:

- [`lib/data/services/schedule_state_service.dart`](../lib/data/services/schedule_state_service.dart)

Core state:

- pending items
- completed items
- presentation

### 9.6 Completion Mechanism

`set_presentation` can set `stopFlag: true` to end the agent loop.

### 9.7 Risk Points

- The same item may be added repeatedly.
- todo and event fields are easily mixed up.
- presentation may reference non-existent item ids.

### 9.8 Improvement Directions

- Add an item merge / duplicate detection tool.
- Apply stronger schema validation for event/todo types.
- Split presentation generation and state mutation into two phases.

## 10. AskClarificationAgent Design

### 10.1 Design Intent

Asks the user one short question only when high-value ambiguous information appears.

### 10.2 Trigger

Entry points:

- [`lib/agent/ask_clarification_agent/ask_clarification_agent.dart`](../lib/agent/ask_clarification_agent/ask_clarification_agent.dart)
- [`lib/agent/skills/ask_clarification/ask_clarification_skill.dart`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)

Trigger:

```text
PostCardRouterAgent
  -> ask_clarification_task
```

### 10.3 Prompt

File:

- [`lib/agent/ask_clarification_agent/prompt.dart`](../lib/agent/ask_clarification_agent/prompt.dart)

Core rules:

- aggressive skip
- one question
- avoid duplicates
- prefer one-tap response
- do not block other Agents

### 10.4 Tools

- `create_clarification_request`
- `get_pending_clarification_requests`
- `get_recent_clarification_requests`

### 10.5 Writes

Writes:

- ClarificationRequestService
- Timeline attachment card generated by the service layer

### 10.6 Risk Points

- Asking too many questions ruins the logging experience.
- Unstable dedupe_key causes repeated questions.
- Overly specific proposed_memory induces Resolution to write incorrect memory.

### 10.7 Improvement Directions

- Add a user disturbance budget for clarification.
- Establish templates for question types.
- Add a standardized helper for dedupe_key.

## 11. ClarificationResolutionAgent Design

### 11.1 Design Intent

After the user answers a clarification, determines whether the answer is worth writing to long-term user memory.

### 11.2 Trigger

Entry points:

- [`lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart`](../lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart)
- [`lib/data/services/task_handlers/clarification_resolution_handler.dart`](../lib/data/services/task_handlers/clarification_resolution_handler.dart)

Trigger:

```text
clarificationAnswered
  -> clarification_resolution_task
```

### 11.3 Prompt

Inline prompt; core rules:

- Only write stable facts, preferences, relationships, identity, habits, and long-term project context.
- Do not write temporary card-only corrections.
- Do not concretize vague/manual/unknown.
- Output in the same language.
- dedupe against existing memory.

### 11.4 Tools

- `append_memories`

### 11.5 Fallback

When LLM fails:

- `_buildFallbackMemory(...)`
- Prefer option memory
- Then consider proposed_memory
- Do not write vague options

### 11.6 Risk Points

- If proposed_memory templates are over-designed, incorrect long-term facts may be written.
- Multiple choice needs handling for multiple memory concatenation.
- Custom input may be more specific than options, but the current fallback conservatively does not write custom answers.

### 11.7 Improvement Directions

- Store "expected write type" for each clarification request.
- Add source fact id to memory writes.
- Record resolution decision rationale for user review.

## 12. KnowledgeInsightAgent Design

### 12.1 Design Intent

Mines trends, patterns, life states, and cross-record insights from long-term data.

### 12.2 Trigger

Entry points:

- [`lib/agent/insight_agent/knowledge_insight_agent.dart`](../lib/agent/insight_agent/knowledge_insight_agent.dart)
- [`lib/data/services/task_handlers/knowledge_insight_handler.dart`](../lib/data/services/task_handlers/knowledge_insight_handler.dart)

Triggers:

- Manual update
- `knowledgeInsightRefreshRequested`

### 12.3 Prompt

Static prompt:

- [`lib/agent/insight_agent/prompt.dart`](../lib/agent/insight_agent/prompt.dart)

Skill prompt:

- `Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(...)`

Dynamic context:

- current time
- knowledge insight run context
- existing insight cards
- user activity stats
- memory read-only prompt

### 12.4 Tools

File read:

- `LS`
- `Glob`
- `Grep`
- `Read`
- `BatchRead`

General:

- `search_workspace_event_logs`
- `getCurrentTime`

Insight skill:

- `get_exists_knowledge_insight_cards`
- `save_knowledge_insight_cards`
- `delete_knowledge_insight_card`
- `delete_knowledge_insight_tags`
- `get_available_insight_card_templates`
- `get_user_activity_stats`

### 12.5 Permissions

```text
Workspace: read
Facts: read
Cards: read
PKM: read
KnowledgeInsights: write
```

### 12.6 Sub-Agents

`disableSubAgents: false`

Design implications:

- Large-scale data collection can be delegated to clone subagents.
- The main Agent is responsible for final insights and writes.

### 12.7 Risk Points

- Full analysis is costly.
- Insights may over-infer from small samples.
- Event logs only start from 2026-01-23; history must be queried from files.

### 12.8 Improvement Directions

- Introduce insight confidence / evidence list.
- Split initial full analysis from incremental analysis.
- Apply a more conservative strategy for deleting old insights.

## 13. MemoryAgent Design

### 13.1 Design Intent

Batch-compresses user input into a long-term user profile, without recording a running log of events.

### 13.2 Trigger

Entry points:

- [`lib/data/services/memory_sync_service.dart`](../lib/data/services/memory_sync_service.dart)
- [`lib/agent/memory_agent/memory_agent.dart`](../lib/agent/memory_agent/memory_agent.dart)

Trigger:

```text
PkmAgent success
  -> MemorySyncService.enqueueFact
  -> batch threshold 5
  -> MemoryAgent.run
```

### 13.3 Prompt

Inline Strict Memory Curator prompt.

Core strategy:

- Default deny.
- Most input is not written to memory.
- Only retain user attributes sustainable over months/years.
- Language matches input.
- Do not treat system media analysis as the user's original words.

### 13.4 Tools

- `append_memories`
- `AskClarificationSkill`

### 13.5 Writes

Writes user-level memory via `MemoryManagement`.

### 13.6 Risk Points

- Long-term memory pollution.
- System analysis content mistaken for user self-report.
- Oversized batch context leads to coarse extraction.

### 13.7 Improvement Directions

- Add source fact ids to memory entries.
- Allow users to review/revoke newly added memory.
- Write by type for preference, identity, and habit.

## 14. SuperAgent / Chat Design

### 14.1 Design Intent

SuperAgent is the central coordinating Agent when the user actively chats. It is not a single-task Agent, but an intent recognition and tool coordination layer.

### 14.2 Trigger

Entry points:

- [`lib/data/services/chat_service.dart`](../lib/data/services/chat_service.dart)
- [`lib/agent/super_agent/super_agent.dart`](../lib/agent/super_agent/super_agent.dart)

Triggers:

- Ordinary chat
- timeline card detail chat
- insight card chat
- quick query

### 14.3 Prompt

Static prompt:

- [`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart)

Dynamic supplements:

- Comprehensive correction principles
- Interaction guidelines
- Page scene context
- Location context
- refs context
- current time
- memory prompt
- quick query read-only prompt

### 14.4 Tools

Normal mode:

- Full file tool suite
- `search_workspace_event_logs`
- `getCurrentTime`
- `get_pkm_overview`
- memory tools

Quick Query:

- `LS`
- `Glob`
- `Grep`
- `Read`
- `BatchRead`
- `search_event_logs`
- `getCurrentTime`
- `get_pkm_overview`

### 14.5 Skills

- `KnowledgeInsightSkill`
- `TimelineCardSkill`
- `PkmSkill`
- `SystemActionSkill`
- `AskClarificationSkill`

Scene forced activation:

- timeline card detail: `manage_timeline_card`, `manage_pkm`
- insight card chat: `update_knowledge_insight`

### 14.6 Risk Points

- Normal mode has broad file write permissions.
- When multiple skills are simultaneously available, the model may over-call heavy tools.
- Chat corrections may need to synchronously modify Cards, PKM, and Asset Analysis; logic is complex.

### 14.7 Improvement Directions

- Introduce an intent router to select capabilities before exposing tools.
- Add confirmation for high-risk write operations.
- More thoroughly isolate quick query and full chat at the UI/Agent layer.

## 15. CompanionAgent Design

### 15.1 Design Intent

CompanionAgent is the character private chat Agent, with goals of long-term companionship and relationship continuity.

### 15.2 Trigger

Entry points:

- [`lib/agent/companion_agent/companion_agent.dart`](../lib/agent/companion_agent/companion_agent.dart)
- [`lib/agent/skills/companion_agent/companion_agent_skill.dart`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)

Trigger:

- Character chat interface calls `CompanionAgent.chat(...)`

### 15.3 Prompt

Dynamic prompt:

- character system prompt override
- character persona
- user profile
- character memory entries
- style examples
- behavior rules
- safety boundary
- memory update guidance

### 15.4 Tools

Character-level:

- `MemoryRead`
- `MemoryWrite`
- `MemoryEdit`
- `MemoryRemove`
- `HistorySearch`
- `SendActionMessage`

User-level:

- `append_memories`

### 15.5 Context

From `CharacterContextAssembler`:

- character world
- compressed checkpoints
- recent timeline
- user knowledge cards

### 15.6 Compression

After conversation, based on token usage, calls:

- `CharacterContextCompressor.compressIfNeeded(...)`

### 15.7 Risk Points

- Excessive anthropomorphism or dependency.
- Character-level memory and user-level memory confusion.
- In safety crises, must maintain character feel without sacrificing real-world help.

### 15.8 Improvement Directions

- Add categories to character memory writes.
- Establish a unified template for safety escalation.
- Make a clearer UI distinction between "character action messages" and "spoken text."

## 16. Extended Agent Design

### 16.1 PersonaAgent

Responsibilities:

- Design or update virtual character persona.

Entry point:

- [`lib/agent/persona_agent/persona_agent.dart`](../lib/agent/persona_agent/persona_agent.dart)

Tools:

- PKM read tools
- `GetCharacterPersona`
- `CreateOrUpdateCharacterPersona`

Design issues:

- Current profileContent is TODO.
- Character creation writes YAML directly; further evaluation is needed on whether it should fully go through CharacterService.

### 16.2 Custom Agent Hosts

Responsibilities:

- Let users define event-driven Agents.

Entry points:

- [`lib/data/services/custom_agent_config_service.dart`](../lib/data/services/custom_agent_config_service.dart)
- [`lib/data/services/task_handlers/custom_agent_task_handler.dart`](../lib/data/services/task_handlers/custom_agent_task_handler.dart)
- [`lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart`](../lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart)
- [`lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart`](../lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart)

Design characteristics:

- Custom event subscriptions.
- Event serializer converts events to XML.
- Supports converting images/audio from XML into multimodal parts.
- Supports file-based skills and JavaScript runtime.
- Run results create chat session and system_task card.

Risks:

- Custom prompt / skill permissions need strict isolation.
- workingDirectory determines writable boundaries.

## 17. Cross-Cutting Design: Memory

### 17.1 User-Level Memory

Uses:

- User identity
- Long-term preferences
- Habits
- Assets / environment
- AI interaction preferences

Primary users:

- MemoryAgent
- SuperAgent
- CompanionAgent
- ClarificationResolutionAgent
- CommentAgent reply scenarios

Core file:

- [`lib/agent/memory/memory_management.dart`](../lib/agent/memory/memory_management.dart)

### 17.2 Character-Level Memory

Uses:

- Dynamics of the relationship between character and user
- Support preferences
- Style feedback
- Emotional patterns
- open threads
- inside jokes

Primary users:

- CommentAgent
- CompanionAgent

Core files:

- [`lib/agent/memory/character_memory_service.dart`](../lib/agent/memory/character_memory_service.dart)
- [`lib/agent/skills/comment_agent/tools/memory_tools.dart`](../lib/agent/skills/comment_agent/tools/memory_tools.dart)

### 17.3 Design Principles

- User-level memory is cross-character global facts.
- Character-level memory is a specific character's relationship context.
- Do not store chat transcripts directly as memory.
- Do not directly convert system media analysis into memory.

## 18. Cross-Cutting Design: File Permissions

Core files:

- [`lib/agent/security/file_permission_manager.dart`](../lib/agent/security/file_permission_manager.dart)
- [`lib/agent/built_in_tools/file_tools.dart`](../lib/agent/built_in_tools/file_tools.dart)

Typical permissions:

| Agent | Permission Design |
| --- | --- |
| PkmAgent | `/PKM` write |
| KnowledgeInsightAgent | Workspace/Cards/Facts/PKM read, KnowledgeInsights write |
| SuperAgent | Workspace write; Quick Query read-only |
| CommentAgent | Workspace read for Read/Grep |
| PersonaAgent | PKM read |
| Custom hosts | configured workingDirectory write |

Design principles:

- Do not bypass FileSystemService.
- Do not directly operate on workspace paths.
- Agents should not have write permissions beyond their responsibilities.

## 19. Cross-Cutting Design: LLM Configuration

Core entry points:

- `UserStorage.getAgentLLMResources(agentId)`
- `UserStorage.getAgentLLMConfig(agentId)`

Design characteristics:

- Each configurable Agent can independently select a model.
- When unconfigured, some Agents skip or use rule-based fallback.

Common fallbacks:

- CardAgent: rule-based card matcher
- PkmAgent: skip
- PostCardRouter: skip
- CommentAgent: skip
- AnalyzeAssets: skip LLM analysis, retain safety/preprocessing results

## 20. Cross-Cutting Design: Failure / Retry

Task execution:

- `LocalTaskExecutor`

Failure handling:

- `handleGenericAgentFailure`
- `handleCardAgentFailureImpl`
- `rethrowIfNonRetryable(...)`

Design characteristics:

- Heavy tasks are persisted.
- Agent state is recoverable.
- Some tasks have by-user concurrency policy.

Notes:

- Agent prompt changes may affect retry behavior.
- Tool stopFlag changes may cause loop detection or incomplete tasks.

## 21. Most Worthwhile Design Improvements Right Now

### 21.1 CommentAgent Prompt Priority

Problem:

- character override is currently placed before core rules.

Recommendation:

- Non-overridable rules at highest priority.
- Override only as character style; must not override tool/safety.

### 21.2 CommentAgent Memory Tool Mismatch

Problem:

- Prompt mentions `append_memories`, but ordinary automatic comments may not have this tool.

Recommendation:

- Initial comment prompt should not mention user-level memory.
- User reply prompt may allow user-level memory updates.

### 21.3 SuperAgent Permissions Too Broad

Problem:

- Ordinary chat has workspace write and multiple skills.

Recommendation:

- Introduce an intent router.
- Default to read-only first; write operations require explicit confirmation or entering a specific skill mode.

### 21.4 KnowledgeInsight Insufficient Evidence Chain

Problem:

- Insights may lack explicit evidence.

Recommendation:

- Add evidence facts / pkm refs / confidence to insight cards.

### 21.5 PKM Automatic Maintenance Too Implicit

Problem:

- PkmAgent can be triggered by system reminder to reorganize structure, but the user may not be aware.

Recommendation:

- Output an explicit action summary for maintenance.
- Add preview or a separate task for large-scale refactoring.

### 21.6 Clarification Disturbance Budget

Problem:

- Although the prompt calls for aggressive skip, there is no system-level budget.

Recommendation:

- Limit unanswered clarifications per day/week.
- After user dismisses, raise the threshold for similar questions.

## 22. Design Checklist Before Changing an Agent

Before changing any core Agent, at minimum check:

1. Does it affect event triggers?
2. Does it affect task dependencies?
3. Does it affect prompt priority?
4. Does it affect tool availability?
5. Does it affect file permissions?
6. Does it affect memory writes?
7. Does it affect stopFlag?
8. Does it affect task retry / resume?
9. Does it require migrating existing state?
10. Does it require new tests or evals?

## 23. Recommended Next Splits

If continuing systematic optimization, recommend splitting documentation or tasks in this order:

1. `CommentAgent` design refactor
2. `SuperAgent` intent router design
3. `PKM Agent` write and maintenance safety design
4. `KnowledgeInsight` evidence schema design
5. `Memory` user-level / character-level boundary design
6. `Clarification` disturbance budget and resolution policy design

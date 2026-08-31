# Memex Agent Capability Map

[中文](agent_overview.md) | English

This document inventories Memex built-in Agents, host Agents, Prompts, and Tools based on the current codebase. Its goal is not a product introduction, but to help you go deeper on each Agent's responsibility boundaries, trigger mechanisms, Prompt sources, and tool write scope.

Related entry points:

- HTML visualization page: [agent_overview.html](agent_overview.html)
- Code reading index: [agent_prompt_tools_code_index.md](agent_prompt_tools_code_index.md)
- Agent ID registry: [`lib/domain/models/agent_definitions.dart`](../lib/domain/models/agent_definitions.dart)
- Event subscriptions and task registration: [`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)

## 1. Overall Mental Model

Memex Agent capability is not determined by the system prompt alone, but jointly constrained by five layers:

1. **Event triggering**: `GlobalEventBus` decides which events enqueue which tasks.
2. **Task execution**: `LocalTaskExecutor` persists tasks and handles retries, dependencies, and concurrency policy.
3. **Agent construction**: Each Agent declares `systemPrompts`, `tools`, `skills`, `planMode`, `disableSubAgents`, compressor, and state persistence inside `StatefulAgent(...)`.
4. **Permission boundaries**: All file tools go through `FilePermissionManager`; different Agents have different readable/writable roots.
5. **Dynamic context**: memory, location, event logs, schedule state, character context, PKM overview, and similar data are injected via prompt/reminder.

Therefore, when tuning Agent behavior you should look at prompt, tools schema, handler payload, permissions, and stopFlag together.

## 2. Main Pipeline After User Input

The main entry is `MemexRouter._registerEventSubscriptions()`.

After the user submits an input, the system publishes `SystemEventTypes.userInputSubmitted`, then enters the following pipeline:

1. `handle_analyze_assets`
   - Subscription ID: `analyze_assets`
   - Task type: `handle_analyze_assets`
   - Responsible for image/audio analysis, EXIF, GPS, OCR.

2. `card_agent_task`
   - Subscription ID: `card_agent`
   - Depends on: `analyze_assets`
   - Generates or updates a Timeline Card.

3. `pkm_agent_task`
   - Subscription ID: `pkm_agent`
   - Depends on: `analyze_assets`
   - Serial dependency on the previous PKM task, to avoid concurrent PKM modifications.
   - Writes PKM and updates the card insight.

4. `comment_agent_task`
   - Subscription ID: `comment_agent`
   - Depends on: `pkm_agent`
   - Selects a character and generates a private timeline comment.

5. `post_card_router_task`
   - Subscription ID: `post_card_router`
   - Depends on: `analyze_assets`
   - Only does routing decisions, and triggers as needed:
     - `schedule_aggregator_task`
     - `ask_clarification_task`

Other important events:

- `cardCommentPosted` -> `process_ai_reply`
- `knowledgeInsightRefreshRequested` -> `knowledge_insight_task`
- `scheduleAggregationRequested` -> `schedule_aggregator_task`
- `clarificationAnswered` -> `clarification_resolution_task`

## 3. Built-in Agents Configurable on the Settings Page

Configurable Agent IDs come from `AgentDefinitions.displayNames`.

| Agent ID | Display name | Implementation/entry | Core responsibility |
| --- | --- | --- | --- |
| `analyze_assets` | Media analysis | `analyze_assets_handler.dart` | Analyze input attachments, produce `.analysis.txt` and OCR |
| `card_agent` | Cards | `CardAgent` | Turn input into a structured Timeline Card |
| `pkm_agent` | PKM | `PkmAgent` | Organize input into P.A.R.A. PKM, and write back card insight |
| `knowledge_insight_agent` | Insights | `KnowledgeInsightAgent` | Analyze Facts/PKM/Cards, maintain Knowledge Insight cards |
| `comment_agent` | Comments | `CommentAgent` | Character comments and user reply handling |
| `chat_agent` | Chat | `SuperAgent` | Default chat hub, calls tools and skills as needed |
| `companion_agent` | Companion | `CompanionAgent` | Character private chat, maintains character-level and user-level memory |
| `profile_agent` | Memory summary | `MemoryAgent` | Batch extraction of long-term user memory |
| `post_card_router_agent` | Post-Card Router | `PostCardRouterAgent` | Decides whether to trigger schedule or clarification Agents |
| `schedule_aggregator_agent` | Schedule | `ScheduleAggregatorAgent` | Maintains schedule state and presentation |
| `ask_clarification_agent` | Ask Clarification | `AskClarificationAgent` | Decides whether a clarification question should be created |
| `clarification_resolution_agent` | Ask resolution | `ClarificationResolutionAgent` | After the user answers a clarification, decides whether to write long-term memory |

## 4. Agent-by-Agent Details

### 4.1 Media analysis

The implementation is not a full `StatefulAgent`, but an LLM tool-style task handler; it is still configured independently in model settings.

- Entry: [`lib/data/services/task_handlers/analyze_assets_handler.dart`](../lib/data/services/task_handlers/analyze_assets_handler.dart)
- Prompt: `Prompts.assetAnalysisPrompt(...)`
- LLM resource ID: `AgentDefinitions.analyzeAssets`
- Capabilities:
  - Attachment safety checks
  - Image dimensions, EXIF time, GPS coordinates
  - Reverse geocoding and matching against user-tagged places
  - Image/audio multimodal description
  - Google ML Kit OCR
- Writes:
  - `{asset}.analysis.txt`
  - `{asset}.ocr.txt`
- Downstream dependents:
  - `CardAgent`
  - `PkmAgent`
  - `PostCardRouterAgent`

### 4.2 CardAgent

Turns each raw input into a timeline card.

- Entry: [`lib/agent/card_agent/card_agent.dart`](../lib/agent/card_agent/card_agent.dart)
- Handler: [`lib/data/services/task_handlers/card_agent_handler.dart`](../lib/data/services/task_handlers/card_agent_handler.dart)
- Prompt:
  - [`lib/agent/card_agent/prompts.dart`](../lib/agent/card_agent/prompts.dart)
  - `Prompts.cardAgentUserMessagePromptForPublishNewContent(...)`
  - `Prompts.timelineCardSkillSystemPrompt(...)`
- Skill:
  - `TimelineCardSkill(forceActivate: true, stopAfterSuccessSaveCard: true)`
- Tools:
  - `get_card_metadata`
  - `save_timeline_card`
- Memory:
  - Injects a user memory reminder, read-only.
- Writes:
  - Cards YAML
  - After rendering the card, refreshes the UI via `EventBusService`.
- Fallback:
  - Uses `rule_based_card_matcher.dart` when the LLM is not configured.
- Key constraints:
  - `fact_id` must match the original input.
  - `ui_configs` must be complete and cannot be empty.
  - After the run, checks whether the card exists, whether status is completed, and whether title and ui config are complete.

### 4.3 PkmAgent

Organizes input into the `/PKM` P.A.R.A. structure, and writes knowledge insight back onto the card.

- Entry: [`lib/agent/pkm_agent/pkm_agent.dart`](../lib/agent/pkm_agent/pkm_agent.dart)
- Handler: [`lib/data/services/task_handlers/pkm_agent_handler.dart`](../lib/data/services/task_handlers/pkm_agent_handler.dart)
- Prompt:
  - [`lib/agent/pkm_agent/prompts.dart`](../lib/agent/pkm_agent/prompts.dart)
  - `Prompts.pkmAgentInstructionForNewPublishedContent(...)`
  - `Prompts.pkmSkillSystemPrompt(...)`
- Skill:
  - `PkmSkill(forceActivate: true, workingDirectory: '/')`
- File tools:
  - `Read`
  - `BatchRead`
  - `Write`
  - `Edit`
  - `Move`
  - `Remove`
  - `LS`
  - `Glob`
  - `Grep`
- Skill tools:
  - `update_timeline_card_insight`
  - `skip_pkm_organization`
- Permissions:
  - Write-only to `FileSystemService.getPkmPath(userId)`.
- Memory:
  - User memory is injected as a read-only reminder.
  - PkmAgent is not given memory write tools.
- Key constraints:
  - `detectNonPersistentInput()` identifies inputs such as "don't remember / don't save / don't write long-term memory" before they reach the LLM.
  - PKM tasks run serially to avoid concurrent edits.
  - File-read tools append a system reminder in cases such as oversized structure, fragmentation, date-based filenames, and frequent edits, so the Agent can proactively reorganize.

### 4.4 KnowledgeInsightAgent

Maintains Knowledge Insights, producing insight cards such as stats, trends, maps, charts, and summaries.

- Entry: [`lib/agent/insight_agent/knowledge_insight_agent.dart`](../lib/agent/insight_agent/knowledge_insight_agent.dart)
- Prompt: [`lib/agent/insight_agent/prompt.dart`](../lib/agent/insight_agent/prompt.dart)
- Skill: [`KnowledgeInsightSkill`](../lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart)
- Tools:
  - File-read tools: `LS`, `Glob`, `Grep`, `Read`, `BatchRead`
  - `search_workspace_event_logs`
  - `getCurrentTime`
  - `get_exists_knowledge_insight_cards`
  - `save_knowledge_insight_cards`
  - `delete_knowledge_insight_card`
  - `delete_knowledge_insight_tags`
  - `get_available_insight_card_templates`
  - `get_user_activity_stats`
- Permissions:
  - Facts, Cards, PKM, Workspace are read-only.
  - KnowledgeInsights is writable.
- Memory:
  - memory read-only prompt.
- Key constraints:
  - On the first run, if there are no existing insights, a full analysis is required.
  - `planMode: PlanMode.auto`
  - `disableSubAgents: false`; the prompt allows clone subagents for complex tasks.

### 4.5 CommentAgent

Generates character comments on the user's private timeline, and also handles user replies to comments.

- Entry: [`lib/agent/comment_agent/comment_agent.dart`](../lib/agent/comment_agent/comment_agent.dart)
- Handler: [`lib/data/services/task_handlers/comment_agent_handler.dart`](../lib/data/services/task_handlers/comment_agent_handler.dart)
- Prompt:
  - [`lib/agent/comment_agent/prompts.dart`](../lib/agent/comment_agent/prompts.dart)
  - `Prompts.commentSkillSystemPrompt(...)`
  - Character persona, system prompt override, style examples
  - User profile, character memory, character world, recent interactions, PKM/card context
- Skill:
  - `CommentAgentSkill`
- Tools:
  - `Read`
  - `Grep`
  - `SaveComment`
  - `SkipComment`
  - When a character is present: `MemoryRead`, `MemoryWrite`, `MemoryEdit`, `MemoryRemove`, `HistorySearch`
  - In the user-reply scenario, user-level `append_memories` can be enabled
- Character selection:
  - Explicit `@character` takes priority.
  - Single-character mode uses `CharacterSelectionService.selectCharacter(...)`.
  - Multi-character mode uses `selectMultipleCharacters(...)`.
- Key constraints:
  - Visible output must come from the character identity.
  - Must not present as Memex, an assistant, an analyst, or a therapist.
  - Comments should be short, natural, and low-interruption.

### 4.6 Chat / SuperAgent

The central Agent for the default chat entry point.

- Entry: [`lib/data/services/chat_service.dart`](../lib/data/services/chat_service.dart)
- Agent: [`lib/agent/super_agent/super_agent.dart`](../lib/agent/super_agent/super_agent.dart)
- Prompt: [`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart)
- ChatService additionally injects:
  - Comprehensive error-correction principles
  - Interaction guidelines
  - Page/scene context
  - location context
  - refs context
  - Current time
- Tools:
  - Full set of file tools
  - `search_workspace_event_logs`
  - `getCurrentTime`
  - `get_pkm_overview`
  - Memory tools are added when not in Quick Query mode
- Skills:
  - `KnowledgeInsightSkill`
  - `TimelineCardSkill`
  - `PkmSkill`
  - `SystemActionSkill`
  - `AskClarificationSkill`
- Quick Query:
  - Read-only mode.
  - Keeps only `LS`, `Glob`, `Grep`, `Read`, `BatchRead`, `search_event_logs`, `getCurrentTime`, `get_pkm_overview`.
  - Excludes `manage_timeline_card` and `ask_clarification`.

### 4.7 CompanionAgent

Character private-chat Agent.

- Entry: [`lib/agent/companion_agent/companion_agent.dart`](../lib/agent/companion_agent/companion_agent.dart)
- Skill: [`CompanionAgentSkill`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)
- Dynamic Prompt sources:
  - Character persona
  - character system prompt override
  - style examples
  - user profile
  - character memory entries
  - character world
  - compressed interaction history
  - recent cross-scene interactions
  - user knowledge cards
  - memory update guidance
- Tools:
  - character-level: `MemoryRead`, `MemoryWrite`, `MemoryEdit`, `MemoryRemove`, `HistorySearch`
  - action: `SendActionMessage`
  - user-level: `append_memories`
- Key constraints:
  - Should feel like a real chat, not like an assistant, coach, therapist, or product UI.
  - For ordinary emotional chat, give a visible reply first; tools cannot replace the reply.
  - User-level memory and character-level memory are separate.
  - Has safety-response rules for self-harm, harming others, abuse, or acute crisis.

### 4.8 MemoryAgent / profile_agent

Batch extraction of long-term user memory.

- Entry: [`lib/agent/memory_agent/memory_agent.dart`](../lib/agent/memory_agent/memory_agent.dart)
- Trigger service: [`lib/data/services/memory_sync_service.dart`](../lib/data/services/memory_sync_service.dart)
- LLM resource ID: `AgentDefinitions.profileAgent`
- Prompt:
  - Inline `Strict Memory Curator` prompt.
- Tools:
  - `append_memories`
  - `AskClarificationSkill`
- Triggers:
  - After PkmAgent succeeds, `MemorySyncService.enqueueFact(...)`.
  - By default, processes after 5 facts have accumulated.
- Key constraints:
  - Default deny: most inputs are not written to memory.
  - Excludes tasks, reminders, temporary context, one-off actions, and already-known information.
  - Only keeps identity, strong preferences, long-term assets/environment, habits, and AI interaction preferences.
  - Memory language must match the input.

### 4.9 PostCardRouterAgent

Lightweight post-card routing Agent.

- Entry: [`lib/agent/post_card_router_agent/post_card_router_agent.dart`](../lib/agent/post_card_router_agent/post_card_router_agent.dart)
- Prompt: [`lib/agent/post_card_router_agent/prompt.dart`](../lib/agent/post_card_router_agent/prompt.dart)
- Tool:
  - `select_downstream_agents`
- Activatable targets:
  - `schedule_aggregator`
  - `ask_clarification`
- Key constraints:
  - Makes only one tool call.
  - May return an empty list.
  - Must not write PKM, create cards, or modify schedule.

### 4.10 ScheduleAggregatorAgent

Maintains schedule state and schedule presentation.

- Entry: [`lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart`](../lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart)
- Prompt: [`lib/agent/schedule_aggregator_agent/prompt.dart`](../lib/agent/schedule_aggregator_agent/prompt.dart)
- Skill: [`ScheduleAggregationSkill`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)
- Tools:
  - `get_schedule_state`
  - `add_pending_item`
  - `update_pending_item`
  - `complete_pending_item`
  - `complete_subtask`
  - `set_presentation`
  - `search_completed`
- Data:
  - `ScheduleStateService`
- Key constraints:
  - `set_presentation` can stop the agent loop.
  - State mutations must execute in dependency order.
  - Presentation timeline is at most 7 days.
  - Output language must match the user input.

### 4.11 AskClarificationAgent

Decides whether to create a high-value clarification question.

- Entry: [`lib/agent/ask_clarification_agent/ask_clarification_agent.dart`](../lib/agent/ask_clarification_agent/ask_clarification_agent.dart)
- Prompt: [`lib/agent/ask_clarification_agent/prompt.dart`](../lib/agent/ask_clarification_agent/prompt.dart)
- Skill: [`AskClarificationSkill`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)
- Tools:
  - `create_clarification_request`
  - `get_pending_clarification_requests`
  - `get_recent_clarification_requests`
- Memory:
  - read-only user memory snapshot.
- Key constraints:
  - aggressive skip.
  - Ask only one question.
  - Prefer one-tap types: `confirm`, `single_choice`, `multi_choice`.
  - Must avoid semantic duplication.
  - Does not block other Agents.

### 4.12 ClarificationResolutionAgent

After the user answers a clarification, decides whether the answer becomes long-term memory.

- Entry: [`lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart`](../lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart)
- Handler: [`lib/data/services/task_handlers/clarification_resolution_handler.dart`](../lib/data/services/task_handlers/clarification_resolution_handler.dart)
- Prompt:
  - Inline Agent system prompt.
- Tools:
  - `append_memories`
- Inputs:
  - request
  - answerData
  - options
  - evidenceFactIds
  - existing memory context
- Key constraints:
  - Only writes stable facts, preferences, relationships, identity, habits, and long-term project context.
  - Does not write temporary card-only corrections.
  - Does not force vague/manual/unknown options into specifics.
  - When the LLM fails, the handler has a deterministic fallback.

## 5. Host and Supporting Agents

### 5.1 PersonaAgent

Character-design Agent.

- Entry: [`lib/agent/persona_agent/persona_agent.dart`](../lib/agent/persona_agent/persona_agent.dart)
- Prompt:
  - `_buildSystemPrompt(...)` inline.
- Tools:
  - `LS`
  - `Glob`
  - `Grep`
  - `Read`
  - `GetCharacterPersona`
  - `CreateOrUpdateCharacterPersona`
- Permissions:
  - File tools are PKM read-only.
- Responsibilities:
  - Designs or updates a character persona based on the user profile/PKM and existing characters.

### 5.2 Custom Agent Hosts

Execution hosts for custom Agents.

- Config service: [`lib/data/services/custom_agent_config_service.dart`](../lib/data/services/custom_agent_config_service.dart)
- Execution handler: [`lib/data/services/task_handlers/custom_agent_task_handler.dart`](../lib/data/services/task_handlers/custom_agent_task_handler.dart)
- Host types:
  - `PureSkillHostAgent`
  - `MemexSkillHostAgent`
- Inputs:
  - SystemEvent is serialized to XML.
  - `fs://...` image/audio references in the XML are converted into multimodal content parts.
- Tools:
  - File tools within the working directory
  - `search_workspace_event_logs`
  - `getCurrentTime`
  - File-based Skills
  - `FlutterJavaScriptRuntime`
- Outputs:
  - Creates a chat session.
  - Creates a system_task timeline card to display the run result.

### 5.3 MemexSkillHostAgent

Custom skill host with the Memex worldview.

- Entry: [`lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart`](../lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart)
- Prompt: [`lib/agent/memex_skill_host_agent/prompts.dart`](../lib/agent/memex_skill_host_agent/prompts.dart)
- Tools:
  - `LS`
  - `Glob`
  - `Grep`
  - `Read`
  - `BatchRead`
  - `Write`
  - `Move`
  - `Remove`
  - `Edit`
  - `search_workspace_event_logs`
  - `getCurrentTime`
- Does not include:
  - memory tools
  - PKM overview tool

### 5.4 PureSkillHostAgent

Lightweight custom skill host.

- Entry: [`lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart`](../lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart)
- Prompt:
  - `pureSkillHostAgentSystemPrompt`
  - Content is very short: a personal assistant on the phone, concise, helpful, and friendly.
- Tools:
  - Essentially the same as MemexSkillHostAgent.

### 5.5 FileSystemSkillAgent

Experimental handler.

- Entry: [`lib/data/services/task_handlers/file_system_skill_agent_handler.dart`](../lib/data/services/task_handlers/file_system_skill_agent_handler.dart)
- Status:
  - Currently `file_system_skill_agent_task` is not registered in `MemexRouter._init()`.
- Role:
  - Dynamically creates a `submit_summary` skill.
  - Has the Agent read `SKILL.md`, then use `RunJavaScript` to execute `scripts/on_submit.js`.

## 6. Core Tool Families

### 6.1 File System Tools

Implementation: [`lib/agent/built_in_tools/file_tools.dart`](../lib/agent/built_in_tools/file_tools.dart)

Tools:

- `Read`
- `BatchRead`
- `Write`
- `Edit`
- `Move`
- `Remove`
- `LS`
- `Glob`
- `Grep`

All file operations go through:

- `FilePermissionManager`
- `FileOperationService`
- `FileSystemService`

### 6.2 Event Logs

Implementation: [`lib/agent/built_in_tools/search_event_logs_tool.dart`](../lib/agent/built_in_tools/search_event_logs_tool.dart)

Tools:

- `search_workspace_event_logs`

Important limits:

- Event logs are recorded starting from **2026-01-23**.
- Earlier history must be looked up in workspace files.

### 6.3 Memory

Implementation: [`lib/agent/memory/memory_management.dart`](../lib/agent/memory/memory_management.dart)

User-level tools:

- `append_memories`

Character-level tools:

- `MemoryRead`
- `MemoryWrite`
- `MemoryEdit`
- `MemoryRemove`
- `HistorySearch`

### 6.4 System Action

Implementation: [`lib/agent/skills/manage_system_action/system_action_skill.dart`](../lib/agent/skills/manage_system_action/system_action_skill.dart)

Tools:

- `create_calendar_event`
- `create_reminder`
- `get_recent_actions`
- `cancel_action`

Constraints:

- Create or cancel actions only on an explicit request.
- Must look up recent actions before canceling/modifying.

## 7. Recommended Order for Digging Deeper into Prompts and Tools

1. First read [`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)
   - Look at task handler registration.
   - Look at event subscription.
   - Look at dependsOn, priority, concurrencyPolicy.

2. Then read each Agent's constructor
   - Search for `StatefulAgent(`.
   - Focus on `systemPrompts`, `tools`, `skills`, `planMode`, `disableSubAgents`, `systemCallback`.

3. Then read the Skill files
   - `lib/agent/skills/manage_timeline_card/timeline_card_skill.dart`
   - `lib/agent/skills/manage_pkm/pkm_skill.dart`
   - `lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart`
   - `lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`
   - `lib/agent/skills/ask_clarification/ask_clarification_skill.dart`
   - `lib/agent/skills/comment_agent/comment_agent_skill.dart`
   - `lib/agent/skills/companion_agent/companion_agent_skill.dart`

4. Finally read dynamic context
   - memory: `lib/agent/memory/`
   - character context: `lib/agent/context/`
   - schedule run context: `schedule_aggregator_agent.dart`
   - insight run context: `knowledge_insight_run_context.dart`
   - location context: `LocationContextService`

## 8. Checklist Before Changing a Prompt

- Is this behavior already supported by an existing tool/skill?
- Does the tool schema allow the model to pass the required fields?
- Does the Agent actually have that tool?
- Do file permissions allow reading/writing the target path?
- Is this Agent an automatic task or a chat scenario?
- Could it be ended early by `stopFlag`?
- Is there handler-level fallback or pre-skip logic?
- Do tests or evals need to be updated?
- Could it increase the risk of polluting long-term user memory?
- Could it break per-user workspace isolation?


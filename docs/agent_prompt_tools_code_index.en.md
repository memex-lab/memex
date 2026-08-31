# Memex Agent Prompt / Tools Code Index

[中文](agent_prompt_tools_code_index.md) | English

This index is organized in the order of "which code to read when you want to understand a given Agent." It supplements [agent_overview.md](agent_overview.md), focusing on source entry points, class names, function names, and tool names.

## 1. Global Entry Points

### Agent IDs and Settings Page

File: [`lib/domain/models/agent_definitions.dart`](../lib/domain/models/agent_definitions.dart)

Key objects:

```dart
class AgentDefinitions {
  static const String analyzeAssets = 'analyze_assets';
  static const String cardAgent = 'card_agent';
  static const String pkmAgent = 'pkm_agent';
  static const String knowledgeInsightAgent = 'knowledge_insight_agent';
  static const String commentAgent = 'comment_agent';
  static const String chatAgent = 'chat_agent';
  static const String companionAgent = 'companion_agent';
  static const String profileAgent = 'profile_agent';
  static const String postCardRouterAgent = 'post_card_router_agent';
  static const String scheduleAggregatorAgent = 'schedule_aggregator_agent';
  static const String askClarificationAgent = 'ask_clarification_agent';
  static const String clarificationResolutionAgent =
      'clarification_resolution_agent';
}
```

Purpose:

- `displayNames` controls what appears on the settings page.
- `configurableAgentIds` determines which Agents can be independently configured with a model.

### Task Handler Registration

File: [`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)

Read these first:

- `_init()`
- `_registerEventSubscriptions()`

Core handlers:

```text
handle_analyze_assets              -> handleAnalyzeAssetsImpl
card_agent_task                    -> handleCardAgentImpl
pkm_agent_task                     -> handlePkmAgentImpl
comment_agent_task                 -> handleCommentAgentImpl
process_ai_reply                   -> handleProcessAiReplyImpl
knowledge_insight_task             -> handleKnowledgeInsight
schedule_aggregator_task           -> handleScheduleAggregation
post_card_router_task              -> handlePostCardRouter
ask_clarification_task             -> handleAskClarificationTask
clarification_resolution_task      -> handleClarificationResolution
```

Core subscriptions:

```text
userInputSubmitted
  -> analyze_assets
  -> card_agent        dependsOn analyze_assets
  -> pkm_agent         dependsOn analyze_assets, plus previous pkm task
  -> comment_agent     dependsOn pkm_agent
  -> post_card_router  dependsOn analyze_assets

cardCommentPosted
  -> process_ai_reply

knowledgeInsightRefreshRequested
  -> knowledge_insight_task

scheduleAggregationRequested
  -> schedule_aggregator_task

clarificationAnswered
  -> clarification_resolution_task
```

## 2. Agent Constructor Index

### CardAgent

Files:

- [`lib/agent/card_agent/card_agent.dart`](../lib/agent/card_agent/card_agent.dart)
- [`lib/data/services/task_handlers/card_agent_handler.dart`](../lib/data/services/task_handlers/card_agent_handler.dart)

Read these first:

1. `processWithCardAgent(...)`
2. `CardAgent.runWithContent(...)`
3. `CardAgent._createAgent(...)`
4. `CardAgent.inspectCardRunCompletion(...)`

Key `StatefulAgent` parameters:

```dart
name: 'card_agent'
planMode: PlanMode.none
tools: []
skills: [
  TimelineCardSkill(stopAfterSuccessSaveCard: true, forceActivate: true)
]
systemPrompts: [cardAgentSystemPrompt]
disableSubAgents: true
systemCallback: createSystemCallback(userId)
```

Prompt sources:

- `cardAgentSystemPrompt`
- `Prompts.cardAgentUserMessagePromptForPublishNewContent(...)`
- `Prompts.timelineCardSkillSystemPrompt(...)`

Tool sources:

- `TimelineCardSkill._buildTools(...)`

### PkmAgent

Files:

- [`lib/agent/pkm_agent/pkm_agent.dart`](../lib/agent/pkm_agent/pkm_agent.dart)
- [`lib/data/services/task_handlers/pkm_agent_handler.dart`](../lib/data/services/task_handlers/pkm_agent_handler.dart)

Read these first:

1. `PkmAgent.detectNonPersistentInput(...)`
2. `processWithPkmAgent(...)`
3. `PkmAgent.runWithContent(...)`
4. `PkmAgent.createAgent(...)`
5. `PkmAgent._getPkmOverview(...)`

Key `StatefulAgent` parameters:

```dart
name: 'pkm_agent'
tools: [
  Read,
  BatchRead,
  Write,
  Edit,
  Move,
  Remove,
  LS,
  Glob,
  Grep,
]
skills: [
  PkmSkill(forceActivate: true, workingDirectory: '/')
]
systemPrompts: [pkmAgentSystemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Permissions:

```dart
PermissionRule(
  rootPath: fileService.getPkmPath(userId),
  access: FileAccessType.write,
)
```

Prompt sources:

- `pkmAgentSystemPrompt`
- `Prompts.pkmAgentInstructionForNewPublishedContent(...)`
- `Prompts.pkmSkillSystemPrompt(...)`
- dynamic PKM overview
- read-only user memory reminder

Tool sources:

- `FileToolFactory`
- `PkmSkill._buildTools(...)`

### KnowledgeInsightAgent

Files:

- [`lib/agent/insight_agent/knowledge_insight_agent.dart`](../lib/agent/insight_agent/knowledge_insight_agent.dart)
- [`lib/data/services/task_handlers/knowledge_insight_handler.dart`](../lib/data/services/task_handlers/knowledge_insight_handler.dart)
- [`lib/agent/insight_agent/knowledge_insight_run_context.dart`](../lib/agent/insight_agent/knowledge_insight_run_context.dart)

Read these first:

1. `KnowledgeInsightAgent.updateKnowledgeInsight(...)`
2. `KnowledgeInsightAgent._createAgent(...)`
3. `buildKnowledgeInsightRunContext(...)`
4. `_createInsightSummaryCardIfNeeded(...)`

Key `StatefulAgent` parameters:

```dart
name: 'knowledge_insight_agent'
tools: [
  LS,
  Glob,
  Grep,
  Read,
  BatchRead,
  search_workspace_event_logs,
  getCurrentTime,
]
skills: [KnowledgeInsightSkill(forceActivate: true)]
systemPrompts: [
  knowledgeInsightAgentSystemPrompt,
  memoryReadOnlyPrompt,
]
disableSubAgents: false
planMode: PlanMode.auto
```

Permissions:

```text
Workspace/Facts/Cards/PKM: read
KnowledgeInsights: write
```

Prompt sources:

- `knowledgeInsightAgentSystemPrompt`
- `Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(...)`
- `MemoryManagement.buildMemoryReadOnlyPrompt()`
- `buildKnowledgeInsightRunContext(...)`

Tool sources:

- `FileToolFactory`
- `buildSearchEventLogsTool()`
- `getCurrentTimeTool`
- `KnowledgeInsightSkill`

### CommentAgent

Files:

- [`lib/agent/comment_agent/comment_agent.dart`](../lib/agent/comment_agent/comment_agent.dart)
- [`lib/data/services/task_handlers/comment_agent_handler.dart`](../lib/data/services/task_handlers/comment_agent_handler.dart)
- [`lib/agent/context/character_context_assembler.dart`](../lib/agent/context/character_context_assembler.dart)

Read these first:

1. `handleCommentAgentImpl(...)`
2. `handleProcessAiReplyImpl(...)`
3. `CommentAgent.runWithContent(...)`
4. `CommentAgent._createAgent(...)`
5. `CharacterContextAssembler.build(...)`

Key `StatefulAgent` parameters:

```dart
name: 'comment_agent'
systemPrompts: [commentAgentSystemPrompt, memoryManagementPrompt]
tools: withMemoryManagement ? memory tools : []
skills: [CommentAgentSkill(... forceActivate: true)]
disableSubAgents: true
planMode: PlanMode.none
```

Prompt sources:

- `commentAgentSystemPrompt`
- `Prompts.commentAgentInitialCommentPrompt`
- `Prompts.commentSkillSystemPrompt(...)`
- character persona
- character system prompt override
- style examples
- character context reminders

Tool sources:

- `CommentAgentSkill`
- `CharacterToolsFactory.buildCommentTools(...)`
- optional `MemoryManagement.buildMemoryManagementTools()`

### SuperAgent / Chat

Files:

- [`lib/data/services/chat_service.dart`](../lib/data/services/chat_service.dart)
- [`lib/agent/super_agent/super_agent.dart`](../lib/agent/super_agent/super_agent.dart)
- [`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart)

Read these first:

1. `ChatService.sendMessage(...)`
2. `SuperAgent.createAgent(...)`
3. `ChatService._setupControllerListeners(...)`
4. `_createSession(...)` / `_addMessageToSession(...)`

Key `StatefulAgent` parameters:

```dart
name: agentName ?? 'memex_agent'
tools: quickQuery ? readOnlyTools : allTools + memoryTools
skills: [
  KnowledgeInsightSkill(),
  TimelineCardSkill(),
  PkmSkill(workingDirectory: '/PKM'),
  SystemActionSkill(),
  AskClarificationSkill(),
]
systemPrompts: [
  superAgentSystemPrompt,
  memorySystemPrompt,
  optionalQuickQueryPrompt,
  additionalSystemPrompt,
]
planMode: PlanMode.auto
disableSubAgents: true
```

Prompt sources:

- `superAgentSystemPrompt`
- inline additional prompt in `ChatService`
- scene context
- refs context
- location context
- current time
- memory prompt

Quick Query read-only tools:

```text
LS
Glob
Grep
Read
BatchRead
search_event_logs
getCurrentTime
get_pkm_overview
```

### CompanionAgent

Files:

- [`lib/agent/companion_agent/companion_agent.dart`](../lib/agent/companion_agent/companion_agent.dart)
- [`lib/agent/skills/companion_agent/companion_agent_skill.dart`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)
- [`lib/agent/context/character_context_assembler.dart`](../lib/agent/context/character_context_assembler.dart)

Read these first:

1. `CompanionAgent.chat(...)`
2. `CompanionAgent._createAgent(...)`
3. `CompanionAgentSkill._buildSystemPrompt(...)`
4. `CharacterContextCompressor.compressIfNeeded(...)`

Key `StatefulAgent` parameters:

```dart
name: 'companion_agent'
skills: [CompanionAgentSkill(... forceActivate: true)]
tools: memoryManagement.buildMemoryManagementTools()
systemPrompts: [memoryManagementPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Skill tools:

```text
MemoryRead
MemoryWrite
MemoryEdit
MemoryRemove
HistorySearch
SendActionMessage
```

### MemoryAgent / profile_agent

Files:

- [`lib/agent/memory_agent/memory_agent.dart`](../lib/agent/memory_agent/memory_agent.dart)
- [`lib/data/services/memory_sync_service.dart`](../lib/data/services/memory_sync_service.dart)
- [`lib/agent/memory/memory_management.dart`](../lib/agent/memory/memory_management.dart)

Read these first:

1. `MemorySyncService.enqueueFact(...)`
2. `MemorySyncService._processQueue(...)`
3. `MemorySyncService._processBatch(...)`
4. `MemoryAgent.run(...)`
5. `MemoryManagement.buildMemoryManagementTools()`

Key `StatefulAgent` parameters:

```dart
name: 'memory_agent'
tools: memoryManagement.buildMemoryManagementTools()
skills: [AskClarificationSkill()]
systemPrompts: [systemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Prompt sources:

- inline Strict Memory Curator prompt in `MemoryAgent.run(...)`
- existing memory context
- batch facts

### PostCardRouterAgent

Files:

- [`lib/agent/post_card_router_agent/post_card_router_agent.dart`](../lib/agent/post_card_router_agent/post_card_router_agent.dart)
- [`lib/data/services/task_handlers/post_card_router_handler.dart`](../lib/data/services/task_handlers/post_card_router_handler.dart)

Read these first:

1. `handlePostCardRouter(...)`
2. `runPostCardRouter(...)`
3. `PostCardRouterAgent.route(...)`
4. `_buildActivateTool(...)`
5. `_enqueueDownstream(...)`

Key `StatefulAgent` parameters:

```dart
name: 'post_card_router_agent'
tools: [select_downstream_agents]
systemPrompts: [postCardRouterSystemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Optional downstream:

```text
schedule_aggregator
ask_clarification
```

### ScheduleAggregatorAgent

Files:

- [`lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart`](../lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart)
- [`lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)
- [`lib/data/services/schedule_state_service.dart`](../lib/data/services/schedule_state_service.dart)

Read these first:

1. `ScheduleAggregatorAgent.updateScheduleAggregation(...)`
2. `ScheduleAggregatorAgent._createAgent(...)`
3. `_buildScheduleRunContext(...)`
4. `ScheduleAggregationSkill`
5. `ScheduleStateService`

Key `StatefulAgent` parameters:

```dart
name: 'schedule_aggregator_agent'
tools: const []
skills: [
  ScheduleAggregationSkill(
    forceActivate: true,
    stopAfterSetPresentation: true,
  )
]
systemPrompts: [scheduleAggregatorSystemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Skill tools:

```text
get_schedule_state
add_pending_item
update_pending_item
complete_pending_item
complete_subtask
set_presentation
search_completed
```

### AskClarificationAgent

Files:

- [`lib/agent/ask_clarification_agent/ask_clarification_agent.dart`](../lib/agent/ask_clarification_agent/ask_clarification_agent.dart)
- [`lib/agent/skills/ask_clarification/ask_clarification_skill.dart`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)
- [`lib/data/services/clarification_request_service.dart`](../lib/data/services/clarification_request_service.dart)

Read these first:

1. `handleAskClarificationTask(...)`
2. `AskClarificationAgent.run(...)`
3. `AskClarificationSkill._buildSystemPrompt()`
4. `AskClarificationSkill._buildTools()`

Key `StatefulAgent` parameters:

```dart
name: 'ask_clarification_agent'
tools: const []
skills: [AskClarificationSkill(forceActivate: true)]
systemPrompts: [askClarificationAgentSystemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Skill tools:

```text
create_clarification_request
get_pending_clarification_requests
get_recent_clarification_requests
```

### ClarificationResolutionAgent

Files:

- [`lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart`](../lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart)
- [`lib/data/services/task_handlers/clarification_resolution_handler.dart`](../lib/data/services/task_handlers/clarification_resolution_handler.dart)

Read these first:

1. `handleClarificationResolution(...)`
2. `ClarificationResolutionAgent.run(...)`
3. `_buildFallbackMemory(...)`

Key `StatefulAgent` parameters:

```dart
name: 'clarification_resolution_agent'
tools: memoryManagement.buildMemoryManagementTools()
systemPrompts: [inline resolution prompt]
disableSubAgents: true
planMode: PlanMode.none
```

Key tools:

```text
append_memories
```

## 3. Skill / Tool Code Index

### TimelineCardSkill

File: [`lib/agent/skills/manage_timeline_card/timeline_card_skill.dart`](../lib/agent/skills/manage_timeline_card/timeline_card_skill.dart)

Prompts:

- `Prompts.timelineCardSkillSystemPrompt(...)`
- Template source: [`timeline_templates.dart`](../lib/agent/skills/manage_timeline_card/timeline_templates.dart)

Tools:

```text
get_card_metadata
save_timeline_card
```

Write paths:

- `FileSystemService.updateCardFile(...)`
- `EventBusService.emitEvent(CardDetailUpdatedMessage(...))`

### PkmSkill

File: [`lib/agent/skills/manage_pkm/pkm_skill.dart`](../lib/agent/skills/manage_pkm/pkm_skill.dart)

Prompts:

- `Prompts.pkmSkillSystemPrompt(...)`

Tools:

```text
update_timeline_card_insight
skip_pkm_organization
```

Write paths:

- `FileSystemService.updateCardFile(...)`

### KnowledgeInsightSkill

File: [`lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart`](../lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart)

Prompts:

- `Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(...)`

Tools:

```text
get_exists_knowledge_insight_cards
save_knowledge_insight_cards
delete_knowledge_insight_card
delete_knowledge_insight_tags
get_available_insight_card_templates
get_user_activity_stats
```

Templates:

- [`lib/agent/skills/knowledge_insight/native_widgets.dart`](../lib/agent/skills/knowledge_insight/native_widgets.dart)

### ScheduleAggregationSkill

File: [`lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)

Prompts:

- `Prompts.scheduleAggregatorSkillPrompt(...)`

Tools:

```text
get_schedule_state
add_pending_item
update_pending_item
complete_pending_item
complete_subtask
set_presentation
search_completed
```

Services:

- `ScheduleStateService`

### AskClarificationSkill

File: [`lib/agent/skills/ask_clarification/ask_clarification_skill.dart`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)

Tools:

```text
create_clarification_request
get_pending_clarification_requests
get_recent_clarification_requests
```

Services:

- `ClarificationRequestService`

### CommentAgentSkill

File: [`lib/agent/skills/comment_agent/comment_agent_skill.dart`](../lib/agent/skills/comment_agent/comment_agent_skill.dart)

Prompts:

- `Prompts.commentSkillSystemPrompt(...)`
- character persona
- character memory
- style examples

Tool sources:

- `CharacterToolsFactory.buildCommentTools(...)`

### CompanionAgentSkill

File: [`lib/agent/skills/companion_agent/companion_agent_skill.dart`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)

Prompts:

- `CompanionAgentSkill._buildSystemPrompt(...)`

Tool sources:

- `CharacterToolsFactory.buildCompanionTools(...)`

### CharacterToolsFactory

File: [`lib/agent/skills/character_tools_factory.dart`](../lib/agent/skills/character_tools_factory.dart)

Comment tools:

```text
Read
Grep
SaveComment
SkipComment
MemoryRead
MemoryWrite
MemoryEdit
MemoryRemove
HistorySearch
```

Companion tools:

```text
MemoryRead
MemoryWrite
MemoryEdit
MemoryRemove
HistorySearch
SendActionMessage
```

### SystemActionSkill

File: [`lib/agent/skills/manage_system_action/system_action_skill.dart`](../lib/agent/skills/manage_system_action/system_action_skill.dart)

Tools:

```text
create_calendar_event
create_reminder
get_recent_actions
cancel_action
```

Services:

- `SystemActionService`

### FileToolFactory

File: [`lib/agent/built_in_tools/file_tools.dart`](../lib/agent/built_in_tools/file_tools.dart)

Tools:

```text
Read
BatchRead
Write
Edit
Move
Remove
LS
Glob
Grep
```

Permissions:

- `FilePermissionManager.checkPermission(...)`
- `PermissionRule(rootPath, access)`

### Common Tools

File: [`lib/agent/common_tools.dart`](../lib/agent/common_tools.dart)

Tools:

```text
getCurrentTime
get_pkm_overview
```

### Event Log Tool

File: [`lib/agent/built_in_tools/search_event_logs_tool.dart`](../lib/agent/built_in_tools/search_event_logs_tool.dart)

Tool:

```text
search_workspace_event_logs
```

Note:

- Event logging started on 2026-01-23.
- Data before that date must be looked up in files.

### AssetAnalysisTool

File: [`lib/agent/built_in_tools/asset_analysis_tool.dart`](../lib/agent/built_in_tools/asset_analysis_tool.dart)

Callers:

- `analyze_assets_handler.dart`

Prompt:

- `Prompts.assetAnalysisPrompt(...)`

## 4. Prompt File Index

| File | Main Content | Used By |
| --- | --- | --- |
| [`lib/agent/card_agent/prompts.dart`](../lib/agent/card_agent/prompts.dart) | `cardAgentSystemPrompt` | CardAgent |
| [`lib/agent/pkm_agent/prompts.dart`](../lib/agent/pkm_agent/prompts.dart) | `pkmAgentSystemPrompt` | PkmAgent |
| [`lib/agent/comment_agent/prompts.dart`](../lib/agent/comment_agent/prompts.dart) | `commentAgentSystemPrompt` | CommentAgent |
| [`lib/agent/insight_agent/prompt.dart`](../lib/agent/insight_agent/prompt.dart) | `knowledgeInsightAgentSystemPrompt` | KnowledgeInsightAgent |
| [`lib/agent/post_card_router_agent/prompt.dart`](../lib/agent/post_card_router_agent/prompt.dart) | `postCardRouterSystemPrompt` | PostCardRouterAgent |
| [`lib/agent/schedule_aggregator_agent/prompt.dart`](../lib/agent/schedule_aggregator_agent/prompt.dart) | `scheduleAggregatorSystemPrompt` | ScheduleAggregatorAgent |
| [`lib/agent/ask_clarification_agent/prompt.dart`](../lib/agent/ask_clarification_agent/prompt.dart) | `askClarificationAgentSystemPrompt` | AskClarificationAgent |
| [`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart) | `superAgentSystemPrompt` | Chat / SuperAgent |
| [`lib/agent/memex_skill_host_agent/prompts.dart`](../lib/agent/memex_skill_host_agent/prompts.dart) | `memexSkillHostAgentSystemPrompt` | MemexSkillHostAgent |
| [`lib/agent/prompts.dart`](../lib/agent/prompts.dart) | shared skill prompts, tool descriptions, asset prompt, file tool descriptions | Most Agents / Skills |

## 5. Common Search Commands

Find all `StatefulAgent` constructions:

```bash
rg -n "StatefulAgent\\(" lib/agent lib/data/services
```

Find all tool names:

```bash
rg -n "Tool\\(|name:\\s*['\\\"]" lib/agent/skills lib/agent/built_in_tools lib/agent/common_tools.dart
```

Find all skill names:

```bash
rg -n "class .*Skill|name:\\s*['\\\"]" lib/agent/skills
```

Find all event subscriptions:

```bash
rg -n "subscribe\\(|subscribeSync|registerHandler" lib/data/repositories/memex_router.dart lib/data/services
```

Find model configuration usage for a given Agent:

```bash
rg -n "AgentDefinitions\\.(cardAgent|pkmAgent|knowledgeInsightAgent|commentAgent|chatAgent|companionAgent|profileAgent|postCardRouterAgent|scheduleAggregatorAgent|askClarificationAgent|clarificationResolutionAgent)" lib
```

## 6. Decision Points When Reading Code

When reading an Agent, ask in this order:

1. Is this Agent an automated task, a chat entry point, or a custom host?
2. Where does it obtain LLM resources?
3. How is its sessionId constructed, and does it reuse state?
4. Does it resume an interrupted run?
5. Does it have a responseId cache?
6. Are its system prompts static or dynamically assembled?
7. What data do dynamic reminders include?
8. Which tools does it own?
9. Do any tools have a stopFlag?
10. What is the file permission root?
11. Are writes done via tools, a service, or direct file writes?
12. Does the handler have pre-skip logic, fallbacks, or a failure handler?

## 7. High-Risk Change Points

### Modifying `agent/prompts.dart`

Large blast radius. This file contains:

- Timeline card skill prompt
- PKM skill prompt
- File tool descriptions
- Comment skill prompt
- Knowledge Insight skill prompt
- Asset analysis prompt
- Schedule aggregation skill prompt

Confirm callers before making changes.

### Modifying FileToolFactory

Affected areas include:

- PkmAgent
- SuperAgent
- KnowledgeInsightAgent
- Custom Agent Hosts
- PersonaAgent
- CommentAgent read-only file tools

Pay special attention to permissions and path resolution.

### Modifying memory tools

Affected areas include:

- SuperAgent
- CompanionAgent
- MemoryAgent
- ClarificationResolutionAgent
- CommentAgent reply scenarios

Risk: polluting the long-term user profile.

### Modifying CharacterToolsFactory

Affected areas:

- CommentAgent
- CompanionAgent

Distinguish user-level memory from character-level memory.

### Modifying router / schedule

Affected areas:

- PostCardRouterAgent trigger logic.
- ScheduleAggregatorAgent state mutation.
- Device calendar/reminder action sync.

Watch for duplicate triggers, idempotency, and stopFlag.

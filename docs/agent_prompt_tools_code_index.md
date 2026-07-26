# Memex Agent Prompt / Tools 代码索引

这份索引按“想理解某个 Agent 时应该读哪些代码”的顺序组织。它补充 [agent_overview.md](agent_overview.md)，偏源码入口、类名、函数名和工具名。

## 1. 全局入口

### Agent ID 和设置页

文件：[`lib/domain/models/agent_definitions.dart`](../lib/domain/models/agent_definitions.dart)

关键对象：

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

作用：

- `displayNames` 决定设置页展示。
- `configurableAgentIds` 决定哪些 Agent 可独立配置模型。

### Task handler 注册

文件：[`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)

重点读：

- `_init()`
- `_registerEventSubscriptions()`

核心 handler：

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

核心订阅：

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

## 2. Agent 构造函数索引

### CardAgent

文件：

- [`lib/agent/card_agent/card_agent.dart`](../lib/agent/card_agent/card_agent.dart)
- [`lib/data/services/task_handlers/card_agent_handler.dart`](../lib/data/services/task_handlers/card_agent_handler.dart)

优先读：

1. `processWithCardAgent(...)`
2. `CardAgent.runWithContent(...)`
3. `CardAgent._createAgent(...)`
4. `CardAgent.inspectCardRunCompletion(...)`

`StatefulAgent` 关键参数：

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

Prompt 来源：

- `cardAgentSystemPrompt`
- `Prompts.cardAgentUserMessagePromptForPublishNewContent(...)`
- `Prompts.timelineCardSkillSystemPrompt(...)`

Tools 来源：

- `TimelineCardSkill._buildTools(...)`

### PkmAgent

文件：

- [`lib/agent/pkm_agent/pkm_agent.dart`](../lib/agent/pkm_agent/pkm_agent.dart)
- [`lib/data/services/task_handlers/pkm_agent_handler.dart`](../lib/data/services/task_handlers/pkm_agent_handler.dart)

优先读：

1. `PkmAgent.detectNonPersistentInput(...)`
2. `processWithPkmAgent(...)`
3. `PkmAgent.runWithContent(...)`
4. `PkmAgent.createAgent(...)`
5. `PkmAgent._getPkmOverview(...)`

`StatefulAgent` 关键参数：

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

权限：

```dart
PermissionRule(
  rootPath: fileService.getPkmPath(userId),
  access: FileAccessType.write,
)
```

Prompt 来源：

- `pkmAgentSystemPrompt`
- `Prompts.pkmAgentInstructionForNewPublishedContent(...)`
- `Prompts.pkmSkillSystemPrompt(...)`
- dynamic PKM overview
- read-only user memory reminder

Tools 来源：

- `FileToolFactory`
- `PkmSkill._buildTools(...)`

### KnowledgeInsightAgent

文件：

- [`lib/agent/insight_agent/knowledge_insight_agent.dart`](../lib/agent/insight_agent/knowledge_insight_agent.dart)
- [`lib/data/services/task_handlers/knowledge_insight_handler.dart`](../lib/data/services/task_handlers/knowledge_insight_handler.dart)
- [`lib/agent/insight_agent/knowledge_insight_run_context.dart`](../lib/agent/insight_agent/knowledge_insight_run_context.dart)

优先读：

1. `KnowledgeInsightAgent.updateKnowledgeInsight(...)`
2. `KnowledgeInsightAgent._createAgent(...)`
3. `buildKnowledgeInsightRunContext(...)`
4. `_createInsightSummaryCardIfNeeded(...)`

`StatefulAgent` 关键参数：

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

权限：

```text
Workspace/Facts/Cards/PKM: read
KnowledgeInsights: write
```

Prompt 来源：

- `knowledgeInsightAgentSystemPrompt`
- `Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(...)`
- `MemoryManagement.buildMemoryReadOnlyPrompt()`
- `buildKnowledgeInsightRunContext(...)`

Tools 来源：

- `FileToolFactory`
- `buildSearchEventLogsTool()`
- `getCurrentTimeTool`
- `KnowledgeInsightSkill`

### CommentAgent

文件：

- [`lib/agent/comment_agent/comment_agent.dart`](../lib/agent/comment_agent/comment_agent.dart)
- [`lib/data/services/task_handlers/comment_agent_handler.dart`](../lib/data/services/task_handlers/comment_agent_handler.dart)
- [`lib/agent/context/character_context_assembler.dart`](../lib/agent/context/character_context_assembler.dart)

优先读：

1. `handleCommentAgentImpl(...)`
2. `handleProcessAiReplyImpl(...)`
3. `CommentAgent.runWithContent(...)`
4. `CommentAgent._createAgent(...)`
5. `CharacterContextAssembler.build(...)`

`StatefulAgent` 关键参数：

```dart
name: 'comment_agent'
systemPrompts: [commentAgentSystemPrompt, memoryManagementPrompt]
tools: withMemoryManagement ? memory tools : []
skills: [CommentAgentSkill(... forceActivate: true)]
disableSubAgents: true
planMode: PlanMode.none
```

Prompt 来源：

- `commentAgentSystemPrompt`
- `Prompts.commentAgentInitialCommentPrompt`
- `Prompts.commentSkillSystemPrompt(...)`
- character persona
- character system prompt override
- style examples
- character context reminders

Tools 来源：

- `CommentAgentSkill`
- `CharacterToolsFactory.buildCommentTools(...)`
- optional `MemoryManagement.buildMemoryManagementTools()`

### SuperAgent / Chat

文件：

- [`lib/data/services/chat_service.dart`](../lib/data/services/chat_service.dart)
- [`lib/agent/super_agent/super_agent.dart`](../lib/agent/super_agent/super_agent.dart)
- [`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart)

优先读：

1. `ChatService.sendMessage(...)`
2. `SuperAgent.createAgent(...)`
3. `ChatService._setupControllerListeners(...)`
4. `_createSession(...)` / `_addMessageToSession(...)`

`StatefulAgent` 关键参数：

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

Prompt 来源：

- `superAgentSystemPrompt`
- `ChatService` 内联 additional prompt
- scene context
- refs context
- location context
- current time
- memory prompt

Quick Query read-only tools：

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

文件：

- [`lib/agent/companion_agent/companion_agent.dart`](../lib/agent/companion_agent/companion_agent.dart)
- [`lib/agent/skills/companion_agent/companion_agent_skill.dart`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)
- [`lib/agent/context/character_context_assembler.dart`](../lib/agent/context/character_context_assembler.dart)

优先读：

1. `CompanionAgent.chat(...)`
2. `CompanionAgent._createAgent(...)`
3. `CompanionAgentSkill._buildSystemPrompt(...)`
4. `CharacterContextCompressor.compressIfNeeded(...)`

`StatefulAgent` 关键参数：

```dart
name: 'companion_agent'
skills: [CompanionAgentSkill(... forceActivate: true)]
tools: memoryManagement.buildMemoryManagementTools()
systemPrompts: [memoryManagementPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Skill tools：

```text
MemoryRead
MemoryWrite
MemoryEdit
MemoryRemove
HistorySearch
SendActionMessage
```

### MemoryAgent / profile_agent

文件：

- [`lib/agent/memory_agent/memory_agent.dart`](../lib/agent/memory_agent/memory_agent.dart)
- [`lib/data/services/memory_sync_service.dart`](../lib/data/services/memory_sync_service.dart)
- [`lib/agent/memory/memory_management.dart`](../lib/agent/memory/memory_management.dart)

优先读：

1. `MemorySyncService.enqueueFact(...)`
2. `MemorySyncService._processQueue(...)`
3. `MemorySyncService._processBatch(...)`
4. `MemoryAgent.run(...)`
5. `MemoryManagement.buildMemoryManagementTools()`

`StatefulAgent` 关键参数：

```dart
name: 'memory_agent'
tools: memoryManagement.buildMemoryManagementTools()
skills: [AskClarificationSkill()]
systemPrompts: [systemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Prompt 来源：

- `MemoryAgent.run(...)` 内联 Strict Memory Curator prompt
- existing memory context
- batch facts

### PostCardRouterAgent

文件：

- [`lib/agent/post_card_router_agent/post_card_router_agent.dart`](../lib/agent/post_card_router_agent/post_card_router_agent.dart)
- [`lib/data/services/task_handlers/post_card_router_handler.dart`](../lib/data/services/task_handlers/post_card_router_handler.dart)

优先读：

1. `handlePostCardRouter(...)`
2. `runPostCardRouter(...)`
3. `PostCardRouterAgent.route(...)`
4. `_buildActivateTool(...)`
5. `_enqueueDownstream(...)`

`StatefulAgent` 关键参数：

```dart
name: 'post_card_router_agent'
tools: [select_downstream_agents]
systemPrompts: [postCardRouterSystemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

可选 downstream：

```text
schedule_aggregator
ask_clarification
```

### ScheduleAggregatorAgent

文件：

- [`lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart`](../lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart)
- [`lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)
- [`lib/data/services/schedule_state_service.dart`](../lib/data/services/schedule_state_service.dart)

优先读：

1. `ScheduleAggregatorAgent.updateScheduleAggregation(...)`
2. `ScheduleAggregatorAgent._createAgent(...)`
3. `_buildScheduleRunContext(...)`
4. `ScheduleAggregationSkill`
5. `ScheduleStateService`

`StatefulAgent` 关键参数：

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

Skill tools：

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

文件：

- [`lib/agent/ask_clarification_agent/ask_clarification_agent.dart`](../lib/agent/ask_clarification_agent/ask_clarification_agent.dart)
- [`lib/agent/skills/ask_clarification/ask_clarification_skill.dart`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)
- [`lib/data/services/clarification_request_service.dart`](../lib/data/services/clarification_request_service.dart)

优先读：

1. `handleAskClarificationTask(...)`
2. `AskClarificationAgent.run(...)`
3. `AskClarificationSkill._buildSystemPrompt()`
4. `AskClarificationSkill._buildTools()`

`StatefulAgent` 关键参数：

```dart
name: 'ask_clarification_agent'
tools: const []
skills: [AskClarificationSkill(forceActivate: true)]
systemPrompts: [askClarificationAgentSystemPrompt]
disableSubAgents: true
planMode: PlanMode.none
```

Skill tools：

```text
create_clarification_request
get_pending_clarification_requests
get_recent_clarification_requests
```

### ClarificationResolutionAgent

文件：

- [`lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart`](../lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart)
- [`lib/data/services/task_handlers/clarification_resolution_handler.dart`](../lib/data/services/task_handlers/clarification_resolution_handler.dart)

优先读：

1. `handleClarificationResolution(...)`
2. `ClarificationResolutionAgent.run(...)`
3. `_buildFallbackMemory(...)`

`StatefulAgent` 关键参数：

```dart
name: 'clarification_resolution_agent'
tools: memoryManagement.buildMemoryManagementTools()
systemPrompts: [inline resolution prompt]
disableSubAgents: true
planMode: PlanMode.none
```

关键工具：

```text
append_memories
```

## 3. Skill / Tool 代码索引

### TimelineCardSkill

文件：[`lib/agent/skills/manage_timeline_card/timeline_card_skill.dart`](../lib/agent/skills/manage_timeline_card/timeline_card_skill.dart)

Prompt：

- `Prompts.timelineCardSkillSystemPrompt(...)`
- 模板来源：[`timeline_templates.dart`](../lib/agent/skills/manage_timeline_card/timeline_templates.dart)

Tools：

```text
get_card_metadata
save_timeline_card
```

写入路径：

- `FileSystemService.updateCardFile(...)`
- `EventBusService.emitEvent(CardDetailUpdatedMessage(...))`

### PkmSkill

文件：[`lib/agent/skills/manage_pkm/pkm_skill.dart`](../lib/agent/skills/manage_pkm/pkm_skill.dart)

Prompt：

- `Prompts.pkmSkillSystemPrompt(...)`

Tools：

```text
update_timeline_card_insight
skip_pkm_organization
```

写入路径：

- `FileSystemService.updateCardFile(...)`

### KnowledgeInsightSkill

文件：[`lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart`](../lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart)

Prompt：

- `Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(...)`

Tools：

```text
get_exists_knowledge_insight_cards
save_knowledge_insight_cards
delete_knowledge_insight_card
delete_knowledge_insight_tags
get_available_insight_card_templates
get_user_activity_stats
```

模板：

- [`lib/agent/skills/knowledge_insight/native_widgets.dart`](../lib/agent/skills/knowledge_insight/native_widgets.dart)

### ScheduleAggregationSkill

文件：[`lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)

Prompt：

- `Prompts.scheduleAggregatorSkillPrompt(...)`

Tools：

```text
get_schedule_state
add_pending_item
update_pending_item
complete_pending_item
complete_subtask
set_presentation
search_completed
```

服务：

- `ScheduleStateService`

### AskClarificationSkill

文件：[`lib/agent/skills/ask_clarification/ask_clarification_skill.dart`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)

Tools：

```text
create_clarification_request
get_pending_clarification_requests
get_recent_clarification_requests
```

服务：

- `ClarificationRequestService`

### CommentAgentSkill

文件：[`lib/agent/skills/comment_agent/comment_agent_skill.dart`](../lib/agent/skills/comment_agent/comment_agent_skill.dart)

Prompt：

- `Prompts.commentSkillSystemPrompt(...)`
- character persona
- character memory
- style examples

Tools 来源：

- `CharacterToolsFactory.buildCommentTools(...)`

### CompanionAgentSkill

文件：[`lib/agent/skills/companion_agent/companion_agent_skill.dart`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)

Prompt：

- `CompanionAgentSkill._buildSystemPrompt(...)`

Tools 来源：

- `CharacterToolsFactory.buildCompanionTools(...)`

### CharacterToolsFactory

文件：[`lib/agent/skills/character_tools_factory.dart`](../lib/agent/skills/character_tools_factory.dart)

Comment tools：

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

Companion tools：

```text
MemoryRead
MemoryWrite
MemoryEdit
MemoryRemove
HistorySearch
SendActionMessage
```

### SystemActionSkill

文件：[`lib/agent/skills/manage_system_action/system_action_skill.dart`](../lib/agent/skills/manage_system_action/system_action_skill.dart)

Tools：

```text
create_calendar_event
create_reminder
get_recent_actions
cancel_action
```

服务：

- `SystemActionService`

### FileToolFactory

文件：[`lib/agent/built_in_tools/file_tools.dart`](../lib/agent/built_in_tools/file_tools.dart)

Tools：

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

权限：

- `FilePermissionManager.checkPermission(...)`
- `PermissionRule(rootPath, access)`

### Common Tools

文件：[`lib/agent/common_tools.dart`](../lib/agent/common_tools.dart)

Tools：

```text
getCurrentTime
get_pkm_overview
```

### Event Log Tool

文件：[`lib/agent/built_in_tools/search_event_logs_tool.dart`](../lib/agent/built_in_tools/search_event_logs_tool.dart)

Tool：

```text
search_workspace_event_logs
```

注意：

- event logging 从 2026-01-23 开始。
- 早于该日期的数据必须查文件。

### AssetAnalysisTool

文件：[`lib/agent/built_in_tools/asset_analysis_tool.dart`](../lib/agent/built_in_tools/asset_analysis_tool.dart)

调用者：

- `analyze_assets_handler.dart`

Prompt：

- `Prompts.assetAnalysisPrompt(...)`

## 4. Prompt 文件索引

| 文件 | 主要内容 | 使用者 |
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
| [`lib/agent/prompts.dart`](../lib/agent/prompts.dart) | shared skill prompts, tool descriptions, asset prompt, file tool descriptions | 多数 Agent / Skill |

## 5. 常用搜索命令

查所有 StatefulAgent 构造：

```bash
rg -n "StatefulAgent\\(" lib/agent lib/data/services
```

查所有 Tool 名：

```bash
rg -n "Tool\\(|name:\\s*['\\\"]" lib/agent/skills lib/agent/built_in_tools lib/agent/common_tools.dart
```

查所有 Skill 名：

```bash
rg -n "class .*Skill|name:\\s*['\\\"]" lib/agent/skills
```

查所有事件订阅：

```bash
rg -n "subscribe\\(|subscribeSync|registerHandler" lib/data/repositories/memex_router.dart lib/data/services
```

查某个 Agent 的模型配置使用：

```bash
rg -n "AgentDefinitions\\.(cardAgent|pkmAgent|knowledgeInsightAgent|commentAgent|chatAgent|companionAgent|profileAgent|postCardRouterAgent|scheduleAggregatorAgent|askClarificationAgent|clarificationResolutionAgent)" lib
```

## 6. 读代码时的判断点

读一个 Agent 时，按这个顺序问：

1. 这个 Agent 是自动任务、聊天入口，还是自定义宿主？
2. 它在哪里获取 LLM resources？
3. 它的 sessionId 如何构造，是否复用状态？
4. 它有没有 resume interrupted run？
5. 它有无 responseId cache？
6. 它的 system prompts 是静态还是动态拼接？
7. dynamic reminders 包含哪些数据？
8. 它拥有哪些 tools？
9. tools 是否有 stopFlag？
10. 文件权限 root 是什么？
11. 写入是通过工具、service，还是直接文件写入？
12. handler 是否有前置跳过、兜底或 failure handler？

## 7. 高风险修改点

### 修改 `agent/prompts.dart`

影响范围大。这个文件包含：

- Timeline card skill prompt
- PKM skill prompt
- File tool descriptions
- Comment skill prompt
- Knowledge Insight skill prompt
- Asset analysis prompt
- Schedule aggregation skill prompt

改动前先确认调用方。

### 修改 FileToolFactory

影响范围包括：

- PkmAgent
- SuperAgent
- KnowledgeInsightAgent
- Custom Agent Hosts
- PersonaAgent
- CommentAgent 的只读文件工具

需要特别小心权限和路径解析。

### 修改 memory tools

影响范围包括：

- SuperAgent
- CompanionAgent
- MemoryAgent
- ClarificationResolutionAgent
- CommentAgent 回复场景

风险是污染长期用户画像。

### 修改 CharacterToolsFactory

影响范围：

- CommentAgent
- CompanionAgent

要区分用户级 memory 和角色级 memory。

### 修改 router / schedule

影响范围：

- PostCardRouterAgent 的触发判断。
- ScheduleAggregatorAgent 的 state mutation。
- 设备日历/提醒 action 同步。

需要关注重复触发、幂等性和 stopFlag。


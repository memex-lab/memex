# Memex Agent 能力梳理

中文 | [English](agent_overview.en.md)

本文档基于当前代码整理 Memex 内置 Agent、宿主型 Agent、Prompt 和 Tools。它的目标不是做产品介绍，而是帮助继续深入理解每个 Agent 的职责边界、触发方式、Prompt 来源和工具写入范围。

相关入口：

- HTML 可视化页：[agent_overview.html](agent_overview.html)
- 代码阅读索引：[agent_prompt_tools_code_index.md](agent_prompt_tools_code_index.md)
- Agent ID 注册表：[`lib/domain/models/agent_definitions.dart`](../lib/domain/models/agent_definitions.dart)
- 事件订阅和任务注册：[`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)

## 1. 总体心智模型

Memex 的 Agent 能力不是只由 system prompt 决定，而是由五层共同约束：

1. **事件触发**：`GlobalEventBus` 决定哪些事件会让哪些任务入队。
2. **任务执行**：`LocalTaskExecutor` 持久化任务、处理重试、依赖和并发策略。
3. **Agent 构造**：每个 Agent 在 `StatefulAgent(...)` 里声明 `systemPrompts`、`tools`、`skills`、`planMode`、`disableSubAgents`、压缩器和状态保存。
4. **权限边界**：文件工具全部经由 `FilePermissionManager`，不同 Agent 的可读写 root 不同。
5. **动态上下文**：memory、location、event logs、schedule state、character context、PKM overview 等通过 prompt/reminder 注入。

因此，调 Agent 行为时应同时看 prompt、tools schema、handler payload、权限和 stopFlag。

## 2. 用户输入后的主链路

主入口在 `MemexRouter._registerEventSubscriptions()`。

用户提交一条输入后，系统发布 `SystemEventTypes.userInputSubmitted`，然后进入以下链路：

1. `handle_analyze_assets`
   - 订阅 ID：`analyze_assets`
   - 任务类型：`handle_analyze_assets`
   - 负责图片/音频分析、EXIF、GPS、OCR。

2. `card_agent_task`
   - 订阅 ID：`card_agent`
   - 依赖：`analyze_assets`
   - 生成或更新 Timeline Card。

3. `pkm_agent_task`
   - 订阅 ID：`pkm_agent`
   - 依赖：`analyze_assets`
   - 串行依赖上一条 PKM task，避免并发修改 PKM。
   - 写 PKM，并更新卡片 insight。

4. `comment_agent_task`
   - 订阅 ID：`comment_agent`
   - 依赖：`pkm_agent`
   - 选择角色并生成私密时间线评论。

5. `post_card_router_task`
   - 订阅 ID：`post_card_router`
   - 依赖：`analyze_assets`
   - 只做路由判断，按需触发：
     - `schedule_aggregator_task`
     - `ask_clarification_task`

其他重要事件：

- `cardCommentPosted` -> `process_ai_reply`
- `knowledgeInsightRefreshRequested` -> `knowledge_insight_task`
- `scheduleAggregationRequested` -> `schedule_aggregator_task`
- `clarificationAnswered` -> `clarification_resolution_task`

## 3. 设置页可配置的内置 Agent

可配置 Agent ID 来自 `AgentDefinitions.displayNames`。

| Agent ID | 显示名 | 实现/入口 | 核心职责 |
| --- | --- | --- | --- |
| `analyze_assets` | Media analysis | `analyze_assets_handler.dart` | 分析输入附件，产出 `.analysis.txt` 和 OCR |
| `card_agent` | Cards | `CardAgent` | 将输入生成结构化 Timeline Card |
| `pkm_agent` | PKM | `PkmAgent` | 将输入组织进 P.A.R.A. PKM，并回写卡片 insight |
| `knowledge_insight_agent` | Insights | `KnowledgeInsightAgent` | 分析 Facts/PKM/Cards，维护 Knowledge Insight 卡片 |
| `comment_agent` | Comments | `CommentAgent` | 角色评论和用户回复处理 |
| `chat_agent` | Chat | `SuperAgent` | 默认聊天中枢，按需调用工具和技能 |
| `companion_agent` | Companion | `CompanionAgent` | 角色私聊，维护角色级和用户级记忆 |
| `profile_agent` | Memory summary | `MemoryAgent` | 批量抽取长期用户记忆 |
| `post_card_router_agent` | Post-Card Router | `PostCardRouterAgent` | 判断是否触发日程或澄清 Agent |
| `schedule_aggregator_agent` | Schedule | `ScheduleAggregatorAgent` | 维护 schedule state 和展示 |
| `ask_clarification_agent` | Ask Clarification | `AskClarificationAgent` | 判断是否需要创建澄清问题 |
| `clarification_resolution_agent` | Ask resolution | `ClarificationResolutionAgent` | 用户回答澄清后，决定是否写入长期 memory |

## 4. Agent 逐个说明

### 4.1 Media analysis

实现不是完整 `StatefulAgent`，而是 LLM 工具型任务 handler，但它在模型设置中独立配置。

- 入口：[`lib/data/services/task_handlers/analyze_assets_handler.dart`](../lib/data/services/task_handlers/analyze_assets_handler.dart)
- Prompt：`Prompts.assetAnalysisPrompt(...)`
- LLM 资源 ID：`AgentDefinitions.analyzeAssets`
- 能力：
  - 附件安全检查
  - 图片尺寸、EXIF 时间、GPS 坐标
  - 反向地理编码和用户标记地点匹配
  - 图片/音频多模态描述
  - Google ML Kit OCR
- 写入：
  - `{asset}.analysis.txt`
  - `{asset}.ocr.txt`
- 后续依赖：
  - `CardAgent`
  - `PkmAgent`
  - `PostCardRouterAgent`

### 4.2 CardAgent

把每条原始输入变成时间线卡片。

- 入口：[`lib/agent/card_agent/card_agent.dart`](../lib/agent/card_agent/card_agent.dart)
- Handler：[`lib/data/services/task_handlers/card_agent_handler.dart`](../lib/data/services/task_handlers/card_agent_handler.dart)
- Prompt：
  - [`lib/agent/card_agent/prompts.dart`](../lib/agent/card_agent/prompts.dart)
  - `Prompts.cardAgentUserMessagePromptForPublishNewContent(...)`
  - `Prompts.timelineCardSkillSystemPrompt(...)`
- Skill：
  - `TimelineCardSkill(forceActivate: true, stopAfterSuccessSaveCard: true)`
- Tools：
  - `get_card_metadata`
  - `save_timeline_card`
- Memory：
  - 注入用户 memory reminder，只读。
- 写入：
  - Cards YAML
  - 渲染卡片后通过 `EventBusService` 刷新 UI。
- 兜底：
  - LLM 未配置时使用 `rule_based_card_matcher.dart`。
- 关键约束：
  - `fact_id` 必须和原始输入一致。
  - `ui_configs` 必须完整，不能空。
  - 运行后会检查卡片是否存在、状态是否 completed、标题和 ui config 是否齐全。

### 4.3 PkmAgent

把输入组织进 `/PKM` 的 P.A.R.A. 结构，并把知识化 insight 写回卡片。

- 入口：[`lib/agent/pkm_agent/pkm_agent.dart`](../lib/agent/pkm_agent/pkm_agent.dart)
- Handler：[`lib/data/services/task_handlers/pkm_agent_handler.dart`](../lib/data/services/task_handlers/pkm_agent_handler.dart)
- Prompt：
  - [`lib/agent/pkm_agent/prompts.dart`](../lib/agent/pkm_agent/prompts.dart)
  - `Prompts.pkmAgentInstructionForNewPublishedContent(...)`
  - `Prompts.pkmSkillSystemPrompt(...)`
- Skill：
  - `PkmSkill(forceActivate: true, workingDirectory: '/')`
- 文件工具：
  - `Read`
  - `BatchRead`
  - `Write`
  - `Edit`
  - `Move`
  - `Remove`
  - `LS`
  - `Glob`
  - `Grep`
- Skill tools：
  - `update_timeline_card_insight`
  - `skip_pkm_organization`
- 权限：
  - 只写 `FileSystemService.getPkmPath(userId)`。
- Memory：
  - 用户 memory 注入为只读 reminder。
  - 不给 PkmAgent memory 写入工具。
- 关键约束：
  - `detectNonPersistentInput()` 会在进 LLM 前识别“不要记/不要保存/不要写长期记忆”等输入。
  - PKM task 串行，避免并发编辑。
  - 读文件工具会在结构过大、碎片化、日期文件名、频繁编辑等场景追加 system reminder，让 Agent 可主动整理。

### 4.4 KnowledgeInsightAgent

维护 Knowledge Insights，输出统计、趋势、地图、图表、摘要等 insight cards。

- 入口：[`lib/agent/insight_agent/knowledge_insight_agent.dart`](../lib/agent/insight_agent/knowledge_insight_agent.dart)
- Prompt：[`lib/agent/insight_agent/prompt.dart`](../lib/agent/insight_agent/prompt.dart)
- Skill：[`KnowledgeInsightSkill`](../lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart)
- Tools：
  - 文件读工具：`LS`、`Glob`、`Grep`、`Read`、`BatchRead`
  - `search_workspace_event_logs`
  - `getCurrentTime`
  - `get_exists_knowledge_insight_cards`
  - `save_knowledge_insight_cards`
  - `delete_knowledge_insight_card`
  - `delete_knowledge_insight_tags`
  - `get_available_insight_card_templates`
  - `get_user_activity_stats`
- 权限：
  - Facts、Cards、PKM、Workspace 只读。
  - KnowledgeInsights 可写。
- Memory：
  - memory read-only prompt。
- 关键约束：
  - 第一次运行如果没有现有 insight，会要求全量分析。
  - `planMode: PlanMode.auto`
  - `disableSubAgents: false`，prompt 允许复杂任务用 clone subagent。

### 4.5 CommentAgent

为用户私密时间线生成角色评论，也处理用户对评论的回复。

- 入口：[`lib/agent/comment_agent/comment_agent.dart`](../lib/agent/comment_agent/comment_agent.dart)
- Handler：[`lib/data/services/task_handlers/comment_agent_handler.dart`](../lib/data/services/task_handlers/comment_agent_handler.dart)
- Prompt：
  - [`lib/agent/comment_agent/prompts.dart`](../lib/agent/comment_agent/prompts.dart)
  - `Prompts.commentSkillSystemPrompt(...)`
  - 角色 persona、system prompt override、style examples
  - 用户 profile、角色记忆、角色世界、近期互动、PKM/card 上下文
- Skill：
  - `CommentAgentSkill`
- Tools：
  - `Read`
  - `Grep`
  - `SaveComment`
  - `SkipComment`
  - 有角色时：`MemoryRead`、`MemoryWrite`、`MemoryEdit`、`MemoryRemove`、`HistorySearch`
  - 用户回复场景可开启用户级 `append_memories`
- 选择角色：
  - 显式 `@角色` 优先。
  - 单角色模式走 `CharacterSelectionService.selectCharacter(...)`。
  - 多角色模式走 `selectMultipleCharacters(...)`。
- 关键约束：
  - 可见输出必须来自角色身份。
  - 不表现为 Memex、助理、分析师、治疗师。
  - 评论要短、自然、低打扰。

### 4.6 Chat / SuperAgent

默认聊天入口的中央 Agent。

- 入口：[`lib/data/services/chat_service.dart`](../lib/data/services/chat_service.dart)
- Agent：[`lib/agent/super_agent/super_agent.dart`](../lib/agent/super_agent/super_agent.dart)
- Prompt：[`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart)
- ChatService 额外注入：
  - 综合纠错原则
  - 交互准则
  - 页面场景 context
  - location context
  - refs context
  - 当前时间
- Tools：
  - 文件工具全套
  - `search_workspace_event_logs`
  - `getCurrentTime`
  - `get_pkm_overview`
  - 非 Quick Query 模式下加入 memory tools
- Skills：
  - `KnowledgeInsightSkill`
  - `TimelineCardSkill`
  - `PkmSkill`
  - `SystemActionSkill`
  - `AskClarificationSkill`
- Quick Query：
  - 只读模式。
  - 只保留 `LS`、`Glob`、`Grep`、`Read`、`BatchRead`、`search_event_logs`、`getCurrentTime`、`get_pkm_overview`。
  - 排除 `manage_timeline_card` 和 `ask_clarification`。

### 4.7 CompanionAgent

角色私聊 Agent。

- 入口：[`lib/agent/companion_agent/companion_agent.dart`](../lib/agent/companion_agent/companion_agent.dart)
- Skill：[`CompanionAgentSkill`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)
- Prompt 动态来源：
  - 角色 persona
  - character system prompt override
  - style examples
  - user profile
  - character memory entries
  - character world
  - compressed interaction history
  - recent cross-scene interactions
  - user knowledge cards
  - memory update guidance
- Tools：
  - character-level：`MemoryRead`、`MemoryWrite`、`MemoryEdit`、`MemoryRemove`、`HistorySearch`
  - action：`SendActionMessage`
  - user-level：`append_memories`
- 关键约束：
  - 要像真实聊天，不像助理、教练、治疗师或产品界面。
  - 普通情绪聊天先给可见回复，工具不能替代回复。
  - 用户级 memory 和角色级 memory 分开。
  - 对自伤、伤害他人、虐待或急性危机有安全响应规则。

### 4.8 MemoryAgent / profile_agent

批量抽取长期用户记忆。

- 入口：[`lib/agent/memory_agent/memory_agent.dart`](../lib/agent/memory_agent/memory_agent.dart)
- 触发服务：[`lib/data/services/memory_sync_service.dart`](../lib/data/services/memory_sync_service.dart)
- LLM 资源 ID：`AgentDefinitions.profileAgent`
- Prompt：
  - 内联 `Strict Memory Curator` prompt。
- Tools：
  - `append_memories`
  - `AskClarificationSkill`
- 触发：
  - PkmAgent 成功后 `MemorySyncService.enqueueFact(...)`。
  - 默认累计 5 条 fact 后处理。
- 关键约束：
  - Default deny：大多数输入不写 memory。
  - 排除任务、提醒、临时上下文、一次性动作、已有信息。
  - 只保留身份、强偏好、长期资产/环境、习惯、AI 交互偏好。
  - memory 语言必须跟输入一致。

### 4.9 PostCardRouterAgent

轻量级后置路由 Agent。

- 入口：[`lib/agent/post_card_router_agent/post_card_router_agent.dart`](../lib/agent/post_card_router_agent/post_card_router_agent.dart)
- Prompt：[`lib/agent/post_card_router_agent/prompt.dart`](../lib/agent/post_card_router_agent/prompt.dart)
- Tool：
  - `select_downstream_agents`
- 可激活目标：
  - `schedule_aggregator`
  - `ask_clarification`
- 关键约束：
  - 只做一次工具调用。
  - 可以返回空列表。
  - 不能写 PKM、不能建卡、不能改 schedule。

### 4.10 ScheduleAggregatorAgent

维护 schedule state 和日程展示。

- 入口：[`lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart`](../lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart)
- Prompt：[`lib/agent/schedule_aggregator_agent/prompt.dart`](../lib/agent/schedule_aggregator_agent/prompt.dart)
- Skill：[`ScheduleAggregationSkill`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)
- Tools：
  - `get_schedule_state`
  - `add_pending_item`
  - `update_pending_item`
  - `complete_pending_item`
  - `complete_subtask`
  - `set_presentation`
  - `search_completed`
- 数据：
  - `ScheduleStateService`
- 关键约束：
  - `set_presentation` 可 stop agent loop。
  - state mutation 要按依赖顺序执行。
  - presentation timeline 最多 7 天。
  - 输出语言必须跟用户输入一致。

### 4.11 AskClarificationAgent

判断是否创建高价值澄清问题。

- 入口：[`lib/agent/ask_clarification_agent/ask_clarification_agent.dart`](../lib/agent/ask_clarification_agent/ask_clarification_agent.dart)
- Prompt：[`lib/agent/ask_clarification_agent/prompt.dart`](../lib/agent/ask_clarification_agent/prompt.dart)
- Skill：[`AskClarificationSkill`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)
- Tools：
  - `create_clarification_request`
  - `get_pending_clarification_requests`
  - `get_recent_clarification_requests`
- Memory：
  - read-only 用户 memory snapshot。
- 关键约束：
  - aggressive skip。
  - 只问一个问题。
  - 优先 one-tap 类型：`confirm`、`single_choice`、`multi_choice`。
  - 必须避免语义重复。
  - 不阻塞其他 Agent。

### 4.12 ClarificationResolutionAgent

用户回答澄清后，判断答案是否成为长期记忆。

- 入口：[`lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart`](../lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart)
- Handler：[`lib/data/services/task_handlers/clarification_resolution_handler.dart`](../lib/data/services/task_handlers/clarification_resolution_handler.dart)
- Prompt：
  - Agent 内联系统 prompt。
- Tools：
  - `append_memories`
- 输入：
  - request
  - answerData
  - options
  - evidenceFactIds
  - existing memory context
- 关键约束：
  - 只写稳定事实、偏好、关系、身份、习惯、长期项目上下文。
  - 不写临时 card-only corrections。
  - 不把 vague/manual/unknown 选项强行具体化。
  - LLM 失败时 handler 有 deterministic fallback。

## 5. 宿主型和支撑型 Agent

### 5.1 PersonaAgent

角色设计 Agent。

- 入口：[`lib/agent/persona_agent/persona_agent.dart`](../lib/agent/persona_agent/persona_agent.dart)
- Prompt：
  - `_buildSystemPrompt(...)` 内联。
- Tools：
  - `LS`
  - `Glob`
  - `Grep`
  - `Read`
  - `GetCharacterPersona`
  - `CreateOrUpdateCharacterPersona`
- 权限：
  - 文件工具只读 PKM。
- 职责：
  - 根据用户 profile/PKM 和现有角色，设计或更新角色 persona。

### 5.2 Custom Agent Hosts

自定义 Agent 的执行宿主。

- 配置服务：[`lib/data/services/custom_agent_config_service.dart`](../lib/data/services/custom_agent_config_service.dart)
- 执行 handler：[`lib/data/services/task_handlers/custom_agent_task_handler.dart`](../lib/data/services/task_handlers/custom_agent_task_handler.dart)
- Host 类型：
  - `PureSkillHostAgent`
  - `MemexSkillHostAgent`
- 输入：
  - SystemEvent 会序列化成 XML。
  - XML 中的 `fs://...` 图片/音频引用会转成多模态 content part。
- Tools：
  - 工作目录内文件工具
  - `search_workspace_event_logs`
  - `getCurrentTime`
  - 文件型 Skills
  - `FlutterJavaScriptRuntime`
- 输出：
  - 创建 chat session。
  - 创建 system_task timeline card 展示运行结果。

### 5.3 MemexSkillHostAgent

带 Memex 世界观的自定义 skill host。

- 入口：[`lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart`](../lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart)
- Prompt：[`lib/agent/memex_skill_host_agent/prompts.dart`](../lib/agent/memex_skill_host_agent/prompts.dart)
- Tools：
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
- 不包含：
  - memory tools
  - PKM overview tool

### 5.4 PureSkillHostAgent

轻量自定义 skill host。

- 入口：[`lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart`](../lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart)
- Prompt：
  - `pureSkillHostAgentSystemPrompt`
  - 内容非常短：手机上的个人助理，简洁、有帮助、友好。
- Tools：
  - 与 MemexSkillHostAgent 基本一致。

### 5.5 FileSystemSkillAgent

实验性 handler。

- 入口：[`lib/data/services/task_handlers/file_system_skill_agent_handler.dart`](../lib/data/services/task_handlers/file_system_skill_agent_handler.dart)
- 状态：
  - 当前未在 `MemexRouter._init()` 注册 `file_system_skill_agent_task`。
- 作用：
  - 动态创建 `submit_summary` skill。
  - 让 Agent 读 `SKILL.md`，再用 `RunJavaScript` 执行 `scripts/on_submit.js`。

## 6. 核心工具族

### 6.1 文件系统工具

实现：[`lib/agent/built_in_tools/file_tools.dart`](../lib/agent/built_in_tools/file_tools.dart)

工具：

- `Read`
- `BatchRead`
- `Write`
- `Edit`
- `Move`
- `Remove`
- `LS`
- `Glob`
- `Grep`

所有文件操作都经过：

- `FilePermissionManager`
- `FileOperationService`
- `FileSystemService`

### 6.2 Event Logs

实现：[`lib/agent/built_in_tools/search_event_logs_tool.dart`](../lib/agent/built_in_tools/search_event_logs_tool.dart)

工具：

- `search_workspace_event_logs`

重要限制：

- 事件日志从 **2026-01-23** 起记录。
- 更早历史必须查工作区文件。

### 6.3 Memory

实现：[`lib/agent/memory/memory_management.dart`](../lib/agent/memory/memory_management.dart)

用户级工具：

- `append_memories`

角色级工具：

- `MemoryRead`
- `MemoryWrite`
- `MemoryEdit`
- `MemoryRemove`
- `HistorySearch`

### 6.4 System Action

实现：[`lib/agent/skills/manage_system_action/system_action_skill.dart`](../lib/agent/skills/manage_system_action/system_action_skill.dart)

工具：

- `create_calendar_event`
- `create_reminder`
- `get_recent_actions`
- `cancel_action`

约束：

- 只有明确请求时才创建或取消动作。
- 取消/修改前必须先查 recent actions。

## 7. 继续深挖 Prompt 和 Tools 的推荐顺序

1. 先读 [`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)
   - 看 task handler 注册。
   - 看 event subscription。
   - 看 dependsOn、priority、concurrencyPolicy。

2. 再读每个 Agent 的构造函数
   - 搜 `StatefulAgent(`。
   - 重点看 `systemPrompts`、`tools`、`skills`、`planMode`、`disableSubAgents`、`systemCallback`。

3. 再读 Skill 文件
   - `lib/agent/skills/manage_timeline_card/timeline_card_skill.dart`
   - `lib/agent/skills/manage_pkm/pkm_skill.dart`
   - `lib/agent/skills/knowledge_insight/knowledge_insight_skill.dart`
   - `lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`
   - `lib/agent/skills/ask_clarification/ask_clarification_skill.dart`
   - `lib/agent/skills/comment_agent/comment_agent_skill.dart`
   - `lib/agent/skills/companion_agent/companion_agent_skill.dart`

4. 最后读动态上下文
   - memory：`lib/agent/memory/`
   - character context：`lib/agent/context/`
   - schedule run context：`schedule_aggregator_agent.dart`
   - insight run context：`knowledge_insight_run_context.dart`
   - location context：`LocationContextService`

## 8. 改 Prompt 前的检查清单

- 这个行为是不是已有 tool/skill 支持？
- tool schema 是否允许模型传入需要的字段？
- Agent 是否真的拥有该 tool？
- 文件权限是否允许读/写目标路径？
- 这个 Agent 是自动任务还是聊天场景？
- 是否会被 `stopFlag` 提前结束？
- 是否有 handler 级兜底或前置跳过逻辑？
- 是否需要更新 tests 或 eval？
- 是否会影响用户长期 memory 污染风险？
- 是否会破坏 per-user workspace 隔离？


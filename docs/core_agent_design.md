# Memex 核心 Agent 全量设计

中文 | [English](core_agent_design.en.md)

本文档整理当前 Memex 核心 Agent 的设计意图、触发方式、Prompt 结构、Tools、状态管理、数据写入边界和可改进点。

配套文档：

- 能力总览：[agent_overview.md](agent_overview.md)
- Prompt / Tools 代码索引：[agent_prompt_tools_code_index.md](agent_prompt_tools_code_index.md)
- HTML 可视化页：[agent_overview.html](agent_overview.html)

## 1. 核心设计目标

Memex 是本地优先的个人生活记录系统。Agent 系统的核心目标是：

1. **记录自动结构化**
   - 用户只负责输入。
   - 系统自动完成媒体理解、卡片生成、知识沉淀、评论、日程抽取和长期记忆更新。

2. **每个 Agent 只拥有一个主要职责**
   - CardAgent 只做卡片。
   - PkmAgent 只做 PKM 和卡片 insight。
   - CommentAgent 只做角色评论。
   - ScheduleAggregatorAgent 只做 schedule state。
   - KnowledgeInsightAgent 只做 Knowledge Insights。

3. **所有重工作都持久化执行**
   - 慢任务走 `LocalTaskExecutor`。
   - 任务可重试、可恢复、可依赖、可按用户串行。

4. **所有数据保持本地边界**
   - Facts、Cards、PKM、KnowledgeInsights、ChatSessions、Memory 都在本地 workspace。
   - Agent 文件访问通过 `FilePermissionManager` 限权。

5. **Prompt 不单独决定能力**
   - 能力由 prompt、tools、skills、handler payload、file permission、runtime reminders 共同决定。

## 2. 核心 Agent 范围

本文档把以下 Agent 作为核心设计对象：

| Agent | 类型 | 核心职责 |
| --- | --- | --- |
| Media analysis | 自动任务 | 多模态附件理解 |
| CardAgent | 自动任务 | 生成 Timeline Card |
| PkmAgent | 自动任务 | 写 PKM，更新卡片 insight |
| CommentAgent | 自动任务 / 回复任务 | 角色评论和回复 |
| PostCardRouterAgent | 自动任务 | 路由后续 Agent |
| ScheduleAggregatorAgent | 自动任务 / 手动刷新 | 维护 schedule state 和展示 |
| AskClarificationAgent | 自动任务 | 创建高价值澄清问题 |
| ClarificationResolutionAgent | 自动任务 | 把澄清答案转成长期记忆 |
| KnowledgeInsightAgent | 手动/周期刷新 | 生成和维护知识洞察 |
| MemoryAgent | 后台批处理 | 抽取长期用户记忆 |
| SuperAgent | 用户聊天 | 中央对话和工具协调 |
| CompanionAgent | 用户聊天 | 角色私聊和关系记忆 |

扩展对象：

- PersonaAgent
- PureSkillHostAgent
- MemexSkillHostAgent
- Custom Agent runtime

## 3. 全局执行架构

### 3.1 事件驱动

核心入口是：

- [`lib/data/repositories/memex_router.dart`](../lib/data/repositories/memex_router.dart)
- `MemexRouter._init()`
- `MemexRouter._registerEventSubscriptions()`

事件流：

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

### 3.2 主输入链路

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

关键依赖：

- `card_agent` 依赖 `analyze_assets`
- `pkm_agent` 依赖 `analyze_assets`
- `comment_agent` 依赖 `pkm_agent`
- `post_card_router` 依赖 `analyze_assets`
- `pkm_agent` 额外依赖上一条 PKM task，保证串行

### 3.3 状态与恢复

绝大多数核心 Agent 使用：

- `loadOrCreateAgentState(...)`
- `saveAgentState(...)`
- `AgentController`
- `addAgentLogger(...)`
- `addAgentActivityCollector(...)`

设计含义：

- 每个 Agent session 可恢复。
- LLM 历史可以压缩。
- Agent 活动可被 UI 展示。
- 失败任务可通过 `LocalTaskExecutor` 重试。

### 3.4 Prompt 组成

典型 Prompt 不是单一字符串，而是：

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

因此看 Prompt 时必须同时看：

- Agent 构造函数
- Skill 构造函数
- Tool schema
- handler 传入的 user message
- state.systemReminders

## 4. Media analysis 设计

### 4.1 设计意图

Media analysis 是输入链路的第一阶段。它把附件从“不可读的二进制文件”转成后续 Agent 可消费的文本上下文。

它不是完整 `StatefulAgent`，而是独立 LLM handler，但在设置页作为 `analyze_assets` 配置模型。

### 4.2 触发

入口：

- [`lib/data/services/task_handlers/analyze_assets_handler.dart`](../lib/data/services/task_handlers/analyze_assets_handler.dart)

触发：

```text
SystemEventTypes.userInputSubmitted
  -> handle_analyze_assets
```

### 4.3 输入

```text
fact_id
asset_paths
```

### 4.4 核心能力

- 过滤不支持格式
- 安全检查
- 图片 EXIF 提取
- 图片尺寸和比例
- GPS 坐标
- 反向地理编码
- 用户自定义地点匹配
- LLM 多模态分析
- 本地 OCR

### 4.5 Prompt

Prompt 入口：

- `Prompts.assetAnalysisPrompt(...)`
- 文件：[`lib/agent/prompts.dart`](../lib/agent/prompts.dart)

设计重点：

- 分析结果要是后续 Agent 可引用的客观描述。
- 系统生成的媒体分析不能被当成用户原话。
- 图片 metadata 会拼进 prompt。

### 4.6 写入

写入文件：

```text
Facts/assets/{asset}.analysis.txt
Facts/assets/{asset}.ocr.txt
```

### 4.7 风险点

- 媒体分析错误会影响 CardAgent 和 PkmAgent。
- 纯媒体输入如果分析失败，后续 handler 会按失败处理。
- OCR 是本地工具，可能和 LLM 分析产生冲突，需要后续 prompt 明确“分析是参考，原图/原音频才是事实源”。

### 4.8 改进方向

- 把 OCR 和 LLM 视觉分析分成两个独立字段，降低混淆。
- 给图片分析增加“确定性等级”：observed / inferred / uncertain。
- 对人脸、地点、关系类推断更保守。

## 5. CardAgent 设计

### 5.1 设计意图

CardAgent 把原始输入转成 Timeline Card。它解决的是展示层结构化问题，不负责长期知识组织。

### 5.2 触发

入口：

- [`lib/data/services/task_handlers/card_agent_handler.dart`](../lib/data/services/task_handlers/card_agent_handler.dart)
- [`lib/agent/card_agent/card_agent.dart`](../lib/agent/card_agent/card_agent.dart)

触发：

```text
userInputSubmitted
  -> card_agent_task
  dependsOn analyze_assets
```

### 5.3 输入

```text
fact_id
combined_text
markdown_entry
created_at_ts
location_context_reminder
asset_analyses
```

### 5.4 Prompt 结构

静态 prompt：

- [`lib/agent/card_agent/prompts.dart`](../lib/agent/card_agent/prompts.dart)

动态 prompt：

- `Prompts.cardAgentUserMessagePromptForPublishNewContent(...)`
- `TimelineCardSkill.getTimelineCardMetadata(...)`
- 用户语言指令
- 用户长期 memory reminder
- 媒体分析
- location context

### 5.5 Tools / Skills

CardAgent 自身：

```dart
tools: []
skills: [
  TimelineCardSkill(
    stopAfterSuccessSaveCard: true,
    forceActivate: true,
  )
]
```

TimelineCardSkill tools：

- `get_card_metadata`
- `save_timeline_card`

### 5.6 写入

通过 `save_timeline_card` 写 Cards YAML。

核心字段：

- `fact_id`
- `title`
- `timestamp`
- `status`
- `tags`
- `ui_configs`
- `insight`
- `comments`

### 5.7 完成判定

`CardRunCompletionEvidence` 检查：

- 是否调用成功的 save tool
- card 文件是否存在
- `persisted_fact_id` 是否匹配
- status 是否 completed
- title 是否存在
- ui_configs 是否存在

### 5.8 兜底设计

如果 `card_agent` 没有有效 LLM 配置：

- 使用 [`rule_based_card_matcher.dart`](../lib/agent/card_agent/rule_based_card_matcher.dart)

### 5.9 风险点

- CardAgent 容易把“任务/愿望/未来地点”误当成已发生事实。
- location context 有助于补充当前位置，但也可能污染远程事件或计划。
- card templates 的 schema 越复杂，越容易生成空 `data` 或错误字段。

### 5.10 改进方向

- 增加 card template 选择的 few-shot。
- 对 address 增加更强的“actual occurrence only”规则。
- 对 `ui_configs.data` 做 schema 校验和自动修复。

## 6. PkmAgent 设计

### 6.1 设计意图

PkmAgent 把输入沉淀到 P.A.R.A. 知识库，同时更新对应 Timeline Card 的 insight。

它是自动链路里最重要的知识写入 Agent。

### 6.2 触发

入口：

- [`lib/data/services/task_handlers/pkm_agent_handler.dart`](../lib/data/services/task_handlers/pkm_agent_handler.dart)
- [`lib/agent/pkm_agent/pkm_agent.dart`](../lib/agent/pkm_agent/pkm_agent.dart)

触发：

```text
userInputSubmitted
  -> pkm_agent_task
  dependsOn analyze_assets
  dependsOn previous pkm_agent_task
```

### 6.3 输入

```text
fact_id
combined_text
created_at_ts
location_context_reminder
asset_analyses
PKM overview
user memory read-only context
```

### 6.4 Prompt 结构

静态 prompt：

- [`lib/agent/pkm_agent/prompts.dart`](../lib/agent/pkm_agent/prompts.dart)

共享 prompt：

- `Prompts.pkmAgentInstructionForNewPublishedContent(...)`
- `Prompts.pkmSkillSystemPrompt(...)`

动态上下文：

- PKM directory overview
- user language instruction
- user memory reminder
- media analysis
- location context

### 6.5 Tools / Skills

文件工具：

- `Read`
- `BatchRead`
- `Write`
- `Edit`
- `Move`
- `Remove`
- `LS`
- `Glob`
- `Grep`

Skill：

- `PkmSkill`

Skill tools：

- `update_timeline_card_insight`
- `skip_pkm_organization`

### 6.6 权限

只写：

```text
/PKM
```

不提供 memory 写入工具。

### 6.7 非持久化输入设计

`PkmAgent.detectNonPersistentInput(...)` 会在 LLM 前识别：

- 不要记
- 别保存
- 不写长期记忆
- do not save/store/remember

识别后直接跳过，避免浪费 LLM 和误写 PKM。

### 6.8 P.A.R.A. 维护设计

PkmAgent 的读工具会追加结构提醒：

- 文件太长
- 目录太碎
- 文件名含日期
- 文件被频繁编辑

这些提醒会让 Agent 不仅组织当前输入，也有机会整理结构。

### 6.9 写入结果

写入：

- PKM Markdown files
- card insight

后续：

- 成功后进入 `MemorySyncService.enqueueFact(...)`

### 6.10 风险点

- PKM 写入是长期结构，错误成本高。
- 过度积极整理可能破坏用户既有结构。
- `update_timeline_card_insight` 与文件编辑需要协调，避免 insight 引用未实际写入的内容。

### 6.11 改进方向

- 给 P.A.R.A. maintenance 单独开关或阈值。
- 给 PKM 文件编辑增加 diff preview / rollback 元信息。
- 对 related fact ids 做更严格校验。

## 7. CommentAgent 设计

### 7.1 设计意图

CommentAgent 让虚拟角色在用户的私密记录下自然评论，提升表达反馈和陪伴感。

它不是知识分析 Agent，不应该像助理、教练、治疗师或产品界面。

### 7.2 触发

入口：

- [`lib/data/services/task_handlers/comment_agent_handler.dart`](../lib/data/services/task_handlers/comment_agent_handler.dart)
- [`lib/agent/comment_agent/comment_agent.dart`](../lib/agent/comment_agent/comment_agent.dart)

触发：

```text
new input
  -> comment_agent_task
  dependsOn pkm_agent

cardCommentPosted
  -> process_ai_reply
```

### 7.3 角色选择

角色选择路径：

1. payload 显式 `character_id`
2. 输入里 `@角色`
3. 单角色模式：`CharacterSelectionService.selectCharacter(...)`
4. 多角色模式：`selectMultipleCharacters(...)`

### 7.4 Prompt 结构

外层边界：

- [`lib/agent/comment_agent/prompts.dart`](../lib/agent/comment_agent/prompts.dart)

核心 skill prompt：

- `Prompts.commentSkillSystemPrompt(...)`
- 文件：[`lib/agent/prompts.dart`](../lib/agent/prompts.dart)

动态角色 prompt：

- `CommentAgentSkill._buildSystemPrompt(...)`
- 文件：[`lib/agent/skills/comment_agent/comment_agent_skill.dart`](../lib/agent/skills/comment_agent/comment_agent_skill.dart)

任务消息：

- `CommentAgent._buildCommentTaskMessage(...)`

### 7.5 动态上下文

来自 `CharacterContextAssembler.build(...)`：

- user profile
- character memory entries
- character world
- compressed interaction history
- recent cross-scene interactions
- user knowledge cards

任务消息包含：

- original post
- initial insight
- PKM context
- existing comments
- reply routing
- user request
- current time / location context

### 7.6 Tools / Skills

Skill：

- `CommentAgentSkill`

Tools：

- `Read`
- `Grep`
- `SaveComment`
- `SkipComment`
- `MemoryRead`
- `MemoryWrite`
- `MemoryEdit`
- `MemoryRemove`
- `HistorySearch`

用户回复场景可额外启用：

- `append_memories`

### 7.7 完成机制

必须调用一个 completion tool：

- `SaveComment`
- `SkipComment`

`SaveComment` 和 `SkipComment` 都会返回 `stopFlag: true`。

### 7.8 写入

`SaveComment` 写入：

- Card comments
- character timeline event
- event log

### 7.9 风险点

- `character.systemPromptOverride` 当前被放在核心规则前，可能覆盖安全和工具规则。
- Prompt 里提到 `append_memories`，但普通初始评论不一定拥有这个 tool。
- 角色记忆和用户长期记忆容易混淆。
- 多角色评论容易重复或过度热闹。

### 7.10 改进方向

- 把不可覆盖规则放在最高优先级。
- 把角色 override 限定为“风格/语气”，不能覆盖工具和安全规则。
- 初始评论和用户回复使用两套 memory prompt。
- 明确“该不该说”的 policy。

## 8. PostCardRouterAgent 设计

### 8.1 设计意图

PostCardRouterAgent 是轻量 selector。它避免所有后置 Agent 都无脑运行。

### 8.2 触发

入口：

- [`lib/data/services/task_handlers/post_card_router_handler.dart`](../lib/data/services/task_handlers/post_card_router_handler.dart)
- [`lib/agent/post_card_router_agent/post_card_router_agent.dart`](../lib/agent/post_card_router_agent/post_card_router_agent.dart)

触发：

```text
userInputSubmitted
  -> post_card_router_task
  dependsOn analyze_assets
```

### 8.3 Prompt

文件：

- [`lib/agent/post_card_router_agent/prompt.dart`](../lib/agent/post_card_router_agent/prompt.dart)

核心规则：

- 保守。
- 空列表是合法答案。
- 只调用一次 `select_downstream_agents`。
- 不执行副作用。

### 8.4 Tool

唯一工具：

- `select_downstream_agents`

可选目标：

- `schedule_aggregator`
- `ask_clarification`

### 8.5 写入

不直接写业务数据。

只做：

- 发布 `scheduleAggregationRequested`
- 入队 `ask_clarification_task`

### 8.6 风险点

- 召回不足：漏掉应进入 schedule 的事项。
- 召回过度：把普通记录误判为 schedule。
- ask clarification 过度会打扰用户。

### 8.7 改进方向

- 为 schedule 和 clarification 各自增加可解释阈值。
- 将 router 结果写入 task result，便于调试。
- 对手动刷新和自动路由做区分。

## 9. ScheduleAggregatorAgent 设计

### 9.1 设计意图

维护用户当前 schedule state，并生成杂志式展示。

### 9.2 触发

入口：

- [`lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart`](../lib/agent/schedule_aggregator_agent/schedule_aggregator_agent.dart)
- [`lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart`](../lib/agent/skills/schedule_aggregation/schedule_aggregation_skill.dart)

触发：

- `scheduleAggregationRequested`
- 手动刷新
- PostCardRouterAgent 激活

### 9.3 Prompt

静态 prompt：

- [`lib/agent/schedule_aggregator_agent/prompt.dart`](../lib/agent/schedule_aggregator_agent/prompt.dart)

Skill prompt：

- `Prompts.scheduleAggregatorSkillPrompt(...)`

动态上下文：

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

### 9.5 数据模型

核心服务：

- [`lib/data/services/schedule_state_service.dart`](../lib/data/services/schedule_state_service.dart)

核心状态：

- pending items
- completed items
- presentation

### 9.6 完成机制

`set_presentation` 可以 `stopFlag: true`，用于结束 agent loop。

### 9.7 风险点

- 同一事项可能重复 add。
- todo 和 event 字段容易混用。
- presentation 可能引用不存在的 item id。

### 9.8 改进方向

- 增加 item merge / duplicate detection tool。
- 对 event/todo 类型做更强 schema 校验。
- 将 presentation 生成和 state mutation 分成两阶段。

## 10. AskClarificationAgent 设计

### 10.1 设计意图

只在高价值模糊信息出现时向用户提一个短问题。

### 10.2 触发

入口：

- [`lib/agent/ask_clarification_agent/ask_clarification_agent.dart`](../lib/agent/ask_clarification_agent/ask_clarification_agent.dart)
- [`lib/agent/skills/ask_clarification/ask_clarification_skill.dart`](../lib/agent/skills/ask_clarification/ask_clarification_skill.dart)

触发：

```text
PostCardRouterAgent
  -> ask_clarification_task
```

### 10.3 Prompt

文件：

- [`lib/agent/ask_clarification_agent/prompt.dart`](../lib/agent/ask_clarification_agent/prompt.dart)

核心规则：

- aggressive skip
- 一个问题
- 避免重复
- 优先 one-tap response
- 不阻塞其他 Agent

### 10.4 Tools

- `create_clarification_request`
- `get_pending_clarification_requests`
- `get_recent_clarification_requests`

### 10.5 写入

写入：

- ClarificationRequestService
- Timeline 附件卡由服务层生成

### 10.6 风险点

- 问太多会破坏记录体验。
- dedupe_key 不稳定会重复问。
- proposed_memory 太具体会诱导 Resolution 写错 memory。

### 10.7 改进方向

- 对 clarification 增加用户打扰预算。
- 对问题类型建立模板。
- 对 dedupe_key 做标准化 helper。

## 11. ClarificationResolutionAgent 设计

### 11.1 设计意图

用户回答澄清后，判断答案是否值得写入长期用户 memory。

### 11.2 触发

入口：

- [`lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart`](../lib/agent/clarification_resolution_agent/clarification_resolution_agent.dart)
- [`lib/data/services/task_handlers/clarification_resolution_handler.dart`](../lib/data/services/task_handlers/clarification_resolution_handler.dart)

触发：

```text
clarificationAnswered
  -> clarification_resolution_task
```

### 11.3 Prompt

内联 prompt，核心规则：

- 只写稳定事实、偏好、关系、身份、习惯、长期项目上下文。
- 不写临时 card-only corrections。
- vague/manual/unknown 不具体化。
- 同语言输出。
- dedupe against existing memory。

### 11.4 Tools

- `append_memories`

### 11.5 Fallback

LLM 失败时：

- `_buildFallbackMemory(...)`
- 优先 option memory
- 再考虑 proposed_memory
- 模糊选项不写

### 11.6 风险点

- proposed_memory 模板如果设计过度，会写入错误长期事实。
- multiple choice 需要处理多个 memory 拼接。
- 自定义输入可能比选项更具体，但当前 fallback 对 custom answer 保守不写。

### 11.7 改进方向

- 给每个 clarification request 存“预期写入类型”。
- 对 memory 写入加来源 fact id。
- 记录 resolution 决策理由，便于用户查看。

## 12. KnowledgeInsightAgent 设计

### 12.1 设计意图

从长期数据中挖掘趋势、模式、生活状态和跨记录洞察。

### 12.2 触发

入口：

- [`lib/agent/insight_agent/knowledge_insight_agent.dart`](../lib/agent/insight_agent/knowledge_insight_agent.dart)
- [`lib/data/services/task_handlers/knowledge_insight_handler.dart`](../lib/data/services/task_handlers/knowledge_insight_handler.dart)

触发：

- 手动更新
- `knowledgeInsightRefreshRequested`

### 12.3 Prompt

静态 prompt：

- [`lib/agent/insight_agent/prompt.dart`](../lib/agent/insight_agent/prompt.dart)

Skill prompt：

- `Prompts.knowledgeInsightAgentKnowledgeInsightSkillPrompt(...)`

动态上下文：

- current time
- knowledge insight run context
- existing insight cards
- user activity stats
- memory read-only prompt

### 12.4 Tools

文件读：

- `LS`
- `Glob`
- `Grep`
- `Read`
- `BatchRead`

通用：

- `search_workspace_event_logs`
- `getCurrentTime`

Insight skill：

- `get_exists_knowledge_insight_cards`
- `save_knowledge_insight_cards`
- `delete_knowledge_insight_card`
- `delete_knowledge_insight_tags`
- `get_available_insight_card_templates`
- `get_user_activity_stats`

### 12.5 权限

```text
Workspace: read
Facts: read
Cards: read
PKM: read
KnowledgeInsights: write
```

### 12.6 子 Agent

`disableSubAgents: false`

设计含义：

- 大范围资料收集可以委托 clone subagent。
- 主 Agent 负责最终洞察和写入。

### 12.7 风险点

- 全量分析成本高。
- Insight 容易基于少量样本过度推断。
- 事件日志从 2026-01-23 才开始，历史必须查文件。

### 12.8 改进方向

- 引入 insight confidence / evidence list。
- 将首次全量分析和增量分析拆开。
- 对删除旧 insight 增加更保守策略。

## 13. MemoryAgent 设计

### 13.1 设计意图

把用户输入批量压缩成长期用户画像，不记录流水账。

### 13.2 触发

入口：

- [`lib/data/services/memory_sync_service.dart`](../lib/data/services/memory_sync_service.dart)
- [`lib/agent/memory_agent/memory_agent.dart`](../lib/agent/memory_agent/memory_agent.dart)

触发：

```text
PkmAgent success
  -> MemorySyncService.enqueueFact
  -> batch threshold 5
  -> MemoryAgent.run
```

### 13.3 Prompt

内联 Strict Memory Curator prompt。

核心策略：

- Default deny。
- 大多数输入不写 memory。
- 只保留可持续数月/数年的用户属性。
- 语言和输入一致。
- 不把系统媒体分析当用户原话。

### 13.4 Tools

- `append_memories`
- `AskClarificationSkill`

### 13.5 写入

通过 `MemoryManagement` 写用户级 memory。

### 13.6 风险点

- 长期记忆污染。
- 系统分析内容被误认为用户自述。
- 批处理上下文过大导致提取粗糙。

### 13.7 改进方向

- memory entry 增加 source fact ids。
- 用户可审阅/撤销新增 memory。
- 对 preference、identity、habit 分类型写入。

## 14. SuperAgent / Chat 设计

### 14.1 设计意图

SuperAgent 是用户主动聊天时的中央协调 Agent。它不是单一任务 Agent，而是意图识别和工具协调层。

### 14.2 触发

入口：

- [`lib/data/services/chat_service.dart`](../lib/data/services/chat_service.dart)
- [`lib/agent/super_agent/super_agent.dart`](../lib/agent/super_agent/super_agent.dart)

触发：

- 普通聊天
- timeline card detail chat
- insight card chat
- quick query

### 14.3 Prompt

静态 prompt：

- [`lib/agent/super_agent/prompts.dart`](../lib/agent/super_agent/prompts.dart)

动态补充：

- 综合纠错原则
- 交互准则
- 页面 scene context
- location context
- refs context
- current time
- memory prompt
- quick query read-only prompt

### 14.4 Tools

普通模式：

- 文件工具全套
- `search_workspace_event_logs`
- `getCurrentTime`
- `get_pkm_overview`
- memory tools

Quick Query：

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

场景强制激活：

- timeline card detail：`manage_timeline_card`、`manage_pkm`
- insight card chat：`update_knowledge_insight`

### 14.6 风险点

- 普通模式文件写权限大。
- 多 skill 同时可用时，模型可能过度调用重工具。
- 聊天纠错可能需要同步修改 Cards、PKM、Asset Analysis，逻辑复杂。

### 14.7 改进方向

- 引入 intent router，先选能力再暴露工具。
- 对高风险写操作增加 confirmation。
- 将 quick query 和 full chat 在 UI/Agent 层更彻底隔离。

## 15. CompanionAgent 设计

### 15.1 设计意图

CompanionAgent 是角色私聊 Agent，目标是长期陪伴和关系连续性。

### 15.2 触发

入口：

- [`lib/agent/companion_agent/companion_agent.dart`](../lib/agent/companion_agent/companion_agent.dart)
- [`lib/agent/skills/companion_agent/companion_agent_skill.dart`](../lib/agent/skills/companion_agent/companion_agent_skill.dart)

触发：

- 角色聊天界面调用 `CompanionAgent.chat(...)`

### 15.3 Prompt

动态 prompt：

- character system prompt override
- character persona
- user profile
- character memory entries
- style examples
- behavior rules
- safety boundary
- memory update guidance

### 15.4 Tools

角色级：

- `MemoryRead`
- `MemoryWrite`
- `MemoryEdit`
- `MemoryRemove`
- `HistorySearch`
- `SendActionMessage`

用户级：

- `append_memories`

### 15.5 上下文

来自 `CharacterContextAssembler`：

- character world
- compressed checkpoints
- recent timeline
- user knowledge cards

### 15.6 压缩

对话后根据 token usage 调用：

- `CharacterContextCompressor.compressIfNeeded(...)`

### 15.7 风险点

- 过度拟人或过度依赖。
- 角色级 memory 和用户级 memory 混淆。
- 安全危机下需要保持角色感但不能牺牲现实帮助。

### 15.8 改进方向

- 对角色 memory 写入增加类别。
- 对 safety escalation 建立统一模板。
- 对“角色动作消息”和“说话文本”做更明确 UI 区分。

## 16. 扩展 Agent 设计

### 16.1 PersonaAgent

职责：

- 设计或更新虚拟角色 persona。

入口：

- [`lib/agent/persona_agent/persona_agent.dart`](../lib/agent/persona_agent/persona_agent.dart)

Tools：

- PKM read tools
- `GetCharacterPersona`
- `CreateOrUpdateCharacterPersona`

设计问题：

- 当前 profileContent 是 TODO。
- 角色创建直接写 YAML，需要继续评估是否应完全走 CharacterService。

### 16.2 Custom Agent Hosts

职责：

- 让用户自定义事件驱动 Agent。

入口：

- [`lib/data/services/custom_agent_config_service.dart`](../lib/data/services/custom_agent_config_service.dart)
- [`lib/data/services/task_handlers/custom_agent_task_handler.dart`](../lib/data/services/task_handlers/custom_agent_task_handler.dart)
- [`lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart`](../lib/agent/pure_skill_host_agent/pure_skill_host_agent.dart)
- [`lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart`](../lib/agent/memex_skill_host_agent/memex_skill_host_agent.dart)

设计特点：

- 自定义事件订阅。
- event serializer 把事件转 XML。
- 支持图片/音频从 XML 中转成 multimodal part。
- 支持文件型 skills 和 JavaScript runtime。
- 运行结果创建 chat session 和 system_task card。

风险：

- 自定义 prompt / skill 权限需要严格隔离。
- workingDirectory 决定可写边界。

## 17. 横向设计：Memory

### 17.1 用户级 memory

用途：

- 用户身份
- 长期偏好
- 习惯
- 资产/环境
- AI 交互偏好

主要使用者：

- MemoryAgent
- SuperAgent
- CompanionAgent
- ClarificationResolutionAgent
- CommentAgent 回复场景

核心文件：

- [`lib/agent/memory/memory_management.dart`](../lib/agent/memory/memory_management.dart)

### 17.2 角色级 memory

用途：

- 角色和用户之间的关系动态
- 支持偏好
- 风格反馈
- 情绪模式
- open threads
- inside jokes

主要使用者：

- CommentAgent
- CompanionAgent

核心文件：

- [`lib/agent/memory/character_memory_service.dart`](../lib/agent/memory/character_memory_service.dart)
- [`lib/agent/skills/comment_agent/tools/memory_tools.dart`](../lib/agent/skills/comment_agent/tools/memory_tools.dart)

### 17.3 设计原则

- 用户级 memory 是跨角色全局事实。
- 角色级 memory 是某个角色关系上下文。
- 不要把聊天原文直接存为 memory。
- 不要把系统媒体分析直接转成 memory。

## 18. 横向设计：File Permissions

核心文件：

- [`lib/agent/security/file_permission_manager.dart`](../lib/agent/security/file_permission_manager.dart)
- [`lib/agent/built_in_tools/file_tools.dart`](../lib/agent/built_in_tools/file_tools.dart)

典型权限：

| Agent | 权限设计 |
| --- | --- |
| PkmAgent | `/PKM` write |
| KnowledgeInsightAgent | Workspace/Cards/Facts/PKM read, KnowledgeInsights write |
| SuperAgent | Workspace write；Quick Query read-only |
| CommentAgent | Workspace read for Read/Grep |
| PersonaAgent | PKM read |
| Custom hosts | configured workingDirectory write |

设计原则：

- 不要绕过 FileSystemService。
- 不要直接操作 workspace 路径。
- Agent 不应拥有超出职责的写权限。

## 19. 横向设计：LLM 配置

核心入口：

- `UserStorage.getAgentLLMResources(agentId)`
- `UserStorage.getAgentLLMConfig(agentId)`

设计特点：

- 每个可配置 Agent 可独立选择模型。
- 未配置时部分 Agent 会跳过或使用规则兜底。

常见兜底：

- CardAgent：rule-based card matcher
- PkmAgent：跳过
- PostCardRouter：跳过
- CommentAgent：跳过
- AnalyzeAssets：跳过 LLM 分析，保留安全/预处理结果

## 20. 横向设计：Failure / Retry

任务执行：

- `LocalTaskExecutor`

失败处理：

- `handleGenericAgentFailure`
- `handleCardAgentFailureImpl`
- `rethrowIfNonRetryable(...)`

设计特点：

- 重任务持久化。
- Agent 可恢复 state。
- 部分任务有 by-user concurrency policy。

注意：

- Agent prompt 改动可能影响 retry 行为。
- Tool stopFlag 改动可能导致 loop detection 或任务不完成。

## 21. 当前最值得优化的设计点

### 21.1 CommentAgent 的 prompt priority

问题：

- character override 目前在核心规则前面。

建议：

- 不可覆盖规则最高优先级。
- override 只作为角色风格，不允许覆盖 tool/safety。

### 21.2 CommentAgent 的 memory tool mismatch

问题：

- Prompt 提到 `append_memories`，但普通自动评论不一定拥有这个 tool。

建议：

- 初始评论 prompt 不提用户级 memory。
- 用户回复 prompt 才允许用户级 memory 更新。

### 21.3 SuperAgent 权限过大

问题：

- 普通聊天拥有 workspace write 和多种 skills。

建议：

- 引入 intent router。
- 默认先只读，写操作需要明确确认或进入具体 skill mode。

### 21.4 KnowledgeInsight 证据链不足

问题：

- 洞察可能缺少 explicit evidence。

建议：

- insight card 增加 evidence facts / pkm refs / confidence。

### 21.5 PKM 自动维护过于隐式

问题：

- PkmAgent 可被 system reminder 触发结构整理，但用户不一定感知。

建议：

- maintenance 输出显式 action summary。
- 对大范围重构增加 preview 或单独 task。

### 21.6 Clarification 打扰预算

问题：

- 虽然 prompt 要 aggressive skip，但缺少系统级 budget。

建议：

- 按天/周限制未回答澄清数量。
- 用户 dismiss 后提高同类问题阈值。

## 22. 改 Agent 前的设计 Checklist

改任何核心 Agent 前，至少检查：

1. 是否影响事件触发？
2. 是否影响任务依赖？
3. 是否影响 prompt 优先级？
4. 是否影响 tool 可用性？
5. 是否影响文件权限？
6. 是否影响 memory 写入？
7. 是否影响 stopFlag？
8. 是否影响 task retry / resume？
9. 是否需要迁移已有 state？
10. 是否需要新增测试或 eval？

## 23. 推荐后续拆分

如果要继续系统化优化，建议按下面顺序拆文档或任务：

1. `CommentAgent` 设计重构
2. `SuperAgent` intent router 设计
3. `PKM Agent` 写入和维护安全设计
4. `KnowledgeInsight` evidence schema 设计
5. `Memory` 用户级 / 角色级边界设计
6. `Clarification` 打扰预算和 resolution policy 设计


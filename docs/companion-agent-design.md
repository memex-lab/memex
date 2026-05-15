# Memex 角色系统设计文档

更新时间：2026-05-11

## 1. 概述

Memex 的角色系统让 AI 角色在两个场景中以统一人格与用户互动：

- **聊天（Companion Chat）**：用户主动找角色 1v1 对话，类似微信好友。
- **评论（Comment）**：角色在用户的时间线卡片下自动发表评论。

两个场景共享同一套角色身份、记忆、历史，角色表现为"同一个人"。

## 2. 角色模型（CharacterModel）

存储路径：`workspace/_<userId>/Characters/<characterId>.yaml`

```dart
class CharacterModel {
  String id;
  String name;
  List<String> tags;
  String persona;                    // 角色人设（markdown 结构）
  bool enabled;
  String? avatar;
  bool isPrimaryCompanion;           // 用户选定的主要陪伴角色
  String? interestFilter;            // 关注领域（供 CharacterSelectionService 使用）
  String? firstMessage;              // 首次聊天时角色发送的开场白
  String? systemPromptOverride;      // 角色级 system prompt 覆盖
  String? postHistoryInstructions;   // 注入到历史之后的指令
  String? mesExample;                // 风格示例对话
  List<CharacterMemoryBlock> memory; // 旧字段，保留兼容但不再作为主要记忆来源
}
```

### persona 内部结构

```markdown
## Identity
角色的核心描述...

## Personality
性格特征...

## Scenario
场景设定...
```

## 3. 角色记忆系统

### 3.1 存储路径

```
workspace/_<userId>/_System/character_memory/<characterId>/
├── memory_entries.jsonl      # 长期稳定记忆（声明式事实）
├── world_entries.jsonl       # 角色世界书（SillyTavern character_book）
├── timeline.jsonl            # 跨场景统一事件流（最近原文）
├── archived_timeline.jsonl   # 压缩归档的原始事件（HistorySearch 可查）
├── checkpoints.jsonl         # 压缩后的阶段摘要
└── indexes.json              # 迁移版本、游标、上次压缩时间
```

### 3.2 记忆层级

| 层 | 文件 | 注入位置 | 说明 |
|---|---|---|---|
| 用户画像 | `_System/memory/memory.json` | Skill System Prompt | 全局用户 profile，由 MemoryManagement 维护 |
| 角色长期记忆 | `memory_entries.jsonl` | Skill System Prompt | 全量注入，不做检索过滤。agent 通过 MemoryAdd/Replace/Remove 工具维护 |
| 角色世界书 | `world_entries.jsonl` | systemReminders | 按 keys 关键词触发 + constant 条目常驻，硬性截断 2000 tokens |
| 压缩摘要 | `checkpoints.jsonl` | User Message 前缀 | 作为 `[CONTEXT SUMMARY — REFERENCE ONLY]` 节点注入 |
| 最近历史 | `timeline.jsonl` 尾部 | systemReminders | 全量保留（压缩后的 timeline 不再截断） |
| 用户知识库 | PKM/Facts grep + FTS | systemReminders | 按 queryHint 检索，硬性截断 2000 tokens |

### 3.3 上下文注入分布

**System Prompt（Skill 层，稳定身份信息）：**
- 角色 systemPromptOverride（如有）
- 角色 persona + 行为规则
- User Profile
- Character Memory Entries（全量）
- Style Examples（mesExample，如有）
- Memory Update Guidance

**systemReminders（动态上下文，每次 run 前刷新）：**
- Triggered Character World Entries
- Recent Cross-Scene Interactions（timeline 尾部）
- User Knowledge Cards
- Post History Instructions（如有）

**User Message 前缀：**
- Compaction Summary（压缩摘要 checkpoint）

## 4. 统一事件流（Timeline）

### 4.1 事件类型

```dart
enum CharacterMemoryEventType {
  userChatMessage,        // 用户在聊天中发的消息
  characterChatMessage,   // 角色在聊天中的回复
  postObserved,           // 角色观察到用户发的帖子（评论场景输入）
  characterComment,       // 角色发表的评论
  userCommentReply,       // 用户在评论区回复角色
}
```

### 4.2 写入时机

- `PersonaChatService.addUserMessage/addCharacterMessage` → 写入 chat 事件
- `CommentToolFactory.SaveComment` → 写入 characterComment 事件
- `CommentAgent.runAndGetResponse` → 写入 postObserved 事件
- `postCommentEndpoint`（用户回复评论）→ 写入 userCommentReply 事件

### 4.3 FTS 索引

三张 FTS5 虚拟表（schema version 13）：
- `character_memory_fts` — 记忆条目检索
- `character_world_fts` — 世界书条目检索
- `character_timeline_fts` — 事件流检索（支持 scene/thread/archived 过滤）

## 5. 压缩系统

### 5.1 触发条件

压缩在 agent run **完成后**触发，基于 API 返回的真实 `promptTokens`：
- 软阈值：`promptTokens > contextWindow * 0.55`（默认 64000 * 0.55 = 35200）
- 硬阈值：`promptTokens > contextWindow * 0.70`
- 冷却：压缩失败后 10 分钟内不重复触发（除非超硬阈值）

### 5.2 压缩流程

1. **确定边界**：保留最近 40 条事件（`keepRecent`），找到安全切割点（保证最后一条用户消息在保留区）
2. **Pre-trim**：去重近似行、截断超长 JSON metadata
3. **LLM 摘要**：对被裁掉的事件生成结构化 checkpoint（Topic Continuity / Stable Facts / Relationship Changes / Emotional Trajectory / Open Threads）
   - 预算：12000 字符（≈3000 tokens）
   - 超长时自动请求 condense 重试
   - 重试后仍超长则硬截断
4. **归档**：旧事件写入 `archived_timeline.jsonl`，checkpoint 写入 `checkpoints.jsonl`，timeline 只保留最近部分
5. **记忆提取**：从被压缩的原始事件中用 LLM 提取稳定事实写入 `memory_entries.jsonl`

### 5.3 记忆大小控制

- `memory_entries.jsonl`：写入时检查总字符数，超过 8000 字符时返回 WARNING 提醒 agent 合并/清理
- `checkpoints.jsonl`：生成时通过 prompt 约束 + 重试 + 兜底截断控制在 12000 字符以内
- `world_entries` / `knowledgeCards`：读取时硬性截断 2000 tokens
- `timeline` / `userProfile`：不截断，完全依赖压缩系统控制总量

## 6. Agent 架构

### 6.1 CompanionAgent（聊天场景）

```
用户发消息 → persona_chat_screen
  → CompanionAgent.chat()
    → resolveCharacterSessionId() — 找到最新 session（中断则 resume，否则递增新建）
    → CharacterContextAssembler.build() — 组装上下文快照
    → CompanionAgentSkill — 构建 system prompt（persona + profile + memories + mesExample）
    → state.systemReminders — 注入 world/timeline/knowledge/postHistoryInstructions
    → StatefulAgent.run() — 执行（无内置压缩器）
    → 成功后检查 promptTokens → compressIfNeeded()
```

### 6.2 CommentAgent（评论场景）

```
用户发记录 → GlobalEventBus → comment_agent_task
  → CommentAgent.createAgent()
    → resolveCharacterSessionId()
    → CharacterContextAssembler.build()
    → CommentAgentSkill — 构建 system prompt（persona + profile + memories）
    → state.systemReminders — 注入 world/timeline/knowledge
    → StatefulAgent 创建
  → CommentAgent.runAndGetResponse()
    → 构建结构化任务消息（factId + rawInput + insight + pkmContext）
    → 注入 compaction summary 节点
    → StatefulAgent.run()
    → 成功后检查 promptTokens → compressIfNeeded()
```

### 6.3 Session 管理

- Session ID 格式：`{agent}_{userId}_{characterId}_{N}`（递增序号）
- `resolveCharacterSessionId`：扫描 state 目录，找最新 session
  - 如果 `isRunning`（中断了）→ 返回该 session 用于 resume
  - 如果已完成 → 返回 `N+1` 新 session
- 每次 run 都是全新 session，不积累跨消息历史（历史由 timeline 系统提供）
- `autoSaveStateFunc` 保留用于中断恢复和排查

### 6.4 Agent 工具

**聊天场景工具**（`CharacterToolsFactory.buildCompanionTools`）：
- `MemoryRead` — 查看角色记忆（辅助精确操作）
- `MemoryAdd` — 添加稳定记忆
- `MemoryReplace` — 替换已有记忆
- `MemoryRemove` — 删除记忆
- `HistorySearch` — 搜索原始交互历史（recent + archived）

**评论场景工具**（`CharacterToolsFactory.buildCommentTools`）：
- `Read` / `Grep` — 文件读取（只读权限）
- `SaveComment` — 保存评论（带 stopFlag）
- `MemoryRead/Add/Replace/Remove` — 同上
- `HistorySearch` — 同上

## 7. SillyTavern 角色卡导入

### 7.1 支持的格式

- SillyTavern V2 JSON 角色卡
- 内嵌角色卡的 PNG 图片（tEXt / iTXt chunk）

### 7.2 字段映射

| V2 字段 | 映射目标 | 运行时用途 |
|---------|---------|-----------|
| `name` | `CharacterModel.name` | 角色名 |
| `description` | persona `## Identity` | System Prompt |
| `personality` | persona `## Personality` | System Prompt |
| `scenario` | persona `## Scenario` | System Prompt |
| `first_mes` | `CharacterModel.firstMessage` | 首次聊天时作为角色消息发送给用户 |
| `mes_example` | `CharacterModel.mesExample` | System Prompt 的 Style Examples 段 |
| `system_prompt` | `CharacterModel.systemPromptOverride` | System Prompt 最前面注入 |
| `post_history_instructions` | `CharacterModel.postHistoryInstructions` | systemReminders 注入 |
| `tags` | `CharacterModel.tags` | UI 展示 |
| `character_book` | `world_entries.jsonl` | 按 keys 触发注入到 systemReminders |
| `creator_notes` | 不导入 | 纯元数据，不发送给模型 |
| `alternate_greetings` | 不导入 | — |

### 7.3 世界书条目

```jsonl
{"id":"card_book_0","keys":["keyword1","keyword2"],"content":"...","comment":"entry title","constant":false,"enabled":true,"source":"tavern_character_book"}
```

- `constant: true` → 常驻注入（不需要 key 触发）
- `enabled: false` → 不会被触发
- 触发逻辑：当前输入 queryHint 包含 keys 中的关键词，或 FTS 匹配

### 7.4 导入入口

- UI：角色配置页 AppBar 的下载图标 → `TavernImportScreen`
- 路由：`/tavern-import`
- 功能：文件选择 → 预览 → 冲突检测 → 可选设为主要陪伴角色 → 确认导入

## 8. firstMessage 机制

当用户首次打开与某角色的聊天（`PersonaChatMessages` 表中该角色无消息）：
1. 检查 `character.firstMessage` 是否非空
2. 调用 `PersonaChatService.addCharacterMessage` 写入开场白
3. 该消息同时写入 `timeline.jsonl`（作为 `characterChatMessage` 事件）
4. UI 展示为角色发送的第一条消息

## 9. 迁移

### 数据库迁移（schema version 13）

`from < 13` 时创建 `character_memory_fts`、`character_world_fts`、`character_timeline_fts` 三张 FTS5 虚拟表。

### 文件迁移（CharacterMemoryService.ensureMigrated）

首次访问角色记忆时（`migration_version < 1`）：
- 将旧的 `Characters/{characterId}_relationship.md` 和 `Characters/{characterId}_emotional_state.md` 重命名为 `.deprecated_YYYYMMDD` 后缀
- 写入 `indexes.json` 的 `migration_version: 1`

## 10. 代码文件索引

| 文件 | 职责 |
|------|------|
| `lib/domain/models/character_model.dart` | 角色数据模型 |
| `lib/data/services/character_service.dart` | 角色 CRUD、默认角色种子 |
| `lib/agent/context/character_context_assembler.dart` | 统一上下文组装 |
| `lib/agent/memory/character_memory_service.dart` | 统一记忆存储（timeline/memory/world/checkpoints） |
| `lib/agent/memory/character_memory_updater.dart` | 压缩时从原始事件提取稳定记忆 |
| `lib/agent/memory/character_context_compressor.dart` | Timeline 压缩（基于真实 promptTokens 触发） |
| `lib/agent/context/compaction_summary_node.dart` | 构造压缩摘要注入节点 |
| `lib/agent/context/user_knowledge_context_service.dart` | 用户知识库检索 |
| `lib/agent/companion_agent/companion_agent.dart` | 聊天场景 agent |
| `lib/agent/comment_agent/comment_agent.dart` | 评论场景 agent |
| `lib/agent/skills/companion_agent/companion_agent_skill.dart` | 聊天 Skill（system prompt 构建） |
| `lib/agent/skills/comment_agent/comment_agent_skill.dart` | 评论 Skill（system prompt 构建） |
| `lib/agent/skills/comment_agent/tools/memory_tools.dart` | MemoryRead/Add/Replace/Remove/HistorySearch 工具 |
| `lib/agent/skills/comment_agent/tools/comment_tools.dart` | SaveComment 工具 |
| `lib/agent/skills/character_tools_factory.dart` | 统一工具工厂 |
| `lib/agent/state_util.dart` | Agent state 管理 + resolveCharacterSessionId |
| `lib/data/services/tavern_character_import_service.dart` | SillyTavern 角色卡导入 |
| `lib/data/services/persona_chat_service.dart` | 聊天消息持久化 + timeline 事件写入 |
| `lib/ui/character/widgets/persona_chat_screen.dart` | 聊天 UI |
| `lib/ui/character/widgets/tavern_import_screen.dart` | 导入 UI |
| `lib/ui/character/widgets/character_config_screen.dart` | 角色管理 UI |
| `lib/db/daos/search_dao.dart` | FTS5 索引管理 |
| `lib/db/app_database.dart` | Schema migration（version 13） |

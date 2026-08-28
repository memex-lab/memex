# Memex Character System Design

[中文](companion-agent-design.md) | English

Updated: 2026-05-11

## 1. Overview

Memex characters interact with the user as one consistent persona in two scenes:

- **Companion Chat**: the user starts a 1:1 conversation, like messaging a WeChat friend.
- **Comment**: the character automatically comments on the user's timeline cards.

Both scenes share the same identity, memory, and history, so the character reads as the same person.

## 2. Character model (`CharacterModel`)

Storage path: `workspace/_<userId>/Characters/<characterId>.yaml`

```dart
class CharacterModel {
  String id;
  String name;
  List<String> tags;
  String persona;                    // Character persona (markdown structure)
  bool enabled;
  String? avatar;
  bool isPrimaryCompanion;           // User-selected primary companion
  String? interestFilter;            // Focus areas (used by CharacterSelectionService)
  String? firstMessage;              // Opening line on first chat
  String? systemPromptOverride;      // Character-level system prompt override
  String? postHistoryInstructions;   // Injected after history
  String? mesExample;                // Style example dialogue
  List<CharacterMemoryBlock> memory; // Legacy field; kept for compatibility, not the main memory source
}
```

### Persona structure

```markdown
## Identity
Core description of the character...

## Personality
Personality traits...

## Scenario
Scene setup...
```

## 3. Character memory

### 3.1 Storage paths

```
workspace/_<userId>/_System/character_memory/<characterId>/
├── memory_entries.jsonl      # Long-term stable memory (declarative facts)
├── world_entries.jsonl       # Character world book (SillyTavern character_book)
├── timeline.jsonl            # Cross-scene event stream (recent original text)
├── archived_timeline.jsonl   # Compressed archived events (searchable via HistorySearch)
├── checkpoints.jsonl         # Stage summaries after compaction
└── indexes.json              # Migration version, cursors, last compaction time
```

### 3.2 Memory layers

| Layer | File | Injected at | Notes |
|---|---|---|---|
| User profile | `_System/memory/memory.json` | Skill system prompt | Global user profile, maintained by MemoryManagement |
| Character long-term memory | `memory_entries.jsonl` | Skill system prompt | Injected in full, no retrieval filter. The agent maintains it with MemoryAdd/Replace/Remove |
| Character world book | `world_entries.jsonl` | systemReminders | Triggered by `keys` plus constant entries; hard-truncated at 2000 tokens |
| Compaction summary | `checkpoints.jsonl` | User-message prefix | Injected as a `[CONTEXT SUMMARY — REFERENCE ONLY]` node |
| Recent history | Tail of `timeline.jsonl` | systemReminders | Kept in full after compaction (no extra tail trim) |
| User knowledge base | PKM/Facts grep + FTS | systemReminders | Retrieved with `queryHint`; hard-truncated at 2000 tokens |

### 3.3 Where context is injected

**System prompt (skill layer, stable identity):**
- Character `systemPromptOverride` (if any)
- Character persona + behavior rules
- User profile
- Character memory entries (full set)
- Style examples (`mesExample`, if any)
- Memory update guidance

**systemReminders (dynamic, refreshed before each run):**
- Triggered character world entries
- Recent cross-scene interactions (timeline tail)
- User knowledge cards
- Post-history instructions (if any)

**User-message prefix:**
- Compaction summary checkpoint

## 4. Unified event stream (timeline)

### 4.1 Event types

```dart
enum CharacterMemoryEventType {
  userChatMessage,        // User message in chat
  characterChatMessage,   // Character reply in chat
  postObserved,           // Character observed a user post (comment-scene input)
  characterComment,       // Character published a comment
  userCommentReply,       // User replied to the character in comments
}
```

### 4.2 When events are written

- `PersonaChatService.addUserMessage/addCharacterMessage` → chat events
- `CommentToolFactory.SaveComment` → `characterComment`
- `CommentAgent.runAndGetResponse` → `postObserved`
- `postCommentEndpoint` (user reply on a comment) → `userCommentReply`

### 4.3 FTS indexes

Three FTS5 virtual tables (schema version 13):
- `character_memory_fts` — memory entry search
- `character_world_fts` — world-book search
- `character_timeline_fts` — event-stream search (supports scene/thread/archived filters)

## 5. Compaction

### 5.1 Triggers

Compaction runs **after** an agent run, using the real `promptTokens` from the API:
- Soft threshold: `promptTokens > contextWindow * 0.55` (default 64000 * 0.55 = 35200)
- Hard threshold: `promptTokens > contextWindow * 0.70`
- Cooldown: do not retry within 10 minutes after a failed compaction unless the hard threshold is exceeded

### 5.2 Compaction flow

1. **Pick a cut**: keep the latest 40 events (`keepRecent`) and find a safe split so the last user message stays in the retained window
2. **Pre-trim**: drop near-duplicate lines and truncate oversized JSON metadata
3. **LLM summary**: build a structured checkpoint from dropped events (Topic Continuity / Stable Facts / Relationship Changes / Emotional Trajectory / Open Threads)
   - Budget: 12000 characters (≈3000 tokens)
   - If over budget, request a condense retry
   - If still over budget, hard-truncate
4. **Archive**: write old events to `archived_timeline.jsonl`, checkpoints to `checkpoints.jsonl`, and keep only the recent timeline
5. **Memory extract**: use the LLM to pull stable facts from compacted events into `memory_entries.jsonl`

### 5.3 Size limits

- `memory_entries.jsonl`: warn the agent to merge/clean when total characters exceed 8000
- `checkpoints.jsonl`: prompt constraints + retry + fallback truncation keep it under 12000 characters
- `world_entries` / `knowledgeCards`: hard-truncate at 2000 tokens on read
- `timeline` / `userProfile`: not truncated; compaction is the only volume control

## 6. Agent architecture

### 6.1 CompanionAgent (chat)

```
User sends a message → persona_chat_screen
  → CompanionAgent.chat()
    → resolveCharacterSessionId() — latest session (resume if interrupted, else increment)
    → CharacterContextAssembler.build() — assemble the context snapshot
    → CompanionAgentSkill — build system prompt (persona + profile + memories + mesExample)
    → state.systemReminders — inject world/timeline/knowledge/postHistoryInstructions
    → StatefulAgent.run() — execute (no built-in compressor)
    → on success, check promptTokens → compressIfNeeded()
```

### 6.2 CommentAgent (comments)

```
User posts a record → GlobalEventBus → comment_agent_task
  → CommentAgent.createAgent()
    → resolveCharacterSessionId()
    → CharacterContextAssembler.build()
    → CommentAgentSkill — build system prompt (persona + profile + memories)
    → state.systemReminders — inject world/timeline/knowledge
    → create StatefulAgent
  → CommentAgent.runAndGetResponse()
    → build structured task message (factId + rawInput + insight + pkmContext)
    → inject compaction summary node
    → StatefulAgent.run()
    → on success, check promptTokens → compressIfNeeded()
```

### 6.3 Session management

- Session ID format: `{agent}_{userId}_{characterId}_{N}` (incrementing)
- `resolveCharacterSessionId`: scan the state directory for the latest session
  - If `isRunning` (interrupted) → return that session to resume
  - If completed → return `N+1` as a new session
- Each run is a fresh session; cross-message history comes from the timeline system
- `autoSaveStateFunc` remains for crash recovery and debugging

### 6.4 Agent tools

**Chat tools** (`CharacterToolsFactory.buildCompanionTools`):
- `MemoryRead` — inspect character memory (for precise edits)
- `MemoryAdd` — add stable memory
- `MemoryReplace` — replace existing memory
- `MemoryRemove` — delete memory
- `HistorySearch` — search original interaction history (recent + archived)

**Comment tools** (`CharacterToolsFactory.buildCommentTools`):
- `Read` / `Grep` — file read (read-only permission)
- `SaveComment` — save a comment (with stopFlag)
- `MemoryRead/Add/Replace/Remove` — same as chat
- `HistorySearch` — same as chat

## 7. SillyTavern character-card import

### 7.1 Supported formats

- SillyTavern V2 JSON character cards
- PNG images with an embedded card (tEXt / iTXt chunk)

### 7.2 Field mapping

| V2 field | Maps to | Runtime use |
|---------|---------|-----------|
| `name` | `CharacterModel.name` | Character name |
| `description` | persona `## Identity` | System prompt |
| `personality` | persona `## Personality` | System prompt |
| `scenario` | persona `## Scenario` | System prompt |
| `first_mes` | `CharacterModel.firstMessage` | Sent as the character's first chat message |
| `mes_example` | `CharacterModel.mesExample` | Style Examples section of the system prompt |
| `system_prompt` | `CharacterModel.systemPromptOverride` | Injected at the front of the system prompt |
| `post_history_instructions` | `CharacterModel.postHistoryInstructions` | Injected via systemReminders |
| `tags` | `CharacterModel.tags` | UI |
| `character_book` | `world_entries.jsonl` | Key-triggered injection into systemReminders |
| `creator_notes` | not imported | Metadata only; not sent to the model |
| `alternate_greetings` | not imported | — |

### 7.3 World-book entries

```jsonl
{"id":"card_book_0","keys":["keyword1","keyword2"],"content":"...","comment":"entry title","constant":false,"enabled":true,"source":"tavern_character_book"}
```

- `constant: true` → always injected (no key trigger)
- `enabled: false` → never triggered
- Trigger logic: current `queryHint` contains a key, or FTS matches

### 7.4 Import entry points

- UI: download icon on the character config AppBar → `TavernImportScreen`
- Route: `/tavern-import`
- Flow: pick file → preview → conflict check → optional set as primary companion → confirm import

## 8. `firstMessage`

When the user first opens chat with a character (no rows in `PersonaChatMessages` for that character):
1. Check that `character.firstMessage` is non-empty
2. Call `PersonaChatService.addCharacterMessage` to persist the greeting
3. Also write it to `timeline.jsonl` as a `characterChatMessage` event
4. Show it in the UI as the character's first message

## 9. Migrations

### Database (schema version 13)

When `from < 13`, create the three FTS5 virtual tables: `character_memory_fts`, `character_world_fts`, `character_timeline_fts`.

### Files (`CharacterMemoryService.ensureMigrated`)

On first access of character memory (`migration_version < 1`):
- Rename legacy `Characters/{characterId}_relationship.md` and `Characters/{characterId}_emotional_state.md` with a `.deprecated_YYYYMMDD` suffix
- Write `migration_version: 1` into `indexes.json`

## 10. Code index

| File | Role |
|------|------|
| `lib/domain/models/character_model.dart` | Character data model |
| `lib/data/services/character_service.dart` | Character CRUD and default seeds |
| `lib/agent/context/character_context_assembler.dart` | Shared context assembly |
| `lib/agent/memory/character_memory_service.dart` | Unified memory storage (timeline/memory/world/checkpoints) |
| `lib/agent/memory/character_context_compressor.dart` | Timeline compaction (triggered by real promptTokens) |
| `lib/agent/context/user_knowledge_context_service.dart` | User knowledge retrieval |
| `lib/agent/companion_agent/companion_agent.dart` | Chat-scene agent |
| `lib/agent/comment_agent/comment_agent.dart` | Comment-scene agent |
| `lib/agent/skills/companion_agent/companion_agent_skill.dart` | Chat skill (system prompt) |
| `lib/agent/skills/comment_agent/comment_agent_skill.dart` | Comment skill (system prompt) |
| `lib/agent/skills/comment_agent/tools/memory_tools.dart` | MemoryRead/Add/Replace/Remove/HistorySearch |
| `lib/agent/skills/comment_agent/tools/comment_tools.dart` | SaveComment |
| `lib/agent/skills/character_tools_factory.dart` | Shared tool factory |
| `lib/agent/state_util.dart` | Agent state + resolveCharacterSessionId |
| `lib/data/services/tavern_character_import_service.dart` | SillyTavern card import |
| `lib/data/services/persona_chat_service.dart` | Chat persistence + timeline events |
| `lib/ui/character/widgets/persona_chat_screen.dart` | Chat UI |
| `lib/ui/character/widgets/tavern_import_screen.dart` | Import UI |
| `lib/ui/character/widgets/character_config_screen.dart` | Character management UI |
| `lib/db/daos/search_dao.dart` | FTS5 index management |
| `lib/db/app_database.dart` | Schema migration (version 13) |

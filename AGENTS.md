# Memex — Project Context for Coding Agent

> *"Always leave the code better than you found it."* — The Boy Scout Rule

Memex is a local-first, AI-powered personal life recording app built with Flutter (iOS + Android). The user's journal workspace is stored locally: timeline cards, PKM files, media assets, schedules, knowledge insights, and indexes live under the selected filesystem root plus SQLite. AI features use the configured model service (BYO provider, local Ollama, OAuth providers, or optional Memex AI for model access/billing); Memex does not host the user's journal data. SuperAgent orchestrates specialist workers that turn raw inputs into timeline cards, PKM entries, schedule state, knowledge insights, comments, and long-term memory updates. Respect the existing abstractions: use the right service for data access, follow the layer boundaries, and read the surrounding code before making changes. Shortcuts that bypass encapsulation create bugs that are hard to trace in a system with agents, event pipelines, and per-user isolation.

## Build & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after changing Drift tables or *.g.dart sources
flutter run --flavor globalDev   # Android local Dev overseas, isolated package/data
flutter run --flavor cnDev       # Android local Dev China, isolated package/data
flutter run --flavor globalEarly # Android Early overseas, isolated package/data
flutter run --flavor cnEarly     # Android Early China, isolated package/data
flutter run --flavor global      # Stable overseas; avoid for local dev
flutter run --flavor cn          # Stable China domestic; avoid for local dev
flutter analyze
flutter test
cd ios && pod install && cd ..
```

Never edit `*.g.dart` files — always regenerate.

## Testing Requirements

Behavior changes must include tests in the same PR. Documentation, comments, or
pure repository configuration changes may skip app tests only when the PR test
plan explains why.

- Add or update **unit tests** for changed domain models, utilities,
  repositories, services, task handlers, agents, routing decisions, database
  behavior, or non-UI ViewModel logic. Mirror the `lib/` path under `test/`
  whenever a clear home exists.
- Add or update **widget tests** for any UI rendering, state, navigation,
  dialog/sheet, button, gesture, error/empty/loading state, localization, or
  user interaction change. The test should assert the visible behavior a user
  relies on.
- Add an integration or full-chain regression test when a change crosses
  repository/service/router/event/task/agent boundaries or fixes a golden-path
  flow such as capture, card generation, timeline refresh, backup/restore, or
  LLM configuration.
- Do not delete, weaken, or rewrite tests just to make a change pass. If a test
  expectation changes, preserve the old behavior in a new assertion when it is
  still supported, or explain the behavior change in the PR.
- Run the smallest meaningful targeted tests while iterating, then run
  `flutter test` and `flutter analyze` before publishing when feasible. If a
  command is not run, the PR test plan must state the exact reason.

## Architecture

**MVVM + Provider** following [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide).

### Layers

- **UI layer** — Views (widgets) contain no business logic. ViewModels extend `ChangeNotifier`, each UI feature has `view_models/` and `widgets/` subdirectories.
- **Data layer** — `MemexRouter` is a thin routing/facade; it delegates to repositories and services. **Do not put complex business logic in MemexRouter.** New features should add repository functions or service classes, then wire them through MemexRouter.
  - **Repositories** (`data/repositories/`) — source of truth for domain data. Return `Future<Result<T>>` using domain models, not DTOs.
  - **Services** (`data/services/`) — local-first app services play the backend role for local work: filesystem I/O, SQLite, task execution, search indexing, LLM client calls, optional Memex AI/account integration, health data, speech transcription, etc. Can be stateful singletons.
- **Domain layer** — `domain/models/` for business models (e.g. `TimelineCardModel`, `LLMConfig`). `data/model/` for protocol/transport DTOs (e.g. `ChatEvent`). Don't mix them. Optional `domain/use_cases/` for complex logic that merges multiple repositories or is reused across ViewModels.

### Dependency rules

- `dependencies.dart` registers **only** repositories/services (currently just `MemexRouter`), **never ViewModels**
- ViewModels receive `MemexRouter` via constructor: `MyViewModel({required MemexRouter router})`
- ViewModel must NOT depend on `BuildContext` or any widget
- `data/` layer must NOT depend on `ui/` or any specific feature
- `domain/models/` must NOT depend on Flutter, Repository, or Service

## Logging

Use `getLogger('ComponentName')` from `utils/logger.dart` (wraps `package:logging`), not `print()`.

### ViewModel ↔ Screen wiring

**Naming conventions:**
- ViewModels: `*_viewmodel.dart` (lowercase), class `XxxViewModel`
- Full-screen pages: `*_screen.dart`, class `XxxScreen`
- Non-screen widgets: use semantically clear suffixes like `*_page.dart`, `*_dialog.dart`, `*_widget.dart`, etc.

**Wiring rules:**

- Screens declare `final XxxViewModel viewModel;` with `required this.viewModel` constructor
- Use `ListenableBuilder(listenable: widget.viewModel)` — **not** `context.watch<XxxViewModel>()`
- Sub-route ViewModels: created in `router.dart` route builders with `context.read<MemexRouter>()`
- Root-level ViewModels (Timeline, Insight, KnowledgeBase): created once in `RootShell` via `MultiProvider`, passed down to tab screens via constructor

### Result & Command

**Result** (`utils/result.dart`) — core error handling pattern, used throughout:
```dart
// Repository returns Result<T>
Future<Result<List<TagModel>>> fetchTags() => runResult(() async { ... });

// ViewModel consumes with .when() — no raw try/catch
final result = await _router.fetchTimelineCards(page: 1, limit: 20);
result.when(
  onOk: (cards) { this.cards = cards; notifyListeners(); },
  onError: (e, st) { errorMessage = '加载失败'; notifyListeners(); },
);
// Void success: const Ok.v()
// Extensions: result.isOk, result.isError, result.valueOrThrow
```

**Command** (`utils/command.dart`) — optional wrapper for retryable async loads. Wraps a `Future<Result<T>>` action into a `ChangeNotifier` with `running`/`error`/`completed` states, so UI can bind via `ListenableBuilder`.

## Data Model

- Workspace source data lives mostly on the filesystem (YAML/JSON/Markdown/media) with SQLite used for indexes, caches, tasks, and query speed. Each data type has a dedicated service — **always use these for app data changes, never manipulate managed files directly with `dart:io`**: cards/facts/assets/tags/insights/templates/schedule → `FileSystemService`; characters → `CharacterService`; chat → `ChatService`; memory → `MemoryManagement`/`MemorySyncService`; custom agents → `CustomAgentConfigService`; backup → `BackupService`.
- All workspace path definitions (e.g. `getCardsPath`, `getFactsPath`) must live in `FileSystemService` — never hardcode paths elsewhere.
- User-related preferences (user ID, LLM configs, agent configs, locale, storage location, etc.) are centralized in `UserStorage` (`utils/user_storage.dart`). System-level or temporary flags can live in their own service.
- Per-user workspace: `workspace/_<userId>/` with subdirs including `Facts/`, `Facts/assets/`, `Cards/`, `PKM/`, `KnowledgeInsights/`, `Schedule/`, `ChatSessions/`, `_UserSettings/`, and `_System/`. Memory files live under `_System/memory/`; agent state under `_System/state_dir/`.

## UI & Design System

**Card rendering** uses two factories:
- `NativeCardFactory.build(templateId, data, ...)`
- `NativeWidgetFactory.build(template, data)`

**Common UI patterns:**
- `ListenableBuilder(listenable: Listenable.merge([vm, vm.load]))` for reactive rebuilds
- `ToastHelper.showSuccess/showError/showInfo` for feedback
- `showGeneralDialog` with `AgentChatDialog` for AI chat overlays
- Any interaction UI change must include a widget test covering the behavior.

### Timeline Screen boundaries

`TimelineScreen` handles page-level orchestration only (tab switching, pagination, pull-to-refresh, navigation). Do not add card-specific special-case logic here. Reuse `NativeCardFactory` / `NativeWidgetFactory` for card rendering and `CardAttachmentFactory` for attachments — keep templateId branching and card-type checks out of the screen layer.

## Event & Task System

The app uses an event-driven pipeline for processing. When deciding how to handle a new feature's processing logic, consider:

- **`GlobalEventBus`** — the system event bus. Publish a `SystemEvent` when an action may have multiple independent consumers (built-in agents, FTS indexing, user-defined custom agents, etc.). This decouples the publisher from subscribers and makes the system extensible. Subscribers can be **sync** (awaited inline, for lightweight work) or **async** (enqueued as persistent tasks for heavy work like LLM calls).

- **`LocalTaskExecutor`** — persistent task queue for work that is slow and **must complete** (e.g. agent LLM calls that take seconds to minutes). Tasks survive app restarts and retry on failure. Async subscribers on `GlobalEventBus` are automatically enqueued here. Task handlers are registered in `MemexRouter._init()`.

- **`EventBusService`** — lightweight UI notification bus. Task handlers and repositories call `emitEvent()` when data changes (card created, card updated, insight generated, error occurred) so ViewModels can refresh the screen. Ephemeral, not persisted — purely for driving UI updates.

### SQLite change observation

Use `TableChangeNotifier.instance.watch(tableName, handler)` to react to table-level changes. Do not scatter Drift `query.watch()` streams across services and ViewModels — centralize change observation through `TableChangeNotifier` so there is one subscription per table and consistent dispatch.

## Agent System

All agents are built on `dart_agent_core`'s `StatefulAgent`. When creating or modifying agents, follow these conventions:

- **Agent creation pattern**: `loadOrCreateAgentState()` → `AgentController` with `addAgentLogger()` + `addAgentActivityCollector()` → configure tools/skills/permissions → `StatefulAgent(...)` with `hooks: [createAgentPromptHook(...), ...]`. Always pass `autoSaveStateFunc` for state persistence.
- **LLM resources**: obtain via `UserStorage.getAgentLLMResources(agentId)` — handles per-agent model config resolution and client instantiation.
- **File access**: each agent declares its own `FilePermissionManager` with explicit `PermissionRule`s (read/write/none per directory). Build file tools via `FileToolFactory`. Never give an agent broader access than it needs.
- **Skills**: built-in Dart skills in `agent/skills/` (e.g. `PkmSkill`, `TimelineCardSkill`, `KnowledgeInsightSkill`). Passed as `skills:` parameter to `StatefulAgent`.
- **Prompts**: co-locate with the agent/skill/tool that uses them. Large prompts go in a dedicated `prompts.dart` as constants or builder methods (e.g. `agent/super_agent/prompts.dart`). Short prompts can be inline string variables in the code file. Shared prompts go in `agent/prompts.dart`.
- **Hooks**: use `AgentHook`s for cross-cutting agent behavior around model requests, tool calls, turn completion, persistence, retries, and runtime coordination. Prefer hooks when behavior should apply consistently across an agent run instead of being scattered through tool implementations. Be deliberate about what goes into persisted history or state: one-turn context should stay transient unless future turns need the provenance.

### SuperAgent and child workers

- `SuperAgent` is the root conversational orchestrator. It owns user-facing replies, record identity, and coordination; specialist child workers own bounded production tasks.
- Child workers are launched through `delegate_to_subagent` fixed presets in `agent/super_agent/subagent/delegate_subagent_tool.dart`. Do not create free-form child types from prompts alone; update the preset registry, permissions, skills, and `superAgentSystemPrompt` together.
- Capture normally mints/reuses one `fact_id`, then delegates independent `timeline_card`, `pkm`, and when relevant `schedule` work in parallel. The Card worker is the source of truth for whether a new record was actually saved.
- `task_content` is an array of text and asset blocks. Use asset blocks for attachments (`{"type":"asset","ref":"fs://..."}`); child agents can directly inspect image assets, so text should carry only the record words, fact_id mapping, and goal.
- SuperAgent and child workers must use owning skills/tools for managed data (`manage_timeline_card`, `manage_pkm`, `update_schedule_aggregation`, `update_knowledge_insight`, `manage_memory`). Raw file tools are for reading/searching or explicitly allowed workspace files, not bypassing managed write paths.
- Quick Query mode is read-only. Any new skill or tool that can mutate app data must be excluded from Quick Query, not just hidden from the base tool list.

## Localization

Two approaches — pick the right one based on string length:
- **Short UI strings** (labels, buttons, toasts): ARB files in `lib/l10n/` (standard Flutter l10n). Keep both `app_en.arb` and `app_zh.arb` in sync.
- **Multi-line text** (long descriptions, agent prompts, onboarding copy): defined directly in `AppLocalizationsExt` (`lib/l10n/app_localizations_ext.dart`) as Dart code — better readability than JSON for multi-line content.

Access all strings via `UserStorage.l10n` (static, initialized in `main()`).

# Memex — Project Context for Coding Agent

> *"Always leave the code better than you found it."* — The Boy Scout Rule

Memex is a local-first, AI-powered personal life recording app built with Flutter (iOS + Android). All user data stays on-device — a multi-agent system processes inputs into timeline cards, extracts knowledge, and generates cross-record insights. Users bring their own LLM provider. Respect the existing abstractions: use the right service for data access, follow the layer boundaries, and read the surrounding code before making changes. Shortcuts that bypass encapsulation create bugs that are hard to trace in a system with agents, event pipelines, and per-user isolation.

## Build & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after changing Drift tables or *.g.dart sources
flutter run --flavor global   # overseas (default if omitted)
flutter run --flavor cn       # China domestic
flutter analyze
flutter test
cd ios && pod install && cd ..
```

Never edit `*.g.dart` files — always regenerate.

## Architecture

**MVVM + Provider** following [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide).

### Layers

- **UI layer** — Views (widgets) contain no business logic. ViewModels extend `ChangeNotifier`, each UI feature has `view_models/` and `widgets/` subdirectories.
- **Data layer** — `MemexRouter` is a thin routing/facade; it delegates to repositories and services. **Do not put complex business logic in MemexRouter.** New features should add repository functions or service classes, then wire them through MemexRouter.
  - **Repositories** (`data/repositories/`) — source of truth for domain data. Return `Future<Result<T>>` using domain models, not DTOs.
  - **Services** (`data/services/`) — local-first app with no backend, so services play the backend role: filesystem I/O, SQLite, task execution, search indexing, LLM client calls, health data, speech transcription, etc. Can be stateful singletons.
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

- All workspace data lives on the filesystem (YAML/JSON/Markdown). Each data type has a dedicated service — **always use these, never manipulate files directly with `dart:io`**: cards/facts/assets/tags/insights/templates → `FileSystemService`; characters → `CharacterService`; chat → `ChatService`; memory → `MemorySyncService`; custom agents → `CustomAgentConfigService`; backup → `BackupService`.
- All workspace path definitions (e.g. `getCardsPath`, `getFactsPath`) must live in `FileSystemService` — never hardcode paths elsewhere.
- User-related preferences (user ID, LLM configs, agent configs, locale, storage location, etc.) are centralized in `UserStorage` (`utils/user_storage.dart`). System-level or temporary flags can live in their own service.
- Per-user workspace: `workspace/_<userId>/` with subdirs: `Facts/`, `Cards/`, `PKM/`, `KnowledgeInsights/`, `ChatSessions/`, `Memory/`, `_UserSettings/`, `_System/`

## UI & Design System

**Card rendering** uses two factories:
- `NativeCardFactory.build(templateId, data, ...)`
- `NativeWidgetFactory.build(template, data)`

**Common UI patterns:**
- `ListenableBuilder(listenable: Listenable.merge([vm, vm.load]))` for reactive rebuilds
- `ToastHelper.showSuccess/showError/showInfo` for feedback
- `showGeneralDialog` with `AgentChatDialog` for AI chat overlays

## Event & Task System

The app uses an event-driven pipeline for processing. When deciding how to handle a new feature's processing logic, consider:

- **`GlobalEventBus`** — the system event bus. Publish a `SystemEvent` when an action may have multiple independent consumers (built-in agents, FTS indexing, user-defined custom agents, etc.). This decouples the publisher from subscribers and makes the system extensible. Subscribers can be **sync** (awaited inline, for lightweight work) or **async** (enqueued as persistent tasks for heavy work like LLM calls).

- **`LocalTaskExecutor`** — persistent task queue for work that is slow and **must complete** (e.g. agent LLM calls that take seconds to minutes). Tasks survive app restarts and retry on failure. Async subscribers on `GlobalEventBus` are automatically enqueued here. Task handlers are registered in `MemexRouter._init()`.

- **`EventBusService`** — lightweight UI notification bus. Task handlers and repositories call `emitEvent()` when data changes (card created, card updated, insight generated, error occurred) so ViewModels can refresh the screen. Ephemeral, not persisted — purely for driving UI updates.

## Agent System

All agents are built on `dart_agent_core`'s `StatefulAgent`. When creating or modifying agents, follow these conventions:

- **Agent creation pattern**: `loadOrCreateAgentState()` → `AgentController` with `addAgentLogger()` + `addAgentActivityCollector()` → configure tools/skills → `StatefulAgent(systemCallback: createSystemCallback(userId))`. Always pass `autoSaveStateFunc` for state persistence.
- **LLM resources**: obtain via `UserStorage.getAgentLLMResources(agentId)` — handles per-agent model config resolution and client instantiation.
- **File access**: each agent declares its own `FilePermissionManager` with explicit `PermissionRule`s (read/write/none per directory). Build file tools via `FileToolFactory`. Never give an agent broader access than it needs.
- **Skills**: built-in Dart skills in `agent/skills/` (e.g. `PkmSkill`, `TimelineCardSkill`, `KnowledgeInsightSkill`). Passed as `skills:` parameter to `StatefulAgent`.
- **Prompts**: co-locate with the agent/skill/tool that uses them. Large prompts go in a dedicated `prompts.dart` as constants or builder methods (e.g. `agent/pkm_agent/prompts.dart`). Short prompts can be inline string variables in the code file. Shared prompts go in `agent/prompts.dart`.

## Localization

Two approaches — pick the right one based on string length:
- **Short UI strings** (labels, buttons, toasts): ARB files in `lib/l10n/` (standard Flutter l10n). Keep both `app_en.arb` and `app_zh.arb` in sync.
- **Multi-line text** (long descriptions, agent prompts, onboarding copy): defined directly in `AppLocalizationsExt` (`lib/l10n/app_localizations_ext.dart`) as Dart code — better readability than JSON for multi-line content.

Access all strings via `UserStorage.l10n` (static, initialized in `main()`).


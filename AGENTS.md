# Memex — Project Context for Claude Code

## Product

Memex is a local-first, AI-native personal knowledge management app built with Flutter. Users capture text, photos, and voice recordings. A multi-agent system automatically organizes records into structured timeline cards, extracts knowledge, and generates cross-record insights.

All data stays on-device. Users bring their own LLM provider (Gemini, OpenAI, Claude, AWS Bedrock).

### Core Capabilities
- Multi-modal input: text, images, voice recording with EXIF extraction and on-device OCR/labeling (Google ML Kit)
- AI-powered card generation: inputs are transformed into typed timeline cards (task, event, metric, person, place, gallery, etc.)
- Knowledge organization using P.A.R.A methodology (Projects, Areas, Resources, Archives)
- Insight engine: surfaces patterns across records as charts, narratives, maps, and timelines
- Conversational AI assistant for discussing cards and topics
- App lock with biometric authentication
- i18n: English and Chinese

### Target Platforms
- iOS (App Store: MemexAI)
- Android (GitHub Releases APK)

---

## Tech Stack

- Flutter (Dart ≥ 3.6, < 4.0), Material 3 with custom `AppTheme` in `lib/ui/core/themes/`

### Architecture
- MVVM with Provider for state management
- `ChangeNotifier`-based ViewModels created at the screen level, not registered globally
- `Command` pattern (Compass-style) for async operations with running/error/completed states
- Sealed `Result<T>` type (`Ok`/`Error`) for explicit error handling — no raw try/catch in ViewModels
- `MemexRouter` singleton acts as the central repository/service facade
- GoRouter for declarative navigation (`lib/routing/`)
- Dependencies registered in `lib/config/dependencies.dart` — only repositories/services, never ViewModels

### Database
- Drift (SQLite) with code generation; tables in `lib/db/tables.dart`, generated files: `*.g.dart`
- Local filesystem storage via `FileSystemService`

### AI / Agent System
- Multi-agent architecture using `dart_agent_core`
- Agents: PKM, Card, Insight, Comment, Memory, Persona, Super (orchestrator)
- Composable skills in `lib/agent/skills/`
- LLM client abstraction in `lib/llm_client/` supporting multiple providers
- On-device ML: `google_mlkit_text_recognition`, `google_mlkit_image_labeling`

### Key Libraries
- `provider`, `go_router`, `drift`/`sqlite3_flutter_libs`, `dio`/`http`, `web_socket_channel`
- `fl_chart`, `flutter_map`/`latlong2`, `image_picker`/`camera`/`photo_manager`
- `record`/`audioplayers`, `flutter_markdown`, `local_auth`, `health`/`pedometer`
- `workmanager`, `intl`, `google_generative_ai`

---

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── app_initializer.dart
├── config/
│   ├── app_config.dart
│   └── dependencies.dart      # DI setup (repositories/services only)
├── agent/                     # Multi-agent AI system
│   ├── pkm_agent/
│   ├── card_agent/
│   ├── insight_agent/
│   ├── comment_agent/
│   ├── memory_agent/
│   ├── persona_agent/
│   ├── super_agent/           # Orchestrator
│   ├── skills/                # Composable skills
│   ├── built_in_tools/
│   ├── memory/
│   └── security/
├── data/
│   ├── model/                 # DTOs
│   ├── repositories/
│   └── services/
├── db/                        # Drift database layer
├── domain/models/             # Domain models
├── l10n/                      # ARB localization files
├── llm_client/                # LLM provider abstraction
├── routing/                   # GoRouter config
├── ui/                        # MVVM presentation layer
│   ├── core/                  # Shared widgets, themes
│   ├── timeline/
│   ├── insight/
│   ├── knowledge/
│   ├── chat/
│   ├── calendar/
│   ├── character/
│   ├── memory/
│   ├── settings/
│   ├── app_lock/
│   ├── main_screen/
│   ├── agent_activity/
│   └── user_setup/
└── utils/                     # result.dart, command.dart, logger.dart, etc.
```

### Conventions
- Each UI feature has `view_models/` and `widgets/` subdirectories
- ViewModels extend `ChangeNotifier`, created at screen level via `ChangeNotifierProvider`
- Repositories are standalone functions or thin wrappers, accessed through `MemexRouter`
- Never edit `*.g.dart` files — they are generated
- Assets in `assets/`, platform code in `android/`, `ios/`

---

## Common Commands

```bash
flutter pub get
flutter run
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs
cd ios && pod install && cd ..
```

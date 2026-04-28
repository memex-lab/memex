# Contributing to Memex

Thanks for helping make Memex better. Memex is a local-first, AI-native personal knowledge app, so we are careful about changes that affect privacy, local data, database migrations, agent behavior, and LLM provider boundaries.

Opening an issue helps us understand demand, but it does not guarantee that the feature will be implemented. Maintainers use issues as a signal pool, the project board as an execution queue, and the roadmap as a statement of direction.

## Ways to Contribute

- Report reproducible bugs.
- Improve documentation, localization, and examples.
- Fix small UI issues or mobile platform bugs.
- Add tests around existing behavior.
- Add or improve LLM provider adapters.
- Propose agent skills, card templates, import/export flows, and local-first data workflows.

For large product changes, please open an issue or discussion before writing code.

## What Needs Design First

Please wait for maintainer feedback before opening a large PR that changes:

- Database schema, migrations, or storage paths.
- Agent orchestration, event bus behavior, background task scheduling, or skill execution.
- Security, app lock, local file access, or privacy boundaries.
- LLM client abstractions or provider authentication flows.
- Navigation structure, core timeline/card models, or backup/restore behavior.
- Any feature that adds cloud dependency, telemetry, account systems, or server-side storage.

These areas can still receive community contributions, but they need a shared design before implementation.

## Issue Triage

We use labels to make issue state visible:

- `type: bug`, `type: feature`, `type: enhancement`, `type: docs`, `type: question`
- `area: timeline`, `area: ai-agents`, `area: llm-provider`, `area: local-first`, `area: ios`, `area: android`, `area: i18n`, `area: ux`
- `priority: p0`, `priority: p1`, `priority: p2`, `priority: p3`
- `needs info`, `needs reproduction`, `needs product decision`, `accepted`, `ready for contributor`
- `good first issue`, `help wanted`, `not planned`, `duplicate`

Issue states usually move like this:

```text
new issue
-> triage
-> needs info / discussion / accepted / not planned
-> ready for contributor
-> in progress
-> done
```

`accepted` means the direction fits Memex. `ready for contributor` means the scope is clear enough for someone to start implementation.

## Priority Guide

- `priority: p0`: data loss, privacy leak, app cannot launch, core recording flow broken.
- `priority: p1`: common workflow blocked, such as input, card generation, LLM configuration, backup/restore, or app lock.
- `priority: p2`: meaningful usability improvement, common platform bug, or widely requested enhancement.
- `priority: p3`: nice-to-have, experimental idea, long-term product direction.

Community demand matters, but maintainers also consider strategic fit, implementation cost, maintenance risk, and whether the change preserves Memex's local-first and privacy-first principles.

## Pull Request Workflow

1. Fork the repository and create a focused branch.
2. Keep PRs small enough to review. Split unrelated changes.
3. Follow the architecture already in the codebase:
   - MVVM with `ChangeNotifier` view models created at screen level.
   - Repositories/services registered through `lib/config/dependencies.dart`.
   - `MemexRouter` as the central facade.
   - `Result<T>` and `Command` for explicit async state and errors.
   - No manual edits to generated `*.g.dart` files.
4. Add or update tests when changing behavior.
5. Fill in the PR template, including screenshots or screen recordings for UI changes.

Maintainers may close PRs that are out of scope, too broad, or conflict with the local-first product direction. We will try to say that early so contributors do not spend unnecessary time.

## Development Setup

See [BUILD.md](BUILD.md) for flavor-specific build commands.

Common commands:

```bash
flutter pub get
flutter test
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

For iOS:

```bash
cd ios && pod install && cd ..
```

## Code Style

- Prefer existing patterns over new abstractions.
- Keep user data local unless a user explicitly configures an external LLM provider.
- Avoid hidden telemetry or network calls.
- Use clear domain names for cards, agents, memory, timeline, and knowledge features.
- Keep localization in sync for user-visible strings.
- Do not commit secrets, signing keys, generated build artifacts, or local config files.

## Security and Privacy

Do not open public issues for vulnerabilities that could expose private data, files, model credentials, app lock behavior, or backup contents. Please contact the maintainers privately first.

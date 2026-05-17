# PR Policy Preflight Rules

Policy Preflight is a deterministic rule check for pull requests. It does not
call AI, run Flutter, execute PR code, or decide whether the code is
semantically correct. It only classifies objective risk signals from PR metadata,
changed files, and diff content.

In the current shadow phase, Preflight only reports a decision. Its decision is
not a merge blocker yet.

Human-facing Markdown output is bilingual. JSON keeps stable English field names
and includes Chinese labels/messages such as `decision_zh` and `message_zh`.

## Decision Levels

### `reject`

The PR contains an objective policy violation or cannot be safely evaluated.
The author should rework the PR before it enters the normal merge path.

### `high_risk`

The PR may be valid, but it touches sensitive areas or has enough change volume
that maintainer review is required.

### `low_risk`

No deterministic rule found a reason to reject the PR or require maintainer
review. AI review and normal CI can still raise additional concerns.

## Reject Rules

These rules always produce `reject`.

| Rule | How it is checked | Why it rejects |
| --- | --- | --- |
| Secret or signing material | Changed file path matches keystore, `.pem`, `.p8`, `.key`, `key.properties`, or credential-like patterns | Secrets and signing material must not enter PR review. |
| Generated Dart without source | `*.g.dart`, `*.freezed.dart`, or `*.gr.dart` changed without the matching `.dart` source file | Generated output should not be edited by hand. |
| Policy control deleted | Preflight docs, the preflight script, or CODEOWNERS-style control files are deleted | Review controls should not be weakened silently. |
| Unsafe workflow pattern | Added workflow content contains `permissions: write-all`, Docker socket mount, privileged container, `curl | bash`, or `wget | sh` | Workflow changes can expose tokens or execute untrusted code. |
| Preflight collection failure | The script cannot read git refs, changed files, or diff context | A PR that cannot be evaluated should not be treated as low risk. |

## High-Risk Path Rules

These rules produce `high_risk`.

| Path or area | Why it is high risk |
| --- | --- |
| `.github/**` | CI, release, and repository automation can change the trust boundary. |
| `android/**` | Platform permissions, signing, flavors, and packaging can affect release safety. |
| `ios/**` | Platform permissions, entitlements, signing, and packaging can affect release safety. |
| `pubspec.yaml`, `pubspec.lock` | Dependency changes can affect build, runtime, and supply-chain risk. |
| `analysis_options.yaml` | Analyzer/lint changes can weaken code quality checks. |
| `lib/main.dart`, `lib/dependencies.dart`, `lib/router.dart` | App startup, dependency registration, and navigation are golden paths. |
| `lib/utils/user_storage.dart` | User identity, locale, storage, LLM config, and preferences are privacy-sensitive. |
| `lib/data/services/file_system_service.dart` | Workspace paths and local data access are data-integrity sensitive. |
| `lib/data/services/backup_service.dart` | Backup/restore changes can cause data loss. |
| `lib/data/services/global_event_bus.dart` | Event routing can affect multiple independent consumers. |
| `lib/data/services/local_task_executor.dart` | Persistent background tasks must complete and retry correctly. |
| `lib/data/services/event_bus_service.dart` | UI refresh events can hide or surface stale data. |
| `lib/data/services/task_handlers/**` | Agent/task processing can trigger slow, persistent, or cross-cutting behavior. |
| `lib/agent/**` | Agent prompts, tools, skills, and file permissions affect safety boundaries. |
| Timeline/card rendering factories | Timeline and card rendering are core user-facing golden paths. |
| Preflight docs/script/control files | Review policy changes need maintainer eyes. |

## High-Risk Structure Rules

These rules also produce `high_risk`.

| Rule | How it is checked | Why it is high risk |
| --- | --- | --- |
| Generated Dart with source | Generated file and matching source file both changed | Maintainer should verify code generation was intentional. |
| Localization pair mismatch | Only one of `lib/l10n/app_en.arb` or `lib/l10n/app_zh.arb` changed | User-facing strings should stay in sync across languages. |
| Large PR | Changed file count exceeds the low-risk threshold | Broad changes are harder to validate quickly. |
| Large diff | Total changed lines exceed the low-risk threshold | Large diffs are not suitable for the fast low-risk path. |
| Large single-file change | One file exceeds the single-file low-risk threshold | Large concentrated changes need human context. |
| Diff truncated | Diff exceeds the configured byte limit | The reviewer cannot see the full change. |
| Binary file outside low-risk asset path | Binary file changed outside `assets/icons/**` | Binary content is hard to review from diff. |

## Sensitive Keyword Rules

For selected source and configuration paths, added lines are scanned for
sensitive keywords. A match produces `high_risk`.

Examples:

- `UserStorage`
- `FilePermissionManager`
- `PermissionRule`
- `GlobalEventBus`
- `LocalTaskExecutor`
- `BackupService`
- workspace path helpers such as `getCardsPath` or `getFactsPath`
- credential-like identifiers such as `apiKey`, `accessToken`, `secret`,
  `password`, or `credential`
- network-related code such as `http`, `dio`, `WebSocket`, or `request(`
- destructive file operations such as `deleteSync`, `unlinkSync`, or `delete(`

## Warning Rules

Warnings do not change a PR to `high_risk` by themselves.

| Rule | How it is checked | Why it warns |
| --- | --- | --- |
| Missing test signal | Production Dart files changed without test files or a clear test plan | The PR may still be fine, but the reviewer should notice the missing evidence. |
| Missing PR title | PR title is empty | Review context is incomplete. |
| Missing PR body | PR body is empty | Review context is incomplete. |

## Shadow-Mode Behavior

During shadow mode:

- `low_risk`, `high_risk`, and `reject` are all reported.
- The workflow exits successfully so the PR is not blocked.
- Results are written to the workflow summary and uploaded as artifacts.

After calibration, a separate gate can decide how to use the result as a merge
requirement.

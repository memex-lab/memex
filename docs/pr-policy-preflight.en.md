# PR Policy Preflight Rules

Policy Preflight is a deterministic rule check for pull requests. It does not
call AI, run Flutter, execute PR code, or decide whether the code is
semantically correct. It treats the PR as data and looks for governance,
trust-boundary, and objective hard-policy signals from PR metadata, changed
files, and diff content.

A reject fails the governance job. High risk routes to a maintainer. Branch protection is configured separately.

Human-facing Markdown comments are split into two language sections: Chinese
first, then English. They do not interleave Chinese and English line by line.
Human-facing output does not show a risk score. JSON keeps stable English field
names and includes Chinese labels/messages such as `decision_zh` and
`message_zh`.

## Boundary With Flutter CI

Preflight is suitable for `pull_request_target` because it only executes trusted
scripts from the default branch and never runs PR-branch code. It should only
own hard rules around governance and trust boundaries, such as workflows, review
policy, lint configuration, secrets, signing material, and content that cannot
be safely reviewed from a diff.

Ordinary application code should not be primarily classified by directory-based
risk rules. Code quality is handled by a separate normal `pull_request` CI job
because that job executes PR code and must run without secrets and with minimal
permissions. This repository uses `.github/workflows/pr-flutter-quality.yml` for
that check, with `scripts/compare_flutter_analyze.py` and
`scripts/compare_flutter_test_failures.py` comparing base and PR analyzer/test
output as a baseline.

Flutter Quality runs the tooling tests, checks ARB key parity, and runs the regression scenarios selected by `scripts/verify_pr.py`. It compares analyzer findings and Flutter test failures against the base revision. New findings or failures, incomplete baseline evidence, or a failed selected scenario prevent a passing quality check.

## Handoff to local Codex

An open, non-draft PR enters the local review queue when both preflight jobs pass, their reports match the PR and its base/head revisions, and the current review is outstanding. Both `low_risk` and `high_risk` can enter the queue. A `reject` blocks entry.

Local Codex publishes a review comment and records the verdict against the reviewed PR, base, head, title and body. For a high-risk decision or a sensitive change flagged by the review tool, recording `passed` requires approval of the current head by a maintainer with write access other than the PR author. Maintainers make the merge decision. See the [local review procedure](local-pr-review.md) for the queue and verdict commands.

## Decision Levels

### `reject`

The PR contains an objective policy violation or cannot be safely evaluated.
The author should rework the PR before it enters the normal merge path.

### `high_risk`

The PR touches governance controls such as review rules, repository automation,
or lint configuration, or contains content that cannot be safely verified from
the diff. Maintainer review is required.

### `low_risk`

The governance check found no policy flags. Flutter verification and local Codex review still apply.

## Reject Rules

These rules always produce `reject`.

| Rule | How it is checked | Why it rejects |
| --- | --- | --- |
| Secret or signing material | Changed file path matches keystore, `.pem`, `.p8`, `.key`, `key.properties`, or credential-like patterns | Secrets and signing material must not enter PR review. |
| Generated Dart without source | `*.g.dart`, `*.freezed.dart`, or `*.gr.dart` changed without the matching `.dart` source file | Generated output should not be edited by hand. |
| Policy control deleted | Preflight docs, the preflight script, or CODEOWNERS-style control files are deleted | Review controls should not be weakened silently. |
| Unsafe workflow pattern | Added workflow content contains `permissions: write-all`, Docker socket mount, privileged container, `curl | bash`, or `wget | sh` | Workflow changes can expose tokens or execute untrusted code. |
| Preflight collection failure | The script cannot read git refs, changed files, or diff context | A PR that cannot be evaluated should not be treated as low risk. |

## High-Risk Rules

These rules produce `high_risk`.

| Rule | How it is checked | Why it is high risk |
| --- | --- | --- |
| GitHub configuration or workflow | `.github/**` changed | CI, release, and repository automation can change the trust boundary. |
| Analyzer/lint configuration | `analysis_options.yaml` changed | Lint configuration affects the trustworthiness of `flutter analyze`. |
| Review policy control | Preflight docs, the preflight script, or CODEOWNERS-style files changed | Review rules themselves should receive maintainer eyes. |
| Diff truncated | Diff exceeds the configured byte limit, currently 1,000,000 bytes by default | Reviewers and AI cannot see the full change. |
| Binary file outside low-risk asset path | Binary file changed outside `assets/icons/**` | Binary content is hard to review from diff. |

## Out of Scope

Policy Preflight should not own semantic review or attention heuristics. The
local Codex reviewer evaluates the following signals using the diff and PR context, and records `needs-human` when independent judgment or critical evidence is missing.

- Missing or weak test evidence.
- User-facing localization or UI behavior concerns.
- Sensitive architecture keywords such as `UserStorage`, `PermissionRule`,
  `GlobalEventBus`, `apiKey`, or `deleteSync`.
- Broad diffs, large single-file changes, and review-context quality such as a
  sparse PR title or body.
- Whether a generated file that changed with its source was produced by the
  expected codegen path.

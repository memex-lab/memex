# PR Policy Preflight Rules

Policy Preflight is a deterministic rule check for pull requests. It does not
call AI, run Flutter, execute PR code, or decide whether the code is
semantically correct. It treats the PR as data and looks for governance,
trust-boundary, and objective hard-policy signals from PR metadata, changed
files, and diff content.

In the current shadow phase, Preflight only reports a decision. Its decision is
not a merge blocker yet.

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

Recommended quality gates:

- `flutter analyze --no-pub`: prefer a fully green result.
- If the repository still has historical analyzer debt, maintain a baseline and
  require the PR to introduce no new analyzer issues. The long-term target
  should still be fully green.
- `flutter test --no-pub`: prefer all tests to pass. If `main` temporarily has
  historical failures, require the PR to introduce no new failing test.
- Add compile/build checks when the PR touches platform, flavor, release, or
  build-pipeline behavior.

When the low-risk fast path is enabled later, a PR should satisfy all of these:

- Preflight has no `reject` or `high_risk` result.
- Flutter CI is green, or the PR introduces no new analyzer/test issue.
- AI review says the PR is compliant and low risk.
- A maintainer still clicks merge manually. There is no auto-merge.

## Decision Levels

### `reject`

The PR contains an objective policy violation or cannot be safely evaluated.
The author should rework the PR before it enters the normal merge path.

### `high_risk`

The PR touches governance controls such as review rules, repository automation,
or lint configuration, or contains content that cannot be safely verified from
the diff. Maintainer review is required.

### `low_risk`

No deterministic rule found a reason to reject the PR or require maintainer
review. AI review and normal CI can still raise additional semantic, quality, or
test-evidence concerns.

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
following signals require maintainer review using the actual diff and PR
context. The `PR AI Review` workflow has been retired:

- Missing or weak test evidence.
- User-facing localization or UI behavior concerns.
- Sensitive architecture keywords such as `UserStorage`, `PermissionRule`,
  `GlobalEventBus`, `apiKey`, or `deleteSync`.
- Broad diffs, large single-file changes, and review-context quality such as a
  sparse PR title or body.
- Whether a generated file that changed with its source was produced by the
  expected codegen path.

## Shadow-Mode Behavior

During shadow mode:

- `low_risk`, `high_risk`, and `reject` are all reported.
- The workflow exits successfully so the PR is not blocked.
- Results are written to the workflow summary and uploaded as artifacts. The
  separate preflight-summary workflow may include them in the combined PR
  comment.

After calibration, a separate gate can decide how to use the result as a merge
requirement.

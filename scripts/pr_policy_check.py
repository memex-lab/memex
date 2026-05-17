#!/usr/bin/env python3
"""Deterministic PR policy preflight for Memex.

This script is intentionally boring: it reads git metadata and diffs, applies
path/content rules, and emits machine-readable JSON. It does not execute PR
code, run Flutter, or call an AI model.
"""

from __future__ import annotations

import argparse
from dataclasses import asdict, dataclass
from fnmatch import fnmatch
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
from typing import Iterable


DECISION_LOW_RISK = "low_risk"
DECISION_HIGH_RISK = "high_risk"
DECISION_REJECT = "reject"


@dataclass(frozen=True)
class ChangedFile:
    status: str
    path: str
    old_path: str | None = None
    additions: int = 0
    deletions: int = 0
    binary: bool = False


@dataclass(frozen=True)
class Finding:
    severity: str
    rule_id: str
    message: str
    message_zh: str
    path: str | None = None
    score: int = 0


@dataclass(frozen=True)
class PreflightResult:
    schema_version: int
    decision: str
    risk_score: int
    compliant: bool
    findings: list[Finding]
    metrics: dict[str, int | bool]
    base_ref: str
    head_ref: str
    head_sha: str
    merge_base: str
    changed_files: list[ChangedFile]


SECRET_PATTERNS = [
    "*.jks",
    "*.keystore",
    "*.p8",
    "*.pem",
    "*.key",
    "*.mobileprovision",
    "**/key.properties",
    "**/key-*.properties",
    "**/*secret*",
    "**/*credential*",
    "**/*credentials*",
]

GENERATED_PATTERNS = [
    "**/*.g.dart",
    "**/*.freezed.dart",
    "**/*.gr.dart",
]

POLICY_CONTROL_PATTERNS = [
    "docs/pr-policy-preflight.en.md",
    "docs/pr-policy-preflight.zh.md",
    "scripts/pr_policy_check.py",
    ".github/CODEOWNERS",
]

HIGH_RISK_PATH_RULES: list[tuple[str, list[str], int, str, str]] = [
    ("github-config", [".github/**"], 55, "GitHub configuration or workflow changed.", "GitHub 配置或 workflow 发生变化。"),
    ("android-platform", ["android/**"], 35, "Android platform, signing, flavor, or permission area changed.", "Android 平台、签名、flavor 或权限相关区域发生变化。"),
    ("ios-platform", ["ios/**"], 35, "iOS platform, signing, entitlement, or permission area changed.", "iOS 平台、签名、entitlement 或权限相关区域发生变化。"),
    ("dependency-config", ["pubspec.yaml", "pubspec.lock"], 30, "Dart/Flutter dependency configuration changed.", "Dart/Flutter 依赖配置发生变化。"),
    ("analysis-config", ["analysis_options.yaml"], 25, "Analyzer or lint configuration changed.", "Analyzer 或 lint 配置发生变化。"),
    ("app-entrypoint", ["lib/main.dart", "lib/dependencies.dart", "lib/router.dart"], 40, "App entrypoint, dependency registration, or router changed.", "App 入口、依赖注册或路由发生变化。"),
    ("user-storage", ["lib/utils/user_storage.dart"], 45, "User settings, identity, locale, storage, or LLM configuration boundary changed.", "用户设置、身份、语言、存储或 LLM 配置边界发生变化。"),
    ("filesystem-storage", ["lib/data/services/file_system_service.dart", "lib/data/services/backup_service.dart"], 45, "Local workspace storage or backup boundary changed.", "本地 workspace 存储或备份边界发生变化。"),
    ("event-task-pipeline", ["lib/data/services/global_event_bus.dart", "lib/data/services/local_task_executor.dart", "lib/data/services/event_bus_service.dart", "lib/data/services/task_handlers/**"], 45, "Event bus, persistent task, or background handler changed.", "事件总线、持久任务或后台处理器发生变化。"),
    ("agent-system", ["lib/agent/**"], 45, "Agent, skill, prompt, tool, or file permission area changed.", "Agent、skill、prompt、tool 或文件权限区域发生变化。"),
    ("timeline-rendering", ["lib/ui/**/timeline*_screen.dart", "lib/**/native_card_factory*.dart", "lib/**/native_widget_factory*.dart", "lib/**/card_attachment_factory*.dart"], 40, "Timeline orchestration or card rendering changed.", "Timeline 编排或卡片渲染发生变化。"),
    ("review-policy", POLICY_CONTROL_PATTERNS, 35, "Review policy, preflight script, or control file changed.", "Review policy、preflight 脚本或控制文件发生变化。"),
]

HIGH_RISK_KEYWORDS: list[tuple[str, int, str, str]] = [
    (r"\bUserStorage\b", 10, "UserStorage reference changed.", "UserStorage 引用发生变化。"),
    (r"\bFilePermissionManager\b", 15, "Agent file permission boundary reference changed.", "Agent 文件权限边界引用发生变化。"),
    (r"\bPermissionRule\b", 15, "Agent permission rule reference changed.", "Agent 权限规则引用发生变化。"),
    (r"\bGlobalEventBus\b", 12, "Global event bus reference changed.", "全局事件总线引用发生变化。"),
    (r"\bLocalTaskExecutor\b", 12, "Persistent task executor reference changed.", "持久任务执行器引用发生变化。"),
    (r"\bBackupService\b", 12, "Backup service reference changed.", "备份服务引用发生变化。"),
    (r"\bgetCardsPath\b|\bgetFactsPath\b|\bgetWorkspace", 12, "Workspace path reference changed.", "Workspace 路径引用发生变化。"),
    (r"\b(apiKey|accessToken|secret|password|credential)s?\b", 15, "Credential-like identifier changed.", "疑似凭证标识符发生变化。"),
    (r"\bhttp\b|\bdio\b|\bWebSocket\b|\brequest\(", 10, "Network-related code changed.", "网络相关代码发生变化。"),
    (r"\bdeleteSync\b|\bunlinkSync\b|\bdelete\(|\brm\s+-rf\b", 12, "Deletion or destructive file operation changed.", "删除或破坏性文件操作发生变化。"),
]

WORKFLOW_REJECT_PATTERNS: list[tuple[str, str, str]] = [
    (r"permissions:\s*write-all", "Workflow grants write-all permissions.", "Workflow 授予 write-all 权限。"),
    (r"/var/run/docker\.sock", "Workflow mounts the host Docker socket.", "Workflow 挂载宿主机 Docker socket。"),
    (r"privileged:\s*true", "Workflow requests privileged container execution.", "Workflow 请求 privileged container 执行。"),
    (r"curl\b.*\|\s*(bash|sh)", "Workflow pipes downloaded content into a shell.", "Workflow 将下载内容直接 pipe 到 shell 执行。"),
    (r"wget\b.*\|\s*(bash|sh)", "Workflow pipes downloaded content into a shell.", "Workflow 将下载内容直接 pipe 到 shell 执行。"),
]

SENSITIVE_KEYWORD_SCAN_PATTERNS = [
    ".github/**",
    "android/**",
    "ios/**",
    "lib/**",
    "pubspec.yaml",
    "pubspec.lock",
    "analysis_options.yaml",
    "scripts/**",
]


def normalize_path(path: str) -> str:
    normalized = PurePosixPath(path).as_posix()
    while normalized.startswith("./"):
        normalized = normalized[2:]
    return normalized.lstrip("/")


def path_matches(path: str, patterns: Iterable[str]) -> bool:
    normalized = normalize_path(path)
    return any(fnmatch(normalized, pattern) for pattern in patterns)


def is_test_path(path: str) -> bool:
    normalized = normalize_path(path)
    return normalized.startswith("test/") or normalized.startswith("tests/")


def run_git(repo: Path, args: list[str]) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=repo,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return result.stdout


def parse_name_status(text: str) -> dict[str, ChangedFile]:
    files: dict[str, ChangedFile] = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        status = parts[0]
        if status.startswith(("R", "C")) and len(parts) >= 3:
            files[normalize_path(parts[2])] = ChangedFile(
                status=status,
                old_path=normalize_path(parts[1]),
                path=normalize_path(parts[2]),
            )
        elif len(parts) >= 2:
            files[normalize_path(parts[1])] = ChangedFile(
                status=status,
                path=normalize_path(parts[1]),
            )
    return files


def parse_numstat(text: str) -> dict[str, tuple[int, int, bool]]:
    stats: dict[str, tuple[int, int, bool]] = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        additions_text, deletions_text, path_text = parts[0], parts[1], parts[-1]
        binary = additions_text == "-" or deletions_text == "-"
        additions = 0 if binary else int(additions_text)
        deletions = 0 if binary else int(deletions_text)
        stats[normalize_path(path_text)] = (additions, deletions, binary)
    return stats


def collect_changed_files(repo: Path, base_ref: str, head_ref: str) -> tuple[str, str, list[ChangedFile]]:
    merge_base = run_git(repo, ["merge-base", base_ref, head_ref]).strip()
    head_sha = run_git(repo, ["rev-parse", head_ref]).strip()
    name_status = parse_name_status(
        run_git(repo, ["diff", "--name-status", "--find-renames", f"{merge_base}...{head_ref}"])
    )
    numstat = parse_numstat(
        run_git(repo, ["diff", "--numstat", "--find-renames", f"{merge_base}...{head_ref}"])
    )
    changed_files: list[ChangedFile] = []
    for path, changed_file in sorted(name_status.items()):
        additions, deletions, binary = numstat.get(path, (0, 0, False))
        changed_files.append(
            ChangedFile(
                status=changed_file.status,
                old_path=changed_file.old_path,
                path=changed_file.path,
                additions=additions,
                deletions=deletions,
                binary=binary,
            )
        )
    return merge_base, head_sha, changed_files


def collect_diff(repo: Path, merge_base: str, head_ref: str, max_diff_bytes: int) -> tuple[str, bool, int]:
    diff = run_git(repo, ["diff", "--no-ext-diff", "--find-renames", "--unified=80", f"{merge_base}...{head_ref}"])
    encoded = diff.encode("utf-8", errors="replace")
    if len(encoded) <= max_diff_bytes:
        return diff, False, len(encoded)
    truncated = encoded[:max_diff_bytes].decode("utf-8", errors="replace")
    return truncated, True, len(encoded)


def generated_source_path(path: str) -> str | None:
    path = normalize_path(path)
    for suffix in (".g.dart", ".freezed.dart", ".gr.dart"):
        if path.endswith(suffix):
            return f"{path[: -len(suffix)]}.dart"
    return None


def added_lines_by_path(diff: str) -> dict[str, list[str]]:
    current_path: str | None = None
    result: dict[str, list[str]] = {}
    for line in diff.splitlines():
        if line.startswith("+++ b/"):
            current_path = normalize_path(line.removeprefix("+++ b/"))
            result.setdefault(current_path, [])
            continue
        if current_path and line.startswith("+") and not line.startswith("+++"):
            result[current_path].append(line[1:])
    return result


def has_test_plan(pr_body: str) -> bool:
    body = pr_body.lower()
    if "test plan" in body or "测试" in body or "验证" in body:
        return "not run" not in body and "未运行" not in body
    return False


def evaluate_policy(
    *,
    base_ref: str,
    head_ref: str,
    head_sha: str,
    merge_base: str,
    changed_files: list[ChangedFile],
    diff: str,
    diff_truncated: bool,
    diff_bytes: int,
    pr_title: str,
    pr_body: str,
    max_files_low_risk: int,
    max_lines_low_risk: int,
    max_single_file_lines_low_risk: int,
) -> PreflightResult:
    findings: list[Finding] = []
    paths = {file.path for file in changed_files}
    added_by_path = added_lines_by_path(diff)

    def add(
        severity: str,
        rule_id: str,
        message: str,
        message_zh: str,
        path: str | None = None,
        score: int = 0,
    ) -> None:
        findings.append(
            Finding(
                severity=severity,
                rule_id=rule_id,
                message=message,
                message_zh=message_zh,
                path=path,
                score=score,
            )
        )

    for file in changed_files:
        if path_matches(file.path, SECRET_PATTERNS):
            add(
                "reject",
                "secret-or-signing-material",
                "Signing material, credentials, or credential-like files cannot enter the normal review path.",
                "签名材料、凭证或疑似凭证文件不能进入普通 review 路径。",
                file.path,
                100,
            )

        if file.status.startswith("D") and path_matches(file.path, POLICY_CONTROL_PATTERNS):
            add(
                "reject",
                "policy-control-deleted",
                "Review policy, preflight script, or control file was deleted.",
                "Review policy、preflight 脚本或控制文件被删除。",
                file.path,
                100,
            )

        if path_matches(file.path, GENERATED_PATTERNS):
            source_path = generated_source_path(file.path)
            if source_path and source_path not in paths:
                add(
                    "reject",
                    "generated-file-without-source",
                    "Generated Dart file changed without the matching source file.",
                    "Generated Dart 文件发生变化，但对应源文件没有变化。",
                    file.path,
                    100,
                )
            else:
                add(
                    "high",
                    "generated-file",
                    "Generated Dart file changed; maintainer should verify regeneration.",
                    "Generated Dart 文件发生变化，maintainer 应确认 codegen 是有意且正确的。",
                    file.path,
                    30,
                )

        for rule_id, patterns, score, message, message_zh in HIGH_RISK_PATH_RULES:
            if path_matches(file.path, patterns):
                add("high", rule_id, message, message_zh, file.path, score)

        if file.binary and not file.path.startswith("assets/icons/"):
            add(
                "high",
                "binary-file",
                "Binary file changed outside the low-risk icon asset path.",
                "二进制文件发生变化，且不在低风险 icon asset 路径下。",
                file.path,
                25,
            )

        single_file_lines = file.additions + file.deletions
        if single_file_lines > max_single_file_lines_low_risk:
            add(
                "high",
                "large-single-file-change",
                f"Single file changed {single_file_lines} lines, above low-risk threshold {max_single_file_lines_low_risk}.",
                f"单个文件变更 {single_file_lines} 行，超过低风险阈值 {max_single_file_lines_low_risk}。",
                file.path,
                25,
            )

    if "lib/l10n/app_en.arb" in paths and "lib/l10n/app_zh.arb" not in paths:
        add(
            "high",
            "l10n-pair-mismatch",
            "English ARB changed without matching Chinese ARB update.",
            "英文 ARB 发生变化，但中文 ARB 没有同步变化。",
            "lib/l10n",
            25,
        )
    if "lib/l10n/app_zh.arb" in paths and "lib/l10n/app_en.arb" not in paths:
        add(
            "high",
            "l10n-pair-mismatch",
            "Chinese ARB changed without matching English ARB update.",
            "中文 ARB 发生变化，但英文 ARB 没有同步变化。",
            "lib/l10n",
            25,
        )

    total_lines = sum(file.additions + file.deletions for file in changed_files)
    if len(changed_files) > max_files_low_risk:
        add(
            "high",
            "too-many-files",
            f"PR changes {len(changed_files)} files, above low-risk threshold {max_files_low_risk}.",
            f"PR 修改了 {len(changed_files)} 个文件，超过低风险阈值 {max_files_low_risk}。",
            score=20,
        )
    if total_lines > max_lines_low_risk:
        add(
            "high",
            "too-many-lines",
            f"PR changes {total_lines} lines, above low-risk threshold {max_lines_low_risk}.",
            f"PR 修改了 {total_lines} 行，超过低风险阈值 {max_lines_low_risk}。",
            score=20,
        )
    if diff_truncated:
        add(
            "high",
            "diff-truncated",
            "Diff exceeded the configured preflight size limit and was truncated.",
            "Diff 超过配置的 preflight 大小限制，已被截断。",
            score=30,
        )

    lib_changed = any(path.startswith("lib/") for path in paths)
    test_changed = any(is_test_path(path) for path in paths)
    if lib_changed and not test_changed and not has_test_plan(pr_body):
        add(
            "warn",
            "missing-test-signal",
            "Production Dart files changed without test file changes or a clear test plan in the PR body.",
            "Production Dart 文件发生变化，但没有测试文件变化，也没有清晰的 PR test plan。",
            score=10,
        )

    if not pr_title.strip():
        add("warn", "missing-pr-title", "PR title is empty.", "PR 标题为空。", score=5)
    if not pr_body.strip():
        add("warn", "missing-pr-body", "PR body is empty.", "PR 正文为空。", score=5)

    for path, added_lines in added_by_path.items():
        added_text = "\n".join(added_lines)
        if path_matches(path, [".github/workflows/**"]):
            for pattern, message, message_zh in WORKFLOW_REJECT_PATTERNS:
                if re.search(pattern, added_text, flags=re.IGNORECASE):
                    add("reject", "unsafe-workflow-pattern", message, message_zh, path, 100)
        if path_matches(path, SENSITIVE_KEYWORD_SCAN_PATTERNS):
            for pattern, score, message, message_zh in HIGH_RISK_KEYWORDS:
                if re.search(pattern, added_text, flags=re.IGNORECASE):
                    add("high", "sensitive-keyword", message, message_zh, path, score)

    reject = any(finding.severity == "reject" for finding in findings)
    high = any(finding.severity == "high" for finding in findings)
    risk_score = sum(finding.score for finding in findings)
    if reject:
        decision = DECISION_REJECT
    elif high:
        decision = DECISION_HIGH_RISK
    else:
        decision = DECISION_LOW_RISK

    metrics: dict[str, int | bool] = {
        "changed_files": len(changed_files),
        "lines_added": sum(file.additions for file in changed_files),
        "lines_deleted": sum(file.deletions for file in changed_files),
        "total_changed_lines": total_lines,
        "binary_files": sum(1 for file in changed_files if file.binary),
        "test_files_changed": sum(1 for path in paths if is_test_path(path)),
        "lib_files_changed": sum(1 for path in paths if path.startswith("lib/")),
        "diff_bytes": diff_bytes,
        "diff_truncated": diff_truncated,
    }

    return PreflightResult(
        schema_version=1,
        decision=decision,
        risk_score=risk_score,
        compliant=decision != DECISION_REJECT,
        findings=findings,
        metrics=metrics,
        base_ref=base_ref,
        head_ref=head_ref,
        head_sha=head_sha,
        merge_base=merge_base,
        changed_files=changed_files,
    )


def result_to_dict(result: PreflightResult) -> dict:
    data = asdict(result)
    data["decision_zh"] = decision_label_zh(result.decision)
    data["findings"] = [asdict(finding) for finding in result.findings]
    data["changed_files"] = [asdict(file) for file in result.changed_files]
    return data


def decision_label_zh(decision: str) -> str:
    return {
        DECISION_LOW_RISK: "低风险",
        DECISION_HIGH_RISK: "高风险",
        DECISION_REJECT: "打回",
    }.get(decision, decision)


def severity_label_zh(severity: str) -> str:
    return {
        "reject": "打回",
        "high": "高风险",
        "warn": "警告",
    }.get(severity, severity)


def result_to_markdown(result: PreflightResult) -> str:
    status = {
        DECISION_LOW_RISK: "LOW RISK",
        DECISION_HIGH_RISK: "HIGH RISK",
        DECISION_REJECT: "REJECT",
    }[result.decision]
    status_zh = decision_label_zh(result.decision)
    lines = [
        "# PR Policy Preflight / PR 规则预检",
        "",
        f"- Decision / 判定: `{status}` / `{status_zh}`",
        f"- Risk score / 风险分: `{result.risk_score}`",
        f"- Changed files / 变更文件数: `{result.metrics['changed_files']}`",
        f"- Changed lines / 变更行数: `{result.metrics['total_changed_lines']}`",
        f"- Diff truncated / Diff 是否截断: `{str(result.metrics['diff_truncated']).lower()}`",
        "",
    ]
    if result.findings:
        lines.append("## Findings / 规则命中")
        for finding in result.findings:
            path = f" `{finding.path}`" if finding.path else ""
            severity_zh = severity_label_zh(finding.severity)
            lines.append(f"- `{finding.severity}` / `{severity_zh}` `{finding.rule_id}`{path}")
            lines.append(f"  - EN: {finding.message}")
            lines.append(f"  - 中文: {finding.message_zh}")
    else:
        lines.append("No deterministic policy findings. / 未发现确定性规则问题。")
    return "\n".join(lines) + "\n"


def write_text(path: Path | None, text: str) -> None:
    if path is None:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def read_optional_file(path: Path | None) -> str:
    if path is None:
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run deterministic PR policy preflight.")
    parser.add_argument("--repo-path", type=Path, default=Path.cwd())
    parser.add_argument("--base", default="origin/main")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--pr-title", default="")
    parser.add_argument("--pr-title-file", type=Path)
    parser.add_argument("--pr-body", default="")
    parser.add_argument("--pr-body-file", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--markdown-output", type=Path)
    parser.add_argument("--max-diff-bytes", type=int, default=240_000)
    parser.add_argument("--max-files-low-risk", type=int, default=20)
    parser.add_argument("--max-lines-low-risk", type=int, default=800)
    parser.add_argument("--max-single-file-lines-low-risk", type=int, default=400)
    parser.add_argument("--no-fail-on-decision", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    repo_path = args.repo_path.resolve()
    pr_title = read_optional_file(args.pr_title_file) if args.pr_title_file else args.pr_title
    pr_body = read_optional_file(args.pr_body_file) if args.pr_body_file else args.pr_body

    try:
        merge_base, head_sha, changed_files = collect_changed_files(repo_path, args.base, args.head)
        diff, diff_truncated, diff_bytes = collect_diff(repo_path, merge_base, args.head, args.max_diff_bytes)
        result = evaluate_policy(
            base_ref=args.base,
            head_ref=args.head,
            head_sha=head_sha,
            merge_base=merge_base,
            changed_files=changed_files,
            diff=diff,
            diff_truncated=diff_truncated,
            diff_bytes=diff_bytes,
            pr_title=pr_title,
            pr_body=pr_body,
            max_files_low_risk=args.max_files_low_risk,
            max_lines_low_risk=args.max_lines_low_risk,
            max_single_file_lines_low_risk=args.max_single_file_lines_low_risk,
        )
    except Exception as exc:  # noqa: BLE001 - CLI boundary should report any failure.
        fallback = {
            "schema_version": 1,
            "decision": DECISION_REJECT,
            "risk_score": 100,
            "compliant": False,
            "findings": [
                {
                    "severity": "reject",
                    "rule_id": "preflight-error",
                    "message": f"Preflight failed to collect or evaluate PR context: {exc}",
                    "message_zh": f"Preflight 无法采集或评估 PR context：{exc}",
                    "path": None,
                    "score": 100,
                }
            ],
            "metrics": {},
            "base_ref": args.base,
            "head_ref": args.head,
            "decision_zh": decision_label_zh(DECISION_REJECT),
        }
        json_output = json.dumps(fallback, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        markdown_output = "\n".join(
            [
                "# PR Policy Preflight / PR 规则预检",
                "",
                "- Decision / 判定: `REJECT` / `打回`",
                "- Risk score / 风险分: `100`",
                "",
                "Preflight failed to collect or evaluate PR context.",
                "",
                "Preflight 无法采集或评估 PR context。",
                "",
                f"Error: `{exc}`",
                "",
            ]
        )
        write_text(args.output, json_output)
        write_text(args.markdown_output, markdown_output)
        if not args.output:
            print(json_output, end="")
        return 0 if args.no_fail_on_decision else 1

    json_output = json.dumps(result_to_dict(result), ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    markdown_output = result_to_markdown(result)
    write_text(args.output, json_output)
    write_text(args.markdown_output, markdown_output)
    if not args.output:
        print(json_output, end="")

    if args.no_fail_on_decision:
        return 0
    if result.decision == DECISION_LOW_RISK:
        return 0
    if result.decision == DECISION_HIGH_RISK:
        return 2
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

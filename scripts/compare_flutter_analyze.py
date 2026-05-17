#!/usr/bin/env python3
"""Compare Flutter analyzer reports and fail only on newly introduced issues."""

from __future__ import annotations

import argparse
from collections import Counter
from dataclasses import asdict, dataclass
import json
from pathlib import Path
import re
import sys


ISSUE_RE = re.compile(
    r"^\s*(?P<severity>info|warning|error)\s+•\s+"
    r"(?P<message>.*?)\s+•\s+"
    r"(?P<path>.*?):(?P<line>\d+):(?P<column>\d+)\s+•\s+"
    r"(?P<code>[A-Za-z0-9_]+)\s*$"
)
WRITE_ISSUE_RE = re.compile(
    r"^\[(?P<severity>info|warning|error)\]\s+"
    r"(?P<message>.*?)\s+"
    r"\((?P<path>.*?):(?P<line>\d+):(?P<column>\d+)\)\s*$"
)

PATH_MARKERS = ("/lib/", "/test/", "/scripts/", "/android/", "/ios/")


def normalize_path(path: str) -> str:
    if not Path(path).is_absolute():
        return path
    for marker in PATH_MARKERS:
        if marker in path:
            return path[path.index(marker) + 1 :]
    return Path(path).name


@dataclass(frozen=True)
class AnalyzerIssue:
    severity: str
    message: str
    path: str
    code: str
    line: int
    column: int

    @property
    def baseline_key(self) -> tuple[str, str, str, str]:
        # Ignore line and column so nearby edits do not turn old issues into
        # false positives. Counter comparison still catches additional copies.
        return (self.severity, self.code, self.path, self.message)


def parse_report(text: str) -> list[AnalyzerIssue]:
    issues: list[AnalyzerIssue] = []
    for line in text.splitlines():
        match = ISSUE_RE.match(line)
        if not match:
            match = WRITE_ISSUE_RE.match(line)
        if not match:
            continue
        issues.append(
            AnalyzerIssue(
                severity=match.group("severity"),
                message=match.group("message"),
                path=normalize_path(match.group("path")),
                code=match.groupdict().get("code") or "analyzer",
                line=int(match.group("line")),
                column=int(match.group("column")),
            )
        )
    return issues


def newly_introduced_issues(
    base_issues: list[AnalyzerIssue],
    head_issues: list[AnalyzerIssue],
) -> list[AnalyzerIssue]:
    base_counts = Counter(issue.baseline_key for issue in base_issues)
    new_issues: list[AnalyzerIssue] = []
    for issue in head_issues:
        key = issue.baseline_key
        if base_counts[key] > 0:
            base_counts[key] -= 1
        else:
            new_issues.append(issue)
    return new_issues


def github_annotation(issue: AnalyzerIssue) -> str:
    return (
        f"::error file={issue.path},line={issue.line},col={issue.column},"
        f"title={issue.code}::{issue.severity}: {issue.message}"
    )


def markdown_summary(
    *,
    base_count: int,
    head_count: int,
    new_issues: list[AnalyzerIssue],
) -> str:
    lines = [
        "## Flutter Analyzer Baseline",
        "",
        f"- Base issues: `{base_count}`",
        f"- PR issues: `{head_count}`",
        f"- New issues: `{len(new_issues)}`",
    ]
    if new_issues:
        lines.extend(["", "### New Analyzer Issues"])
        for issue in new_issues[:50]:
            lines.append(
                f"- `{issue.severity}` `{issue.code}` "
                f"`{issue.path}:{issue.line}:{issue.column}`: {issue.message}"
            )
        if len(new_issues) > 50:
            lines.append(f"- ...and {len(new_issues) - 50} more.")
    else:
        lines.extend(["", "No new analyzer issues introduced by this PR."])
    return "\n".join(lines) + "\n"


def read_report(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"Analyzer report not found: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Compare Flutter analyzer reports.")
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--head", required=True, type=Path)
    parser.add_argument("--summary", type=Path)
    parser.add_argument("--markdown-output", type=Path)
    parser.add_argument("--json-output", type=Path)
    args = parser.parse_args(argv)

    base_issues = parse_report(read_report(args.base))
    head_issues = parse_report(read_report(args.head))
    new_issues = newly_introduced_issues(base_issues, head_issues)

    summary = markdown_summary(
        base_count=len(base_issues),
        head_count=len(head_issues),
        new_issues=new_issues,
    )
    print(summary)
    if args.summary:
        with args.summary.open("a", encoding="utf-8") as handle:
            handle.write(summary)
    if args.markdown_output:
        args.markdown_output.parent.mkdir(parents=True, exist_ok=True)
        args.markdown_output.write_text(summary, encoding="utf-8")
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "base_count": len(base_issues),
                    "head_count": len(head_issues),
                    "new_count": len(new_issues),
                    "new_issues": [asdict(issue) for issue in new_issues],
                },
                ensure_ascii=False,
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

    if new_issues:
        for issue in new_issues[:50]:
            print(github_annotation(issue))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Compare Flutter test output and fail only on newly introduced failures."""

from __future__ import annotations

import argparse
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
import re
import sys


FAILURE_RE = re.compile(r"❌\s+(?P<label>.*?)\s+\(failed\)")


@dataclass(frozen=True)
class TestFailure:
    label: str

    @property
    def normalized_label(self) -> str:
        label = self.label
        marker = "/test/"
        if marker in label:
            return label[label.index(marker) + 1 :]
        if label.startswith("test/"):
            return label
        return label

    @property
    def path(self) -> str | None:
        marker = ".dart:"
        if marker not in self.normalized_label:
            return None
        return self.normalized_label.split(marker, 1)[0] + ".dart"


def parse_failures(text: str) -> list[TestFailure]:
    failures: list[TestFailure] = []
    for line in text.splitlines():
        match = FAILURE_RE.search(line)
        if match:
            failures.append(TestFailure(label=match.group("label")))
    return failures


def newly_introduced_failures(
    base_failures: list[TestFailure],
    head_failures: list[TestFailure],
) -> list[TestFailure]:
    base_counts = Counter(failure.normalized_label for failure in base_failures)
    new_failures: list[TestFailure] = []
    for failure in head_failures:
        key = failure.normalized_label
        if base_counts[key] > 0:
            base_counts[key] -= 1
        else:
            new_failures.append(failure)
    return new_failures


def github_annotation(failure: TestFailure) -> str:
    path = failure.path
    if path:
        return f"::error file={path},title=New Flutter test failure::{failure.normalized_label}"
    return f"::error title=New Flutter test failure::{failure.normalized_label}"


def markdown_summary(
    *,
    base_count: int,
    head_count: int,
    new_failures: list[TestFailure],
) -> str:
    lines = [
        "## Flutter Test Baseline",
        "",
        f"- Base failures: `{base_count}`",
        f"- PR failures: `{head_count}`",
        f"- New failures: `{len(new_failures)}`",
    ]
    if new_failures:
        lines.extend(["", "### New Test Failures"])
        for failure in new_failures[:50]:
            lines.append(f"- `{failure.normalized_label}`")
        if len(new_failures) > 50:
            lines.append(f"- ...and {len(new_failures) - 50} more.")
    else:
        lines.extend(["", "No new Flutter test failures introduced by this PR."])
    return "\n".join(lines) + "\n"


def read_report(path: Path) -> str:
    if not path.exists():
        raise FileNotFoundError(f"Flutter test output not found: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Compare Flutter test failures.")
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--head", required=True, type=Path)
    parser.add_argument("--summary", type=Path)
    args = parser.parse_args(argv)

    base_failures = parse_failures(read_report(args.base))
    head_failures = parse_failures(read_report(args.head))
    new_failures = newly_introduced_failures(base_failures, head_failures)

    summary = markdown_summary(
        base_count=len(base_failures),
        head_count=len(head_failures),
        new_failures=new_failures,
    )
    print(summary)
    if args.summary:
        with args.summary.open("a", encoding="utf-8") as handle:
            handle.write(summary)

    if new_failures:
        for failure in new_failures[:50]:
            print(github_annotation(failure))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

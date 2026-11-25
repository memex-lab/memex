#!/usr/bin/env python3
"""Compare Flutter test output and fail only on newly introduced failures."""

from __future__ import annotations

import argparse
from collections import Counter
from dataclasses import asdict, dataclass
import json
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


def machine_failures(text: str, exit_code: int) -> list[TestFailure]:
    """A completed test protocol stream and process status must agree."""
    suites = {}
    tests = {}
    failures = []
    done = None
    completed = 0
    for raw in text.splitlines():
        if not raw.strip():
            continue
        event = json.loads(raw)
        # Flutter multiplexes daemon notifications into the package:test stream.
        if isinstance(event, list) and all(isinstance(item, dict) and
                str(item.get("event", "")).startswith("test.") for item in event):
            continue
        kind = event["type"]
        if done is not None:
            raise ValueError("events after test completion")
        if kind == "suite":
            suite = event["suite"]
            suites[suite["id"]] = suite["path"]
        elif kind == "testStart":
            test = event["test"]
            tests[test["id"]] = (test["suiteID"], test["name"])
        elif kind == "testDone":
            completed += 1
            if event["result"] in {"failure", "error"}:
                suite_id, name = tests[event["testID"]]
                failures.append(TestFailure(f"{suites[suite_id]}: {name}"))
            elif event["result"] != "success":
                raise ValueError("unknown test result")
        elif kind == "done":
            done = event.get("success")
    if (not completed or not isinstance(done, bool) or done != (exit_code == 0)
            or done == bool(failures) or exit_code not in (0, 1)):
        raise ValueError("incomplete or inconsistent test stream/process exit")
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
    parser.add_argument("--markdown-output", type=Path)
    parser.add_argument("--json-output", type=Path)
    parser.add_argument("--base-exit", required=True, type=int)
    parser.add_argument("--head-exit", required=True, type=int)
    args = parser.parse_args(argv)

    try:
        base_failures = machine_failures(read_report(args.base), args.base_exit)
        head_failures = machine_failures(read_report(args.head), args.head_exit)
    except (ValueError, OSError, KeyError, TypeError) as exc:
        print(f"Flutter test evidence incomplete: {exc}", file=sys.stderr)
        return 2
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
    if args.markdown_output:
        args.markdown_output.parent.mkdir(parents=True, exist_ok=True)
        args.markdown_output.write_text(summary, encoding="utf-8")
    if args.json_output:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "base_count": len(base_failures),
                    "head_count": len(head_failures),
                    "new_count": len(new_failures),
                    "new_failures": [asdict(failure) for failure in new_failures],
                },
                ensure_ascii=False,
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

    if new_failures:
        for failure in new_failures[:50]:
            print(github_annotation(failure))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

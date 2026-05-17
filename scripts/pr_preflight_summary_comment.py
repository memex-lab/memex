#!/usr/bin/env python3
"""Post one PR comment after all PR preflight workflows finish.

The summary workflow is intentionally data-only: it downloads artifacts produced
by the two preflight workflows, checks that they belong to the current PR head,
and upserts a single issue comment. It never executes PR code or artifact
content.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from io import BytesIO
import json
import os
import sys
from typing import Any
import urllib.error
import urllib.parse
import urllib.request
import zipfile


COMMENT_MARKER = "<!-- memex-pr-preflight-summary -->"
LEGACY_COMMENT_MARKER = "<!-- memex-pr-policy-preflight -->"
API_VERSION = "2022-11-28"


@dataclass(frozen=True)
class Target:
    key: str
    workflow_file: str
    workflow_name: str
    event: str
    artifact_name: str
    markdown_file: str
    json_file: str


@dataclass(frozen=True)
class TargetResult:
    target: Target
    run: dict[str, Any]
    context: dict[str, Any]
    files: dict[str, str]


TARGETS = [
    Target(
        key="policy",
        workflow_file="pr-policy-preflight.yml",
        workflow_name="PR Policy Preflight",
        event="pull_request_target",
        artifact_name="pr-policy-preflight",
        markdown_file="preflight.md",
        json_file="preflight.json",
    ),
    Target(
        key="flutter",
        workflow_file="pr-flutter-quality.yml",
        workflow_name="PR Flutter Quality",
        event="pull_request",
        artifact_name="pr-flutter-quality",
        markdown_file="flutter-quality.md",
        json_file="flutter-quality.json",
    ),
]


class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):  # noqa: ANN001
        return None


class GitHubApiError(RuntimeError):
    def __init__(self, *, method: str, path: str, status: int, body: str) -> None:
        self.method = method
        self.path = path
        self.status = status
        self.body = body.strip()
        super().__init__(self.__str__())

    def __str__(self) -> str:
        details = f": {self.body}" if self.body else ""
        return f"GitHub API {self.method} {self.path} failed with HTTP {self.status}{details}"


class GitHubClient:
    def __init__(self, *, repo: str, token: str) -> None:
        self.repo = repo
        self.token = token

    def _headers(self) -> dict[str, str]:
        return {
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {self.token}",
            "X-GitHub-Api-Version": API_VERSION,
            "User-Agent": "memex-pr-preflight-summary",
        }

    def request_json(
        self,
        method: str,
        path: str,
        *,
        data: dict[str, Any] | None = None,
        query: dict[str, str | int] | None = None,
    ) -> Any:
        if path.startswith("https://"):
            url = path
        else:
            url = f"https://api.github.com/repos/{self.repo}{path}"
        if query:
            separator = "&" if "?" in url else "?"
            url = f"{url}{separator}{urllib.parse.urlencode(query)}"
        body = None if data is None else json.dumps(data).encode("utf-8")
        headers = self._headers()
        if data is not None:
            headers["Content-Type"] = "application/json"
        request = urllib.request.Request(url, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                raw = response.read()
        except urllib.error.HTTPError as exc:
            error_body = exc.read().decode("utf-8", errors="replace")
            raise GitHubApiError(
                method=method,
                path=path,
                status=exc.code,
                body=error_body,
            ) from exc
        if not raw:
            return None
        return json.loads(raw.decode("utf-8"))

    def request_bytes(self, url: str) -> bytes:
        opener = urllib.request.build_opener(NoRedirectHandler)
        request = urllib.request.Request(url, headers=self._headers(), method="GET")
        try:
            response = opener.open(request, timeout=60)
        except urllib.error.HTTPError as exc:
            if exc.code not in {301, 302, 303, 307, 308}:
                raise
            redirect_url = exc.headers.get("Location")
            if not redirect_url:
                raise
            # Artifact downloads redirect to a short-lived object-storage URL.
            # Fetch the signed URL without GitHub's Authorization header.
            request = urllib.request.Request(
                urllib.parse.urljoin(url, redirect_url),
                headers={"User-Agent": "memex-pr-preflight-summary"},
                method="GET",
            )
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        with response:
            return response.read()

    def workflow_runs(self, target: Target, *, max_pages: int = 3) -> list[dict[str, Any]]:
        runs: list[dict[str, Any]] = []
        for page in range(1, max_pages + 1):
            data = self.request_json(
                "GET",
                f"/actions/workflows/{target.workflow_file}/runs",
                query={"event": target.event, "per_page": 30, "page": page},
            )
            page_runs = data.get("workflow_runs", [])
            runs.extend(page_runs)
            if len(page_runs) < 30:
                break
        return runs

    def artifact_files(self, *, run_id: int, artifact_name: str) -> dict[str, str] | None:
        data = self.request_json(
            "GET",
            f"/actions/runs/{run_id}/artifacts",
            query={"per_page": 100},
        )
        artifacts = [
            artifact
            for artifact in data.get("artifacts", [])
            if artifact.get("name") == artifact_name and not artifact.get("expired")
        ]
        if not artifacts:
            return None

        artifact = sorted(artifacts, key=lambda item: item.get("created_at", ""), reverse=True)[0]
        archive = self.request_bytes(artifact["archive_download_url"])
        files: dict[str, str] = {}
        with zipfile.ZipFile(BytesIO(archive)) as zip_file:
            for name in zip_file.namelist():
                if name.endswith("/"):
                    continue
                files[name] = zip_file.read(name).decode("utf-8", errors="replace")
        return files

    def issue_comments(self, pr_number: int) -> list[dict[str, Any]]:
        comments: list[dict[str, Any]] = []
        page = 1
        while True:
            data = self.request_json(
                "GET",
                f"/issues/{pr_number}/comments",
                query={"per_page": 100, "page": page},
            )
            comments.extend(data)
            if len(data) < 100:
                return comments
            page += 1

    def upsert_comment(self, *, pr_number: int, body: str) -> None:
        existing = next(
            (
                comment
                for comment in self.issue_comments(pr_number)
                if COMMENT_MARKER in (comment.get("body") or "")
                or LEGACY_COMMENT_MARKER in (comment.get("body") or "")
            ),
            None,
        )
        if existing:
            self.request_json("PATCH", f"/issues/comments/{existing['id']}", data={"body": body})
        else:
            self.request_json("POST", f"/issues/{pr_number}/comments", data={"body": body})


def find_file(files: dict[str, str], filename: str) -> str | None:
    for path, content in files.items():
        if path.split("/")[-1] == filename:
            return content
    return None


def load_json_file(files: dict[str, str], filename: str) -> dict[str, Any]:
    content = find_file(files, filename)
    if content is None:
        return {}
    try:
        value = json.loads(content)
    except json.JSONDecodeError:
        return {}
    return value if isinstance(value, dict) else {}


def load_context(files: dict[str, str]) -> dict[str, Any]:
    context = load_json_file(files, "preflight-context.json")
    if not context.get("pr_number") or not context.get("head_sha"):
        raise ValueError("preflight-context.json is missing pr_number or head_sha")
    return context


def trigger_context(client: GitHubClient, *, trigger_run_id: int) -> dict[str, Any] | None:
    for target in TARGETS:
        files = client.artifact_files(run_id=trigger_run_id, artifact_name=target.artifact_name)
        if not files:
            continue
        try:
            return load_context(files)
        except ValueError:
            continue
    return None


def find_matching_result(
    client: GitHubClient,
    *,
    target: Target,
    pr_number: int,
    head_sha: str,
) -> TargetResult | None:
    for run in client.workflow_runs(target):
        if run.get("status") != "completed":
            continue
        try:
            files = client.artifact_files(
                run_id=int(run["id"]),
                artifact_name=target.artifact_name,
            )
        except (urllib.error.URLError, KeyError, ValueError, zipfile.BadZipFile):
            continue
        if not files:
            continue
        try:
            context = load_context(files)
        except ValueError:
            continue
        if int(context["pr_number"]) == pr_number and context["head_sha"] == head_sha:
            return TargetResult(target=target, run=run, context=context, files=files)
    return None


def current_pr_head(client: GitHubClient, *, pr_number: int) -> str | None:
    data = client.request_json("GET", f"/pulls/{pr_number}")
    head = data.get("head") or {}
    return head.get("sha")


def decision_label(decision: str) -> tuple[str, str]:
    return {
        "low_risk": ("LOW RISK", "低风险"),
        "high_risk": ("HIGH RISK", "高风险"),
        "reject": ("REJECT", "打回"),
    }.get(decision, (decision.upper() if decision else "UNKNOWN", decision or "未知"))


def quality_label(overall: str, conclusion: str) -> tuple[str, str]:
    if conclusion != "success":
        return (conclusion.upper() if conclusion else "UNKNOWN", "失败")
    return {
        "passed": ("PASS", "通过"),
        "failed": ("FAIL", "失败"),
        "incomplete": ("INCOMPLETE", "未完成"),
    }.get(overall, ("UNKNOWN", "未知"))


def limited(text: str, *, max_chars: int = 25000) -> str:
    if len(text) <= max_chars:
        return text
    return text[:max_chars].rstrip() + "\n\n...truncated in summary comment..."


def details(summary: str, body: str) -> str:
    return "\n".join(
        [
            "<details>",
            f"<summary>{summary}</summary>",
            "",
            limited(body.strip()),
            "",
            "</details>",
        ]
    )


def build_comment(*, policy: TargetResult, flutter: TargetResult) -> str:
    policy_data = load_json_file(policy.files, policy.target.json_file)
    flutter_data = load_json_file(flutter.files, flutter.target.json_file)
    policy_md = find_file(policy.files, policy.target.markdown_file) or "Policy preflight report was not produced."
    flutter_md = find_file(flutter.files, flutter.target.markdown_file) or "Flutter quality report was not produced."

    decision = policy_data.get("decision", "unknown")
    decision_en, decision_zh = decision_label(decision)
    flutter_overall = str(flutter_data.get("overall", "unknown"))
    flutter_en, flutter_zh = quality_label(flutter_overall, str(flutter.run.get("conclusion", "")))

    if decision == "reject":
        final_zh = "打回：规则预检命中阻断项，需要修复后再进入普通 review。"
        final_en = "Rejected: policy preflight found a blocking issue."
    elif str(flutter.run.get("conclusion", "")) != "success" or flutter_overall != "passed":
        final_zh = "需要修复：Flutter quality 发现新增 analyzer/test 问题或未完整完成。"
        final_en = "Needs fixes: Flutter quality found new analyzer/test issues or did not complete."
    elif decision == "high_risk":
        final_zh = "高风险：质量预检通过，但需要 maintainer 人工 review 后手动合并。"
        final_en = "High risk: quality passed, but maintainer review is required before manual merge."
    elif decision == "low_risk":
        final_zh = "低风险：两个预检均已完成，质量预检通过，可走普通手动合并流程。"
        final_en = "Low risk: both preflights completed and quality passed; use the normal manual merge flow."
    else:
        final_zh = "未确认：预检完成，但 policy 判定不可识别。"
        final_en = "Unconfirmed: preflights completed, but the policy decision is unknown."

    return "\n\n".join(
        [
            COMMENT_MARKER,
            "# PR Preflight Summary / PR 预检汇总",
            "## 中文",
            "\n".join(
                [
                    f"- 统一结论：{final_zh}",
                    f"- Policy preflight：`{decision_zh}`",
                    f"- Flutter quality：`{flutter_zh}`",
                    f"- PR head：`{policy.context['head_sha']}`",
                    f"- Policy run：[{policy.run['id']}]({policy.run['html_url']})",
                    f"- Flutter run：[{flutter.run['id']}]({flutter.run['html_url']})",
                ]
            ),
            "## English",
            "\n".join(
                [
                    f"- Combined result: {final_en}",
                    f"- Policy preflight: `{decision_en}`",
                    f"- Flutter quality: `{flutter_en}`",
                    f"- PR head: `{policy.context['head_sha']}`",
                    f"- Policy run: [{policy.run['id']}]({policy.run['html_url']})",
                    f"- Flutter run: [{flutter.run['id']}]({flutter.run['html_url']})",
                ]
            ),
            details("PR Policy Preflight / PR 规则预检", policy_md),
            details("PR Flutter Quality / Flutter 质量预检", flutter_md),
        ]
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Upsert the combined PR preflight comment.")
    parser.add_argument("--repo", required=True)
    parser.add_argument("--trigger-run-id", required=True, type=int)
    parser.add_argument("--dry-run", action="store_true")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        print("GITHUB_TOKEN is required.", file=sys.stderr)
        return 1

    client = GitHubClient(repo=args.repo, token=token)
    context = trigger_context(client, trigger_run_id=args.trigger_run_id)
    if context is None:
        print("Trigger run has no known preflight artifact yet; skipping summary.")
        return 0

    pr_number = int(context["pr_number"])
    head_sha = str(context["head_sha"])
    live_head_sha = current_pr_head(client, pr_number=pr_number)
    if live_head_sha != head_sha:
        print(
            f"Skipping stale preflight summary for PR #{pr_number}: "
            f"artifact head {head_sha}, current head {live_head_sha}."
        )
        return 0

    results: dict[str, TargetResult] = {}
    for target in TARGETS:
        result = find_matching_result(
            client,
            target=target,
            pr_number=pr_number,
            head_sha=head_sha,
        )
        if result is None:
            print(
                f"Waiting for {target.workflow_name} artifact for PR #{pr_number} "
                f"at {head_sha}."
            )
            return 0
        results[target.key] = result

    body = build_comment(policy=results["policy"], flutter=results["flutter"])
    if args.dry_run:
        print(body)
        return 0

    try:
        client.upsert_comment(pr_number=pr_number, body=body)
    except GitHubApiError as exc:
        print(f"::warning::Could not update combined preflight comment for PR #{pr_number}. {exc}")
        return 0

    print(f"Updated combined preflight comment for PR #{pr_number}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

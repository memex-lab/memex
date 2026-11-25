#!/usr/bin/env python3
"""List the local Codex review queue and record a maintainer's exact-head verdict."""

import argparse
import hashlib
import io
import re
import zipfile
from fnmatch import fnmatch
import json
import os
from pathlib import Path
import subprocess
import sys

REPO = "memex-lab/memex"
CHECKS = {
    ("PR Flutter Quality", "Flutter Analyze and Test"),
    ("PR Policy Preflight", "PR Policy Preflight"),
}
VERDICTS = {
    "passed": "success",
    "changes-requested": "failure",
    "needs-human": "pending",
}


def gh(*args, payload=None):
    command = ["gh", *args]
    if payload is not None:
        command += ["--input", "-"]
    result = subprocess.run(command, input=json.dumps(payload) if payload is not None else None,
                            text=True, stdout=subprocess.PIPE, check=True)
    return json.loads(result.stdout)


def api(repo, path, payload=None):
    return gh("api", f"repos/{repo}/{path}".rstrip("/"), payload=payload)


def preflight(checks):
    # gh pr checks maps check suites to their owning workflow. Missing or
    # skipped required jobs cannot provide positive evidence.
    found = {key: [] for key in CHECKS}
    for check in checks:
        key = check["workflow"], check["name"]
        if key in found:
            found[key].append(check["bucket"])
    if any(bucket in {"fail", "cancel"} for buckets in found.values() for bucket in buckets):
        return "preflight-failed"
    if not all(found.values()) or any(bucket != "pass" for buckets in found.values() for bucket in buckets):
        return "waiting-preflight"
    return "ready"


def intent(pr):
    material = json.dumps([pr.get("title"), pr.get("body")], ensure_ascii=False)
    return hashlib.sha256(material.encode()).hexdigest()[:16]


def evidence(repo, pr, checks):
    """Read exact workflow artifacts, including pre-handoff shadow decisions."""
    owner = False
    for check in checks:
        key = check["workflow"], check["name"]
        if key not in CHECKS:
            continue
        match = re.search(r"/actions/runs/(\d+)(?:/|$)", check.get("link", ""))
        if not match:
            return "waiting-preflight"
        policy = key[0] == "PR Policy Preflight"
        artifact = "pr-policy-preflight" if policy else "pr-flutter-quality"
        items = api(repo, f"actions/runs/{match[1]}/artifacts")["artifacts"]
        active = [a for a in items if a["name"] == artifact and not a["expired"]]
        if not active:
            return "waiting-preflight"
        item = max(active, key=lambda a: a["id"])
        if item["size_in_bytes"] > 8_000_000:
            return "waiting-preflight"
        data = subprocess.check_output(["gh", "api", f"repos/{repo}/actions/artifacts/{item['id']}/zip"])
        try:
            with zipfile.ZipFile(io.BytesIO(data)) as archive:
                def read(name):
                    info = archive.getinfo(name)
                    if info.file_size > 1_000_000:
                        raise ValueError("oversized preflight report")
                    return json.loads(archive.read(info))
                context = read("preflight-context.json")
                if (context.get("pr_number"), context.get("base_sha"), context.get("head_sha")) != (
                        pr["number"], pr["base"]["sha"], pr["head"]["sha"]):
                    return "waiting-preflight"
                if policy:
                    decision = read("preflight.json").get("decision")
                    if decision not in {"low_risk", "high_risk"}:
                        return "preflight-failed"
                    owner |= decision == "high_risk"
                elif context.get("checkout_sha") and context["checkout_sha"] != pr.get("merge_commit_sha"):
                    return "waiting-preflight"
                if not policy and read("flutter-quality.json").get("overall") != "passed":
                    return "preflight-failed"
        except (zipfile.BadZipFile, ValueError, KeyError, AttributeError):
            return "waiting-preflight"
    return "ready-owner" if owner else "ready"


def snapshot(repo, number):
    pr = api(repo, f"pulls/{number}")
    head = pr["head"]["sha"]
    if pr["state"] != "open" or pr["draft"]:
        return pr, "closed-or-draft"
    # gh pr checks uses exit 1 for a failed check and 8 for pending checks.
    result = subprocess.run(["gh", "pr", "checks", str(number), "-R", repo,
                             "--json", "name,workflow,bucket,link"], capture_output=True, text=True)
    if not result.stdout.strip() and "no checks reported" in result.stderr.lower():
        return pr, "waiting-preflight"
    if result.returncode not in (0, 1, 8) or not result.stdout.strip():
        raise ValueError(result.stderr.strip() or "Could not read PR checks")
    checks = json.loads(result.stdout)
    state = preflight(checks)
    if state == "ready":
        state = evidence(repo, pr, checks)
    if state not in {"ready", "ready-owner"}:
        return pr, state
    pr["requires_policy_owner"] = state == "ready-owner"
    # The context includes the destination branch and PR number so two PRs
    # sharing a commit cannot inherit each other's review.
    context = review_context(pr)
    pages = gh("api", "--paginate", "--slurp",
               f"repos/{repo}/commits/{head}/statuses?per_page=100")
    for page in pages:
        for status in page:  # GitHub returns newest first.
            if status["context"] == context:
                verdict, _, digest = (status["description"] or "").partition(" ")
                if digest == intent(pr) and VERDICTS.get(verdict) == status["state"]:
                    return pr, verdict
    return pr, "awaiting-codex"


def review_context(pr):
    return f"memex/local-review/{pr['number']}/{pr['base']['sha']}/{intent(pr)}"


def needs_owner(pr, files):
    if len(files) < pr["changed_files"]:
        return True
    patterns = (".github/**", "scripts/*pr*.py", "scripts/compare_flutter*",
                "docs/local-pr-review.md", "docs/review-verification-maintenance.md",
                "lib/*app_lock*", "lib/*backup*", "lib/*restore*", "lib/*auth*",
                "lib/*permission*", "lib/*migration*", "lib/*privacy*",
                "ios/Runner/AppDelegate*", "android/*AndroidManifest.xml")
    return any(fnmatch(path, pattern)
               for item in files for path in (item["filename"], item.get("previous_filename", ""))
               for pattern in patterns)


def independent_approval(repo, pr, reviews):
    # A later changes-requested review supersedes that user's earlier approval.
    decisions = {}
    for r in reviews:
        if r["state"] in {"APPROVED", "CHANGES_REQUESTED", "DISMISSED"}:
            decisions[r["user"]["login"]] = r
    for login, r in decisions.items():
        if (r["state"] == "APPROVED" and r["commit_id"] == pr["head"]["sha"]
                and r["user"]["type"] == "User" and login != pr["user"]["login"]):
            role = api(repo, f"collaborators/{login}/permission")["permission"]
            if role in {"admin", "maintain", "write"}:
                return True
    return False


def record(repo, args):
    pr, state = snapshot(repo, args.number)
    if state in {"closed-or-draft", "preflight-failed", "waiting-preflight"}:
        raise ValueError(f"PR #{args.number}: {state}")
    if args.intent != intent(pr):
        raise ValueError("PR title or body changed. Review the updated intent.")
    if (pr["head"]["sha"], pr["base"]["sha"]) != (args.head, args.base):
        raise ValueError("The reviewed base/head changed. Refresh the diff and evidence.")
    report = args.report.read_text(encoding="utf-8").strip()
    if not report:
        raise ValueError("Review report is empty")
    # Publish the evidence first. A failed status update can never leave a
    # passing status without an auditable report. Reuse the review on retry.
    body = (f"## Local Codex review · {args.verdict}\n\n"
            f"Base: `{args.base}` · Head: `{args.head}`\n\n{report}")
    reviews_path = f"repos/{repo}/pulls/{args.number}/reviews"
    actor = gh("api", "user")["login"]
    pages = gh("api", "--paginate", "--slurp", reviews_path + "?per_page=100")
    if not api(repo, "")["permissions"].get("push"):
        raise ValueError("Recording a verdict requires a repository maintainer with write access.")
    if args.verdict == "passed":
        files = gh("api", "--paginate", "--slurp",
                   f"repos/{repo}/pulls/{args.number}/files?per_page=100")
        if pr["requires_policy_owner"] or needs_owner(pr, [f for page in files for f in page]):
            if not independent_approval(repo, pr, [r for page in pages for r in page]):
                raise ValueError("Needs independent maintainer approval for this head; record needs-human.")
    previous = next((r for p in reversed(pages) for r in reversed(p)
                     if r["user"]["login"] == actor and r["commit_id"] == args.head
                     and r["body"] == body), None)
    review = previous or gh("api", reviews_path, payload={
        "event": "COMMENT", "commit_id": args.head, "body": body})
    latest = api(repo, f"pulls/{args.number}")
    if (latest["state"] != "open" or latest["draft"] or latest["head"]["sha"] != args.head
            or latest["base"]["sha"] != args.base or intent(latest) != args.intent):
        raise ValueError("PR changed during publication; report retained, verdict withheld")
    api(repo, f"statuses/{args.head}", payload={
        "state": VERDICTS[args.verdict], "context": review_context(pr),
        "description": f"{args.verdict} {args.intent}", "target_url": review["html_url"]})
    print(review["html_url"])


def initialize(repo):
    pr = json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text())["pull_request"]
    head = pr["head"]["sha"]
    context = review_context(pr)
    pages = gh("api", "--paginate", "--slurp", f"repos/{repo}/commits/{head}/statuses?per_page=100")
    if not any(s["context"] == context for page in pages for s in page):
        api(repo, f"statuses/{head}", payload={"state": "pending", "context": context,
            "description": "awaiting-codex", "target_url": pr["html_url"]})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=REPO)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("initialize", help="Actions handoff from a trusted pull_request_target event")
    queue = commands.add_parser("queue")
    queue.add_argument("--all", action="store_true", help="include drafts and blocked/reviewed PRs")
    show = commands.add_parser("show")
    show.add_argument("number", type=int)
    finish = commands.add_parser("record")
    finish.add_argument("number", type=int)
    finish.add_argument("--base", required=True)
    finish.add_argument("--head", required=True)
    finish.add_argument("--intent", required=True)
    finish.add_argument("--verdict", required=True, choices=VERDICTS)
    finish.add_argument("--report", required=True, type=Path)
    args = parser.parse_args()
    if args.command == "initialize":
        initialize(args.repo)
        return
    if args.command == "record":
        record(args.repo, args)
        return
    if args.command == "show":
        numbers = [args.number]
    else:
        pages = gh("api", "--paginate", "--slurp",
                   f"repos/{args.repo}/pulls?state=open&sort=created&direction=asc&per_page=100")
        numbers = [pr["number"] for page in pages for pr in page]
    for number in numbers:
        pr, state = snapshot(args.repo, number)
        if args.command == "show" or args.all or state == "awaiting-codex":
            print(f"#{number}\t{state}\t{pr['base']['sha']}..{pr['head']['sha']}\t{intent(pr)}\t{pr['title']}")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, subprocess.CalledProcessError) as exc:
        sys.exit(str(exc))

from io import BytesIO, StringIO
import unittest
from unittest import mock
import urllib.error

from scripts.pr_preflight_summary_comment import (
    GitHubApiError,
    GitHubClient,
    TARGETS,
    TargetResult,
    build_comment,
    trigger_context,
)


class PreflightSummaryCommentTest(unittest.TestCase):
    def test_request_json_preserves_github_error_body(self):
        response = BytesIO(b'{"message":"Resource not accessible by integration"}')
        error = urllib.error.HTTPError(
            "https://api.github.com/repos/memex-lab/memex/issues/120/comments",
            403,
            "Forbidden",
            {},
            response,
        )
        client = GitHubClient(repo="memex-lab/memex", token="token")

        with mock.patch("urllib.request.urlopen", side_effect=error):
            with self.assertRaises(GitHubApiError) as context:
                client.request_json("POST", "/issues/120/comments", data={"body": "x"})

        self.assertEqual(context.exception.status, 403)
        self.assertIn("Resource not accessible by integration", str(context.exception))
        self.assertIn("POST /issues/120/comments", str(context.exception))

    def test_build_comment_includes_one_sentence_details(self):
        context = {
            "pr_number": 120,
            "head_sha": "abc123",
        }
        policy = TargetResult(
            target=TARGETS[0],
            run={"id": 1, "html_url": "https://example.com/policy", "conclusion": "success"},
            context=context,
            files={
                "preflight.json": """
                {
                  "decision": "low_risk",
                  "findings": []
                }
                """,
                "preflight.md": "policy details",
            },
        )
        flutter = TargetResult(
            target=TARGETS[1],
            run={"id": 2, "html_url": "https://example.com/flutter", "conclusion": "success"},
            context=context,
            files={
                "flutter-quality.json": """
                {
                  "overall": "passed",
                  "analyzer": {"status": "passed"},
                  "tests": {"status": "passed"}
                }
                """,
                "flutter-analyze.json": '{"new_count": 0}',
                "flutter-test.json": '{"new_count": 0}',
                "flutter-quality.md": "flutter details",
            },
        )

        comment = build_comment(policy=policy, flutter=flutter)

        self.assertIn("Policy preflight：`未命中治理规则`。未命中打回或高风险规则。", comment)
        self.assertIn("Flutter quality：`通过`。Analyzer 和 test baseline 均未发现新增问题。", comment)
        self.assertIn("Policy preflight: `NO GOVERNANCE FLAGS`. No blocking or high-risk policy signal was found.", comment)
        self.assertIn("Flutter quality: `PASS`. Analyzer and test baselines found no newly introduced issue.", comment)

    def test_trigger_context_skips_transient_artifact_download_error(self):
        class Client:
            def artifact_files(self, *, run_id, artifact_name):  # noqa: ANN001
                raise urllib.error.HTTPError(
                    "https://api.github.com/repos/memex-lab/memex/actions/artifacts/1/zip",
                    502,
                    "Bad Gateway",
                    {},
                    BytesIO(b"bad gateway"),
                )

        with mock.patch("sys.stdout", new_callable=StringIO):
            context = trigger_context(Client(), trigger_run_id=123)

        self.assertIsNone(context)

    def test_trigger_context_continues_after_one_artifact_download_error(self):
        class Client:
            def artifact_files(self, *, run_id, artifact_name):  # noqa: ANN001
                if artifact_name == TARGETS[0].artifact_name:
                    raise urllib.error.HTTPError(
                        "https://api.github.com/repos/memex-lab/memex/actions/artifacts/1/zip",
                        502,
                        "Bad Gateway",
                        {},
                        BytesIO(b"bad gateway"),
                    )
                return {
                    "preflight-context.json": """
                    {
                      "pr_number": 120,
                      "head_sha": "abc123"
                    }
                    """
                }

        with mock.patch("sys.stdout", new_callable=StringIO):
            context = trigger_context(Client(), trigger_run_id=123)

        self.assertEqual(context["pr_number"], 120)
        self.assertEqual(context["head_sha"], "abc123")


if __name__ == "__main__":
    unittest.main()

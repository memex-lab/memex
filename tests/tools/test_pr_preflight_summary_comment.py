from io import BytesIO
import unittest
from unittest import mock
import urllib.error

from scripts.pr_preflight_summary_comment import (
    GitHubApiError,
    GitHubClient,
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


if __name__ == "__main__":
    unittest.main()

import unittest

from scripts.pr_policy_check import (
    ChangedFile,
    DECISION_HIGH_RISK,
    DECISION_LOW_RISK,
    DECISION_REJECT,
    evaluate_policy,
    result_to_dict,
    result_to_markdown,
)


def run_policy(changed_files, diff="", pr_body="Test plan: not needed for docs."):
    return evaluate_policy(
        base_ref="origin/main",
        head_ref="HEAD",
        head_sha="abc123",
        merge_base="base123",
        changed_files=changed_files,
        diff=diff,
        diff_truncated=False,
        diff_bytes=len(diff.encode()),
        pr_title="Test PR",
        pr_body=pr_body,
        max_files_low_risk=20,
        max_lines_low_risk=800,
        max_single_file_lines_low_risk=400,
    )


class PolicyPreflightTest(unittest.TestCase):
    def test_secret_file_rejects(self):
        result = run_policy([ChangedFile(status="A", path="android/key.properties")])

        self.assertEqual(result.decision, DECISION_REJECT)
        self.assertFalse(result.compliant)
        self.assertTrue(result.findings[0].message_zh)

    def test_generated_file_without_source_rejects(self):
        result = run_policy([ChangedFile(status="M", path="lib/db/app_database.g.dart")])

        self.assertEqual(result.decision, DECISION_REJECT)

    def test_generated_file_with_source_is_high_risk(self):
        result = run_policy(
            [
                ChangedFile(status="M", path="lib/db/app_database.dart"),
                ChangedFile(status="M", path="lib/db/app_database.g.dart"),
            ]
        )

        self.assertEqual(result.decision, DECISION_HIGH_RISK)
        self.assertTrue(result.compliant)

    def test_docs_only_is_low_risk(self):
        result = run_policy([ChangedFile(status="M", path="docs/readme.md", additions=10)])

        self.assertEqual(result.decision, DECISION_LOW_RISK)

    def test_workflow_change_is_high_risk(self):
        result = run_policy([ChangedFile(status="M", path=".github/workflows/build.yml")])

        self.assertEqual(result.decision, DECISION_HIGH_RISK)

    def test_unsafe_workflow_pattern_rejects(self):
        diff = (
            "diff --git a/.github/workflows/build.yml b/.github/workflows/build.yml\n"
            "+++ b/.github/workflows/build.yml\n"
            "+permissions: write-all\n"
            "+run: curl https://example.com/install.sh | bash\n"
        )
        result = run_policy([ChangedFile(status="M", path=".github/workflows/build.yml")], diff=diff)

        self.assertEqual(result.decision, DECISION_REJECT)

    def test_single_l10n_file_is_high_risk(self):
        result = run_policy([ChangedFile(status="M", path="lib/l10n/app_en.arb")])

        self.assertEqual(result.decision, DECISION_HIGH_RISK)

    def test_production_change_without_test_signal_warns_only(self):
        result = run_policy(
            [ChangedFile(status="M", path="lib/ui/example_widget.dart", additions=8)],
            pr_body="",
        )

        self.assertEqual(result.decision, DECISION_LOW_RISK)
        self.assertTrue(any(finding.rule_id == "missing-test-signal" for finding in result.findings))

    def test_outputs_include_bilingual_labels(self):
        result = run_policy([ChangedFile(status="M", path=".github/workflows/build.yml")])
        data = result_to_dict(result)
        markdown = result_to_markdown(result)

        self.assertEqual(data["decision_zh"], "高风险")
        self.assertTrue(data["findings"][0]["message_zh"])
        self.assertIn("Decision / 判定", markdown)
        self.assertIn("Findings / 规则命中", markdown)


if __name__ == "__main__":
    unittest.main()

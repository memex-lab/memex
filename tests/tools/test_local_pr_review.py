import argparse
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import local_pr_review as review
from scripts.verify_pr import select


class LocalReviewTest(unittest.TestCase):
    def test_only_completed_required_workflows_are_ready(self):
        checks = [dict(workflow=w, name=n, bucket="pass") for w, n in review.CHECKS]
        self.assertEqual(review.preflight(checks), "ready")
        self.assertEqual(review.preflight(checks[:1]), "waiting-preflight")
        checks[1]["bucket"] = "skipping"
        self.assertEqual(review.preflight(checks), "waiting-preflight")
        checks[1]["bucket"] = "fail"
        self.assertEqual(review.preflight(checks), "preflight-failed")

    def test_same_head_separate_pr_or_base_needs_fresh_verdict(self):
        pr = {"number": 12, "base": {"sha": "aaa"}}
        self.assertNotEqual(review.review_context(pr),
                            review.review_context(dict(pr, number=13)))
        self.assertNotEqual(review.review_context(pr),
                            review.review_context(dict(pr, base={"sha": "bbb"})))

    def test_record_withholds_status_when_concurrent_push_lands(self):
        pr = {"number": 12, "state": "open", "draft": False,
              "base": {"sha": "base"}, "head": {"sha": "head"}}
        with tempfile.TemporaryDirectory() as temp:
            report = Path(temp) / "review.md"
            report.write_text("Verified restored rows.")
            args = argparse.Namespace(number=12, base="base", head="head", intent=review.intent(pr),
                                      verdict="changes-requested", report=report)
            with patch.object(review, "snapshot", return_value=(pr, "awaiting-codex")), \
                 patch.object(review, "gh", side_effect=[{"login":"maintainer"}, [],
                                                        {"html_url":"https://example.org/review"}]), \
                 patch.object(review, "api", side_effect=[{"permissions":{"push":True}}, dict(pr, head={"sha":"new"})]) as api:
                with self.assertRaisesRegex(ValueError, "withheld"):
                    review.record("example/repo", args)
                self.assertEqual(api.call_count, 2)
                api.assert_called_with("example/repo", "pulls/12")

    def test_routing_covers_multiple_scenarios(self):
        self.assertCountEqual(select(["ios/Runner/AppDelegate.swift",
                                      "lib/data/services/backup_service.dart"]),
                              ["restore", "startup"])
        self.assertCountEqual(select(["lib/data/services/file_system_service.dart"]),
                              ["capture", "timeline"])
        self.assertEqual(select(["lib/ui/main_screen/quick_recording_transcript.dart"]), ["voice"])
        self.assertCountEqual(select(["lib/main.dart"]), ["lock", "voice", "startup"])
        self.assertEqual(select(["lib/ui/timeline/widgets/timeline/asset_header_gallery.dart"]), ["timeline", "images"])
        self.assertEqual(select(["README.md"]), [])


class ReviewEvidenceTest(unittest.TestCase):
    def test_intent_edits_invalidate_status_context(self):
        pr = {"number":12, "base":{"sha":"abc"}, "body":"runs locally"}
        self.assertNotEqual(review.review_context(pr),
                            review.review_context(dict(pr, body="uploads recordings")))

    def test_artifact_version_and_policy_are_authoritative(self):
        import io
        import json
        import zipfile
        pr = {"number":12, "head":{"sha":"head"}, "base":{"sha":"base"}}
        checks = [{"workflow":"PR Policy Preflight","name":"PR Policy Preflight",
                   "link":"https://github.com/example/repo/actions/runs/1/job/2"}]
        def classify(base, decision):
            stream = io.BytesIO()
            with zipfile.ZipFile(stream, "w") as archive:
                archive.writestr("preflight-context.json", json.dumps({
                    "pr_number":12,"head_sha":"head","base_sha":base}))
                archive.writestr("preflight.json", json.dumps({"decision":decision}))
            items = {"artifacts":[{"name":"pr-policy-preflight","expired":False,
                                   "id":11,"size_in_bytes":len(stream.getvalue())}]}
            with patch.object(review,"api",return_value=items), \
                 patch.object(review.subprocess,"check_output",return_value=stream.getvalue()):
                return review.evidence("example/repo", pr, checks)
        self.assertEqual(classify("old","low_risk"), "waiting-preflight")
        self.assertEqual(classify("base","reject"), "preflight-failed")
        self.assertEqual(classify("base","high_risk"), "ready-owner")

    def test_independent_approval_needs_current_head_and_role(self):
        pr = {"head":{"sha":"head"}, "user":{"login":"author"}}
        approval = {"user":{"type":"User","login":"owner"},"commit_id":"head","state":"APPROVED"}
        with patch.object(review, "api", return_value={"permission":"write"}):
            self.assertTrue(review.independent_approval("repo", pr, [approval]))
            self.assertFalse(review.independent_approval("repo", pr, [dict(approval, commit_id="old")]))
            self.assertFalse(review.independent_approval("repo", pr, [approval, dict(approval, state="DISMISSED")]))

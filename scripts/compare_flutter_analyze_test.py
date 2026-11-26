#!/usr/bin/env python3

import unittest

if __package__:
    from .compare_flutter_analyze import newly_introduced_issues, parse_report
else:
    from compare_flutter_analyze import newly_introduced_issues, parse_report


BASE_REPORT = """
   info • Use 'const' with the constructor to improve performance • lib/a.dart:10:3 • prefer_const_constructors
warning • Unused import: 'dart:async' • test/a_test.dart:1:8 • unused_import
"""


class CompareFlutterAnalyzeTest(unittest.TestCase):
    def test_parse_report_extracts_analyzer_issues(self):
        issues = parse_report(BASE_REPORT)

        self.assertEqual(len(issues), 2)
        self.assertEqual(issues[0].severity, "info")
        self.assertEqual(issues[0].path, "lib/a.dart")
        self.assertEqual(issues[0].line, 10)
        self.assertEqual(issues[0].code, "prefer_const_constructors")
        self.assertEqual(issues[1].severity, "warning")
        self.assertEqual(issues[1].code, "unused_import")

    def test_moved_existing_issue_is_not_new(self):
        head_report = """
   info • Use 'const' with the constructor to improve performance • lib/a.dart:99:3 • prefer_const_constructors
warning • Unused import: 'dart:async' • test/a_test.dart:1:8 • unused_import
"""

        new_issues = newly_introduced_issues(
            parse_report(BASE_REPORT),
            parse_report(head_report),
        )

        self.assertEqual(new_issues, [])

    def test_additional_copy_of_existing_issue_is_new(self):
        head_report = BASE_REPORT + (
            "   info • Use 'const' with the constructor to improve performance • "
            "lib/a.dart:20:3 • prefer_const_constructors\n"
        )

        new_issues = newly_introduced_issues(
            parse_report(BASE_REPORT),
            parse_report(head_report),
        )

        self.assertEqual(len(new_issues), 1)
        self.assertEqual(new_issues[0].line, 20)

    def test_parses_flutter_write_format_and_normalizes_paths(self):
        issues = parse_report(
            "[warning] Dead code "
            "(/home/runner/work/memex/memex-base/lib/agent/cache.dart:44:5)\n"
            "[error] New problem "
            "(/home/runner/work/memex/memex/test/foo_test.dart:1:2)\n"
        )

        self.assertEqual(len(issues), 2)
        self.assertEqual(issues[0].path, "lib/agent/cache.dart")
        self.assertEqual(issues[0].code, "analyzer")
        self.assertEqual(issues[1].path, "test/foo_test.dart")

    def test_baseline_comparison_ignores_line_drift(self):
        base = parse_report(
            "[warning] Dead code "
            "(/home/runner/work/memex/memex-base/lib/agent/cache.dart:44:5)\n"
        )
        head = parse_report(
            "[warning] Dead code "
            "(/home/runner/work/memex/memex/lib/agent/cache.dart:80:9)\n"
            "[error] New problem "
            "(/home/runner/work/memex/memex/lib/data/new.dart:1:2)\n"
        )

        new_issues = newly_introduced_issues(base, head)

        self.assertEqual(len(new_issues), 1)
        self.assertEqual(new_issues[0].severity, "error")
        self.assertEqual(new_issues[0].path, "lib/data/new.dart")


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3

import unittest

from compare_flutter_analyze import newly_introduced_issues, parse_report


class CompareFlutterAnalyzeTest(unittest.TestCase):
    def test_parses_flutter_stdout_format(self):
        issues = parse_report(
            "warning • Dead code • lib/agent/cache.dart:44:5 • dead_code\n"
            "   info • Use const • test/foo_test.dart:1:2 • prefer_const\n"
        )

        self.assertEqual(len(issues), 2)
        self.assertEqual(issues[0].severity, "warning")
        self.assertEqual(issues[0].code, "dead_code")
        self.assertEqual(issues[0].path, "lib/agent/cache.dart")
        self.assertEqual(issues[0].line, 44)

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

import unittest

from scripts.compare_flutter_analyze import (
    newly_introduced_issues,
    parse_report,
)


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


if __name__ == "__main__":
    unittest.main()

import unittest

from scripts.compare_flutter_test_failures import (
    newly_introduced_failures,
    parse_failures,
)


BASE_OUTPUT = """
✅ /repo/test/a_test.dart: suite passing test
##[group]❌ /repo/test/live_agent_eval_test.dart: Live Agent Evaluation companion + comment agent live run with env config (failed)
OPENAI_BASE_URL / OPENAI_API_KEY not set in test process env
##[endgroup]
"""


class CompareFlutterTestFailuresTest(unittest.TestCase):
    def test_parse_failures_extracts_failed_test_label(self):
        failures = parse_failures(BASE_OUTPUT)

        self.assertEqual(len(failures), 1)
        self.assertEqual(
            failures[0].normalized_label,
            "test/live_agent_eval_test.dart: Live Agent Evaluation companion + comment agent live run with env config",
        )

    def test_same_failure_under_different_workspace_path_is_not_new(self):
        head_output = BASE_OUTPUT.replace("/repo/test/", "/home/runner/work/memex/memex/test/")

        new_failures = newly_introduced_failures(
            parse_failures(BASE_OUTPUT),
            parse_failures(head_output),
        )

        self.assertEqual(new_failures, [])

    def test_additional_failure_is_new(self):
        head_output = BASE_OUTPUT + (
            "##[group]❌ /repo/test/new_test.dart: new failing test (failed)\n"
            "##[endgroup]\n"
        )

        new_failures = newly_introduced_failures(
            parse_failures(BASE_OUTPUT),
            parse_failures(head_output),
        )

        self.assertEqual(len(new_failures), 1)
        self.assertEqual(
            new_failures[0].normalized_label,
            "test/new_test.dart: new failing test",
        )


if __name__ == "__main__":
    unittest.main()


class MachineTest(unittest.TestCase):
    def stream(self, result, success):
        import json
        events = [
            {"type":"suite","suite":{"id":1,"path":"/repo/test/a.dart"}},
            {"type":"testStart","test":{"id":2,"suiteID":1,"name":"restore"}},
            {"type":"testDone","testID":2,"result":result},
            {"type":"done","success":success},
        ]
        return '\n[{"event":"test.startedProcess","params":{}}]\n' + "\n".join(map(json.dumps, events))

    def test_structured_terminal_and_exit_agree(self):
        from scripts.compare_flutter_test_failures import machine_failures
        self.assertEqual(machine_failures(self.stream("success", True), 0), [])
        failed = machine_failures(self.stream("failure", False), 1)
        self.assertEqual(len(newly_introduced_failures([], failed)), 1)
        self.assertEqual(newly_introduced_failures(failed, failed), [])
        for stream, code in [(self.stream("success", True), 1),
                             (self.stream("failure", False), 0),
                             ('{"type":"start"}', 1), ("", 0), ("invalid", 1)]:
            with self.assertRaises(ValueError):
                machine_failures(stream, code)

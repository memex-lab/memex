import datetime as dt
import importlib.util
import unittest
import xml.etree.ElementTree as element_tree
from pathlib import Path
from unittest import mock


SCRIPT_PATH = Path(__file__).with_name("generate_star_history.py")
SPEC = importlib.util.spec_from_file_location("generate_star_history", SCRIPT_PATH)
assert SPEC and SPEC.loader
GENERATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GENERATOR)


class GenerateStarHistoryTest(unittest.TestCase):
    def test_fetches_anonymous_star_timestamps_with_graphql_pagination(self) -> None:
        responses = [mock.MagicMock(), mock.MagicMock()]
        responses[0].read.return_value = (
            b'{"data":{"repository":{"stargazers":{"edges":'
            b'[{"starredAt":"2025-01-01T00:00:00Z"}],"pageInfo":'
            b'{"hasNextPage":true,"endCursor":"next"}}}}}'
        )
        responses[1].read.return_value = (
            b'{"data":{"repository":{"stargazers":{"edges":'
            b'[{"starredAt":"2025-02-01T00:00:00Z"}],"pageInfo":'
            b'{"hasNextPage":false,"endCursor":null}}}}}'
        )
        for response in responses:
            response.__enter__.return_value = response

        with mock.patch.object(
            GENERATOR.urllib.request,
            "urlopen",
            side_effect=responses,
        ) as urlopen:
            dates = GENERATOR.fetch_star_dates("memex-lab/memex", "token")

        self.assertEqual(dates, [dt.date(2025, 1, 1), dt.date(2025, 2, 1)])
        self.assertEqual(urlopen.call_count, 2)
        request_body = urlopen.call_args_list[0].args[0].data.decode("utf-8")
        self.assertIn("starredAt", request_body)
        self.assertNotIn("login", request_body)

    def test_cumulative_points_groups_stars_by_date(self) -> None:
        dates = [
            dt.date(2025, 2, 1),
            dt.date(2025, 1, 1),
            dt.date(2025, 1, 1),
        ]

        self.assertEqual(
            GENERATOR.cumulative_points(dates),
            [(dt.date(2025, 1, 1), 2), (dt.date(2025, 2, 1), 3)],
        )

    def test_svg_is_deterministic_and_contains_summary(self) -> None:
        dates = [dt.date(2025, 1, 1), dt.date(2025, 2, 1)]

        first = GENERATOR.render_svg("memex-lab/memex", dates)
        second = GENERATOR.render_svg("memex-lab/memex", list(reversed(dates)))

        self.assertEqual(first, second)
        self.assertIn("2 current stargazers", first)
        self.assertIn("Star History", first)
        self.assertIn("memex-lab/memex", first)
        self.assertIn('id="xkcdify"', first)
        self.assertIn("#dd4528", first)
        self.assertIn("Comic Sans MS", first)
        self.assertEqual(
            element_tree.fromstring(first).tag,
            "{http://www.w3.org/2000/svg}svg",
        )


if __name__ == "__main__":
    unittest.main()

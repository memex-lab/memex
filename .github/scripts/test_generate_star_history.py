import datetime as dt
import importlib.util
import unittest
import xml.etree.ElementTree as element_tree
from pathlib import Path


SCRIPT_PATH = Path(__file__).with_name("generate_star_history.py")
SPEC = importlib.util.spec_from_file_location("generate_star_history", SCRIPT_PATH)
assert SPEC and SPEC.loader
GENERATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GENERATOR)


class GenerateStarHistoryTest(unittest.TestCase):
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
        self.assertIn("2 current stars", first)
        self.assertIn("memex-lab/memex Star History", first)
        self.assertEqual(
            element_tree.fromstring(first).tag,
            "{http://www.w3.org/2000/svg}svg",
        )


if __name__ == "__main__":
    unittest.main()

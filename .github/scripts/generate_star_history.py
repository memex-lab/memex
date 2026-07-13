#!/usr/bin/env python3
"""Generate a deterministic SVG chart from a repository's current stargazers."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import urllib.error
import urllib.request
from collections import Counter
from html import escape
from pathlib import Path


API_VERSION = "2026-03-10"
LINK_PATTERN = re.compile(r'<([^>]+)>;\s*rel="([^"]+)"')


def fetch_star_dates(repository: str, token: str) -> list[dt.date]:
    url = f"https://api.github.com/repos/{repository}/stargazers?per_page=100"
    dates: list[dt.date] = []

    while url:
        request = urllib.request.Request(
            url,
            headers={
                "Accept": "application/vnd.github.star+json",
                "Authorization": f"Bearer {token}",
                "User-Agent": f"{repository}-star-history-workflow",
                "X-GitHub-Api-Version": API_VERSION,
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = json.load(response)
                links = {
                    relation: target
                    for target, relation in LINK_PATTERN.findall(
                        response.headers.get("Link", "")
                    )
                }
        except urllib.error.HTTPError as error:
            body = error.read().decode("utf-8", errors="replace")
            raise RuntimeError(
                f"GitHub stargazers API returned HTTP {error.code}: {body}"
            ) from error

        for item in payload:
            starred_at = item.get("starred_at")
            if not starred_at:
                raise RuntimeError(
                    "GitHub did not return starred_at timestamps; check the Accept header "
                    "and token permissions."
                )
            dates.append(dt.datetime.fromisoformat(starred_at.replace("Z", "+00:00")).date())

        url = links.get("next", "")

    return sorted(dates)


def cumulative_points(dates: list[dt.date]) -> list[tuple[dt.date, int]]:
    counts = Counter(dates)
    total = 0
    points: list[tuple[dt.date, int]] = []
    for date in sorted(counts):
        total += counts[date]
        points.append((date, total))
    return points


def render_svg(repository: str, dates: list[dt.date]) -> str:
    width, height = 900, 500
    left, right, top, bottom = 82, 32, 72, 68
    plot_width = width - left - right
    plot_height = height - top - bottom
    points = cumulative_points(dates)
    total = len(dates)

    if points:
        start_date = points[0][0]
        end_date = points[-1][0]
    else:
        start_date = end_date = dt.date.today()

    span_days = max((end_date - start_date).days, 1)
    y_max = max(total, 1)

    def x_position(date: dt.date) -> float:
        return left + ((date - start_date).days / span_days) * plot_width

    def y_position(value: int) -> float:
        return top + plot_height - (value / y_max) * plot_height

    chart_points = [(start_date, 0), *points]
    path = " ".join(
        f"{'M' if index == 0 else 'L'} {x_position(date):.2f} {y_position(value):.2f}"
        for index, (date, value) in enumerate(chart_points)
    )

    grid_lines: list[str] = []
    y_labels: list[str] = []
    for index in range(6):
        value = round(y_max * index / 5)
        y = y_position(value)
        grid_lines.append(
            f'<line x1="{left}" y1="{y:.2f}" x2="{width - right}" y2="{y:.2f}" />'
        )
        y_labels.append(
            f'<text x="{left - 14}" y="{y + 5:.2f}" text-anchor="end">{value}</text>'
        )

    x_labels: list[str] = []
    for index in range(6):
        offset = round(span_days * index / 5)
        date = start_date + dt.timedelta(days=offset)
        x = x_position(date)
        x_labels.append(
            f'<text x="{x:.2f}" y="{height - 30}" text-anchor="middle">{date.isoformat()}</text>'
        )

    title = escape(repository)
    empty_message = ""
    if not points:
        empty_message = (
            f'<text class="empty" x="{width / 2}" y="{top + plot_height / 2}" '
            'text-anchor="middle">No stars yet</text>'
        )

    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title description">
  <title id="title">Star history for {title}</title>
  <desc id="description">{total} current stargazers, grouped by the date each star was added.</desc>
  <style>
    text {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; fill: #64748b; font-size: 12px; }}
    .heading {{ fill: #334155; font-size: 22px; font-weight: 600; }}
    .total {{ fill: #64748b; font-size: 14px; }}
    .grid {{ stroke: #94a3b8; stroke-opacity: .32; stroke-width: 1; }}
    .axis {{ stroke: #64748b; stroke-opacity: .55; stroke-width: 1; }}
    .history {{ fill: none; stroke: #f59e0b; stroke-linecap: round; stroke-linejoin: round; stroke-width: 3; }}
    .empty {{ font-size: 16px; }}
    @media (prefers-color-scheme: dark) {{
      text, .total {{ fill: #94a3b8; }}
      .heading {{ fill: #e2e8f0; }}
      .grid {{ stroke: #64748b; }}
      .axis {{ stroke: #94a3b8; }}
    }}
  </style>
  <text class="heading" x="{left}" y="36">{title} Star History</text>
  <text class="total" x="{left}" y="58">{total} current stars</text>
  <g class="grid">{''.join(grid_lines)}</g>
  <line class="axis" x1="{left}" y1="{top}" x2="{left}" y2="{top + plot_height}" />
  <line class="axis" x1="{left}" y1="{top + plot_height}" x2="{width - right}" y2="{top + plot_height}" />
  <g>{''.join(y_labels)}</g>
  <g>{''.join(x_labels)}</g>
  <path class="history" d="{path}" />
  {empty_message}
</svg>
'''


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository", default=os.environ.get("GITHUB_REPOSITORY"))
    parser.add_argument("--token", default=os.environ.get("GITHUB_TOKEN"))
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.repository:
        raise SystemExit("--repository or GITHUB_REPOSITORY is required")
    if not args.token:
        raise SystemExit("--token or GITHUB_TOKEN is required")

    dates = fetch_star_dates(args.repository, args.token)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(render_svg(args.repository, dates), encoding="utf-8")
    print(f"Generated {args.output} from {len(dates)} current stargazers")


if __name__ == "__main__":
    main()

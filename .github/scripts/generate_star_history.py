#!/usr/bin/env python3
"""Generate a deterministic SVG chart from a repository's current stargazers."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import math
import os
import urllib.error
import urllib.request
from collections import Counter
from html import escape
from pathlib import Path


API_VERSION = "2026-03-10"
STARGAZERS_QUERY = """
query StarHistory($owner: String!, $name: String!, $cursor: String) {
  repository(owner: $owner, name: $name) {
    stargazers(first: 100, after: $cursor) {
      edges { starredAt }
      pageInfo { hasNextPage endCursor }
    }
  }
}
"""


def fetch_star_dates(repository: str, token: str) -> list[dt.date]:
    try:
        owner, name = repository.split("/", maxsplit=1)
    except ValueError as error:
        raise ValueError("repository must use the owner/name format") from error

    dates: list[dt.date] = []
    cursor: str | None = None

    while True:
        body = json.dumps(
            {
                "query": STARGAZERS_QUERY,
                "variables": {"owner": owner, "name": name, "cursor": cursor},
            }
        ).encode("utf-8")
        request = urllib.request.Request(
            "https://api.github.com/graphql",
            data=body,
            headers={
                "Accept": "application/vnd.github+json",
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
                "User-Agent": f"{repository}-star-history-workflow",
                "X-GitHub-Api-Version": API_VERSION,
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = json.load(response)
        except urllib.error.HTTPError as error:
            body = error.read().decode("utf-8", errors="replace")
            raise RuntimeError(
                f"GitHub GraphQL API returned HTTP {error.code}: {body}"
            ) from error

        if payload.get("errors"):
            raise RuntimeError(f"GitHub GraphQL API returned errors: {payload['errors']}")
        repository_data = payload.get("data", {}).get("repository")
        if repository_data is None:
            raise RuntimeError(f"GitHub could not find repository {repository}")
        connection = repository_data["stargazers"]

        for edge in connection["edges"]:
            starred_at = edge.get("starredAt")
            if not starred_at:
                raise RuntimeError(
                    "GitHub did not return starredAt timestamps; check token permissions."
                )
            dates.append(dt.datetime.fromisoformat(starred_at.replace("Z", "+00:00")).date())

        page_info = connection["pageInfo"]
        if not page_info["hasNextPage"]:
            break
        cursor = page_info["endCursor"]

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
    width, height = 900, 600
    left, right, top, bottom = 70, 30, 60, 50
    plot_width = width - left - right
    plot_height = height - top - bottom
    points = cumulative_points(dates)
    total = len(dates)

    if points:
        start_date = points[0][0]
        end_date = points[-1][0]
    else:
        start_date = end_date = dt.date(1970, 1, 1)

    span_days = max((end_date - start_date).days, 1)
    y_max = max(total, 1)

    def x_position(date: dt.date) -> float:
        return left + ((date - start_date).days / span_days) * plot_width

    def y_position(value: int) -> float:
        return top + plot_height - (value / y_max) * plot_height

    coordinates = [(x_position(date), y_position(value)) for date, value in points]
    if len(coordinates) < 2:
        path = " ".join(
            f"{'M' if index == 0 else 'L'} {x:.2f} {y:.2f}"
            for index, (x, y) in enumerate(coordinates)
        )
    else:
        slopes = [
            (coordinates[index + 1][1] - coordinates[index][1])
            / (coordinates[index + 1][0] - coordinates[index][0])
            for index in range(len(coordinates) - 1)
        ]
        tangents = [slopes[0]]
        tangents.extend(
            (slopes[index - 1] + slopes[index]) / 2
            for index in range(1, len(coordinates) - 1)
        )
        tangents.append(slopes[-1])

        for index, slope in enumerate(slopes):
            if slope == 0:
                tangents[index] = 0
                tangents[index + 1] = 0
                continue
            alpha = tangents[index] / slope
            beta = tangents[index + 1] / slope
            magnitude = alpha * alpha + beta * beta
            if magnitude > 9:
                scale = 3 / math.sqrt(magnitude)
                tangents[index] = scale * alpha * slope
                tangents[index + 1] = scale * beta * slope

        segments = [f"M {coordinates[0][0]:.2f} {coordinates[0][1]:.2f}"]
        for index in range(len(coordinates) - 1):
            x0, y0 = coordinates[index]
            x1, y1 = coordinates[index + 1]
            distance = x1 - x0
            segments.append(
                "C "
                f"{x0 + distance / 3:.2f} {y0 + tangents[index] * distance / 3:.2f}, "
                f"{x1 - distance / 3:.2f} {y1 - tangents[index + 1] * distance / 3:.2f}, "
                f"{x1:.2f} {y1:.2f}"
            )
        path = " ".join(segments)

    raw_step = y_max / 5
    exponent = 10 ** math.floor(math.log10(raw_step))
    fraction = raw_step / exponent
    if fraction < 1.5:
        tick_step = exponent
    elif fraction < 3:
        tick_step = 2 * exponent
    elif fraction < 7:
        tick_step = 5 * exponent
    else:
        tick_step = 10 * exponent
    tick_step = max(1, tick_step)

    y_labels: list[str] = []
    value = tick_step
    while value < y_max:
        y = y_position(value)
        y_labels.append(
            f'<line class="tick" x1="{left - 2}" y1="{y:.2f}" x2="{left}" y2="{y:.2f}" />'
            f'<text x="{left - 9}" y="{y + 5:.2f}" text-anchor="end">{int(value)}</text>'
        )
        value += tick_step

    x_labels: list[str] = []
    for index in range(5):
        offset = round(span_days * (index + 0.5) / 5)
        date = start_date + dt.timedelta(days=offset)
        x = x_position(date)
        label = f"{date:%b} {date.day}, {date.year}"
        x_labels.append(
            f'<line class="tick" x1="{x:.2f}" y1="{top + plot_height}" x2="{x:.2f}" y2="{top + plot_height + 2}" />'
            f'<text x="{x:.2f}" y="{top + plot_height + 25}" text-anchor="middle">{label}</text>'
        )

    repo_label = escape(repository)
    empty_message = ""
    if not points:
        empty_message = (
            f'<text class="empty" x="{width / 2}" y="{top + plot_height / 2}" '
            'text-anchor="middle">No stars yet</text>'
        )

    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img" aria-labelledby="title description">
  <title id="title">Star history for {repo_label}</title>
  <desc id="description">{total} current stargazers, grouped by the date each star was added.</desc>
  <defs>
    <filter id="xkcdify" filterUnits="userSpaceOnUse" x="-5" y="-5" width="{width + 10}" height="{height + 10}">
      <feTurbulence type="fractalNoise" baseFrequency="0.05" result="noise" />
      <feDisplacementMap in="SourceGraphic" in2="noise" scale="5" xChannelSelector="R" yChannelSelector="G" />
    </filter>
  </defs>
  <style>
    .background {{ fill: #fff; }}
    text {{ font-family: "Comic Sans MS", "Bradley Hand", cursive; fill: #000; font-size: 16px; }}
    .heading {{ font-size: 20px; font-weight: bold; }}
    .axis, .tick {{ stroke: #000; stroke-width: 1; }}
    .axis, .history, .legend-box, .legend-color {{ filter: url(#xkcdify); }}
    .history {{ fill: none; stroke: #dd4528; stroke-linecap: round; stroke-linejoin: round; stroke-width: 3; }}
    .legend-box {{ fill: #fff; fill-opacity: .85; stroke: #000; stroke-width: 2; }}
    .legend-color {{ fill: #dd4528; }}
    .watermark {{ fill: #666; font-size: 14px; }}
    .empty {{ font-size: 16px; }}
    @media (prefers-color-scheme: dark) {{
      .background {{ fill: #0d1117; }}
      text {{ fill: #fff; }}
      .axis, .tick {{ stroke: #fff; }}
      .history {{ stroke: #ff6b6b; }}
      .legend-box {{ fill: #0d1117; stroke: #fff; }}
      .legend-color {{ fill: #ff6b6b; }}
      .watermark {{ fill: #999; }}
    }}
  </style>
  <rect class="background" width="{width}" height="{height}" />
  <text class="heading" x="50%" y="30" text-anchor="middle">Star History</text>
  <text x="{width / 2}" y="{height - 10}" text-anchor="middle">Date</text>
  <text x="20" y="{height / 2}" text-anchor="middle" transform="rotate(-90 20 {height / 2})">GitHub Stars</text>
  <line class="axis" x1="{left}" y1="{top}" x2="{left}" y2="{top + plot_height}" />
  <line class="axis" x1="{left}" y1="{top + plot_height}" x2="{width - right}" y2="{top + plot_height}" />
  <g>{''.join(y_labels)}</g>
  <g>{''.join(x_labels)}</g>
  <path class="history" d="{path}" />
  <g>
    <rect class="legend-box" x="{left + 8}" y="{top + 5}" width="{max(165, len(repository) * 8 + 38)}" height="32" rx="5" />
    <rect class="legend-color" x="{left + 15}" y="{top + 17}" width="8" height="8" rx="2" />
    <text x="{left + 29}" y="{top + 29}" font-size="15">{repo_label}</text>
  </g>
  <text class="watermark" x="{width - right}" y="{height - 10}" text-anchor="end">style inspired by star-history.com</text>
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

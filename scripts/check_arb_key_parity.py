#!/usr/bin/env python3
"""Fail when locale ARB key sets drift from app_en.arb."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"


def message_keys(path: Path) -> set[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {key for key in data if not key.startswith("@")}


def main() -> int:
    template = L10N / "app_en.arb"
    if not template.exists():
        print(f"missing template ARB: {template}", file=sys.stderr)
        return 1

    expected = message_keys(template)
    failures: list[str] = []

    for path in sorted(L10N.glob("app_*.arb")):
        if path.name == "app_en.arb":
            continue
        actual = message_keys(path)
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        if missing or extra:
            failures.append(path.name)
            if missing:
                preview = ", ".join(missing[:8])
                suffix = "..." if len(missing) > 8 else ""
                print(f"{path.name}: missing {len(missing)} keys ({preview}{suffix})")
            if extra:
                preview = ", ".join(extra[:8])
                suffix = "..." if len(extra) > 8 else ""
                print(f"{path.name}: extra {len(extra)} keys ({preview}{suffix})")

    if failures:
        print(
            f"ARB key parity check failed for {len(failures)} locale(s). "
            "Sync keys with lib/l10n/app_en.arb.",
            file=sys.stderr,
        )
        return 1

    print(f"ARB key parity OK across {len(list(L10N.glob('app_*.arb'))) - 1} locales.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

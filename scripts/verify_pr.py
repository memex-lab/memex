#!/usr/bin/env python3
"""Run focused Memex regression scenarios selected from the Git diff."""
import argparse
import json
from pathlib import Path
import subprocess

SCENARIOS = {
    "capture": (("offline", "capture", "local_task", "chat_service", "file_system_service"),
                ("test/data/services/offline_capture_queue_test.dart",)),
    "voice": (("recording", "speech_transcription", "whisper_service", "vocal_tone", "lib/main.dart"),
              ("test/ui/main_screen/quick_recording_transcript_test.dart",)),
    "timeline": (("timeline", "card_cache", "card_dao", "file_system_service", "repositories/card.dart"),
                 ("test/data/repositories/timeline_pagination_property_test.dart",)),
    "images": (("asset_header_gallery", "local_image", "image_preview_cache"),
               ("test/ui/core/widgets/local_image_safety_test.dart",)),
    "comments": (("post_comment", "comment_reply", "timeline_comment", "timeline_card_detail", "repositories/card.dart"),
                 ("test/data/repositories/timeline_comment_journey_test.dart",)),
    "restore": (("backup", "restore", "lib/data/db/", "lib/db/", "migration", "lib/data/database"),
                ("test/data/services/backup_service_test.dart",
                 "test/ui/settings/widgets/backup_restore_page_test.dart")),
    "lock": (("app_lock", "root_shell", "privacy", "lib/main.dart"),
             ("test/ui/app_lock/app_lock_session_test.dart", "test/ui/app_lock/app_entry_pin_test.dart")),
    "agent": (("lib/agent/", "lib/data/agent", "permission", "built_in_tools"),
              ("test/agent/super_agent_permissions_test.dart",)),
    "startup": (("ios/", "android/", "lib/main.dart", "deep_link"),
                ("test/app_startup_test.dart",)),
}


def select(paths):
    return [name for name, (triggers, _) in SCENARIOS.items()
            if any(trigger in path for trigger in triggers for path in paths)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", default="origin/main")
    parser.add_argument("--report", type=Path, help="write the selected scenarios, revision and outcome")
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--scenario", choices=SCENARIOS, action="append")
    args = parser.parse_args()
    changed = subprocess.check_output(["git", "diff", "--no-renames", "--name-only", "-z",
                                       args.base], text=True).split("\0")
    changed += subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard",
                                        "-z"], text=True).split("\0")
    selected = args.scenario or select(changed)
    tests = sorted({test for name in selected for test in SCENARIOS[name][1]})
    print("Scenarios:", ", ".join(selected) or "none matched", flush=True)
    def report(status):
        if args.report:
            args.report.write_text(json.dumps({
                "base": subprocess.check_output(["git", "rev-parse", args.base], text=True).strip(),
                "checkout": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
                "scenarios": selected, "test_files": tests, "status": status,
            }, indent=2) + "\n", encoding="utf-8")
    report("not-selected" if not tests else "not-run")
    if tests and not args.list:
        for test in tests:
            if not Path(test).is_file():
                parser.exit(2, f"Missing scenario test: {test}\n")
        result = subprocess.run(["flutter", "test", "--no-pub", *tests])
        report("passed" if result.returncode == 0 else "failed")
        return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())

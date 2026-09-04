#!/usr/bin/env python3
"""Generate localized template gallery Dart files via machine translation."""

from __future__ import annotations

import json
import re
import sys
import time
from pathlib import Path

from deep_translator import GoogleTranslator

ROOT = Path(__file__).resolve().parents[1]
GALLERY = ROOT / "lib/l10n/gallery"
EN_FILE = GALLERY / "template_gallery_en.dart"
CACHE_FILE = Path(__file__).parent / ".template_gallery_translation_cache.json"

LOCALE_SUFFIX = {
    "de": "De",
    "ja": "Ja",
    "ko": "Ko",
    "es": "Es",
    "hi": "Hi",
    "ar": "Ar",
    "pt": "Pt",
    "fr": "Fr",
    "id": "Id",
    "fa": "Fa",
    "vi": "Vi",
    "th": "Th",
    "tr": "Tr",
    "ru": "Ru",
    "it": "It",
}

# Google Translate language codes
LOCALE_TARGET = {
    "de": "de",
    "ja": "ja",
    "ko": "ko",
    "es": "es",
    "hi": "hi",
    "ar": "ar",
    "pt": "pt",
    "fr": "fr",
    "id": "id",
    "fa": "fa",
    "vi": "vi",
    "th": "th",
    "tr": "tr",
    "ru": "ru",
    "it": "it",
}

SKIP_EXACT = {
    "default",
    "dark",
    "neutral",
    "online",
    "high",
    "up",
    "indigo",
    "emerald",
    "orange",
    "false",
    "true",
    "me",
    "flutter.dev",
    "Apple S9",
    "IP68",
    "Dart",
    "Flutter",
    "Memex",
    "AI",
    "Excited",
    "WEEKLY REVIEW",
    "DAILY INSIGHT",
    "template_gallery_models.dart",
    "Interstellar",
    "Napoleon Hill",
    "Peter Drucker",
    "Arthur C. Clarke",
    "Beijing",
    "Shanghai",
    "Alex Zhang",
    "Jan 22 - Jan 28, 2026",
    "2023.10.27",
    "2026-03-10T14:00:00",
    "2026-03-10T16:00:00",
    "00:30",
    "09:00",
    "12:30",
    "14:00",
    "¥ 38",
    "¥ 8",
    "¥ 22",
    "¥ 68.00",
    "500ml",
    "65%",
    "8.5h",
    "4.2h",
    "create it",
    "3 Photos",
    "1.9\" AMOLED",
    "45mm",
    "32g",
}

SKIP_PATTERN = re.compile(
    r"^(#|https?://|[0-9]+(\.[0-9]+)?%?$|[0-9]+(\.[0-9]+)?[h]?$|"
    r"[0-9]{4}-[0-9]{2}-[0-9]{2}|"
    r".*_card(_v1)?$|.*_v1$|classic_card|snippet|article|conversation|quote|"
    r"compact_card|snapshot|gallery|video|canvas|metric|rating|mood|progress|"
    r"event|duration|task|routine|procedure|person|place|spec_sheet|transaction|link)$"
)

STRING_RE = re.compile(r"'((?:\\'|[^'])*)'")


def should_translate(text: str) -> bool:
    if text in SKIP_EXACT:
        return False
    if text.startswith(("http://", "https://")):
        return False
    if len(text) <= 2:
        return False
    if SKIP_PATTERN.match(text):
        return False
    if re.fullmatch(r"[0-9.]+", text):
        return False
    if re.fullmatch(r"#[0-9A-Fa-f]{6}", text):
        return False
    # Mostly ASCII technical identifiers
    if re.fullmatch(r"[A-Za-z0-9_.\-]+", text) and text[0].islower():
        return False
    return True


def extract_strings(content: str) -> list[str]:
    seen: set[str] = set()
    strings: list[str] = []
    for match in STRING_RE.finditer(content):
        text = match.group(1)
        if should_translate(text) and text not in seen:
            seen.add(text)
            strings.append(text)
    return strings


def load_cache() -> dict[str, dict[str, str]]:
    if CACHE_FILE.exists():
        return json.loads(CACHE_FILE.read_text())
    return {}


def save_cache(cache: dict[str, dict[str, str]]) -> None:
    CACHE_FILE.write_text(json.dumps(cache, ensure_ascii=False, indent=2))


SHORT_WORD_OVERRIDES: dict[str, dict[str, str]] = {
    "ja": {"Completed": "完了", "Remaining": "残り", "Focus": "集中", "Mood": "気分", "Notes": "記録"},
    "ko": {"Completed": "완료", "Remaining": "남음", "Focus": "집중", "Mood": "기분", "Notes": "기록"},
    "zh": {"Completed": "已完成", "Remaining": "剩余"},
}

def translate_text(text: str, target: str, cache: dict[str, dict[str, str]]) -> str:
    locale_cache = cache.setdefault(target, {})
    if text in locale_cache:
        return locale_cache[text]
    override = SHORT_WORD_OVERRIDES.get(target, {}).get(text)
    if override:
        locale_cache[text] = override
        save_cache(cache)
        return override
    translator = GoogleTranslator(source="en", target=target)
    for attempt in range(3):
        try:
            translated = translator.translate(text)
            break
        except Exception:
            time.sleep(0.5 * (attempt + 1))
    else:
        # Keep English for untranslatable short tokens.
        translated = text
    locale_cache[text] = translated
    save_cache(cache)
    time.sleep(0.05)
    return translated


def dart_escape(text: str) -> str:
    escaped = text.replace("\\", "\\\\").replace("'", "\\'")
    # Keep common Dart escape sequences functional instead of rendering the
    # two characters "\\n" in localized multi-line gallery content.
    for sequence in ("n", "r", "t"):
        escaped = escaped.replace(f"\\\\{sequence}", f"\\{sequence}")
    return escaped


def apply_translations(content: str, mapping: dict[str, str]) -> str:
    result = content
    for source, target in sorted(mapping.items(), key=lambda kv: -len(kv[0])):
        if source != target:
            result = result.replace(f"'{source}'", f"'{dart_escape(target)}'")
    return result


def rename_constants(content: str, suffix: str) -> str:
    return (
        content.replace(
            "timelineTemplateGallerySectionsEn",
            f"timelineTemplateGallerySections{suffix}",
        ).replace(
            "insightTemplateGalleryItemsEn",
            f"insightTemplateGalleryItems{suffix}",
        )
    )


def generate_locale(locale: str, en_content: str, strings: list[str], cache: dict) -> None:
    target = LOCALE_TARGET[locale]
    suffix = LOCALE_SUFFIX[locale]
    out = GALLERY / f"template_gallery_{locale}.dart"
    mapping: dict[str, str] = {}
    print(f"Translating {len(strings)} strings to {locale}...")
    for i, text in enumerate(strings):
        if i % 20 == 0:
            print(f"  {locale}: {i}/{len(strings)}")
        mapping[text] = translate_text(text, target, cache)
    content = rename_constants(en_content, suffix)
    content = apply_translations(content, mapping)
    out.write_text(content)
    print(f"Wrote {out.name} ({len(content.splitlines())} lines)")


def main() -> None:
    en_content = EN_FILE.read_text()
    strings = extract_strings(en_content)
    print(f"Found {len(strings)} translatable strings")
    cache = load_cache()
    locales = sys.argv[1:] or list(LOCALE_SUFFIX)
    unsupported = sorted(set(locales) - set(LOCALE_SUFFIX))
    if unsupported:
        raise SystemExit(f"Unsupported locale(s): {', '.join(unsupported)}")
    for locale in locales:
        generate_locale(locale, en_content, strings, cache)
    print("Done.")


if __name__ == "__main__":
    main()

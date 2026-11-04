#!/usr/bin/env python3
"""Machine-translate the store listing in fastlane/metadata/android/en-US/ into every app locale.

English is the source: title.txt, short_description.txt, full_description.txt and
changelogs/<versionCode>.txt in en-US/. The title is a name and is copied as is.
Locale folders use Google Play's language codes (see LOCALES); F-Droid reads the same tree.

Usage:
  python3 scripts/mt_store_listings.py                          # all locales, all fields
  python3 scripts/mt_store_listings.py --locale de --locale sl  # app locale codes
  python3 scripts/mt_store_listings.py --field changelog        # only the newest changelog
  python3 scripts/mt_store_listings.py --check                  # only check lengths
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
METADATA = ROOT / "fastlane" / "metadata" / "android"
ENGLISH = METADATA / "en-US"

# App locale (values-<code>) to store folder. Google Play has no listing language for
# bs, ga and mt; their folders are for F-Droid and are skipped when uploading to Play.
LOCALES = {
    "ar": "ar", "bg": "bg", "bn": "bn-BD", "bs": "bs", "ca": "ca", "cs": "cs-CZ",
    "da": "da-DK", "de": "de-DE", "el": "el-GR", "es": "es-ES", "et": "et", "fa": "fa",
    "fi": "fi-FI", "fr": "fr-FR", "ga": "ga", "he": "iw-IL", "hi": "hi-IN", "hr": "hr",
    "hu": "hu-HU", "id": "id", "is": "is-IS", "it": "it-IT", "ja": "ja-JP", "ko": "ko-KR",
    "lt": "lt", "lv": "lv", "mk": "mk-MK", "mt": "mt", "nb": "no-NO", "nl": "nl-NL",
    "pl": "pl-PL", "pt": "pt-PT", "ro": "ro", "ru": "ru-RU", "sk": "sk", "sl": "sl",
    "sq": "sq", "sr": "sr", "sv": "sv-SE", "th": "th", "tr": "tr-TR", "uk": "uk",
    "ur": "ur", "vi": "vi", "zh": "zh-CN",
}

LIMITS = {"title.txt": 30, "short_description.txt": 80, "full_description.txt": 4000, "changelogs": 500}
FIELDS = ("short_description", "full_description", "changelog")


def newest_changelog(folder: Path) -> Path | None:
    logs = sorted((folder / "changelogs").glob("*.txt"), key=lambda p: int(p.stem))
    return logs[-1] if logs else None


def check_lengths() -> list[str]:
    problems = []
    for folder in sorted(p for p in METADATA.iterdir() if p.is_dir()):
        for name in ("title.txt", "short_description.txt", "full_description.txt"):
            path = folder / name
            if path.is_file() and len(path.read_text(encoding="utf-8").strip()) > LIMITS[name]:
                problems.append(f"{folder.name}/{name}: {len(path.read_text(encoding='utf-8').strip())} > {LIMITS[name]}")
        for log in (folder / "changelogs").glob("*.txt"):
            n = len(log.read_text(encoding="utf-8").strip())
            if n > LIMITS["changelogs"]:
                problems.append(f"{folder.name}/changelogs/{log.name}: {n} > {LIMITS['changelogs']}")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--locale", action="append", help="Only these app locale codes")
    parser.add_argument("--field", action="append", choices=FIELDS, help="Only these fields")
    parser.add_argument("--check", action="store_true", help="Only check the store length limits")
    args = parser.parse_args()

    if not args.check:
        sys.path.insert(0, str(SCRIPT_DIR))
        import mt_l10n_arbs as mt  # noqa: PLC0415

        mt.load_dotenv_file(ROOT / ".env")
        codes = args.locale or list(LOCALES)
        fields = args.field or list(FIELDS)
        log = newest_changelog(ENGLISH)
        source = {
            "short_description": (ENGLISH / "short_description.txt").read_text(encoding="utf-8").strip(),
            "full_description": (ENGLISH / "full_description.txt").read_text(encoding="utf-8").strip(),
            "changelog": log.read_text(encoding="utf-8").strip() if log else "",
        }
        title = (ENGLISH / "title.txt").read_text(encoding="utf-8").strip()

        deepl_key = os.environ.get("DEEPL_AUTH_KEY")
        deepl_targets = None
        if deepl_key:
            try:
                deepl_targets = mt.fetch_deepl_target_languages(deepl_key)
            except Exception:  # noqa: BLE001
                deepl_targets = None
        google_key = os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY")
        azure_key = os.environ.get("AZURE_TRANSLATOR_KEY")
        azure_region = os.environ.get("AZURE_TRANSLATOR_REGION")
        pacer = mt.RequestPacer(min_interval_s=mt.DEFAULT_MIN_INTERVAL_S)

        for code in codes:
            tag = LOCALES.get(code)
            if tag is None:
                print(f"{code}: not in LOCALES", file=sys.stderr)
                return 1
            backend = mt.pick_mt_backend(
                code,
                deepl_auth_key=deepl_key,
                deepl_targets=deepl_targets,
                google_api_key=google_key,
                azure_key=azure_key,
                azure_region=azure_region,
                prefer="deepl",
            )
            if backend is None:
                print("No MT credentials: set DEEPL_AUTH_KEY or Google/Azure keys (doc/L10N_MT_CLOUD.md).", file=sys.stderr)
                return 1
            translator = mt.make_translator(
                backend,
                code,
                mymemory_email=os.environ.get("MYMEMORY_EMAIL"),
                google_api_key=google_key,
                azure_key=azure_key,
                azure_region=azure_region,
                azure_endpoint=os.environ.get("AZURE_TRANSLATOR_ENDPOINT"),
                deepl_auth_key=deepl_key,
            )
            dest = METADATA / tag
            dest.mkdir(parents=True, exist_ok=True)
            (dest / "title.txt").write_text(title + "\n", encoding="utf-8")
            for field in fields:
                text = source[field]
                if not text:
                    continue
                translated = mt.translate_with_retry(translator, text, pacer).strip()
                if field == "changelog":
                    out = dest / "changelogs" / log.name
                    out.parent.mkdir(exist_ok=True)
                else:
                    out = dest / f"{field}.txt"
                out.write_text(translated + "\n", encoding="utf-8")
            print(f"Wrote {dest.relative_to(ROOT)} ({backend})")

    problems = check_lengths()
    for problem in problems:
        print(f"too long: {problem}", file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Machine-translate the store listing in fastlane/metadata/android/en-US/ into every app locale.

English is the source: title.txt, short_description.txt, full_description.txt and
changelogs/<versionCode>.txt in en-US/. The title is a name and is copied as is.
Locale folders use fastlane's language codes (see LOCALES); F-Droid reads the tree.

Usage:
  python3 scripts/mt_store_listings.py                          # all locales, all fields
  python3 scripts/mt_store_listings.py --locale de --locale sl  # app locale codes
  python3 scripts/mt_store_listings.py --field changelog        # only the newest changelog
  python3 scripts/mt_store_listings.py --check                  # only check lengths
"""
from __future__ import annotations

import argparse
import os
import re
import sys
import time
import unicodedata
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
METADATA = ROOT / "fastlane" / "metadata" / "android"
ENGLISH = METADATA / "en-US"

# App locale (values-<code>) to store folder.
LOCALES = {
    "af": "af", "ak": "ak", "am": "am", "an": "an", "ar": "ar", "as": "as", "ay": "ay",
    "az": "az-AZ", "b+es+419": "es-419", "b+zh+Hant": "zh-TW", "ba": "ba", "be": "be",
    "bg": "bg", "bm": "bm", "bn": "bn-BD", "br": "br", "bs": "bs", "ca": "ca",
    "cs": "cs-CZ", "cy": "cy", "da": "da-DK", "de": "de-DE", "dz": "dz", "ee": "ee",
    "el": "el-GR", "eo": "eo", "es": "es-ES", "et": "et", "eu": "eu-ES", "fa": "fa",
    "ff": "ff", "fi": "fi-FI", "fil": "fil", "fr": "fr-FR", "ga": "ga", "gd": "gd",
    "gl": "gl-ES", "gn": "gn", "gu": "gu", "ha": "ha", "he": "iw-IL", "hi": "hi-IN",
    "hr": "hr", "ht": "ht", "hu": "hu-HU", "hy": "hy-AM", "id": "id", "ig": "ig",
    "is": "is-IS", "it": "it-IT", "ja": "ja-JP", "jv": "jv", "ka": "ka-GE", "kk": "kk",
    "km": "km-KH", "kn": "kn-IN", "ko": "ko-KR", "ky": "ky-KG", "la": "la", "lb": "lb",
    "lg": "lg", "ln": "ln", "lo": "lo-LA", "lt": "lt", "lv": "lv", "mg": "mg",
    "mi": "mi", "mk": "mk-MK", "ml": "ml-IN", "mn": "mn-MN", "mr": "mr-IN", "ms": "ms",
    "mt": "mt", "my": "my-MM", "nb": "no-NO", "ne": "ne-NP", "nl": "nl-NL", "oc": "oc",
    "om": "om", "or": "or", "pa": "pa", "pl": "pl-PL", "ps": "ps", "pt": "pt-PT",
    "pt-rBR": "pt-BR", "qu": "qu", "rn": "rn", "ro": "ro", "ru": "ru-RU", "rw": "rw",
    "sa": "sa", "sg": "sg", "si": "si-LK", "sk": "sk", "sl": "sl", "sn": "sn",
    "so": "so", "sq": "sq", "sr": "sr", "st": "st", "su": "su", "sv": "sv-SE",
    "sw": "sw", "ta": "ta-IN", "te": "te-IN", "tg": "tg", "th": "th", "ti": "ti",
    "tk": "tk", "tn": "tn", "tr": "tr-TR", "ts": "ts", "tt": "tt", "uk": "uk",
    "ur": "ur", "uz": "uz", "vi": "vi", "wo": "wo", "xh": "xh", "yi": "yi", "yo": "yo",
    "zh": "zh-CN", "zu": "zu",
}

LIMITS = {"title.txt": 30, "short_description.txt": 80, "full_description.txt": 4000, "changelogs": 500}
FIELDS = ("short_description", "full_description", "changelog")


def newest_changelog(folder: Path) -> Path | None:
    logs = sorted((folder / "changelogs").glob("*.txt"), key=lambda p: int(p.stem))
    return logs[-1] if logs else None


PRODUCT_NAMES = ("Android Auto", "F-Droid")


def protect_names(text: str, names: list[str]) -> str:
    for i, name in enumerate(names):
        text = text.replace(name, f"⟦{i}⟧")
    return text


def restore_names(text: str, names: list[str]) -> str:
    """Some languages return the markers with native digits (⟦০⟧) or spaces inside."""
    text = re.sub(r"⟦\s*([^⟧\s]{1,3})\s*⟧", lambda m: f"⟦{ascii_digit(m.group(1))}⟧", text)
    for i, name in enumerate(names):
        text = text.replace(f"⟦{i}⟧", name)
    return text


def translate_lines(mt, translator, pacer, text: str, names: list[str]) -> str:
    """Translators merge and split lines; each line goes alone so headings, bullets and blank lines stay."""
    lines = text.splitlines()
    bodies = [protect_names(line.removeprefix("• "), names) for line in lines]
    for attempt in range(10):
        try:
            pacer.wait_turn()
            out = translator.translate_many(bodies)
            break
        except Exception as exc:  # noqa: BLE001
            if attempt == 9 or not (mt.is_rate_limit_error(exc) or re.search(r"HTTP 5\d\d", str(exc))):
                raise
            time.sleep(min(120.0, 2.0**attempt))
    result = []
    for line, body in zip(lines, out):
        body = restore_names(body.strip(), names) if line.strip() else ""
        result.append(f"• {body}" if line.startswith("• ") else body)
    return "\n".join(result).strip()


def ascii_digit(s: str) -> str:
    return "".join(str(unicodedata.digit(c)) if unicodedata.digit(c, None) is not None else c for c in s)


def check_lengths() -> list[str]:
    problems = []
    title = (ENGLISH / "title.txt").read_text(encoding="utf-8").strip()
    for folder in sorted(p for p in METADATA.iterdir() if p.is_dir()):
        logs = [f"changelogs/{p.name}" for p in (ENGLISH / "changelogs").glob("*.txt")]
        for name in ["short_description.txt", "full_description.txt", *logs]:
            source, path = ENGLISH / name, folder / name
            if path.is_file():
                bullets = [line.startswith("•") for line in source.read_text(encoding="utf-8").strip().splitlines()]
                got_bullets = [line.startswith("•") for line in path.read_text(encoding="utf-8").strip().splitlines()]
                if got_bullets != bullets:
                    problems.append(f"{folder.name}/{name}: lines or bullets differ from English")
                for product in (title, *PRODUCT_NAMES):
                    want = source.read_text(encoding="utf-8").count(product)
                    got = path.read_text(encoding="utf-8").count(product)
                    if got != want:
                        problems.append(f"{folder.name}/{name}: {product} {got}x, expected {want}x")
        for name in ("title.txt", "short_description.txt", "full_description.txt"):
            path = folder / name
            if path.is_file() and len(path.read_text(encoding="utf-8").strip()) > LIMITS[name]:
                problems.append(f"{folder.name}/{name}: too long, {len(path.read_text(encoding='utf-8').strip())} > {LIMITS[name]}")
        for log in (folder / "changelogs").glob("*.txt"):
            n = len(log.read_text(encoding="utf-8").strip())
            if n > LIMITS["changelogs"]:
                problems.append(f"{folder.name}/changelogs/{log.name}: too long, {n} > {LIMITS['changelogs']}")
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
                translated = translate_lines(mt, translator, pacer, text, [title, *PRODUCT_NAMES])
                if field == "changelog":
                    out = dest / "changelogs" / log.name
                    out.parent.mkdir(exist_ok=True)
                else:
                    out = dest / f"{field}.txt"
                out.write_text(translated + "\n", encoding="utf-8")
            print(f"Wrote {dest.relative_to(ROOT)} ({backend})")

    problems = check_lengths()
    for problem in problems:
        print(problem, file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main())

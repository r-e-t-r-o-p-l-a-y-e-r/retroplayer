#!/usr/bin/env python3
"""Machine-translate strings that are missing from app/src/main/res/values-*/strings_arb.xml.

English (values/strings_arb.xml) is the source. Each missing key is translated and
inserted after the key that precedes it in the English file. Existing translations are
never changed unless listed with --key and --force.

Usage:
  python3 scripts/mt_android_strings.py                       # all locales, missing keys
  python3 scripts/mt_android_strings.py --locale de --locale fr
  python3 scripts/mt_android_strings.py --key about_support --force
  python3 scripts/mt_android_strings.py --dry-run
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
RES = ROOT / "app" / "src" / "main" / "res"
ENGLISH = RES / "values" / "strings_arb.xml"

STRING = re.compile(r'^([ \t]*)<string name="([a-z0-9_]+)">(.*?)</string>\n', re.M | re.S)
FORMAT_ARG = re.compile(r"%(?:\d+\$)?[sd]|\n")


def parse_strings(xml: str) -> dict[str, str]:
    """Key to raw (escaped) resource value, in file order."""
    return {m.group(2): m.group(3) for m in STRING.finditer(xml)}


def android_unescape(raw: str) -> str:
    text = raw.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", '"').replace("&apos;", "'")
    text = text.replace("&amp;", "&")
    out, i = [], 0
    while i < len(text):
        c = text[i]
        if c == "\\" and i + 1 < len(text):
            nxt = text[i + 1]
            out.append({"n": "\n", "t": "\t"}.get(nxt, nxt))
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def android_escape(text: str) -> str:
    raw = text.replace("\\", "\\\\").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    raw = raw.replace("'", "\\'").replace('"', '\\"').replace("\n", "\\n").replace("\t", "\\t")
    if raw[:1] in ("@", "?"):
        raw = "\\" + raw
    return raw


def protect(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def repl(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"⟦{len(tokens) - 1}⟧"

    return FORMAT_ARG.sub(repl, text), tokens


def restore(text: str, tokens: list[str]) -> str:
    for i, token in enumerate(tokens):
        text = text.replace(f"⟦{i}⟧", token)
    return text


def insert_string(xml: str, key: str, raw: str, english_order: list[str]) -> str:
    """Insert or replace [key], placed after the nearest preceding English key in [xml]."""
    present = parse_strings(xml)
    line_for = lambda indent: f'{indent}<string name="{key}">{raw}</string>\n'  # noqa: E731
    if key in present:
        m = next(m for m in STRING.finditer(xml) if m.group(2) == key)
        return xml[: m.start()] + line_for(m.group(1)) + xml[m.end():]
    before = english_order[: english_order.index(key)]
    anchor = next((k for k in reversed(before) if k in present), None)
    matches = {m.group(2): m for m in STRING.finditer(xml)}
    if anchor is not None:
        m = matches[anchor]
        return xml[: m.end()] + line_for(m.group(1)) + xml[m.end():]
    first = next(iter(matches.values()), None)
    if first is not None:
        return xml[: first.start()] + line_for(first.group(1)) + xml[first.start():]
    end = xml.rindex("</resources>")
    return xml[:end] + line_for("    ") + xml[end:]


def locale_files() -> dict[str, Path]:
    return {
        p.parent.name.removeprefix("values-"): p
        for p in sorted(RES.glob("values-*/strings_arb.xml"))
    }


def main() -> int:
    sys.path.insert(0, str(SCRIPT_DIR))
    import mt_l10n_arbs as mt  # noqa: PLC0415

    mt.load_dotenv_file(ROOT / ".env")
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--locale", action="append", help="Only these locale codes")
    parser.add_argument("--key", action="append", help="Only these keys")
    parser.add_argument("--force", action="store_true", help="Also retranslate existing values of --key")
    parser.add_argument("--dry-run", action="store_true", help="List what would be translated")
    args = parser.parse_args()
    if args.force and not args.key:
        parser.error("--force needs --key")

    english = parse_strings(ENGLISH.read_text(encoding="utf-8"))
    order = list(english)
    files = locale_files()
    codes = args.locale or list(files)

    deepl_key = os.environ.get("DEEPL_AUTH_KEY")
    deepl_targets = None
    if deepl_key and not args.dry_run:
        try:
            deepl_targets = mt.fetch_deepl_target_languages(deepl_key)
        except Exception:  # noqa: BLE001
            deepl_targets = None
    google_key = os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY")
    azure_key = os.environ.get("AZURE_TRANSLATOR_KEY")
    azure_region = os.environ.get("AZURE_TRANSLATOR_REGION")
    pacer = mt.RequestPacer(min_interval_s=mt.DEFAULT_MIN_INTERVAL_S)

    failed = 0
    for code in codes:
        path = files.get(code)
        if path is None:
            print(f"{code}: no values-{code}/strings_arb.xml", file=sys.stderr)
            failed += 1
            continue
        xml = path.read_text(encoding="utf-8")
        present = parse_strings(xml)
        wanted = [k for k in order if (not args.key or k in args.key) and (k not in present or args.force)]
        if not wanted:
            continue
        if args.dry_run:
            print(f"{code}: {', '.join(wanted)}")
            continue
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
        for key in wanted:
            source, tokens = protect(android_unescape(english[key]))
            try:
                translated = restore(mt.translate_with_retry(translator, source, pacer), tokens).strip()
            except Exception as exc:  # noqa: BLE001
                print(f"{code}/{key}: {exc}", file=sys.stderr)
                failed += 1
                continue
            xml = insert_string(xml, key, android_escape(translated), order)
            print(f"{code}/{key} ({backend}): {translated}")
        path.write_text(xml, encoding="utf-8")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Write store-listings/<code>/ from store-listings/source.en.yaml via MT.

Usage:
  python3 scripts/mt_store_listings.py --write-en
  python3 scripts/mt_store_listings.py --backend auto --locale de --locale sl
  python3 scripts/mt_store_listings.py --backend mymemory --email you@example.com
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
ROOT = SCRIPT_DIR.parent
SOURCE = ROOT / "store-listings" / "source.en.json"
OUT_ROOT = ROOT / "store-listings"

sys.path.insert(0, str(SCRIPT_DIR))
import mt_l10n_arbs as mt  # noqa: E402

import json


def load_source() -> dict[str, str]:
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit("invalid source.en.json")
    out: dict[str, str] = {}
    for k, v in data.items():
        if isinstance(v, str):
            out[k] = v.strip()
        else:
            out[k] = str(v).strip()
    return out


def write_locale(locale: str, fields: dict[str, str]) -> None:
    dest = OUT_ROOT / locale
    dest.mkdir(parents=True, exist_ok=True)
    mapping = {
        "title.txt": "title",
        "short_description.txt": "short_description",
        "full_description.txt": "full_description",
        "whats_new.txt": "whats_new",
        "privacy_policy_url.txt": "privacy_policy_url",
    }
    for filename, key in mapping.items():
        text = fields.get(key, "")
        if text:
            (dest / filename).write_text(text + "\n", encoding="utf-8")


def translate_field(
    text: str,
    code: str,
    backend: mt.Backend,
    pacer: mt.RequestPacer,
    creds: dict,
) -> str:
    if not text.strip():
        return text
    translator = mt.make_translator(
        backend,
        code,
        mymemory_email=creds.get("mymemory_email"),
        google_api_key=creds.get("google_api_key"),
        azure_key=creds.get("azure_key"),
        azure_region=creds.get("azure_region"),
        azure_endpoint=creds.get("azure_endpoint"),
        deepl_auth_key=creds.get("deepl_auth_key"),
    )
    return mt.translate_with_retry(translator, text, pacer)


def main() -> int:
    mt.load_dotenv_file(ROOT / ".env")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--backend",
        choices=("auto", "google-cloud", "azure", "deepl", "google", "mymemory"),
        default="auto",
    )
    parser.add_argument("--locale", action="append", help="Only these codes")
    parser.add_argument(
        "--field",
        action="append",
        dest="fields",
        choices=(
            "title",
            "short_description",
            "full_description",
            "whats_new",
            "privacy_policy_url",
        ),
        help="Only translate these keys (repeatable; default: all except privacy_policy_url)",
    )
    parser.add_argument("--email", help="MyMemory contact email")
    parser.add_argument(
        "--write-en",
        action="store_true",
        help="Only refresh store-listings/en/ from YAML",
    )
    args = parser.parse_args()

    fields = load_source()
    write_locale("en", fields)
    print(f"Wrote {OUT_ROOT / 'en'}")

    if args.write_en:
        return 0

    backend_choice = mt.resolve_backend_choice(args.backend)
    if backend_choice != "auto":
        err = mt.validate_cloud_credentials(backend_choice)
        if err:
            return err

    deepl_key = os.environ.get("DEEPL_AUTH_KEY")
    deepl_targets: set[str] | None = None
    if deepl_key:
        try:
            deepl_targets = mt.fetch_deepl_target_languages(deepl_key)
        except Exception:
            deepl_targets = None

    creds = {
        "mymemory_email": args.email or os.environ.get("MYMEMORY_EMAIL"),
        "google_api_key": os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY"),
        "azure_key": os.environ.get("AZURE_TRANSLATOR_KEY"),
        "azure_region": os.environ.get("AZURE_TRANSLATOR_REGION"),
        "azure_endpoint": os.environ.get("AZURE_TRANSLATOR_ENDPOINT"),
        "deepl_auth_key": deepl_key,
    }

    codes = args.locale if args.locale else list(mt.CODES)
    default_keys = [
        "title",
        "short_description",
        "full_description",
        "whats_new",
    ]
    keys = args.fields if args.fields else default_keys
    pacer = mt.RequestPacer(min_interval_s=mt.DEFAULT_MIN_INTERVAL_S)

    for code in codes:
        if code == "en":
            continue
        if backend_choice == "auto":
            picked = mt.pick_mt_backend(
                code,
                deepl_auth_key=deepl_key,
                deepl_targets=deepl_targets,
                google_api_key=creds["google_api_key"],
                azure_key=creds["azure_key"],
                azure_region=creds["azure_region"],
                prefer="deepl",
            )
            if picked is None:
                picked = "mymemory"
            backend = picked
        else:
            backend = backend_choice

        translated: dict[str, str] = {}
        for key in keys:
            en = fields.get(key, "")
            if not en:
                continue
            try:
                translated[key] = translate_field(en, code, backend, pacer, creds)
            except Exception as exc:
                print(f"  {code}/{key}: {exc} — keeping English", file=sys.stderr)
                translated[key] = en
        # Merge with existing locale files so partial --field runs do not wipe other keys.
        dest = OUT_ROOT / code
        if dest.is_dir():
            mapping = {
                "title.txt": "title",
                "short_description.txt": "short_description",
                "full_description.txt": "full_description",
                "whats_new.txt": "whats_new",
                "privacy_policy_url.txt": "privacy_policy_url",
            }
            for filename, map_key in mapping.items():
                if map_key in translated:
                    continue
                path = dest / filename
                if path.is_file():
                    translated[map_key] = path.read_text(encoding="utf-8").strip()
        if "privacy_policy_url" not in translated:
            translated["privacy_policy_url"] = fields.get("privacy_policy_url", "")
        write_locale(code, translated)
        print(f"Wrote {OUT_ROOT / code} ({backend})")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

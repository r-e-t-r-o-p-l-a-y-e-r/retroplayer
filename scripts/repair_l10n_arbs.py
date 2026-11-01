#!/usr/bin/env python3
"""Repair ARB files after MT corrupted ICU / placeholders."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
TEMPLATE = L10N / "app_en.arb"

CORRUPT_MARK = "⟦"
ICU_PLURAL = ",plural,"


def message_keys(data: dict) -> list[str]:
    return [k for k in data if not k.startswith("@") and k != "@@locale"]


def placeholder_names(en: dict, key: str) -> list[str]:
    meta = en.get(f"@{key}")
    if not isinstance(meta, dict):
        return []
    ph = meta.get("placeholders")
    if not isinstance(ph, dict):
        return []
    return list(ph.keys())


def fix_numbered_placeholders(text: str, names: list[str]) -> str:
    for i, name in enumerate(names):
        text = text.replace(f"{{{i}}}", f"{{{name}}}")
    return text


def main() -> int:
    en = json.loads(TEMPLATE.read_text(encoding="utf-8"))
    fixed = 0
    for path in sorted(L10N.glob("app_*.arb")):
        if path.name == "app_en.arb":
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = False
        for key in message_keys(en):
            en_val = en.get(key)
            if not isinstance(en_val, str):
                continue
            cur = data.get(key)
            if not isinstance(cur, str):
                continue
            names = placeholder_names(en, key)
            if ICU_PLURAL in en_val:
                # Do not reset ICU to English; run mt_l10n_arbs.py --icu-only instead.
                if CORRUPT_MARK in cur:
                    new = en_val
                    changed = True
                    fixed += 1
                continue
            new = cur
            if CORRUPT_MARK in cur:
                new = en_val
                changed = True
                fixed += 1
            elif names:
                corrected = fix_numbered_placeholders(new, names)
                if corrected != new:
                    new = corrected
                    changed = True
                    fixed += 1
                for name in names:
                    if f"{{{name}}}" not in new and f"{{{name}}}" in en_val:
                        new = en_val
                        changed = True
                        fixed += 1
                        break
            if new != cur:
                data[key] = new
        if changed:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            print(path.name)
    print(f"Fixed {fixed} string(s). Re-run MT for simple strings or translate ICU manually.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

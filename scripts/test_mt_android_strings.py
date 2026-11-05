#!/usr/bin/env python3
"""Tests for mt_android_strings (run: python3 scripts/test_mt_android_strings.py)."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mt_android_strings import (  # noqa: E402
    android_escape,
    android_unescape,
    insert_string,
    parse_strings,
    protect,
    restore,
)

XML = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="a">A</string>
    <string name="c">C</string>
</resources>
"""


def test_escape_round_trip() -> None:
    text = "Don't \"quote\" & <b>\nnext"
    assert android_unescape(android_escape(text)) == text
    assert android_escape("@home") == "\\@home"


def test_unescape_resource_value() -> None:
    assert android_unescape("It\\'s A &amp; B\\nC") == "It's A & B\nC"


def test_format_args_and_newlines_are_protected() -> None:
    source, tokens = protect("%1$d tracks\nin %2$s")
    assert "%" not in source and "\n" not in source
    assert restore(source, tokens) == "%1$d tracks\nin %2$s"


def test_missing_key_goes_after_its_english_predecessor() -> None:
    out = insert_string(XML, "b", "B", ["a", "b", "c"])
    assert list(parse_strings(out)) == ["a", "b", "c"]
    assert '    <string name="b">B</string>\n' in out


def test_key_before_all_others_goes_first() -> None:
    out = insert_string(XML, "z", "Z", ["z", "a", "c"])
    assert list(parse_strings(out)) == ["z", "a", "c"]


def test_existing_key_is_replaced_in_place() -> None:
    out = insert_string(XML, "c", "C2", ["a", "c"])
    assert parse_strings(out) == {"a": "A", "c": "C2"}


if __name__ == "__main__":
    for name, fn in list(globals().items()):
        if name.startswith("test_") and callable(fn):
            fn()
    print("ok")

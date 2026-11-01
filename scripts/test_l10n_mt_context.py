#!/usr/bin/env python3
"""Tests for l10n_mt_context (run: python3 scripts/test_l10n_mt_context.py)."""
from __future__ import annotations

import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from l10n_mt_context import (  # noqa: E402
    mt_context_from_en,
    unwrap_cloud_mt,
    wrap_for_cloud_mt,
)


def test_mt_context_from_description() -> None:
    en = {
        "eqBass": "Bass",
        "@eqBass": {"description": "Equalizer preset, not the fish."},
    }
    assert mt_context_from_en(en, "eqBass") == "Equalizer preset, not the fish."


def test_wrap_and_unwrap() -> None:
    wrapped = wrap_for_cloud_mt("Bass", "Equalizer preset.")
    assert wrapped.startswith("Bass\n")
    assert unwrap_cloud_mt("Bas\n[Context: …]", was_wrapped=True) == "Bas"


def test_skip_wrap_for_placeholders() -> None:
    assert wrap_for_cloud_mt("Error: {message}", "ctx") == "Error: {message}"


def main() -> None:
    test_mt_context_from_description()
    test_wrap_and_unwrap()
    test_skip_wrap_for_placeholders()
    print("OK")


if __name__ == "__main__":
    main()

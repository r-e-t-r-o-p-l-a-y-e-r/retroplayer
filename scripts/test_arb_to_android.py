#!/usr/bin/env python3
"""Tests for arb_to_android (run: python3 scripts/test_arb_to_android.py)."""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from arb_to_android import (  # noqa: E402
    ConversionError,
    android_escape,
    convert_message,
    generate,
    qualifier,
    resource_name,
)


class ResourceNameTest(unittest.TestCase):
    def test_camel_case_becomes_snake_case(self) -> None:
        self.assertEqual(resource_name("playlistTrackCount"), "playlist_track_count")
        self.assertEqual(resource_name("eqBass"), "eq_bass")
        self.assertEqual(resource_name("about"), "about")
        self.assertEqual(resource_name("openURL"), "open_url")
        self.assertEqual(resource_name("track2Title"), "track2_title")


class QualifierTest(unittest.TestCase):
    def test_locale_folders(self) -> None:
        self.assertEqual(qualifier("en", default="en"), "values")
        self.assertEqual(qualifier("de", default="en"), "values-de")
        self.assertEqual(qualifier("pt_BR", default="en"), "values-pt-rBR")
        self.assertEqual(qualifier("zh_Hant", default="en"), "values-b+zh+Hant")


class EscapeTest(unittest.TestCase):
    def test_android_specials_are_escaped(self) -> None:
        self.assertEqual(android_escape("It's \"ok\""), "It\\'s \\\"ok\\\"")
        self.assertEqual(android_escape("@home"), "\\@home")
        self.assertEqual(android_escape("?why"), "\\?why")
        self.assertEqual(android_escape("a\nb"), "a\\nb")
        self.assertEqual(android_escape("tab\there"), "tab\\there")
        self.assertEqual(android_escape("back\\slash"), "back\\\\slash")
        self.assertEqual(android_escape("5 < 6 & 7"), "5 &lt; 6 &amp; 7")

    def test_leading_and_trailing_spaces_survive(self) -> None:
        self.assertEqual(android_escape(" x "), "\\u0020x\\u0020")


class ConvertMessageTest(unittest.TestCase):
    def test_plain_text(self) -> None:
        self.assertEqual(convert_message("Bass", []), ("string", "Bass"))

    def test_percent_is_literal_without_placeholders(self) -> None:
        self.assertEqual(convert_message("100%", []), ("string", "100%"))

    def test_placeholders_become_positional_format_args(self) -> None:
        kind, text = convert_message("{count} tracks · {artist}", [("count", "int"), ("artist", "String")])
        self.assertEqual(kind, "string")
        self.assertEqual(text, "%1$d tracks · %2$s")

    def test_placeholder_order_follows_the_template_not_the_translation(self) -> None:
        _, text = convert_message("{artist}: {count}", [("count", "int"), ("artist", "String")])
        self.assertEqual(text, "%2$s: %1$d")

    def test_percent_is_doubled_with_placeholders(self) -> None:
        _, text = convert_message("{count}%", [("count", "int")])
        self.assertEqual(text, "%1$d%%")

    def test_numeric_entities_are_decoded(self) -> None:
        self.assertEqual(convert_message("a&#10;&#10;b", []), ("string", "a\n\nb"))

    def test_exact_plural_branches(self) -> None:
        kind, branches = convert_message(
            "{count,plural, =0{Select tracks} =1{1 selected} other{{count} selected}}",
            [("count", "int")],
        )
        self.assertEqual(kind, "plural")
        self.assertEqual(branches, {"eq0": "Select tracks", "eq1": "1 selected", "other": "%1$d selected"})

    def test_keyword_plurals_are_rejected(self) -> None:
        with self.assertRaises(ConversionError):
            convert_message("{count,plural, one{# track} few{# tracks} other{# tracks}}", [("count", "int")])

    def test_select_and_unknown_placeholders_are_rejected(self) -> None:
        with self.assertRaises(ConversionError):
            convert_message("{gender,select, male{He} other{They}}", [("gender", "String")])
        with self.assertRaises(ConversionError):
            convert_message("Hi {name}", [])


class GenerateTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp())
        self.arb = self.tmp / "arb"
        self.res = self.tmp / "res"
        self.arb.mkdir()
        self.write("en", {
            "@@locale": "en",
            "eqBass": "Bass",
            "@eqBass": {"description": "label"},
            "tracksCount": "{count,plural, =1{1 track} other{{count} tracks}}",
            "@tracksCount": {"placeholders": {"count": {"type": "int"}}},
            "hello": "Hello {name}",
            "@hello": {"placeholders": {"name": {"type": "String"}}},
        })
        self.write("de", {
            "@@locale": "de",
            "eqBass": "Bässe",
            "tracksCount": "{count,plural, =1{1 Titel} other{{count} Titel}}",
            "hello": "Hallo {name}",
        })

    def write(self, locale: str, data: dict) -> None:
        (self.arb / f"app_{locale}.arb").write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")

    def test_writes_default_and_locale_resources_and_locale_config(self) -> None:
        files = generate(self.arb, self.res, template="en")
        self.assertEqual(
            sorted(str(p.relative_to(self.res)) for p in files),
            ["values-de/strings_arb.xml", "values/strings_arb.xml", "xml/locales_config.xml"],
        )
        default = files[self.res / "values/strings_arb.xml"]
        self.assertIn('<string name="eq_bass">Bass</string>', default)
        self.assertIn('<string name="tracks_count_eq1">1 track</string>', default)
        self.assertIn('<string name="tracks_count_other">%1$d tracks</string>', default)
        self.assertIn('<string name="hello">Hello %1$s</string>', default)
        self.assertIn("GENERATED", default)
        german = files[self.res / "values-de/strings_arb.xml"]
        self.assertIn('<string name="eq_bass">Bässe</string>', german)
        config = files[self.res / "xml/locales_config.xml"]
        self.assertIn('<locale android:name="en"/>', config)
        self.assertIn('<locale android:name="de"/>', config)

    def test_output_is_deterministic(self) -> None:
        self.assertEqual(generate(self.arb, self.res, template="en"), generate(self.arb, self.res, template="en"))

    def test_missing_translation_falls_back_to_the_template(self) -> None:
        self.write("fr", {"@@locale": "fr", "eqBass": "Basses"})
        french = generate(self.arb, self.res, template="en")[self.res / "values-fr/strings_arb.xml"]
        self.assertIn("eq_bass", french)
        self.assertNotIn("hello", french)

    def test_translation_with_extra_placeholder_fails(self) -> None:
        self.write("fr", {"@@locale": "fr", "eqBass": "Basses {oops}"})
        with self.assertRaises(ConversionError):
            generate(self.arb, self.res, template="en")


if __name__ == "__main__":
    unittest.main()

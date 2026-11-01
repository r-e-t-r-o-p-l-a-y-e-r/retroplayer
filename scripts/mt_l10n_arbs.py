#!/usr/bin/env python3
"""Machine-translate app_en.arb strings into other app_XX.arb files.

Backends:
  - **google-cloud** — Cloud Translation API v2 (~173k chars fits free tier).
  - **azure** — Azure Translator Text API v3.
  - **deepl** — DeepL API v2 (high quality; not all app locales supported).
  - **mymemory** — free MyMemory API (daily quota).
  - **google** — unofficial Google scraper via deep-translator (often blocked).

Preserves ARB metadata keys and placeholders like {name} / ICU plurals.

Usage:
  python3 scripts/mt_l10n_arbs.py --backend google-cloud
  python3 scripts/mt_l10n_arbs.py --backend azure
  python3 scripts/mt_l10n_arbs.py --backend mymemory --email you@example.com
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path
from typing import Callable, Literal, Protocol

import requests

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))
from icu_arb import translate_icu_plural  # noqa: E402
from l10n_mt_context import (  # noqa: E402
    mt_context_from_en,
    unwrap_cloud_mt,
    wrap_for_cloud_mt,
)

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / "lib" / "l10n"
TEMPLATE = L10N / "app_en.arb"

Backend = Literal["google", "mymemory", "google-cloud", "azure", "deepl"]

GOOGLE_MAX_PACK_CHARS = 3200
MYMEMORY_MAX_PACK_CHARS = 420
MYMEMORY_MAX_SINGLE_CHARS = 480
CLOUD_BATCH_SIZE = 100
CLOUD_MAX_CHARS_PER_REQUEST = 90_000

DEFAULT_MIN_INTERVAL_S = 0.05

CODES = [
    "zh", "hi", "es", "fr", "ar", "bn", "pt", "ru", "ja", "de", "ko", "tr", "vi",
    "it", "id", "pl", "nl", "ur", "fa", "he", "th", "uk", "ro", "el", "cs", "sv",
    "hu", "da", "fi", "nb", "is", "bg", "hr", "sk", "sl", "sr", "lt", "lv", "et",
    "ga", "mt", "sq", "mk", "bs", "ca",
]

GOOGLE_CLOUD_TARGET = {
    "nb": "no",
    "zh": "zh-CN",
}

AZURE_TARGET = {
    "zh": "zh-Hans",
    "nb": "nb",
    "sr": "sr-Latn",
    "he": "he",
}

# DeepL target_lang codes (see developers.deepl.com supported languages)
DEEPL_TARGET = {
    "zh": "ZH-HANS",
    "nb": "NB",
    "pt": "PT-PT",
}

MYMEMORY_TARGET = {
    "zh": "chinese simplified",
    "nb": "norwegian bokmål",
    "ga": "irish gaelic",
    "he": "hebrew",
    "pt": "portuguese",
    "id": "indonesian",
    "vi": "vietnamese",
    "uk": "ukrainian",
    "el": "greek",
    "da": "danish",
    "sv": "swedish",
    "sr": "serbian latin",
    "sl": "slovenian",
    "sq": "albanian",
    "mk": "macedonian",
    "bs": "bosnian",
    "ca": "catalan",
    "hi": "hindi",
    "es": "spanish",
    "fr": "french",
    "ar": "arabic",
    "bn": "bengali",
    "ru": "russian",
    "ja": "japanese",
    "de": "german",
    "ko": "korean",
    "tr": "turkish",
    "it": "italian",
    "pl": "polish",
    "nl": "dutch",
    "ur": "urdu",
    "fa": "persian",
    "th": "thai",
    "ro": "romanian",
    "cs": "czech",
    "hu": "hungarian",
    "fi": "finnish",
    "is": "icelandic",
    "bg": "bulgarian",
    "hr": "croatian",
    "sk": "slovak",
    "lt": "lithuanian",
    "lv": "latvian",
    "et": "estonian",
    "mt": "maltese",
}

BRAND_KEEP = {"appTitle": "Retro Player"}

PLACEHOLDER = re.compile(
    r"\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}"
)

RATE_LIMIT_MARKERS = (
    "too many requests",
    "429",
    "rate limit",
    "slow down",
)

MYMEMORY_RESET_RE = re.compile(
    r"NEXT AVAILABLE IN\s+(\d+)\s+HOURS\s+(\d+)\s+MINUTES(?:\s+(\d+)\s+SECONDS)?",
    re.IGNORECASE,
)


class Translator(Protocol):
    def translate(self, text: str) -> str: ...


class BatchTranslator(Protocol):
    def translate_many(self, texts: list[str]) -> list[str]: ...


class MyMemoryQuotaError(Exception):
    """Daily / anonymous MyMemory quota exhausted."""


class GoogleCloudTranslator:
    """Cloud Translation API v2 (REST + API key)."""

    _URL = "https://translation.googleapis.com/language/translate/v2"

    def __init__(self, target: str, api_key: str) -> None:
        self._target = target
        self._api_key = api_key

    def translate(self, text: str) -> str:
        return self.translate_many([text])[0]

    def translate_many(self, texts: list[str]) -> list[str]:
        if not texts:
            return []
        results: list[str | None] = [None] * len(texts)
        pending_idx: list[int] = []
        pending_text: list[str] = []
        pending_chars = 0

        def flush() -> None:
            nonlocal pending_idx, pending_text, pending_chars
            if not pending_text:
                return
            for i, translated in zip(
                pending_idx, self._post_batch(pending_text)
            ):
                results[i] = translated
            pending_idx = []
            pending_text = []
            pending_chars = 0

        for i, text in enumerate(texts):
            if not text.strip():
                results[i] = text
                continue
            if pending_text and (
                len(pending_text) >= CLOUD_BATCH_SIZE
                or pending_chars + len(text) > CLOUD_MAX_CHARS_PER_REQUEST
            ):
                flush()
            pending_idx.append(i)
            pending_text.append(text)
            pending_chars += len(text)
        flush()
        return [r if r is not None else "" for r in results]

    def _post_batch(self, texts: list[str]) -> list[str]:
        response = requests.post(
            self._URL,
            params={"key": self._api_key},
            json={
                "q": texts,
                "source": "en",
                "target": self._target,
                "format": "text",
            },
            timeout=120,
        )
        if response.status_code == 429:
            raise RuntimeError(f"Google Cloud rate limit: {response.text[:200]}")
        if not response.ok:
            raise RuntimeError(
                f"Google Cloud HTTP {response.status_code}: {response.text[:300]}"
            )
        data = response.json()
        translations = data.get("data", {}).get("translations", [])
        if len(translations) != len(texts):
            raise RuntimeError(
                f"Google Cloud batch size mismatch: {len(texts)} vs {len(translations)}"
            )
        return [t["translatedText"] for t in translations]


class DeepLTranslator:
    """DeepL API v2 (batch text in one request)."""

    _MAX_REQUEST_BYTES = 120_000

    def __init__(self, target_lang: str, auth_key: str) -> None:
        self._target = target_lang
        self._auth_key = auth_key
        self._base = deepl_api_base(auth_key)

    def translate(self, text: str) -> str:
        return self.translate_many([text])[0]

    def translate_many(self, texts: list[str]) -> list[str]:
        if not texts:
            return []
        results: list[str | None] = [None] * len(texts)
        pending_idx: list[int] = []
        pending_text: list[str] = []
        pending_bytes = 0

        def flush() -> None:
            nonlocal pending_idx, pending_text, pending_bytes
            if not pending_text:
                return
            for i, translated in zip(
                pending_idx, self._post_batch(pending_text)
            ):
                results[i] = translated
            pending_idx = []
            pending_text = []
            pending_bytes = 0

        for i, text in enumerate(texts):
            if not text.strip():
                results[i] = text
                continue
            encoded = len(text.encode("utf-8"))
            if pending_text and (
                len(pending_text) >= CLOUD_BATCH_SIZE
                or pending_bytes + encoded > self._MAX_REQUEST_BYTES
            ):
                flush()
            pending_idx.append(i)
            pending_text.append(text)
            pending_bytes += encoded
        flush()
        return [r if r is not None else "" for r in results]

    def translate_many_with_contexts(
        self, texts: list[str], contexts: list[str | None]
    ) -> list[str]:
        if len(texts) != len(contexts):
            raise ValueError("texts and contexts length mismatch")
        if not texts:
            return []
        results: list[str | None] = [None] * len(texts)
        by_ctx: dict[str | None, list[tuple[int, str]]] = {}
        for i, (text, ctx) in enumerate(zip(texts, contexts)):
            if not text.strip():
                results[i] = text
                continue
            by_ctx.setdefault(ctx, []).append((i, text))
        for ctx, chunk in by_ctx.items():
            indices = [t[0] for t in chunk]
            batch_texts = [t[1] for t in chunk]
            translated = self._post_batch(batch_texts, context=ctx)
            for idx, out in zip(indices, translated):
                results[idx] = out
        return [r if r is not None else "" for r in results]

    def _post_batch(
        self, texts: list[str], *, context: str | None = None
    ) -> list[str]:
        body: dict = {
            "text": texts,
            "source_lang": "EN",
            "target_lang": self._target,
        }
        if context:
            body["context"] = context
        response = requests.post(
            f"{self._base}/v2/translate",
            headers={
                "Authorization": f"DeepL-Auth-Key {self._auth_key}",
                "Content-Type": "application/json",
            },
            json=body,
            timeout=120,
        )
        if response.status_code == 456:
            raise RuntimeError(
                "DeepL quota exhausted (456). Check usage or upgrade plan."
            )
        if response.status_code == 429:
            raise RuntimeError(f"DeepL rate limit: {response.text[:200]}")
        if not response.ok:
            raise RuntimeError(
                f"DeepL HTTP {response.status_code}: {response.text[:300]}"
            )
        data = response.json()
        translations = data.get("translations", [])
        if len(translations) != len(texts):
            raise RuntimeError(
                f"DeepL batch size mismatch: {len(texts)} vs {len(translations)}"
            )
        return [t["text"] for t in translations]


class AzureTranslator:
    """Azure AI Translator Text API v3."""

    def __init__(
        self,
        target: str,
        subscription_key: str,
        region: str,
        *,
        endpoint: str = "https://api.cognitive.microsofttranslator.com",
    ) -> None:
        self._target = target
        self._key = subscription_key
        self._region = region
        self._endpoint = endpoint.rstrip("/")

    def translate(self, text: str) -> str:
        return self.translate_many([text])[0]

    def translate_many(self, texts: list[str]) -> list[str]:
        if not texts:
            return []
        results: list[str | None] = [None] * len(texts)
        pending_idx: list[int] = []
        pending_text: list[str] = []
        pending_chars = 0

        def flush() -> None:
            nonlocal pending_idx, pending_text, pending_chars
            if not pending_text:
                return
            for i, translated in zip(
                pending_idx, self._post_batch(pending_text)
            ):
                results[i] = translated
            pending_idx = []
            pending_text = []
            pending_chars = 0

        for i, text in enumerate(texts):
            if not text.strip():
                results[i] = text
                continue
            if pending_text and (
                len(pending_text) >= CLOUD_BATCH_SIZE
                or pending_chars + len(text) > CLOUD_MAX_CHARS_PER_REQUEST
            ):
                flush()
            pending_idx.append(i)
            pending_text.append(text)
            pending_chars += len(text)
        flush()
        return [r if r is not None else "" for r in results]

    def _post_batch(self, texts: list[str]) -> list[str]:
        url = (
            f"{self._endpoint}/translate"
            f"?api-version=3.0&from=en&to={self._target}"
        )
        headers = {
            "Ocp-Apim-Subscription-Key": self._key,
            "Ocp-Apim-Subscription-Region": self._region,
            "Content-Type": "application/json",
        }
        body = [{"Text": t} for t in texts]
        response = requests.post(url, headers=headers, json=body, timeout=120)
        if response.status_code == 429:
            raise RuntimeError(f"Azure rate limit: {response.text[:200]}")
        if not response.ok:
            raise RuntimeError(
                f"Azure HTTP {response.status_code}: {response.text[:300]}"
            )
        data = response.json()
        if len(data) != len(texts):
            raise RuntimeError(
                f"Azure batch size mismatch: {len(texts)} vs {len(data)}"
            )
        return [row["translations"][0]["text"] for row in data]


class MyMemoryClient:
    _URL = "https://api.mymemory.translated.net/get"

    def __init__(self, target_language_name: str, email: str | None) -> None:
        from deep_translator.constants import MY_MEMORY_LANGUAGES_TO_CODES

        self._src = MY_MEMORY_LANGUAGES_TO_CODES["english"]
        self._tgt = MY_MEMORY_LANGUAGES_TO_CODES[target_language_name]
        self._email = email

    def translate(self, text: str) -> str:
        if not text.strip():
            return text
        params: dict[str, str] = {
            "q": text,
            "langpair": f"{self._src}|{self._tgt}",
        }
        if self._email:
            params["de"] = self._email
        response = requests.get(self._URL, params=params, timeout=60)
        try:
            data = response.json()
        except json.JSONDecodeError as exc:
            raise RuntimeError(
                f"MyMemory returned non-JSON (HTTP {response.status_code})"
            ) from exc
        translated = (data.get("responseData") or {}).get("translatedText") or ""
        upper = translated.upper()
        if response.status_code == 429 or "MYMEMORY WARNING" in upper:
            raise MyMemoryQuotaError(
                translated.strip()
                or f"MyMemory HTTP {response.status_code} (daily quota?)"
            )
        if not translated.strip():
            raise RuntimeError("MyMemory returned an empty translation")
        return translated.strip()


class RequestPacer:
    def __init__(self, min_interval_s: float) -> None:
        self._min_interval_s = min_interval_s
        self._last_at = 0.0

    def wait_turn(self) -> None:
        now = time.monotonic()
        elapsed = now - self._last_at
        if elapsed < self._min_interval_s:
            time.sleep(self._min_interval_s - elapsed)
        self._last_at = time.monotonic()


def protect_placeholders(text: str) -> tuple[str, list[str]]:
    tokens: list[str] = []

    def repl(match: re.Match[str]) -> str:
        tokens.append(match.group(0))
        return f"⟦{len(tokens) - 1}⟧"

    return PLACEHOLDER.sub(repl, text), tokens


def restore_placeholders(text: str, tokens: list[str]) -> str:
    for i, token in enumerate(tokens):
        text = text.replace(f"⟦{i}⟧", token)
    return text


def message_keys(data: dict) -> list[str]:
    return [k for k in data if not k.startswith("@") and k != "@@locale"]


def load_arb(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def write_arb(path: Path, data: dict) -> None:
    path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


EQ_PRESET_KEYS = ("eqManually", "eqBass", "eqTreble", "eqVoice")


def _first_is_latin_letter(text: str) -> bool:
    if not text:
        return False
    ch = text[0]
    return ch.isascii() and ch.isalpha()


def harmonize_eq_preset_label_caps(data: dict) -> None:
    """Latin preset labels: match majority capitalization (segmented control)."""
    labeled: list[tuple[str, str]] = [
        (k, data[k])
        for k in EQ_PRESET_KEYS
        if isinstance(data.get(k), str) and data[k]
    ]
    latin = [(k, v) for k, v in labeled if _first_is_latin_letter(v)]
    if len(latin) < 2:
        return
    upper = sum(1 for _, v in latin if v[0].isupper())
    if upper * 2 >= len(latin):
        for key, value in latin:
            if value[0].islower():
                data[key] = value[0].upper() + value[1:]


def parse_mymemory_reset_seconds(message: str) -> int | None:
    match = MYMEMORY_RESET_RE.search(message)
    if not match:
        return None
    hours, minutes, seconds = match.groups()
    return int(hours) * 3600 + int(minutes) * 60 + int(seconds or 0)


def is_rate_limit_error(exc: BaseException) -> bool:
    msg = str(exc).lower()
    return any(marker in msg for marker in RATE_LIMIT_MARKERS)


def deepl_api_base(auth_key: str) -> str:
    """Free keys use api-free.deepl.com; Pro keys use api.deepl.com."""
    if auth_key.rstrip().endswith(":fx"):
        return "https://api-free.deepl.com"
    return "https://api.deepl.com"


def deepl_target_for(code: str) -> str:
    return DEEPL_TARGET.get(code, code).upper()


def fetch_deepl_target_languages(auth_key: str) -> set[str]:
    base = deepl_api_base(auth_key)
    response = requests.get(
        f"{base}/v2/languages",
        params={"type": "target"},
        headers={"Authorization": f"DeepL-Auth-Key {auth_key}"},
        timeout=60,
    )
    if not response.ok:
        raise RuntimeError(
            f"DeepL languages HTTP {response.status_code}: {response.text[:200]}"
        )
    return {row["language"].upper() for row in response.json()}


def mymemory_target_name(code: str) -> str:
    if code in MYMEMORY_TARGET:
        return MYMEMORY_TARGET[code]
    raise ValueError(f"No MyMemory language mapping for locale {code!r}")


def target_label_for(backend: Backend, code: str) -> str:
    if backend == "deepl":
        return deepl_target_for(code)
    if backend == "azure":
        return AZURE_TARGET.get(code, code)
    if backend in ("google", "google-cloud"):
        return GOOGLE_CLOUD_TARGET.get(code, code)
    return mymemory_target_name(code)


def make_translator(
    backend: Backend,
    code: str,
    *,
    mymemory_email: str | None,
    google_api_key: str | None,
    azure_key: str | None,
    azure_region: str | None,
    azure_endpoint: str | None,
    deepl_auth_key: str | None,
) -> Translator:
    if backend == "deepl":
        if not deepl_auth_key:
            raise RuntimeError("DEEPL_AUTH_KEY is not set")
        return DeepLTranslator(deepl_target_for(code), deepl_auth_key)
    if backend == "google-cloud":
        if not google_api_key:
            raise RuntimeError("GOOGLE_CLOUD_TRANSLATE_API_KEY is not set")
        return GoogleCloudTranslator(
            GOOGLE_CLOUD_TARGET.get(code, code),
            google_api_key,
        )
    if backend == "azure":
        if not azure_key or not azure_region:
            raise RuntimeError(
                "AZURE_TRANSLATOR_KEY and AZURE_TRANSLATOR_REGION must be set"
            )
        return AzureTranslator(
            AZURE_TARGET.get(code, code),
            azure_key,
            azure_region,
            endpoint=azure_endpoint or "https://api.cognitive.microsofttranslator.com",
        )
    if backend == "google":
        from deep_translator import GoogleTranslator

        return GoogleTranslator(
            source="en",
            target=GOOGLE_CLOUD_TARGET.get(code, code),
        )
    return MyMemoryClient(mymemory_target_name(code), mymemory_email)


def backend_limits(backend: Backend) -> tuple[int, int]:
    if backend == "mymemory":
        return MYMEMORY_MAX_PACK_CHARS, MYMEMORY_MAX_SINGLE_CHARS
    return GOOGLE_MAX_PACK_CHARS, 4500


def uses_batch_api(backend: Backend) -> bool:
    return backend in ("google-cloud", "azure", "deepl")


def translate_with_retry(
    translator: Translator,
    text: str,
    pacer: RequestPacer,
    *,
    max_retries: int = 10,
) -> str:
    last_error: BaseException | None = None
    for attempt in range(max_retries):
        try:
            pacer.wait_turn()
            return translator.translate(text)
        except MyMemoryQuotaError:
            raise
        except Exception as exc:
            last_error = exc
            if not is_rate_limit_error(exc):
                raise
            backoff = min(120.0, 2.0**attempt)
            print(
                f"  rate limited (attempt {attempt + 1}/{max_retries}), "
                f"sleep {backoff:.0f}s …",
                flush=True,
            )
            time.sleep(backoff)
    raise RuntimeError(f"translate failed after retries: {last_error}")


def split_for_max_chars(text: str, max_chars: int) -> list[str]:
    if len(text) <= max_chars:
        return [text]
    if "\n" in text:
        parts: list[str] = []
        for line in text.split("\n"):
            parts.extend(split_for_max_chars(line, max_chars) if line else [""])
        return parts
    chunks: list[str] = []
    start = 0
    while start < len(text):
        chunks.append(text[start : start + max_chars])
        start += max_chars
    return chunks


def translate_one_payload(
    translator: Translator,
    text: str,
    pacer: RequestPacer,
    max_single_chars: int,
) -> str:
    parts = split_for_max_chars(text, max_single_chars)
    if len(parts) == 1:
        return translate_with_retry(translator, text, pacer)
    translated = [
        translate_with_retry(translator, part, pacer) if part else part
        for part in parts
    ]
    if "\n" in text and all("\n" not in p for p in parts):
        return "\n".join(translated)
    return "".join(translated)


def pack_single_line_strings(
    payloads: list[str],
    max_pack_chars: int,
    max_single_chars: int,
) -> list[list[int]]:
    groups: list[list[int]] = []
    current: list[int] = []
    current_len = 0
    for i, text in enumerate(payloads):
        if "\n" in text or len(text) > max_single_chars:
            if current:
                groups.append(current)
                current = []
                current_len = 0
            groups.append([i])
            continue
        extra = len(text) + (1 if current else 0)
        if current and current_len + extra > max_pack_chars:
            groups.append(current)
            current = [i]
            current_len = len(text)
        else:
            current.append(i)
            current_len += extra
    if current:
        groups.append(current)
    return groups


def translate_payloads_sequential(
    translator: Translator,
    payloads: list[str],
    pacer: RequestPacer,
    max_pack_chars: int,
    max_single_chars: int,
) -> list[str]:
    out = list(payloads)
    groups = pack_single_line_strings(payloads, max_pack_chars, max_single_chars)
    for group in groups:
        if len(group) == 1:
            i = group[0]
            out[i] = translate_one_payload(
                translator, payloads[i], pacer, max_single_chars
            )
            continue
        joined = "\n".join(payloads[i] for i in group)
        if len(joined) > max_single_chars:
            for i in group:
                out[i] = translate_one_payload(
                    translator, payloads[i], pacer, max_single_chars
                )
            continue
        translated = translate_with_retry(translator, joined, pacer)
        parts = translated.split("\n")
        if len(parts) == len(group):
            for idx, part in zip(group, parts):
                out[idx] = part
            continue
        for i in group:
            out[i] = translate_one_payload(
                translator, payloads[i], pacer, max_single_chars
            )
    return out


def _api_payloads_with_context(
    en: dict,
    items: list[tuple[str, str, list[str]]],
    *,
    backend: Backend,
) -> tuple[list[str], list[int], list[bool], list[str | None]]:
    """Build API strings; index_map maps to_send row -> items index."""
    index_map: list[int] = []
    to_send: list[str] = []
    unwrap_flags: list[bool] = []
    deepl_contexts: list[str | None] = []
    for i, (key, protected, _tokens) in enumerate(items):
        if not protected.strip():
            continue
        ctx = mt_context_from_en(en, key)
        index_map.append(i)
        deepl_contexts.append(ctx)
        if backend == "deepl":
            to_send.append(protected)
            unwrap_flags.append(False)
        else:
            wrapped = wrap_for_cloud_mt(protected, ctx)
            to_send.append(wrapped)
            unwrap_flags.append(wrapped != protected)
    return to_send, index_map, unwrap_flags, deepl_contexts


def translate_strings_batch_api(
    translator: BatchTranslator,
    items: list[tuple[str, str, list[str]]],
    pacer: RequestPacer,
    *,
    en: dict,
    backend: Backend,
) -> dict[str, str]:
    """One or few API calls per locale (Google Cloud / Azure / DeepL)."""
    keys = [k for k, _, _ in items]
    payloads = [p for _, p, _ in items]
    tokens_list = [t for _, _, t in items]

    to_send, index_map, unwrap_flags, deepl_contexts = _api_payloads_with_context(
        en, items, backend=backend
    )

    pacer.wait_turn()
    if to_send:
        if backend == "deepl" and hasattr(
            translator, "translate_many_with_contexts"
        ):
            ctx_for_send = [deepl_contexts[i] for i in range(len(to_send))]
            translated_sent = translator.translate_many_with_contexts(  # type: ignore[attr-defined]
                to_send, ctx_for_send
            )
        else:
            translated_sent = translator.translate_many(to_send)
    else:
        translated_sent = []

    results = list(payloads)
    for map_i, raw, unwrap in zip(index_map, translated_sent, unwrap_flags):
        results[map_i] = unwrap_cloud_mt(raw, was_wrapped=unwrap)

    return {
        key: restore_placeholders(raw, tokens)
        for key, raw, tokens in zip(keys, results, tokens_list)
    }


def translate_strings_for_locale(
    translator: Translator,
    items: list[tuple[str, str, list[str]]],
    pacer: RequestPacer,
    max_pack_chars: int,
    max_single_chars: int,
    *,
    en: dict,
    backend: Backend,
) -> dict[str, str]:
    if uses_batch_api(backend) and hasattr(translator, "translate_many"):
        return translate_strings_batch_api(
            translator, items, pacer, en=en, backend=backend
        )
    keys = [k for k, _, _ in items]
    api_payloads: list[str] = []
    unwrap_flags: list[bool] = []
    for key, protected, _tokens in items:
        ctx = mt_context_from_en(en, key)
        if backend == "deepl" and hasattr(translator, "translate_many_with_contexts"):
            api_payloads.append(protected)
            unwrap_flags.append(False)
        else:
            wrapped = wrap_for_cloud_mt(protected, ctx)
            api_payloads.append(wrapped)
            unwrap_flags.append(wrapped != protected)
    if backend == "deepl" and hasattr(translator, "translate_many_with_contexts"):
        contexts = [mt_context_from_en(en, k) for k, _, _ in items]
        pacer.wait_turn()
        translated = translator.translate_many_with_contexts(  # type: ignore[attr-defined]
            api_payloads, contexts
        )
    else:
        translated = translate_payloads_sequential(
            translator,
            api_payloads,
            pacer,
            max_pack_chars,
            max_single_chars,
        )
    translated = [
        unwrap_cloud_mt(raw, was_wrapped=flag)
        for raw, flag in zip(translated, unwrap_flags)
    ]
    return {
        key: restore_placeholders(raw, tokens)
        for key, raw, tokens in zip(keys, translated, [t for _, _, t in items])
    }


def icu_translate_many_factory(
    translator: Translator,
    *,
    en: dict,
    message_key: str,
    backend: Backend,
    pacer: RequestPacer,
) -> Callable[[list[str]], list[str]]:
    ctx = mt_context_from_en(en, message_key)

    def batch(texts: list[str]) -> list[str]:
        if not texts:
            return []
        if backend == "deepl" and hasattr(
            translator, "translate_many_with_contexts"
        ):
            pacer.wait_turn()
            return translator.translate_many_with_contexts(  # type: ignore[attr-defined]
                texts, [ctx] * len(texts)
            )
        wrapped = [wrap_for_cloud_mt(t, ctx) for t in texts]
        flags = [w != t for t, w in zip(texts, wrapped)]
        pacer.wait_turn()
        if hasattr(translator, "translate_many"):
            out = translator.translate_many(wrapped)  # type: ignore[union-attr]
        else:
            out = [translator.translate(w) for w in wrapped]
        return [
            unwrap_cloud_mt(o, was_wrapped=f) for o, f in zip(out, flags)
        ]

    return batch


def locale_already_translated(en: dict, existing: dict, force: bool) -> bool:
    if force:
        return False
    en_settings = en.get("settings")
    cur_settings = existing.get("settings")
    return (
        isinstance(en_settings, str)
        and isinstance(cur_settings, str)
        and cur_settings != en_settings
    )


def is_icu_message(en_val: str) -> bool:
    return ",plural," in en_val or ",select," in en_val


def should_skip_key(en_val: str, cur: object, force: bool) -> bool:
    if not isinstance(cur, str):
        return False
    if force:
        return False
    return cur != en_val


def pick_mt_backend(
    code: str,
    *,
    deepl_auth_key: str | None,
    deepl_targets: set[str] | None,
    google_api_key: str | None,
    azure_key: str | None,
    azure_region: str | None,
    prefer: Backend,
) -> Backend | None:
    """DeepL first, then Google Cloud, then Azure."""
    if prefer == "deepl" and deepl_auth_key and deepl_targets:
        if deepl_target_for(code) in deepl_targets:
            return "deepl"
    if google_api_key:
        return "google-cloud"
    if azure_key and azure_region:
        return "azure"
    return None


def count_http_requests(
    payloads: list[str], max_pack_chars: int, max_single_chars: int
) -> int:
    return len(pack_single_line_strings(payloads, max_pack_chars, max_single_chars))


def resolve_backend_choice(requested: str) -> Backend | Literal["auto"]:
    if requested == "auto":
        return "auto"
    if requested in ("google-cloud", "azure", "deepl", "google", "mymemory"):
        return requested  # type: ignore[return-value]
    raise ValueError(requested)


def validate_cloud_credentials(backend: Backend) -> int | None:
    """Return exit code if credentials missing."""
    if backend == "deepl":
        has_deepl = bool(os.environ.get("DEEPL_AUTH_KEY"))
        has_google = bool(os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY"))
        has_azure = bool(
            os.environ.get("AZURE_TRANSLATOR_KEY")
            and os.environ.get("AZURE_TRANSLATOR_REGION")
        )
        if not (has_deepl or has_google or has_azure):
            print(
                "Set DEEPL_AUTH_KEY and/or Google Cloud / Azure credentials "
                "(see doc/L10N_MT_CLOUD.md).",
                file=sys.stderr,
            )
            return 1
    if backend == "google-cloud":
        if not os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY"):
            print(
                "Set GOOGLE_CLOUD_TRANSLATE_API_KEY (Cloud Translation API v2 key).",
                file=sys.stderr,
            )
            return 1
    if backend == "azure":
        if not os.environ.get("AZURE_TRANSLATOR_KEY"):
            print("Set AZURE_TRANSLATOR_KEY.", file=sys.stderr)
            return 1
        if not os.environ.get("AZURE_TRANSLATOR_REGION"):
            print(
                "Set AZURE_TRANSLATOR_REGION (e.g. westeurope, eastus).",
                file=sys.stderr,
            )
            return 1
    return None


def load_dotenv_file(path: Path) -> None:
    """Load KEY=VALUE lines into os.environ (does not override existing vars)."""
    if not path.is_file():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key:
            os.environ.setdefault(key, value)


def main() -> int:
    load_dotenv_file(ROOT / ".env")
    parser = argparse.ArgumentParser()
    parser.add_argument("--locale", action="append", help="Only these codes")
    parser.add_argument("--force", action="store_true", help="Overwrite translations")
    parser.add_argument(
        "--backend",
        choices=("auto", "google-cloud", "azure", "deepl", "google", "mymemory"),
        default="mymemory",
        help="Translation API (google-cloud, azure, or deepl for bulk MT)",
    )
    parser.add_argument(
        "--max-pack-chars",
        type=int,
        default=None,
        help="Override max chars per combined request (non-cloud backends)",
    )
    parser.add_argument(
        "--min-interval",
        type=float,
        default=DEFAULT_MIN_INTERVAL_S,
        help="Seconds between HTTP requests",
    )
    parser.add_argument(
        "--initial-cooldown",
        type=float,
        default=0.0,
        help="Sleep before starting",
    )
    parser.add_argument(
        "--email",
        default=os.environ.get("MYMEMORY_EMAIL"),
        help="Contact email for MyMemory (env MYMEMORY_EMAIL)",
    )
    parser.add_argument(
        "--continue-on-error",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Keep going if one locale fails (default: on)",
    )
    parser.add_argument(
        "--stop-on-quota",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Stop on first MyMemory daily quota error (default: on)",
    )
    parser.add_argument(
        "--icu-only",
        action="store_true",
        help="Only translate ICU plural keys (4 playlist strings)",
    )
    parser.add_argument(
        "--fill-english-only",
        action="store_true",
        help="Only translate keys that still match English",
    )
    parser.add_argument(
        "--keys",
        action="append",
        metavar="KEY",
        help="Re-translate only these message keys from English (ignores locale skip)",
    )
    args = parser.parse_args()
    only_keys: set[str] | None = set(args.keys) if args.keys else None
    if only_keys:
        unknown = only_keys - set(message_keys(load_arb(TEMPLATE)))
        if unknown:
            print(f"Unknown --keys: {', '.join(sorted(unknown))}", file=sys.stderr)
            return 1

    backend_choice = resolve_backend_choice(args.backend)

    if backend_choice == "mymemory" or backend_choice == "auto":
        try:
            from deep_translator import GoogleTranslator  # noqa: F401
        except ImportError:
            print("Install: pip install deep-translator requests", file=sys.stderr)
            return 1
    elif backend_choice in ("google-cloud", "azure"):
        pass  # requests only

    if backend_choice in ("google-cloud", "azure", "deepl"):
        code = validate_cloud_credentials(backend_choice)
        if code is not None:
            return code

    if args.initial_cooldown > 0:
        print(f"Cooldown {args.initial_cooldown:.0f}s …", flush=True)
        time.sleep(args.initial_cooldown)

    if backend_choice in ("mymemory", "auto") and not args.email:
        print(
            "Warning: no --email / MYMEMORY_EMAIL; anonymous MyMemory quota is tiny.",
            file=sys.stderr,
        )

    google_api_key = os.environ.get("GOOGLE_CLOUD_TRANSLATE_API_KEY")
    azure_key = os.environ.get("AZURE_TRANSLATOR_KEY")
    azure_region = os.environ.get("AZURE_TRANSLATOR_REGION")
    azure_endpoint = os.environ.get("AZURE_TRANSLATOR_ENDPOINT")
    deepl_auth_key = os.environ.get("DEEPL_AUTH_KEY")

    deepl_targets: set[str] | None = None
    if backend_choice == "deepl" and deepl_auth_key:
        try:
            deepl_targets = fetch_deepl_target_languages(deepl_auth_key)
            print(
                f"DeepL: {len(deepl_targets)} target languages available.",
                flush=True,
            )
        except Exception as exc:
            print(f"DeepL language list failed: {exc}", file=sys.stderr)
            if not google_api_key and not (
                azure_key and azure_region
            ):
                return 1
            deepl_targets = set()

    en = load_arb(TEMPLATE)
    en_keys = message_keys(en)
    locales = args.locale if args.locale else CODES
    pacer = RequestPacer(args.min_interval)

    active_backend: Backend | None = None
    if backend_choice == "auto":
        active_backend = None
    else:
        active_backend = backend_choice

    failed_locales: list[str] = []
    quota_stop = False

    for code in locales:
        if active_backend is None:
            active_backend = "google"

        path = L10N / f"app_{code}.arb"
        existing = load_arb(path) if path.exists() else {"@@locale": code}
        if (
            only_keys is None
            and not args.icu_only
            and not args.fill_english_only
            and locale_already_translated(en, existing, args.force)
        ):
            print(f"Skipping {code} (already translated)", flush=True)
            continue

        locale_backend = active_backend
        if backend_choice == "deepl":
            locale_backend = pick_mt_backend(
                code,
                deepl_auth_key=deepl_auth_key,
                deepl_targets=deepl_targets,
                google_api_key=google_api_key,
                azure_key=azure_key,
                azure_region=azure_region,
                prefer="deepl",
            )
            if locale_backend is None:
                print(f"Skipping {code}: no MT backend for this locale", flush=True)
                continue

        def run_locale(backend: Backend) -> dict:
            translator = make_translator(
                backend,
                code,
                mymemory_email=args.email,
                google_api_key=google_api_key,
                azure_key=azure_key,
                azure_region=azure_region,
                azure_endpoint=azure_endpoint,
                deepl_auth_key=deepl_auth_key,
            )
            max_pack, max_single = backend_limits(backend)
            if args.max_pack_chars is not None:
                max_pack = args.max_pack_chars
            label = target_label_for(backend, code)
            print(f"Translating {code} ({backend} -> {label}) …", flush=True)

            out: dict = {"@@locale": code}
            to_translate: list[tuple[str, str, list[str]]] = []

            for key in en_keys:
                meta = f"@{key}"
                if meta in en:
                    out[meta] = en[meta]
                en_val = en[key]
                if not isinstance(en_val, str):
                    out[key] = en_val
                    continue
                cur = existing.get(key)
                if only_keys is not None and key not in only_keys:
                    out[key] = cur if isinstance(cur, str) else en_val
                    continue
                if key in BRAND_KEEP:
                    out[key] = BRAND_KEEP[key]
                    continue
                icu = is_icu_message(en_val)

                if args.icu_only:
                    if not icu:
                        out[key] = cur if isinstance(cur, str) else en_val
                        continue
                    if (
                        not args.force
                        and isinstance(cur, str)
                        and cur != en_val
                    ):
                        out[key] = cur
                        continue
                elif icu:
                    if not hasattr(translator, "translate_many") and not hasattr(
                        translator, "translate"
                    ):
                        out[key] = cur if isinstance(cur, str) else en_val
                    else:
                        icu_batch = icu_translate_many_factory(
                            translator,
                            en=en,
                            message_key=key,
                            backend=backend,
                            pacer=pacer,
                        )
                        out[key] = translate_icu_plural(en_val, icu_batch)
                    continue

                if (
                    args.fill_english_only
                    and not args.force
                    and only_keys is None
                ):
                    if isinstance(cur, str) and cur != en_val:
                        out[key] = cur
                        continue

                if only_keys is None and should_skip_key(en_val, cur, args.force):
                    out[key] = cur if isinstance(cur, str) else en_val
                    continue
                protected, tokens = protect_placeholders(en_val)
                to_translate.append((key, protected, tokens))

            if to_translate:
                payloads = [p for _, p, _ in to_translate]
                if uses_batch_api(backend):
                    batches = max(
                        1,
                        (len([p for p in payloads if p.strip()]) + CLOUD_BATCH_SIZE - 1)
                        // CLOUD_BATCH_SIZE,
                    )
                    print(
                        f"  {len(to_translate)} strings → ~{batches} API batch(es)",
                        flush=True,
                    )
                else:
                    req_count = count_http_requests(payloads, max_pack, max_single)
                    print(
                        f"  {len(to_translate)} strings → ~{req_count} HTTP requests",
                        flush=True,
                    )
                out.update(
                    translate_strings_for_locale(
                        translator,
                        to_translate,
                        pacer,
                        max_pack,
                        max_single,
                        en=en,
                        backend=backend,
                    )
                )
            return out

        try:
            out = run_locale(locale_backend if backend_choice == "deepl" else active_backend)
        except Exception as e:
            if (
                backend_choice == "auto"
                and active_backend == "google"
                and is_rate_limit_error(e)
            ):
                print(
                    "  Google scraper blocked; switching to MyMemory.",
                    flush=True,
                )
                active_backend = "mymemory"
                try:
                    out = run_locale(active_backend)
                except Exception as e2:
                    e = e2
                else:
                    e = None
            if e is not None:
                if isinstance(e, MyMemoryQuotaError):
                    print(f"  failed {code}: MyMemory quota — {e}", file=sys.stderr)
                    wait_s = parse_mymemory_reset_seconds(str(e))
                    if wait_s:
                        print(
                            f"MyMemory resets in ~{wait_s // 60} min.",
                            file=sys.stderr,
                        )
                    if args.stop_on_quota:
                        failed_locales.append(code)
                        quota_stop = True
                        break
                elif is_rate_limit_error(e):
                    print(f"  failed {code}: rate limit — {e}", file=sys.stderr)
                else:
                    print(f"  failed {code}: {e}", file=sys.stderr)
                failed_locales.append(code)
                if args.continue_on_error and not quota_stop:
                    continue
                return 1

        harmonize_eq_preset_label_caps(out)
        write_arb(path, out)
        print(f"  wrote {path.name}", flush=True)

    if failed_locales:
        print(
            f"Finished with failures: {', '.join(failed_locales)}.",
            file=sys.stderr,
        )
        return 1

    print("Done. Run: flutter gen-l10n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

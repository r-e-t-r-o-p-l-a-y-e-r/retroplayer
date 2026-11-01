"""Disambiguation context for machine translation (from app_en.arb metadata)."""
from __future__ import annotations

from typing import Any

# Shown only to MT APIs, not in the app UI.
_CLOUD_CONTEXT_PREFIX = "[Context: "


def mt_context_from_en(en: dict[str, Any], message_key: str) -> str | None:
    """Translator hint from @message_key metadata (description or x-mt-context)."""
    meta = en.get(f"@{message_key}")
    if not isinstance(meta, dict):
        return None
    extra = meta.get("x-mt-context")
    if isinstance(extra, str) and extra.strip():
        return extra.strip()
    desc = meta.get("description")
    if isinstance(desc, str) and desc.strip():
        return desc.strip()
    return None


def can_use_cloud_context_wrap(text: str) -> bool:
    """Multi-line / placeholder strings must not use the first-line MT trick."""
    if "\n" in text:
        return False
    if "{" in text or "}" in text:
        return False
    return True


def wrap_for_cloud_mt(text: str, context: str | None) -> str:
    if not context or not can_use_cloud_context_wrap(text):
        return text
    return f"{text}\n{_CLOUD_CONTEXT_PREFIX}{context}]"


def unwrap_cloud_mt(translated: str, *, was_wrapped: bool) -> str:
    if not was_wrapped:
        return translated
    first = translated.split("\n", 1)[0].strip()
    return first if first else translated.strip()

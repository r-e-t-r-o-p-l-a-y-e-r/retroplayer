"""Parse and rebuild ICU plural messages in ARB files (Flutter subset)."""
from __future__ import annotations

import re
from typing import Callable

_PLURAL_HEAD = re.compile(r"^\{(\w+),plural,\s*")


def _find_matching_brace(s: str, start: int) -> int:
    depth = 0
    i = start
    while i < len(s):
        if s[i] == "{":
            depth += 1
        elif s[i] == "}":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    raise ValueError(f"Unbalanced braces in ICU message: {s[:80]}…")


def parse_plural_message(message: str) -> tuple[str, list[tuple[str, str]]]:
    m = _PLURAL_HEAD.match(message)
    if not m:
        raise ValueError(f"Not a plural ICU message: {message[:60]}…")
    var = m.group(1)
    pos = m.end()
    outer_close = len(message) - 1
    if not message.endswith("}"):
        raise ValueError("Plural message must end with '}'")
    branches: list[tuple[str, str]] = []
    while pos < outer_close:
        while pos < outer_close and message[pos].isspace():
            pos += 1
        if pos >= outer_close:
            break
        sel_match = re.match(r"(=\d+|zero|one|two|few|many|other)\{", message[pos:])
        if not sel_match:
            raise ValueError(f"Expected branch at {pos}: {message[pos:pos+30]}")
        selector = sel_match.group(1)
        brace_start = pos + len(selector)
        inner_start = brace_start + 1
        inner_end = _find_matching_brace(message, brace_start) - 1
        branches.append((selector, message[inner_start:inner_end]))
        pos = inner_end + 1
    return var, branches


def build_plural_message(var: str, branches: list[tuple[str, str]]) -> str:
    parts = [f"{{{var},plural,"]
    for selector, inner in branches:
        parts.append(f" {selector}{{{inner}}}")
    parts.append("}")
    return "".join(parts)


def _protect_var_in_branch(text: str, var: str) -> tuple[str, str]:
    token = f"{{{var}}}"
    if token not in text:
        return text, token
    return text.replace(token, "⟦V⟧"), token


def _restore_var_in_branch(text: str, token: str) -> str:
    return text.replace("⟦V⟧", token)


def translate_icu_plural(
    en_val: str,
    translate_many: Callable[[list[str]], list[str]],
) -> str:
    var, branches = parse_plural_message(en_val)
    selectors = [s for s, _ in branches]
    inners = [inner for _, inner in branches]

    protected: list[str] = []
    tokens: list[str] = []
    for inner in inners:
        p, tok = _protect_var_in_branch(inner, var)
        protected.append(p)
        tokens.append(tok)

    # Deduplicate for fewer API calls
    unique: list[str] = []
    map_idx: list[int] = []
    for p in protected:
        if p in unique:
            map_idx.append(unique.index(p))
        else:
            map_idx.append(len(unique))
            unique.append(p)

    to_translate = [u for u in unique if u.strip()]
    if to_translate:
        translated_unique = translate_many(to_translate)
        lookup = dict(zip(to_translate, translated_unique))
        out_unique = [lookup.get(u, u) for u in unique]
    else:
        out_unique = unique

    new_inners = [
        _restore_var_in_branch(out_unique[map_idx[i]], tokens[i])
        for i in range(len(inners))
    ]
    return build_plural_message(var, list(zip(selectors, new_inners)))

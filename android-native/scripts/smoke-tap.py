#!/usr/bin/env python3
"""uiautomator helpers for scripts/emulator-smoke.sh (stdin = dump XML)."""
from __future__ import annotations

import re
import sys


def _nodes(xml: str) -> list[str]:
    return re.findall(r"<node [^>]*>", xml)


def _attr(node: str, key: str) -> str:
    m = re.search(r"\b" + re.escape(key) + r'="([^"]*)"', node)
    return m.group(1) if m else ""


def _bounds(node: str) -> tuple[int, int, int, int] | None:
    m = re.search(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"', node)
    if not m:
        return None
    return tuple(map(int, m.groups()))  # type: ignore[return-value]


def _tap_point(
    xml: str,
    pattern: str,
    min_y: int,
    max_y: int,
    *,
    x_frac: float = 0.5,
    prefer_desc: bool = True,
    skip_permission_blurb: bool = True,
    row_mode: bool = False,
) -> tuple[int, int] | None:
    hits: list[tuple[int, int, int, int]] = []
    for node in _nodes(xml):
        text, desc = _attr(node, "text"), _attr(node, "content-desc")
        clickable = _attr(node, "clickable") == "true"
        score: int | None = None
        if prefer_desc and desc and re.search(pattern, desc, re.I):
            score = 0 if re.fullmatch(pattern, desc, re.I) else 1
            if row_mode and not clickable:
                score += 10
        if score is None and text and re.search(pattern, text, re.I):
            if skip_permission_blurb and "allow" in text.lower() and "access" in text.lower():
                continue
            if re.fullmatch(pattern, text, re.I):
                score = 2 if row_mode else 1
            else:
                score = 3
        if score is None:
            continue
        b = _bounds(node)
        if not b:
            continue
        x1, y1, x2, y2 = b
        cx = int(x1 + (x2 - x1) * x_frac)
        cy = (y1 + y2) // 2
        if min_y <= cy <= max_y:
            hits.append((score, cy, cx, cy))
    if not hits:
        return None
    hits.sort()
    _, _, cx, cy = hits[0]
    return cx, cy


def main() -> None:
    xml = sys.stdin.read()
    cmd = sys.argv[1]
    if cmd == "row":
        label, min_y, max_y = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
        pt = _tap_point(xml, label, min_y, max_y, x_frac=0.28, prefer_desc=True, row_mode=True)
    elif cmd == "top":
        pattern = sys.argv[2]
        pt = _tap_point(xml, pattern, 140, 320, x_frac=0.5, prefer_desc=True)
    elif cmd == "tap":
        pattern, min_y, max_y = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
        x_frac = float(sys.argv[5]) if len(sys.argv) > 5 else 0.5
        pt = _tap_point(xml, pattern, min_y, max_y, x_frac=x_frac)
    elif cmd == "has":
        pattern = sys.argv[2]
        for node in _nodes(xml):
            text, desc = _attr(node, " text"), _attr(node, "content-desc")
            if any(s and re.search(pattern, s, re.I) for s in (text, desc)):
                sys.exit(0)
        sys.exit(1)
    else:
        sys.stderr.write(f"unknown command: {cmd}\n")
        sys.exit(2)
    if pt is None:
        sys.exit(1)
    print(pt[0], pt[1])


if __name__ == "__main__":
    main()

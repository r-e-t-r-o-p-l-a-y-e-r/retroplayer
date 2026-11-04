#!/usr/bin/env python3
"""Export the Retro Player PNG master and the 512 px store icon from the SVG master."""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SVG = ROOT / "assets" / "icon" / "app_icon.svg"
PNG_MASTER = ROOT / "assets" / "icon" / "app_icon.png"
STORE_ICON = ROOT / "fastlane" / "metadata" / "android" / "en-US" / "images" / "icon.png"


def _find_exporter() -> list[str]:
    if shutil.which("inkscape"):
        return ["inkscape"]
    if shutil.which("rsvg-convert"):
        return ["rsvg-convert"]
    return []


def export_png(exporter: list[str], size: int, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    if exporter[0] == "inkscape":
        subprocess.run(
            ["inkscape", str(SVG), "-o", str(output), "-w", str(size), "-h", str(size)],
            check=True,
        )
        return
    subprocess.run(
        ["rsvg-convert", str(SVG), "-w", str(size), "-h", str(size), "-o", str(output)],
        check=True,
    )


def main() -> None:
    if not SVG.is_file():
        print(f"Missing SVG master: {SVG}", file=sys.stderr)
        sys.exit(1)

    exporter = _find_exporter()
    if not exporter:
        print("Need inkscape or rsvg-convert to export PNGs from SVG.", file=sys.stderr)
        sys.exit(1)

    export_png(exporter, 1024, PNG_MASTER)
    export_png(exporter, 512, STORE_ICON)
    print(f"Source: {SVG}")
    print(f"Wrote {PNG_MASTER}")
    print(f"Wrote {STORE_ICON}")


if __name__ == "__main__":
    main()

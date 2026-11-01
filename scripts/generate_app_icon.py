#!/usr/bin/env python3
"""Export Retro Player PNG icons from the SVG master."""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SVG = ROOT / "assets" / "icon" / "app_icon.svg"
PNG_MASTER = ROOT / "assets" / "icon" / "app_icon.png"
LINUX = ROOT / "linux" / "runner" / "resources" / "app_icon.png"
HICOLOR = ROOT / "linux" / "share" / "icons" / "hicolor"
GRESOURCE_ICONS = ROOT / "linux" / "resources" / "icons"
EXPORT_SIZES = (48, 128, 256, 512, 1024)


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
            [
                "inkscape",
                str(SVG),
                "-o",
                str(output),
                "-w",
                str(size),
                "-h",
                str(size),
            ],
            check=True,
        )
        return

    subprocess.run(
        [
            "rsvg-convert",
            str(SVG),
            "-w",
            str(size),
            "-h",
            str(size),
            "-o",
            str(output),
        ],
        check=True,
    )


def main() -> None:
    if not SVG.is_file():
        print(f"Missing SVG master: {SVG}", file=sys.stderr)
        sys.exit(1)

    exporter = _find_exporter()
    if not exporter:
        print(
            "Need inkscape or rsvg-convert to export PNGs from SVG.",
            file=sys.stderr,
        )
        sys.exit(1)

    for size in EXPORT_SIZES:
        target = PNG_MASTER if size == 1024 else None
        if target is not None:
            export_png(exporter, size, target)

        if size == 512:
            export_png(exporter, size, LINUX)

        if size in (48, 128, 256, 512):
            gresource_dir = GRESOURCE_ICONS
            gresource_dir.mkdir(parents=True, exist_ok=True)
            export_png(
                exporter,
                size,
                gresource_dir / f"app_icon_{size}.png",
            )

        out_dir = HICOLOR / f"{size}x{size}" / "apps"
        export_png(
            exporter,
            size,
            out_dir / "app.retroplayer.png",
        )

    print(f"Source: {SVG}")
    print(f"Wrote {PNG_MASTER}")
    print(f"Wrote {LINUX}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Build the store images in fastlane/metadata/android/en-US/images/.

- icon.png (512 x 512, 32-bit): the launcher glyph on the launcher background colour
- featureGraphic.png (1024 x 500): icon, name, tagline and the player screenshot
- phoneScreenshots/N.png: doc/images/tutorial/*.png, widened by repeating the edge
  pixels so the long side is at most twice the short side (the usual store limit)

Needs Pillow and inkscape (or rsvg-convert) for the SVG master.
Usage: python3 scripts/make_store_images.py
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_app_icon import SVG, _find_exporter, export_png  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
IMAGES = ROOT / "fastlane" / "metadata" / "android" / "en-US" / "images"
TUTORIAL = ROOT / "doc" / "images" / "tutorial"

# RetroPalette.Light and colors.xml ic_launcher_background.
LAUNCHER_BG = (0xEB, 0xE4, 0xD9)
SCREEN = (0xF7, 0xF2, 0xEA)
TEXT_PRIMARY = (0x2B, 0x21, 0x18)
TEXT_MUTED = (0x8A, 0x81, 0x78)
ACCENT = (0xC4, 0x5C, 0x26)
DIVIDER = (0xC9, 0xBF, 0xB3)

FONT_CANDIDATES = [
    "/usr/share/fonts/google-noto-vf/NotoSans[wght].ttf",
    "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf",
    "/usr/share/fonts/google-roboto/Roboto-Regular.ttf",
]

TAGLINE = "Music and audiobooks from your folders"


def glyph(size: int) -> Image.Image:
    exporter = _find_exporter()
    if not exporter:
        raise SystemExit("Need inkscape or rsvg-convert to render the SVG master.")
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "glyph.png"
        export_png(exporter, size, out)
        return Image.open(out).convert("RGBA")


def font(size: int, weight: int) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        if Path(path).is_file():
            f = ImageFont.truetype(path, size)
            try:
                f.set_variation_by_axes([weight])
            except (OSError, AttributeError):
                pass
            return f
    raise SystemExit(f"No font found; tried {FONT_CANDIDATES}")


def icon(size: int = 512) -> Image.Image:
    img = Image.new("RGBA", (size, size), LAUNCHER_BG + (255,))
    img.alpha_composite(glyph(size))
    return img


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width - 1, img.height - 1), radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def feature_graphic() -> Image.Image:
    w, h = 1024, 500
    img = Image.new("RGBA", (w, h), SCREEN + (255,))
    draw = ImageDraw.Draw(img)

    tile = rounded(icon(168), 36)
    img.alpha_composite(tile, (72, 96))

    draw.text((72, 292), "Retro Player", font=font(64, 700), fill=TEXT_PRIMARY)
    draw.text((74, 376), TAGLINE, font=font(28, 400), fill=TEXT_MUTED)
    draw.rectangle((74, 426, 74 + 96, 431), fill=ACCENT)

    shot = Image.open(TUTORIAL / "03-expanded-player.png").convert("RGB")
    shot_h = 452
    shot = shot.resize((round(shot.width * shot_h / shot.height), shot_h), Image.LANCZOS)
    frame = rounded(shot, 20)
    x = w - frame.width - 72
    border = Image.new("RGBA", (frame.width + 4, frame.height + 4), (0, 0, 0, 0))
    ImageDraw.Draw(border).rounded_rectangle((0, 0, border.width - 1, border.height - 1), 22, fill=DIVIDER + (255,))
    img.alpha_composite(border, (x - 2, (h - frame.height) // 2 - 2))
    img.alpha_composite(frame, (x, (h - frame.height) // 2))
    return img.convert("RGB")


def widen_to_two_to_one(img: Image.Image) -> Image.Image:
    """Pads the short side with copies of the edge pixels until long <= 2 * short."""
    w, h = img.size
    if h <= 2 * w:
        return img
    target = -(-h // 2)
    left = (target - w) // 2
    right = target - w - left
    out = Image.new(img.mode, (target, h))
    out.paste(img, (left, 0))
    out.paste(img.crop((0, 0, 1, h)).resize((left, h)), (0, 0))
    out.paste(img.crop((w - 1, 0, w, h)).resize((right, h)), (left + w, 0))
    return out


def main() -> int:
    IMAGES.mkdir(parents=True, exist_ok=True)
    icon().save(IMAGES / "icon.png", optimize=True)
    feature_graphic().save(IMAGES / "featureGraphic.png", optimize=True)

    shots = IMAGES / "phoneScreenshots"
    shots.mkdir(exist_ok=True)
    for old in shots.glob("*.png"):
        old.unlink()
    for i, path in enumerate(sorted(TUTORIAL.glob("*.png")), start=1):
        widen_to_two_to_one(Image.open(path).convert("RGB")).save(shots / f"{i}.png", optimize=True)
    print(f"Wrote {IMAGES}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

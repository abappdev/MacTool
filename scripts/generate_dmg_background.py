#!/usr/bin/env python3
"""Generate a simple DMG Finder background: drag app → Applications."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

WIDTH, HEIGHT = 660, 400
OUT = Path(__file__).resolve().parents[1] / "scripts" / "dmg-background.png"


def font(size: int) -> ImageFont.ImageFont:
    for name in (
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial.ttf",
    ):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main() -> None:
    img = Image.new("RGB", (WIDTH, HEIGHT), (245, 247, 250))
    d = ImageDraw.Draw(img)

    # Soft top band
    for y in range(72):
        t = y / 72
        c = int(236 + (245 - 236) * t)
        d.line([(0, y), (WIDTH, y)], fill=(c, c + 1, c + 3))

    title = font(28)
    body = font(16)
    d.text((WIDTH / 2, 36), "Install MacTool", fill=(28, 35, 45), font=title, anchor="mt")
    d.text(
        (WIDTH / 2, 68),
        "Drag MacTool to Applications",
        fill=(90, 100, 112),
        font=body,
        anchor="mt",
    )

    # Arrow between icon slots (~160 and ~480 at y=180)
    y = 190
    d.line([(250, y), (390, y)], fill=(70, 140, 150), width=6)
    # Arrow head
    d.polygon([(390, y), (365, y - 14), (365, y + 14)], fill=(70, 140, 150))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, "PNG")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()

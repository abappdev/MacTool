#!/usr/bin/env python3
"""Generate MacTool AppIcon.appiconset PNGs — cursor motif on teal-slate fill."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ICONSET = ROOT / "MacTool" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"
PREVIEW = (
    Path.home()
    / "Library/Application Support/Cursor/AgentStores/cursor_agent_stores"
    / "bc-977b8d6e-9d35-450a-884d-b7feedcde30e/files/media/mactool-appicon-preview.png"
)

TOP = (74, 138, 150)
BOTTOM = (42, 69, 80)
CURSOR_FILL = (250, 252, 253)
CURSOR_OUTLINE = (28, 36, 42)
GHOST_FILL = (255, 255, 255, 95)
GHOST_OUTLINE = (255, 255, 255, 55)

CURSOR_POLY = [
    (18, 8),
    (18, 78),
    (34, 62),
    (48, 92),
    (58, 87),
    (44, 57),
    (68, 57),
]

# (filename, pixel_size, Contents.json size, Contents.json scale)
_AT = chr(64) + "2x"
MAC_ICONS = [
    (f"icon_16x16.png", 16, "16x16", "1x"),
    (f"icon_16x16{_AT}.png", 32, "16x16", "2x"),
    (f"icon_32x32.png", 32, "32x32", "1x"),
    (f"icon_32x32{_AT}.png", 64, "32x32", "2x"),
    (f"icon_128x128.png", 128, "128x128", "1x"),
    (f"icon_128x128{_AT}.png", 256, "128x128", "2x"),
    (f"icon_256x256.png", 256, "256x256", "1x"),
    (f"icon_256x256{_AT}.png", 512, "256x256", "2x"),
    (f"icon_512x512.png", 512, "512x512", "1x"),
    (f"icon_512x512{_AT}.png", 1024, "512x512", "2x"),
]


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def make_background(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    assert px is not None
    for y in range(size):
        t = y / max(size - 1, 1)
        r = int(lerp(TOP[0], BOTTOM[0], t))
        g = int(lerp(TOP[1], BOTTOM[1], t))
        b = int(lerp(TOP[2], BOTTOM[2], t))
        for x in range(size):
            dx = (x + 0.5) / size - 0.5
            dy = (y + 0.5) / size - 0.45
            dist = (dx * dx + dy * dy) ** 0.5
            lift = max(0.0, 1.0 - dist * 1.6) * 18
            px[x, y] = (
                min(255, int(r + lift)),
                min(255, int(g + lift * 0.9)),
                min(255, int(b + lift * 0.7)),
                255,
            )
    return img


def transform_poly(
    poly: list[tuple[float, float]],
    *,
    origin: tuple[float, float],
    scale: float,
    offset: tuple[float, float] = (0.0, 0.0),
) -> list[tuple[float, float]]:
    ox, oy = origin
    dx, dy = offset
    return [(ox + x * scale + dx, oy + y * scale + dy) for x, y in poly]


def draw_cursor(
    draw: ImageDraw.ImageDraw,
    poly: list[tuple[float, float]],
    *,
    fill,
    outline,
    width: float,
) -> None:
    draw.polygon(poly, fill=fill, outline=outline)
    if width > 0:
        flat = [c for p in poly for c in p]
        draw.line(flat + list(poly[0]), fill=outline, width=max(1, int(round(width))), joint="curve")


def render_master(size: int = 1024) -> Image.Image:
    base = make_background(size)
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    glyph_scale = size * 0.0052
    origin = (size * 0.27, size * 0.20)

    ghost = transform_poly(
        CURSOR_POLY,
        origin=origin,
        scale=glyph_scale,
        offset=(size * 0.07, size * 0.06),
    )
    ghost_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(ghost_layer)
    gdraw.polygon(ghost, fill=GHOST_FILL)
    gdraw.line(
        [c for p in ghost for c in p] + list(ghost[0]),
        fill=GHOST_OUTLINE,
        width=max(1, int(round(size * 0.004))),
        joint="curve",
    )
    layer = Image.alpha_composite(layer, ghost_layer)
    draw = ImageDraw.Draw(layer)

    main = transform_poly(CURSOR_POLY, origin=origin, scale=glyph_scale)
    draw_cursor(
        draw,
        main,
        fill=CURSOR_FILL,
        outline=CURSOR_OUTLINE,
        width=max(2.0, size * 0.012),
    )

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    shadow_poly = transform_poly(
        CURSOR_POLY,
        origin=origin,
        scale=glyph_scale,
        offset=(size * 0.012, size * 0.018),
    )
    sdraw.polygon(shadow_poly, fill=(0, 0, 0, 55))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=size * 0.018))
    out = Image.alpha_composite(base, shadow)
    out = Image.alpha_composite(out, layer)
    return out


def downscale(master: Image.Image, size: int) -> Image.Image:
    if size >= master.size[0]:
        return master.copy()
    img = master
    while img.size[0] // 2 >= size:
        img = img.resize((img.size[0] // 2, img.size[1] // 2), Image.Resampling.BOX)
    if img.size[0] != size:
        img = img.resize((size, size), Image.Resampling.LANCZOS)
    return img.convert("RGBA")


def contents_json() -> dict:
    return {
        "images": [
            {
                "filename": filename,
                "idiom": "mac",
                "scale": scale,
                "size": logical,
            }
            for filename, _px, logical, scale in MAC_ICONS
        ],
        "info": {"author": "xcode", "version": 1},
    }


def main() -> None:
    # Remove prior mangled/email-redacted files
    ICONSET.mkdir(parents=True, exist_ok=True)
    for p in ICONSET.iterdir():
        if p.name != "Contents.json":
            p.unlink()

    master = render_master(1024)
    for filename, pixel, _logical, _scale in MAC_ICONS:
        out = downscale(master, pixel)
        path = ICONSET / filename
        out.save(path, format="PNG", optimize=True)
        print(f"wrote {path.name} ({pixel}x{pixel})")

    (ICONSET / "Contents.json").write_text(json.dumps(contents_json(), indent=2) + "\n")
    print("wrote Contents.json")

    preview = master.copy()
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    mask = Image.new("L", (1024, 1024), 0)
    mdraw = ImageDraw.Draw(mask)
    radius = int(1024 * 0.2237)
    mdraw.rounded_rectangle((0, 0, 1023, 1023), radius=radius, fill=255)
    rounded = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    rounded.paste(preview, mask=mask)
    rounded.save(PREVIEW, format="PNG", optimize=True)
    print(f"wrote preview {PREVIEW}")


if __name__ == "__main__":
    main()

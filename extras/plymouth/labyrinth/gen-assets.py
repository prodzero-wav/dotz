#!/usr/bin/env python3
"""Renders the LABYRINTH plymouth PNGs. Edit the palette and re-run to retheme (needs Pillow)."""
from PIL import Image, ImageDraw

# palette (repo colours)
BG    = "#060b09"   # set in labyrinth.script too
DIM   = "#1f3a31"
TEAL  = "#6f9f8b"
BONE  = "#d4cba8"
RUST  = "#b5523b"
RINGS = [DIM, "#476c5e", TEAL, "#8f8a6e", BONE]   # outer -> inner
SIZES = [380, 308, 236, 164, 92]                  # px at 1080p, script scales for other screens
T, SS = 6, 4                                       # line thickness, supersampling

def hexrgb(h): h = h.lstrip("#"); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def ring(size, color, k):
    n = size * SS
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    c = hexrgb(color) + (255,)
    t = T * SS
    d.rectangle([0, 0, n - 1, n - 1], outline=c, width=t)
    g = int(n * 0.30); x0 = (n - g) // 2
    d.rectangle([x0, 0, x0 + g, t], fill=(0, 0, 0, 0))     # gap in the top edge
    im = im.rotate(-90 * k, expand=False)
    return im.resize((size, size), Image.LANCZOS)

for i, (s, col) in enumerate(zip(SIZES, RINGS)):
    for k in range(4):
        ring(s, col, k).save(f"ring{i}_{k}.png")

# centre dot with a soft glow
n = 64 * SS
dot = Image.new("RGBA", (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(dot)
r = hexrgb(RUST)
for rad, a in ((30, 28), (24, 55), (18, 100)):
    d.ellipse([n/2 - rad*SS, n/2 - rad*SS, n/2 + rad*SS, n/2 + rad*SS], fill=r + (a,))
d.ellipse([n/2 - 11*SS, n/2 - 11*SS, n/2 + 11*SS, n/2 + 11*SS], fill=r + (255,))
dot.resize((64, 64), Image.LANCZOS).save("dot.png")

Image.new("RGBA", (4, 4), hexrgb(TEAL) + (255,)).save("bar.png")
Image.new("RGBA", (4, 4), hexrgb(DIM) + (255,)).save("track.png")
print("ok")

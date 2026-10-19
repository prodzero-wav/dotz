#!/usr/bin/env python3
"""Render a theme: take each chezmoi-managed file under ~/.config as chezmoi
would write it (canonical LABYRINTH colours), remap the palette, write it live.
Usage: theme-apply.py <theme>"""
import os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HOME = os.path.expanduser("~")
CFG = os.path.join(HOME, ".config")
CACHE = os.path.join(HOME, ".cache", "labyrinth")
name = sys.argv[1]
mapfile = os.path.join(CFG, "labyrinth", "themes", name + ".map")
if not os.path.isfile(mapfile):
    sys.exit(f"no such theme: {name}")

pairs, wall = {}, None
for line in open(mapfile):
    line = line.split("#", 1)[0] if not line.startswith("wallpaper") else line
    p = line.split()
    if len(p) == 2 and re.fullmatch(r"[0-9a-fA-F]{6}", p[0]) and re.fullmatch(r"[0-9a-fA-F]{6}", p[1]):
        pairs[p[0].lower()] = p[1].lower()
    elif len(p) == 3 and p[0] == "wallpaper" and p[1] in ("solid", "image"):
        wall = (p[1], p[2])

hex_re = re.compile(r"(?<![0-9a-fA-F])(" + "|".join(pairs) + r")(?=(?:[0-9a-fA-F]{2})?(?![0-9a-fA-F]))", re.I) if pairs else None
rgb = {}
for o, n in pairs.items():
    ot = tuple(int(o[i:i+2], 16) for i in (0, 2, 4))
    nt = tuple(int(n[i:i+2], 16) for i in (0, 2, 4))
    rgb[ot] = nt
rgb_re = re.compile(r"(?<![\d.])(\d{1,3})(\s*,\s*)(\d{1,3})\2(\d{1,3})(?![\d])") if pairs else None

def convert(text):
    if not pairs:
        return text
    text = hex_re.sub(lambda m: pairs[m.group(1).lower()], text)
    def r(m):
        t = (int(m.group(1)), int(m.group(3)), int(m.group(4)))
        return m.group(2).join(map(str, rgb.get(t, t)))
    return rgb_re.sub(r, text)

# wallpaper: solid colour (made into a png) or an image; used by sway and the lock screen
wallpng = None
if wall:
    kind, val = wall
    if kind == "image":
        wallpng = os.path.expanduser(val)
    else:
        os.makedirs(CACHE, exist_ok=True)
        wallpng = os.path.join(CACHE, f"wall-{name}.png")
        im = "magick" if subprocess.run(["which", "magick"], capture_output=True).returncode == 0 else "convert"
        subprocess.run([im, "-size", "1920x1080", f"xc:{val}", wallpng], check=True)

def render(path):
    try:
        src = subprocess.run(["chezmoi", "cat", path], capture_output=True, text=True, check=True).stdout
    except Exception:
        return None
    out = convert(src)
    if wallpng:
        if path.endswith("/sway/config"):
            out = re.sub(r"(?m)^output \* bg .*$", f"output * bg {wallpng} fill", out)
        if path.endswith("/sway/scripts/lock.sh"):
            out = re.sub(r'(?m)^WALL=.*$', f'WALL="{wallpng}"', out)
    return path, out

try:
    managed = subprocess.run(["chezmoi", "managed", "--path-style", "absolute", "--include", "files"],
                             capture_output=True, text=True, check=True).stdout.split("\n")
except FileNotFoundError:
    sys.exit("chezmoi not found")
skip = os.path.join(CFG, "labyrinth", "themes") + "/"
paths = [p for p in managed if p.startswith(CFG + "/") and not p.startswith(skip) and os.path.isfile(p)]

changed = 0
with ThreadPoolExecutor(8) as ex:
    for res in ex.map(render, paths):
        if not res:
            continue
        path, out = res
        try:
            if open(path).read() != out:
                with open(path, "w") as f:   # keeps mode/ownership
                    f.write(out)
                changed += 1
        except UnicodeDecodeError:
            pass

open(os.path.join(CFG, "labyrinth", "current-theme"), "w").write(name + "\n")
print(f"{name}: {changed} files updated")

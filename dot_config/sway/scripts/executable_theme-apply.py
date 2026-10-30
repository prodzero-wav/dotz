#!/usr/bin/env python3
"""Render a theme: take each chezmoi-managed file under ~/.config as chezmoi
would write it (canonical LABYRINTH colours), remap the palette, write it live.
Usage: theme-apply.py <theme>"""
import glob, os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HOME = os.path.expanduser("~")
CFG = os.path.join(HOME, ".config")
CACHE = os.path.join(HOME, ".cache", "labyrinth")
name = sys.argv[1]
mapfile = os.path.join(CFG, "labyrinth", "themes", name + ".map")
if not os.path.isfile(mapfile):
    sys.exit(f"no such theme: {name}")

pairs, wall, solid = {}, None, None
for line in open(mapfile):
    line = line.split("#", 1)[0] if not line.startswith("wallpaper") else line
    p = line.split()
    if len(p) == 2 and re.fullmatch(r"[0-9a-fA-F]{6}", p[0]) and re.fullmatch(r"[0-9a-fA-F]{6}", p[1]):
        pairs[p[0].lower()] = p[1].lower()
    elif len(p) == 3 and p[0] == "wallpaper" and p[1] in ("solid", "image", "video"):
        wall = (p[1], p[2])
        if p[1] == "solid":
            solid = wall   # remembered as a fallback if a later video/image is missing

hex_re = re.compile(r"(?<![0-9a-fA-F])(" + "|".join(pairs) + r")(?=(?:[0-9a-fA-F]{2})?(?![0-9a-fA-F]))", re.I) if pairs else None
rgb = {}
for o, n in pairs.items():
    ot = tuple(int(o[i:i+2], 16) for i in (0, 2, 4))
    nt = tuple(int(n[i:i+2], 16) for i in (0, 2, 4))
    rgb[ot] = nt
trip = "|".join(r"%d\s*[,;]\s*%d\s*[,;]\s*%d" % t for t in rgb)
rgb_re = re.compile(r"(?<![\d.])(?:%s)(?!\d)" % trip) if pairs else None

def convert(text):
    if not pairs:
        return text
    text = hex_re.sub(lambda m: pairs[m.group(1).lower()], text)
    def r(m):
        nums = tuple(map(int, re.findall(r"\d+", m.group(0))))
        sep = re.search(r"\s*[,;]\s*", m.group(0)).group(0)
        return sep.join(map(str, rgb[nums]))
    return rgb_re.sub(r, text)

# a missing video/image must not break theme switching: fall back to the theme's solid colour
if wall and wall[0] in ("video", "image") and not os.path.isfile(os.path.expanduser(wall[1])):
    print(f"warning: {wall[1]} not found, using solid wallpaper", file=sys.stderr)
    wall = solid
# wallpaper: solid colour (made into a png) or an image; used by sway and the lock screen
wallpng = None
if wall:
    kind, val = wall
    if kind == "video":
        os.makedirs(CACHE, exist_ok=True)
        wallpng = os.path.join(CACHE, f"wall-{name}.png")
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", os.path.expanduser(val), "-frames:v", "1", wallpng], check=True)
    elif kind == "image":
        wallpng = os.path.expanduser(val)
    else:
        os.makedirs(CACHE, exist_ok=True)
        wallpng = os.path.join(CACHE, f"wall-{name}.png")
        im = "magick" if subprocess.run(["which", "magick"], capture_output=True).returncode == 0 else "convert"
        subprocess.run([im, "-size", "1920x1080", f"xc:{val}", wallpng], check=True)

# ---- settings + style (glass | flat), blur radius, gaps ----
# Canonical files in the repo are the glass look. style() makes value-only edits
# on that text *before* the theme palette is applied, so every theme works with every style.
SET = {"style": "glass", "blur": "9", "gaps": "14"}
try:
    for _l in open(os.path.join(CFG, "labyrinth", "settings")):
        _k, _, _v = _l.strip().partition("=")
        if _k == "style" and _v in ("glass", "flat") or _k in ("blur", "gaps") and _v.isdigit():
            SET[_k] = _v
except OSError:
    pass

_ISLANDS = """.modules-left, .modules-center, .modules-right {
  background: linear-gradient(90deg, rgba(6, 11, 9, 0.78), rgba(22, 42, 35, 0.55));
  border: 1px solid rgba(212, 203, 168, 0.32);
  padding: 0 6px;
}
.modules-right {
  background: linear-gradient(270deg, rgba(6, 11, 9, 0.78), rgba(22, 42, 35, 0.55));
}"""
_LAYERS = {"waybar": "shadows disable", "launcher": "shadows enable", "notifications": "shadows disable"}

def style(path, t):
    if path.endswith("/sway/config"):
        t = re.sub(r"(?m)^gaps inner \d+", "gaps inner " + SET["gaps"], t)
        t = re.sub(r"(?m)^blur_radius \d+", "blur_radius " + SET["blur"], t)
    if SET["style"] != "flat":
        return t
    if path.endswith("/sway/config"):
        t = re.sub(r"(?m)^(default(?:_floating)?_border pixel) \d+", r"\1 2", t)
        t = re.sub(r"(?m)^client\.focused .*$", "client.focused          $bone  $bg $bone $bone  $bone", t)
        t = re.sub(r"(?m)^client\.focused_inactive .*$", "client.focused_inactive $green $bg $dim  $green $green", t)
        t = re.sub(r"(?m)^client\.unfocused .*$", "client.unfocused        $green $bg $dim  $green $green", t)
        t = re.sub(r"(?m)^corner_radius \d+", "corner_radius 0", t)
        t = re.sub(r"(?m)^blur enable", "blur disable", t)
        t = re.sub(r"(?m)^shadow_blur_radius \d+", "shadow_blur_radius 55", t)
        t = re.sub(r"(?m)^default_dim_inactive [\d.]+", "default_dim_inactive 0.25", t)
        t = re.sub(r'(?m)^layer_effects "(\w+)" .*$', lambda m: 'layer_effects "%s" %s' % (m[1], _LAYERS.get(m[1], "shadows disable")), t)
        t = re.sub(r'(?m)^(for_window \[app_id="\^\(\?!.*\] opacity) [\d.]+', r"\1 0.95", t)
        t = re.sub(r'(?m)^(for_window \[app_id="firefox"\] opacity) [\d.]+', r"\1 0.9", t)
    elif path.endswith("/sway/scripts/borderglow.py"):
        t = t.replace('f"client.focused {c}99 #060b0966 {c} {c}99 {c}99; shadow_color {c}66"',
                      'f"client.focused {c} #060b09 {c} {c} {c}; shadow_color {c}66"')
    elif path.endswith("/waybar/style.css"):
        t = re.sub(r"window#waybar \{.*?\n\}", "window#waybar {\n  background: transparent;\n  color: #d4cba8;\n}", t, count=1, flags=re.S)
        t = re.sub(r"\.modules-left, \.modules-center, \.modules-right \{.*?\n\}", lambda m: _ISLANDS, t, count=1, flags=re.S)
        t = t.replace("  margin: 4px 2px;\n  border-radius: 10px;\n", "")
        t = t.replace("  border: 1px solid transparent;\n", "  border-bottom: 2px solid transparent;\n")
        t = t.replace("  border: 1px solid rgba(212, 203, 168, 0.28);", "  border-bottom: 2px solid #d4cba8;")
        t = t.replace("rgba(111, 159, 139, 0.22)", "rgba(111, 159, 139, 0.16)")
        t = t.replace("border-color: #b5523b; }", "border-bottom-color: #b5523b; }")
        t = re.sub(r"tooltip \{[^\n]*\}", "tooltip { background: #060b09; border: 1px solid #6f9f8b; }", t, count=1)
    elif path.endswith("/fuzzel/fuzzel.ini"):
        for k, v in (("background", "060b09e6"), ("text", "8f8a6eff"), ("selection", "1f3a31ff"), ("border", "d4cba8ff"), ("radius", "0")):
            t = re.sub(r"(?m)^%s=\w+" % k, "%s=%s" % (k, v), t)
    elif path.endswith("/mako/config"):
        t = re.sub(r"(?m)^background-color=.*", "background-color=#060b09dd", t)
        t = t.replace("border-color=#6f9f8b66", "border-color=#6f9f8b")
        t = re.sub(r"(?m)^border-radius=\d+", "border-radius=0", t)
    elif path.endswith("/swayosd/style.css"):
        t = t.replace("border-radius: 16px;", "border-radius: 0;").replace("border-radius: 6px;", "border-radius: 0;")
        t = t.replace("rgba(212, 203, 168, 0.25)", "rgba(212, 203, 168, 0.4)").replace("rgba(6, 11, 9, 0.55)", "rgba(6, 11, 9, 0.88)")
    elif path.endswith("/foot/foot.ini"):
        t = t.replace("alpha=0.72", "alpha=0.78")
    return t

def render(path):
    try:
        src = subprocess.run(["chezmoi", "cat", path], capture_output=True, text=True, check=True).stdout
    except Exception:
        return None
    out = convert(style(path, src))
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

def firefox():
    """Firefox chrome CSS lives in the profile, not ~/.config: regenerate it from extras/firefox-theme.sh."""
    try:
        srcdir = subprocess.run(["chezmoi", "source-path"], capture_output=True, text=True, check=True).stdout.strip()
        text = open(os.path.join(srcdir, "extras", "firefox-theme.sh")).read()
    except Exception:
        return 0
    files = dict(re.findall(r"cat > \"\$p/chrome/(userChrome\.css|userContent\.css)\" << 'EOF'\n(.*?)\nEOF\n", text, re.S))
    n = 0
    for base in (os.path.join(HOME, ".mozilla", "firefox"), os.path.join(CFG, "mozilla", "firefox")):
        for p in glob.glob(base + "/*.default-release") + glob.glob(base + "/*.default"):
            os.makedirs(os.path.join(p, "chrome"), exist_ok=True)
            for fn, css in files.items():
                path, out = os.path.join(p, "chrome", fn), convert(css) + "\n"
                if not os.path.isfile(path) or open(path).read() != out:
                    open(path, "w").write(out)
                    n += 1
    return n

ff = firefox()
open(os.path.join(CFG, "labyrinth", "current-theme"), "w").write(name + "\n")
print(f"{name}: {changed} files updated" + (f", {ff} firefox files" if ff else ""))

#!/usr/bin/env python3
# Shutdown: scanline glitch, CRT collapse to a line, then a dot, then black.
import sys, time, random, shutil

BONE = (212, 203, 168)
FLOOR = (6, 11, 9)
TEAL = (111, 159, 139)
RUST = (181, 82, 59)
DIM = (31, 58, 49)

W = sys.stdout.write
cols, rows = shutil.get_terminal_size()

def bg(c): return f"\x1b[48;2;{c[0]};{c[1]};{c[2]}m"
def lerp(a, b, t): return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
def row(y, x, n, c): W(f"\x1b[{y+1};{x+1}H{bg(c)}" + " " * max(n, 0))
def clear(): W(bg(FLOOR) + "\x1b[2J")
def frame(t): W("\x1b[0m"); sys.stdout.flush(); time.sleep(t)

W("\x1b[?1049h\x1b[?25l"); clear()
try:
    for f in range(22):  # glitch: tearing scanlines, getting denser
        for _ in range(int(rows * (0.05 + f / 22 * 0.9))):
            x = random.randrange(cols)
            w = min(random.randint(max(cols // 12, 1), max(cols // 2, 2)), cols - x)
            row(random.randrange(rows), x, w, random.choice((BONE, TEAL, TEAL, RUST, DIM, FLOOR)))
        frame(0.04)
    for f in range(14):  # collapse: bone field shrinks to a line
        h = max(1, int(rows * (1 - f / 13) ** 2))
        clear()
        for y in range((rows - h) // 2, (rows - h) // 2 + h):
            row(y, 0, cols, BONE)
        frame(0.025)
    y = rows // 2
    for f in range(16):  # line shrinks to a dot
        w = max(2, int(cols * (1 - f / 15) ** 2.2))
        clear(); row(y, (cols - w) // 2, w, BONE); frame(0.03)
    for f in range(14):  # dot fades out
        clear(); row(y, cols // 2 - 1, 2, lerp(BONE, FLOOR, f / 13)); frame(0.045)
    clear(); frame(0.35)
finally:
    W("\x1b[0m\x1b[?25h\x1b[?1049l"); sys.stdout.flush()

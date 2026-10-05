#!/usr/bin/env python3
# Carves a maze out of bone, floods it, then walks the way out. Any key quits.
import sys, time, random, select, shutil, termios, tty
from collections import deque

WALL = (212, 203, 168)
FLOOR = (6, 11, 9)
DEAD = (31, 58, 49)
TRAIL = (111, 159, 139)
HEAD = (239, 232, 204)

def put(x, y, c):
    sys.stdout.write(f"\x1b[{y+1};{x*2+1}H\x1b[48;2;{c[0]};{c[1]};{c[2]}m  ")

def nap(t):
    sys.stdout.flush()
    if select.select([sys.stdin], [], [], t)[0]:
        raise SystemExit

def maze():
    cols, rows = shutil.get_terminal_size()
    PW, PH = cols // 2, rows
    if PW % 2 == 0: PW -= 1
    if PH % 2 == 0: PH -= 1
    sys.stdout.write("\x1b[2J")
    for y in range(rows):
        sys.stdout.write(f"\x1b[{y+1};1H\x1b[48;2;{WALL[0]};{WALL[1]};{WALL[2]}m" + " " * cols)
    op = [[False] * PW for _ in range(PH)]

    def carve(x, y, c=FLOOR):
        op[y][x] = True
        put(x, y, c)

    carve(1, 1)
    stack = [(1, 1)]
    while stack:
        x, y = stack[-1]
        nb = [(x+dx, y+dy, dx, dy) for dx, dy in ((2,0),(-2,0),(0,2),(0,-2))
              if 0 < x+dx < PW-1 and 0 < y+dy < PH-1 and not op[y+dy][x+dx]]
        if nb:
            nx, ny, dx, dy = random.choice(nb)
            carve(x + dx//2, y + dy//2)
            carve(nx, ny)
            stack.append((nx, ny))
            nap(0.004)
        else:
            stack.pop()

    start, goal = (0, 1), (PW-1, PH-2)
    carve(*start); carve(*goal)
    nap(0.8)

    prev = {start: None}
    q = deque([start]); n = 0
    while q:
        cur = q.popleft()
        if cur == goal: break
        for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
            nx, ny = cur[0]+dx, cur[1]+dy
            if 0 <= nx < PW and 0 <= ny < PH and op[ny][nx] and (nx, ny) not in prev:
                prev[(nx, ny)] = cur
                q.append((nx, ny))
                put(nx, ny, DEAD)
                n += 1
                if n % 3 == 0: nap(0.003)

    path, c = [], goal
    while c:
        path.append(c); c = prev[c]
    path.reverse()
    for i, (x, y) in enumerate(path):
        put(x, y, HEAD)
        if i: put(*path[i-1], TRAIL)
        nap(0.012)
    nap(4)

def main():
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setcbreak(fd)
        sys.stdout.write("\x1b[?1049h\x1b[?25l")
        while True:
            maze()
    except (SystemExit, KeyboardInterrupt):
        pass
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)
        sys.stdout.write("\x1b[0m\x1b[?25h\x1b[?1049l")
        sys.stdout.flush()

main()

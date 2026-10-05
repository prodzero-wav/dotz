#!/usr/bin/env python3
# Pulses the focused border + glow between bone and teal.
import math, os, socket, struct, time

A = (212, 203, 168)
B = (111, 159, 139)

def recvall(s, n):
    buf = b""
    while len(buf) < n:
        chunk = s.recv(n - len(buf))
        if not chunk:
            raise SystemExit
        buf += chunk
    return buf

def run(s, cmd):
    b = cmd.encode()
    s.sendall(b"i3-ipc" + struct.pack("=II", len(b), 0) + b)
    hdr = recvall(s, 14)
    recvall(s, struct.unpack("=I", hdr[6:10])[0])

try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(os.environ["SWAYSOCK"])
    last, t0 = None, time.time()
    while True:
        f = (math.sin((time.time() - t0) * 2 * math.pi / 8) + 1) / 2
        c = "#%02x%02x%02x" % tuple(round(a + (b - a) * f) for a, b in zip(A, B))
        if c != last:
            run(s, f"client.focused {c} #060b09 {c} {c} {c}; shadow_color {c}66")
            last = c
        time.sleep(0.1)
except (SystemExit, KeyboardInterrupt, ConnectionError, BrokenPipeError):
    pass

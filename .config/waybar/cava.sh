#!/usr/bin/env bash
# Cava visualizer cho Waybar:
# cava xuất raw 8-bit (1 byte/cột/frame) -> python chuyển thành ký tự block
exec cava -p "$HOME/.config/waybar/cava.conf" 2>/dev/null | python3 -u -c '
import sys

N = 14                       # phải khớp "bars" trong cava.conf
chars = "▁▂▃▄▅▆▇█"
stdin = sys.stdin.buffer
while (b := stdin.read(N)) and len(b) == N:
    sys.stdout.write("".join(chars[min(v * 8 >> 8, 7)] for v in b) + "\n")
'

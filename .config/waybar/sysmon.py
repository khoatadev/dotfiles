#!/usr/bin/env python3
"""Module 'custom/sysmon' cho Waybar: CPU + RAM + Nhiệt độ trong một pill.

Output: JSON {"text": pango} — chỉ dòng hiển thị trên bar.
"""
import glob
import json
import time

C_BASE = "#cdd6f4"   # màu chữ thường
C_WARN = "#f9e2af"   # vàng khi > 70
C_CRIT = "#f38ba8"   # đỏ khi > 90


def color(pct, temp=False):
    if temp:
        pct = pct / 10  # nhiệt độ: 90°C coi như ngưỡng 90%
    if pct > 90:
        return C_CRIT
    if pct > 70:
        return C_WARN
    return C_BASE


def read_stat():
    with open("/proc/stat") as f:
        return [ln for ln in f if ln.startswith("cpu")]


def cpu_usage():
    """Đo usage tổng + từng lõi trong cửa sổ 0.3s."""
    a = read_stat()
    time.sleep(0.3)
    b = read_stat()
    total, cores = 0.0, []
    for la, lb in zip(a, b):
        pa = [int(x) for x in la.split()[1:]]
        pb = [int(x) for x in lb.split()[1:]]
        d = [y - x for x, y in zip(pa, pb)]
        tot = sum(d)
        pct = 100.0 * (1 - (d[3] + d[4]) / tot) if tot else 0.0
        name = la.split()[0]
        if name == "cpu":
            total = pct
        else:
            cores.append(pct)
    return total, cores


def mem_info():
    info = {}
    with open("/proc/meminfo") as f:
        for ln in f:
            k, v = ln.split(":")
            info[k] = int(v.split()[0]) / 1024 / 1024  # kB -> GB
    total = info["MemTotal"]
    used = total - info["MemAvailable"]
    swap_t = info.get("SwapTotal", 0)
    swap_u = swap_t - info.get("SwapFree", 0)
    return used, total, 100 * used / total, swap_u, swap_t


def cpu_temp():
    """Tự dò sensor coretemp, lấy nhiệt độ Package — không phụ thuộc số hwmon."""
    for p in glob.glob("/sys/class/hwmon/hwmon*"):
        try:
            with open(p + "/name") as f:
                if f.read().strip() != "coretemp":
                    continue
            for lbl in sorted(glob.glob(p + "/temp*_label")):
                with open(lbl) as f:
                    if "Package" in f.read():
                        with open(lbl.replace("_label", "_input")) as f:
                            return int(f.read()) / 1000
        except OSError:
            continue
    return None


def bar(pct, width=10):
    filled = round(pct / 100 * width)
    return "█" * filled + "░" * (width - filled)


total_cpu, cores = cpu_usage()
used, ram_t, ram_p, swap_u, swap_t = mem_info()
temp = cpu_temp()

# ----- dòng trên bar -----
text = ""
if temp is not None:
    text += f"<span color='{color(temp, temp=True)}'>󰔏 {temp:.0f}°C</span>  "
text += f"<span color='{color(ram_p)}'>󰍛 {ram_p:.0f}%</span>  "
text += f"<span color='{color(total_cpu)}'>󰻠 {total_cpu:.0f}%</span>"

print(json.dumps({"text": text}))

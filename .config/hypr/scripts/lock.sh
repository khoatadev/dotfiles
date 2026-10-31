#!/usr/bin/env bash
# lock.sh — đồng bộ wallpaper hiện tại của awww vào màn hình khóa rồi mới mở hyprlock
#
# Cách hoạt động:
#   1. Hỏi awww đang hiển thị wallpaper nào (awww query)
#   2. Cập nhật symlink $LOCK_BG trỏ tới file đó (atomic qua tmp + mv -T)
#   3. exec hyprlock — hyprlock.conf đọc nền từ $LOCK_BG
#
# hypridle gọi script này qua lock_cmd; guard pidof chống 2 instance chồng nhau.

set -u

LOCK_BG="$HOME/.config/hypr/lock-bg.png"

# Chống double-lock (phòng khi được gọi ngoài lock_cmd)
if pidof hyprlock >/dev/null 2>&1; then
    exit 0
fi

if ! command -v hyprlock >/dev/null 2>&1; then
    notify-send "Lock screen" "hyprlock is not installed." 2>/dev/null
    exit 1
fi

# ── Đồng bộ wallpaper từ awww ──
# Output mẫu: ": eDP-1: 1920x1200, scale: 1, currently displaying: image: /path/to/img"
if command -v awww >/dev/null 2>&1; then
    img="$(awww query 2>/dev/null | sed -n 's/.*image: //p' | tail -n 1)"
    # awww transition in progress vẫn trả về path đích — chỉ cập nhật khi file tồn tại
    if [[ -n "${img:-}" && -f "$img" ]]; then
        tmp="${LOCK_BG}.tmp.$$"
        if ln -s "$img" "$tmp" && mv -Tf "$tmp" "$LOCK_BG"; then
            :
        else
            rm -f "${tmp:-}"
        fi
    fi
fi

# Thất bại đồng bộ không chặn việc khóa — symlink cũ vẫn dùng được
exec hyprlock

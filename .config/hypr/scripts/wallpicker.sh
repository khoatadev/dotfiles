#!/usr/bin/env bash
# Wallpaper picker — rofi + awww (fork của swww)
# SUPER + W -> rofi list có thumbnail; chọn -> awww img với transition random
#
# Dùng:
#   wallpicker.sh                 mở rofi picker
#   wallpicker.sh --pick <tên>    áp trực tiếp 1 file (không qua rofi)
#   wallpicker.sh --roll          debug: in 1 bộ transition args ngẫu nhiên

WALLDIR="$HOME/Pictures/Wallpapers"
CMD="awww"       # fork của swww đang dùng trên máy
BASE_DUR="1.6"   # duration gốc (giây) — jitter ±15% lúc apply
FPS="120"
LASTFILE="${XDG_RUNTIME_DIR:-/tmp}/wallpicker_last_type"

# ---------- helpers ----------
rnum() { awk -v a="$1" -v b="$2" 'BEGIN{printf "%.2f", a+rand()*(b-a)}'; }
rint() { echo $(( RANDOM % ($2 - $1 + 1) + $1 )); }
pick() { local -a arr=("$@"); echo "${arr[RANDOM % ${#arr[@]}]}"; }

# Tâm circle cho grow/outer: nửa random hoàn toàn, nửa chọn từ các "neo" đẹp
random_pos() {
	if (( RANDOM % 2 )); then
		echo "$(rnum 0.1 0.9),$(rnum 0.1 0.9)"
	else
		pick "center" "0.15,0.15" "0.85,0.15" "0.15,0.85" "0.85,0.85"
	fi
}

# Pool transition — mỗi generator sinh args với tham số ngẫu nhiên
gen_fade()  { echo "--transition-type fade --transition-bezier $(pick .29,.73,.47,1.00 .65,0,.35,1 0,.55,.45,1 .55,.06,.68,.19)"; }
gen_grow()  { echo "--transition-type grow --transition-pos $(random_pos)"; }
gen_outer() { echo "--transition-type outer --transition-pos $(random_pos)"; }
gen_wipe()  { echo "--transition-type wipe --transition-angle $(rint 0 359)"; }
gen_wave()  { echo "--transition-type wave --transition-angle $(rint 0 359) --transition-wave $(rint 120 420),$(rint 20 70)"; }
gen_fixed() { echo "--transition-type $(pick center any simple)"; }
gen_dir()   { echo "--transition-type $(pick left right top bottom)"; }

# Random 1 transition, cố tránh lặp kiểu vừa dùng (re-roll tối đa 3 lần)
roll_transition() {
	local last="" gen args type
	[[ -f $LASTFILE ]] && last=$(<"$LASTFILE")
	for _ in 1 2 3; do
		gen=$(pick gen_fade gen_grow gen_outer gen_wipe gen_wave gen_fixed gen_dir)
		args=$($gen)
		type=${args#--transition-type }
		type=${type%% *}
		[[ $type != "$last" ]] && break
	done
	echo "$type" > "$LASTFILE"
	echo "$args"
}

apply() {
	local img="$1" args dur
	args=$(roll_transition)
	# duration jitter ±15% -> mỗi lần đổi có nhịp riêng
	dur=$(awk -v d="$BASE_DUR" 'BEGIN{printf "%.2f", d*(0.85+rand()*0.3)}')
	"$CMD" img "$img" $args --transition-duration "$dur" --transition-fps "$FPS"
	echo "[wallpicker] $(basename "$img") | $args | dur=$dur"
}

# ---------- danh sách wallpaper ----------
shopt -s nullglob nocaseglob
mapfile -t files < <(find "$WALLDIR" -maxdepth 1 -type f \
	\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
	-o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.gif' \) | sort)
shopt -u nullglob nocaseglob

if ((${#files[@]} == 0)); then
	rofi -e "Không tìm thấy wallpaper trong $WALLDIR"
	exit 1
fi

# ---------- menu ----------
case "${1:-}" in
--pick)
	# áp trực tiếp theo tên file
	for f in "${files[@]}"; do
		[[ ${f##*/} == "$2" ]] && apply "$f" && exit 0
	done
	echo "Không tìm thấy: $2" >&2
	exit 1
	;;
--roll)
	roll_transition
	exit 0
	;;
*)
	# rofi dmenu protocol: entry\0icon\x1f<path>  (printf %b sinh NUL + 0x1F thật)
	gen_entries() {
		local f
		for f in "${files[@]}"; do
			printf '%b\n' "${f##*/}\0icon\x1f$f"
		done
	}

	sel=$(gen_entries | rofi -dmenu -i -p "Wallpaper" \
		-disable-history \
		-theme-str '
* { font: "Comicshannsmono Nerd Font 14"; }
window {
    width: 700px;
    padding: 10px;
    background-color: rgba(26, 27, 38, 93%);
    border: 2px;
    border-color: rgba(137, 180, 250, 25%);
    border-radius: 12px;
}
inputbar {
    padding: 10px 14px;
    background-color: transparent;
    text-color: #cdd6f4;
}
prompt { text-color: #89b4fa; }
entry {
    text-color: #cdd6f4;
    placeholder: "Type to filter";
    placeholder-color: #6c7086;
}
listview {
    lines: 8;
    fixed-height: false;
    scrollbar: true;
    background-color: transparent;
}
scrollbar { width: 4px; handle-color: #89b4fa; }
element {
    orientation: horizontal;
    spacing: 14px;
    padding: 8px 12px;
    border-radius: 10px;
}
element normal.normal {
    background-color: transparent;
    text-color: #cdd6f4;
}
element alternate.normal {
    background-color: rgba(255, 255, 255, 3%);
    text-color: #cdd6f4;
}
element selected.normal {
    background-color: #31364a;
    text-color: #ffffff;
}
element-icon { size: 3.2em; background-color: transparent; }
element-text { vertical-align: 0.5; text-color: inherit; }')

	# Esc / không chọn -> thoát
	[[ -n ${sel:-} ]] || exit 0
	for f in "${files[@]}"; do
		[[ ${f##*/} == "$sel" ]] && apply "$f" && exit 0
	done
	echo "Không tìm thấy: $sel" >&2
	exit 1
	;;
esac

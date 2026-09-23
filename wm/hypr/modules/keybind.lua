--#==========================================#
--#     __ __           __    _           __ #
--#    / //_/__  __  __/ /_  (_)___  ____/ / #
--#   / ,< / _ \/ / / / __ \/ / __ \/ __  /  #
--#  / /| /  __/ /_/ / /_/ / / / / / /_/ /   #
--# /_/ |_\___/\__, /_.___/_/_/ /_/\__,_/    #
--#           /____/                         #
--#==========================================#

local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "kitty yazi"
local menu = "rofi -show drun"
local browser = "zen"

-- Shortcuts
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + Z", hl.dsp.exec_cmd(browser))

-- Media
hl.bind("ALT + F1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("ALT + F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("ALT + F3", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))

-- Playerctl
hl.bind("SUPER + F1", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SUPER + F2", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + F3", hl.dsp.exec_cmd("playerctl next"))

-- Brightnessctl
hl.bind("ALT + F4", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("ALT + F5", hl.dsp.exec_cmd("brightnessctl set 5%+"))

-- Screenshot
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim ~/Pictures/Screenshots/$(date +'%d-%m-%Y_%H-%M-%S.png')"))
hl.bind("Print", hl.dsp.exec_cmd("grim -g $(slurp) ~/Pictures/Screenshots/$(date +'%d-%m-%Y_%H-%M-%S.png')"))

-- Close Window
hl.bind("SUPER + Q", hl.dsp.window.close())

hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus windows
hl.bind("ALT + left", hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + right", hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + up", hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspace
for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + left", hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/Resize Window
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Exit Hyprland
hl.bind(
	"SUPER + SHIFT + Escape",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

local Terminal = "kitty"
local FileManager = "kitty spf"
local Browser = "zen"
local Launcher = "rofi -show drun"

-- Shortcuts
hl.bind("SUPER + T", hl.dsp.exec_cmd(Terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(FileManager))
hl.bind("SUPER + D", hl.dsp.exec_cmd(Launcher))
hl.bind("SUPER + Z", hl.dsp.exec_cmd(Browser))

-- media
hl.bind("CTRL + F1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("CTRL + F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("CTRL + F3", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))

-- brightnessctl
hl.bind("CTRL + F4", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("CTRL + F5", hl.dsp.exec_cmd("brightnessctl set 5%+"))

-- playerctl
hl.bind("SUPER + F1", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + F2", hl.dsp.exec_cmd("playerctl next"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("playerctl play-pause"))

-- screenshot
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots/ -f $(date +%F_%H-%M-%S).png"))
hl.bind(
	"SUPER + SHIFT + P",
	hl.dsp.exec_cmd("hyprshot -m active -m output -o ~/Pictures/Screenshots/ -f $(date +%F_%H-%M-%S).png")
)

-- Close window
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Exit Hyprland
hl.bind("SUPER + SHIFT_L + Escape", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"))

-- Move focus window
hl.bind("ALT + left", hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + right", hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + up", hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + down", hl.dsp.focus({ direction = "down" }))

-- Move focus workspaces
hl.bind("SUPER + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + left", hl.dsp.focus({ workspace = "e-1" }))

-- workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- special workspaces
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize window
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
--hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
--hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

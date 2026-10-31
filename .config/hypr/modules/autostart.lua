hl.on("hyprland.start", function()
	hl.exec_cmd("fcitx5 -d")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("waybar")
	hl.exec_cmd("qs -c cava-shell") -- CAVA visualizer trên layer wallpaper
end)

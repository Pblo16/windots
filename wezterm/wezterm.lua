-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12.0
config.line_height = 1.2
config.cursor_blink_rate = 2000
-- Terminal color scheme (Horizon Dark)
config.colors = {
	foreground = "#FDF0ED",
	background = "#16191d",
	cursor_bg = "#FDF0ED",
	cursor_fg = "#1C1E26",
	cursor_border = "#FDF0ED",
	selection_fg = "#1C1E26",
	selection_bg = "#FDF0ED",
	scrollbar_thumb = "#232530",
	split = "#777474",
	ansi = {
		"#16161C", -- Black
		"#E95678", -- Red
		"#29D398", -- Green
		"#FAB795", -- Yellow
		"#26BBD9", -- Blue
		"#EE64AE", -- Purple/Magenta
		"#59E3E3", -- Cyan
		"#FADAD1", -- White
	},
	brights = {
		"#F075B7", -- Bright Black
		"#EC6A88", -- Bright Red
		"#3FDAA4", -- Bright Green
		"#FBC3A7", -- Bright Yellow
		"#3FC6DE", -- Bright Blue
		"#F075B7", -- Bright Purple/Magenta
		"#6BE6E6", -- Bright Cyan
		"#FDF0ED", -- Bright White
	},
}

-- This is where you actually apply your config choices
config.window_padding = {
	top = 5,
	right = 0,
	left = 5,
	bottom = 0,
}

-- Background
config.window_background_opacity = 1.00 -- Adjust this value as needed
-- config.win32_system_backdrop = "Acrylic" -- Only Works in Windows

-- UI
config.window_decorations = "NONE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.max_fps = 144 -- hack for smoothness

-- activate only if windows --

config.default_domain = "WSL:Ubuntu"
config.front_end = "OpenGL"
local gpus = wezterm.gui.enumerate_gpus()
if #gpus > 0 then
	config.webgpu_preferred_adapter = gpus[1] -- only set if there's at least one GPU
else
	-- fallback to default behavior or log a message
	wezterm.log_info("No GPUs found, using default settings")
end

config.keys = {
	{ key = "d", mods = "CTRL|ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "CTRL|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "q", mods = "CTRL|ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{ key = "h", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL|ALT", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
}
-- and finally, return the configuration to wezterm
return config


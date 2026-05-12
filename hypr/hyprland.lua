-- Hyprland 0.55+ Lua configuration
-- Split into: colors.lua · binds.lua · hyprland.lua (this file)
-- LSP stubs:  /usr/share/hypr/stubs/hl.meta.lua

local colors = require("colors")
require("binds")


-- Monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.00 })

-- Environment
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-- Autostart (runs once on login, not on config reload)
hl.on("hyprland.start", function()
	hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("xdman --background")
	hl.exec_cmd("jamesdsp -t")

	hl.exec_cmd("kitty -d ~/Projects/ --start-as=fullscreen", { workspace = "1" })
	hl.exec_cmd("brave", { workspace = "2" })
	hl.exec_cmd("spotify", { workspace = "special:magic" })

	hl.exec_cmd("nm-applet")
	hl.exec_cmd("waybar")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("swaync")
end)


-- Config
hl.config({
	general    = {
		gaps_in          = 5,
		gaps_out         = 20,

		border_size      = 1,
		col              = {
			active_border   = { colors = { colors.mat_primary, colors.mat_tertiary }, angle = 45 },
			inactive_border = colors.mat_surface_variant,
		},

		resize_on_border = false,
		allow_tearing    = false,
		layout           = "master",
	},

	decoration = {
		rounding         = 14,
		rounding_power   = 4,

		active_opacity   = 1.0,
		inactive_opacity = 0.9,

		shadow           = {
			enabled      = true,
			range        = 4,
			render_power = 2,
			color        = 0xCC040317,
		},

		blur             = {
			enabled  = true,
			size     = 6,
			passes   = 2,
			vibrancy = 0.1696,
		},
	},

	animations = { enabled = true },

	dwindle    = { preserve_split = true },
	master     = { new_status = "master" },

	misc       = {
		force_default_wallpaper = -1,
		disable_hyprland_logo   = false,
	},

	input      = {
		kb_layout    = "us",
		kb_options   = "caps:swapescape",

		follow_mouse = 1,
		sensitivity  = 0,

		touchpad     = { natural_scroll = false },
	},
})


-- Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Animations
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5.94, bezier = "easeOutQuint" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 4.21, bezier = "easeInOutCubic" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.94, bezier = "easeInOutCubic" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })


-- Per-device input
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })


-- Window rules
hl.window_rule({
	name           = "suppress-maximize-events",
	match          = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name     = "fix-xwayland-drags",
	match    = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

hl.window_rule({
	name  = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move  = "20 monitor_h-120",
	float = true,
})

-- Spotify — semi-transparent to pair with Spicetify theme; matches both class casings
hl.window_rule({
	name    = "spotify-opacity",
	match   = { class = "^[Ss]potify$" },
	opacity = "0.92 0.88",
})

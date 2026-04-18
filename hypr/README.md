# Hypr + Matugen setup — cheatsheet

Quick reference for the rice you already have running. Everything here is
tested on your machine — paste commands straight into a terminal.

---

## 1. Where everything lives

| Thing | Path |
|---|---|
| Hyprland config | `~/.config/hypr/hyprland.conf` |
| Keybinds | `~/.config/hypr/binds.conf` |
| Wallpaper daemon config (legacy, unused) | `~/.config/hypr/hyprpaper.conf` |
| Wallpaper rotator script | `~/.config/hypr/scripts/wallpaper.sh` |
| Wallpaper skip helper | `~/.config/hypr/scripts/wallpaper-skip.sh` |
| Hyprlock | `~/.config/hypr/hyprlock.conf` |
| Hyprlock colors (generated) | `~/.config/hypr/hyprlock-colors.conf` |
| Hyprland border colors (generated) | `~/.config/hypr/colors.conf` |
| Matugen config | `~/.config/matugen/config.toml` |
| Matugen templates | `~/.config/matugen/templates/` |
| Waybar | `~/.config/waybar/{style.css,config}` |
| Waybar colors (generated) | `~/.config/waybar/colors.css` |
| Wofi | `~/.config/wofi/{style.css,config}` |
| Wofi colors (generated) | `~/.config/wofi/colors.css` |
| Swaync | `~/.config/swaync/{style.css,config.json}` |
| Swaync colors (generated) | `~/.config/swaync/colors.css` |
| Kitty | `~/.config/kitty/kitty.conf` |
| Kitty theme (generated) | `~/.config/kitty/matugen-theme.conf` |
| Rofi (bonus) | `~/.config/rofi/{config.rasi,theme.rasi,colors.rasi}` |

Files marked *(generated)* are overwritten by matugen every wallpaper change —
**never edit them by hand**, edit the template under `~/.config/matugen/templates/` instead.

---

## 2. Wallpapers

### Change interval or transition
Edit `~/.config/hypr/scripts/wallpaper.sh`:

```bash
INTERVAL=300                 # seconds between changes
TRANSITION_TYPE="any"        # any|simple|left|right|top|bottom|wipe|wave|grow|center|outer|random
TRANSITION_DURATION=1
```

Restart the script after:

```bash
kill "$(cat /run/user/1000/wallpaper.pid)" 2>/dev/null
nohup ~/.config/hypr/scripts/wallpaper.sh > /tmp/wallpaper.log 2>&1 & disown
```

### Skip to next image
Press `SUPER + W`, or:

```bash
~/.config/hypr/scripts/wallpaper-skip.sh
```

### Set a specific wallpaper manually
```bash
awww img /path/to/image.png --transition-type any
matugen --prefer saturation image /path/to/image.png    # refresh colors
```

### Change wallpaper folder
Edit `WALLPAPER_DIR` in `scripts/wallpaper.sh`. Default `$HOME/Pictures`.

### The daemon is dead / weird behaviour
```bash
pkill awww-daemon
awww-daemon > /tmp/awww.log 2>&1 & disown
awww query            # should print monitor info
```

---

## 3. Matugen (color generation)

### Force-regenerate colors right now
```bash
CURRENT=$(awww query | awk -F'image: ' '{print $2}')
matugen --prefer saturation image "$CURRENT"
```

### Change the color mood
`--prefer` options: `darkness`, `lightness`, `saturation`, `less-saturation`, `value`, `closest-to-fallback`.
Edit the call inside `scripts/wallpaper.sh` if you want a different default.

### Switch dark ↔ light
Edit `~/.config/matugen/config.toml`:
```toml
[config]
reload_apps = true
mode = "light"    # or "dark" (default)
```

### Use a fixed seed color instead of wallpaper
```bash
matugen color hex "#ff6b9d"
```

### Tweak a template
Edit the corresponding file under `~/.config/matugen/templates/`:
- `gtk-colors.css` — waybar/wofi/swaync shared palette
- `kitty-theme.conf` — kitty terminal
- `hyprland-colors.conf` — window border variables
- `hyprlock-colors.conf` — lock screen colors
- `rofi-colors.rasi` — rofi

Then regenerate: `matugen --prefer saturation image "$(awww query | awk -F'image: ' '{print $2}')"`.

### Available color tokens
Most useful inside templates:
`primary`, `on_primary`, `primary_container`, `on_primary_container`,
`secondary`, `tertiary`, `error`, `surface`, `on_surface`,
`surface_container`, `surface_container_high`, `surface_container_lowest`,
`surface_variant`, `on_surface_variant`, `outline`, `outline_variant`,
`shadow`, `inverse_primary`, `background`.

Format: `{{colors.primary.default.hex}}` (with `#`) or `{{colors.primary.default.hex_stripped}}` (without).

---

## 4. Reloading apps

| App | Command | What it does |
|---|---|---|
| Hyprland | `hyprctl reload` | Re-reads hyprland.conf + sourced files |
| Waybar | `pkill -SIGUSR2 waybar` | Hot-reloads CSS + config |
| Swaync | `swaync-client -rs` | Reloads style.css + config.json |
| Kitty (running) | `pkill -SIGUSR1 kitty` | Re-reads kitty.conf (includes theme) |
| Hyprlock | N/A — spawned on demand | New colors next lock |
| Wofi/Rofi | N/A — spawned on demand | New colors next launch |

All of these already fire automatically when matugen regenerates via
post-hooks in `matugen/config.toml`.

---

## 5. Keybinds

Main binds live in `~/.config/hypr/binds.conf`. Syntax:

```
bind = MOD, KEY, action, args
```

Examples already set:
- `SUPER + T` → terminal (kitty)
- `SUPER + Q` → close active window
- `SUPER + SPACE` → wofi
- `SUPER + W` → skip wallpaper
- `SUPER + R` → reload Hyprland
- `SUPER + X` → power menu

### Add a new one
Append to `binds.conf`:
```
bind = SUPER, N, exec, firefox
```
Then `hyprctl reload`.

### Find available actions
```
hyprctl dispatchers    # built-in actions (fullscreen, movefocus, etc.)
```

---

## 6. Common fixes

### Wallpapers stopped rotating
```bash
pgrep -xf "bash /home/steix/.config/hypr/scripts/wallpaper.sh"  # is it running?
cat /run/user/1000/wallpaper.pid                                # matches?
tail /tmp/wallpaper.log                                         # any errors?
```
If dead, restart:
```bash
nohup ~/.config/hypr/scripts/wallpaper.sh > /tmp/wallpaper.log 2>&1 & disown
```

### awww says "invalid request" or "protocol too low"
Usually hyprpaper got restarted instead of awww, or packages drifted.
```bash
pkill hyprpaper awww-daemon
awww-daemon & disown
```

### Waybar won't hot-reload
If SIGUSR2 no longer works (CSS parse error), it's crashed:
```bash
pgrep -x waybar || (waybar & disown)
```
Check CSS syntax: `waybar -l debug 2>&1 | head -30`.

### Swaync shows default styling
Panel has no CSS loaded — usually a parse error:
```bash
swaync -s ~/.config/swaync/style.css -c ~/.config/swaync/config.json 2>&1 | head -30
```
Kill + relaunch: `pkill swaync; swaync & disown`.

### Colors didn't change with new wallpaper
Matugen failed silently. Run manually and watch output:
```bash
matugen --prefer saturation image "$(awww query | awk -F'image: ' '{print $2}')"
```

### Hyprlock looks broken / black
Usually `/tmp/hyprlock-wallpaper` is missing. Your `lock.sh` should set it;
to test manually:
```bash
cp "$(awww query | awk -F'image: ' '{print $2}')" /tmp/hyprlock-wallpaper
hyprlock
```

### Everything looks off after a Hyprland update
```bash
pacman -Q hyprland hyprlock awww waybar   # check versions
hyprctl version                            # confirm running version
journalctl --user -b | grep -iE "hypr|waybar" | tail -30
```

---

## 7. Useful one-liners

```bash
# Show current wallpaper path
awww query | awk -F'image: ' '{print $2}'

# Dump current matugen palette
grep -E "^@define-color (primary|on_primary|surface|on_surface|tertiary|error)" ~/.config/waybar/colors.css

# Preview a random wallpaper without committing
awww img "$(find ~/Pictures -iname '*.png' | shuf -n1)" --transition-type any

# Lock the screen
hyprlock

# Power menu
~/.config/waybar/scripts/powermenu.sh
```

---

## 8. Editing styles safely

All three GTK stylesheets (waybar, wofi, swaync) use the same palette via:
```css
@import url("file:///home/steix/.config/<app>/colors.css");
```

Inside the stylesheet you can use either Material You names
(`@primary`, `@on_surface`, `@surface_container`) or the Catppuccin-compat
aliases (`@base`, `@text`, `@blue`, `@mauve`, `@red` …) — both map to the
generated palette.

Border-radius language currently in use:
- Panels/windows: **30 – 34 px** (squircle)
- Cards/notifications: **22 – 24 px**
- Pills (search bars, rounded buttons): **26 px** or `999px` for true pill

Keep that rhythm and new widgets will match the rest.

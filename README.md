# 🌀 LABYRINTH v2: SwayFX Dotfiles

A custom, atmospheric Wayland desktop environment built around **SwayFX** (a feature-rich fork of Sway with blur, shadows, and window effects), **Foot** terminal emulator, and **Swaylock**.

The theme features a muted, dark earthy palette ("pulled from the painting") with deep forest greens, dark teal accents, bone white text, and warm rust accents.

---

## 🎨 Color Palette

| Name | Hex Code | Visual Sample | Usage |
| :--- | :--- | :--- | :--- |
| **Background** (`$bg`) | `#060b09` | 🖤 `#060b09` | Dark background base |
| **Green** (`$green`) | `#1f3a31` | 🟢 `#1f3a31` | Inactive/Unfocused borders |
| **Teal** (`$teal`) | `#6f9f8b` | 🩵 `#6f9f8b` | Accent / Focus glow & key highlights |
| **Bone** (`$bone`) | `#d4cba8` | 🤍 `#d4cba8` | Foreground text & focused borders |
| **Dim** (`$dim`) | `#8f8a6e` | 💛 `#8f8a6e` | Dimmed text / Secondary indicators |
| **Rust** (`$rust`) | `#b5523b` | 🔴 `#b5523b` | Urgent notifications & error highlights |

---

## 📁 Repository Structure

```text
.
└── dot_config/
    ├── foot/
    │   └── foot.ini         # Foot terminal configuration (transparency, fonts, palette)
    ├── sway/
    │   └── config           # SwayFX window manager configuration
    └── swaylock/
        └── config           # Swaylock screen lock configuration
```

---

## ⌨️ Keybindings Reference

Default `$mod` key is set to **`Super`** (Windows key).

### System & Core Applications
| Keybinding | Action |
| :--- | :--- |
| `$mod` (Release) | Toggle Application Launcher (`fuzzel`) |
| `$mod + Enter` | Open Terminal (`foot`) |
| `$mod + d` | Open Application Launcher (`fuzzel`) |
| `$mod + w` | Focus or Launch Browser (`firefox`) |
| `$mod + Shift + w` | Launch Firefox (New Window) |
| `$mod + n` | Open File Manager (`thunar`) |
| `$mod + p` | Open Audio Control (`pavucontrol`) |
| `$mod + Shift + i` | Open System Information (`fastfetch`) |
| `$mod + z` | Start Screen Saver (`saver.sh start`) |
| `$mod + /` | Keybindings Helper (`keys.sh`) |
| ``$mod + ` `` | Toggle Dropdown Terminal Scratchpad |
| `$mod + q` | Close Focused Window |
| `$mod + Shift + c` | Reload Sway Configuration |
| `$mod + Escape` | Lock Screen (`lock.sh`) |
| `$mod + Shift + e` | Exit Sway Prompt |
| `$mod + Shift + p` | Power Menu (`powermenu.sh`) |
| `$mod + Shift + n` | Dismiss Notifications (`makoctl dismiss -a`) |

### Window Management & Focus
| Keybinding | Action |
| :--- | :--- |
| `$mod + Left / Down / Up / Right` | Move Focus |
| `$mod + Shift + Left / Down / Up / Right` | Move Window Container |
| `$mod + g` | Split Horizontally |
| `$mod + v` | Split Vertically |
| `$mod + f` | Toggle Fullscreen |
| `$mod + s` | Stacking Layout |
| `$mod + t` | Tabbed Layout |
| `$mod + e` | Toggle Split Layout |
| `$mod + Shift + Space` | Toggle Floating Window |
| `$mod + Space` | Toggle Focus between Tiling & Floating |
| `$mod + r` | Enter Resize Mode (Use Arrow keys, `Enter`/`Esc` to exit) |

### Workspaces & Scratchpad
| Keybinding | Action |
| :--- | :--- |
| `$mod + 1..0` | Switch to Workspace 1–10 |
| `$mod + Shift + 1..0` | Move Container to Workspace 1–10 |
| `$mod + Tab` | Switch to Previous Workspace (Back & Forth) |
| `$mod + Shift + -` | Move Focused Window to Scratchpad |
| `$mod + -` | Toggle Scratchpad Window |

### Screenshots & Media / Hardware Controls
| Keybinding | Action |
| :--- | :--- |
| `$mod + Shift + s` | Region Screenshot to Clipboard (`grim + slurp`) |
| `Print` | Fullscreen Screenshot (`~/Pictures/shot-<timestamp>.png`) |
| `XF86AudioRaiseVolume` / `LowerVolume` | Adjust Volume with On-Screen Display (`SwayOSD`) |
| `XF86AudioMute` | Toggle Audio Mute (`SwayOSD`) |
| `XF86MonBrightnessUp` / `Down` | Adjust Screen Brightness (`SwayOSD`) |
| `$mod + \` / `XF86AudioPlay` | Play/Pause Media (`playerctl`) |
| `$mod + ]` / `XF86AudioNext` | Next Media Track (`playerctl`) |
| `$mod + [` / `XF86AudioPrev` | Previous Media Track (`playerctl`) |

---

## 🛠️ Software & Dependencies

To ensure all functions and scripts work properly, install the following packages on your Linux system:

* **Window Manager**: `swayfx` (Sway fork with extra effects)
* **Terminal**: `foot`
* **Launcher**: `fuzzel`
* **Bar & Notifications**: `waybar`, `mako`
* **Lock & Idle Manager**: `swaylock-effects` / `swaylock`, `swayidle`
* **OSD & Control Utilities**: `swayosd`, `playerctl`, `pavucontrol`, `fastfetch`
* **Screenshots**: `grim`, `slurp`, `wl-clipboard`
* **File Manager & Web Browser**: `thunar`, `firefox`
* **Fonts & Cursor**: `UnifontExMono`, `Symbols Nerd Font Mono`, `Hackneyed` cursor theme

---

## 📜 Expected Helper Scripts

The Sway configuration references custom helper scripts under `~/.config/sway/scripts/`:

* `focusorlaunch.sh` — Focuses an existing application window or launches it if not open.
* `saver.sh` — Handles screensaver state (`start` / `stop`).
* `keys.sh` — Displays keybinding cheatsheet.
* `lock.sh` — Manages locking with swaylock.
* `borderglow.py` — Dynamic border effects script.
* `powermenu.sh` — Power management dialog (Shutdown, Reboot, Lock, Exit).

---

## 🚀 Installation & Deployment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/dotfiles.git
   cd dotfiles
   ```

2. **Deploy configuration files**:
   Copy or symlink the `dot_config/` contents to `~/.config/`:
   ```bash
   cp -r dot_config/* ~/.config/
   ```
   Or using GNU Stow:
   ```bash
   stow --target=$HOME/.config dot_config
   ```

3. **Wallpaper Setup**:
   Place your wallpaper image at:
   ```bash
   ~/Pictures/wallpapers/labyrinth.jpg
   ```

---

## 🚀 Suggested Upgrades & Enhancements

*Without removing or breaking any existing configuration, here are recommended enhancements to elevate this setup:*

### 1. 📁 Include Included Helper Scripts
Add the scripts referenced in `~/.config/sway/scripts/` (`focusorlaunch.sh`, `lock.sh`, `borderglow.py`, `saver.sh`, `powermenu.sh`, `keys.sh`) directly into this repository under `dot_config/sway/scripts/` so the setup works out of the box on fresh installations.

### 2. 📊 Custom Waybar & Mako Theme Configs
Add matching `waybar` (bar layout and CSS styling) and `mako` (notification daemon configuration) under `dot_config/waybar/` and `dot_config/mako/` using the `#060b09` LABYRINTH palette for seamless visual unity.

### 3. 📋 Clipboard History Manager
Integrate `cliphist` or `wl-clipboard` with a Fuzzel binding (e.g. `$mod+c` or `$mod+Shift+v`) to provide searchable clipboard history without modifying existing shortcuts.

### 4. 🌙 Night Light / Gamma Control
Add `gammastep` or `wlsunset` to auto-start in Sway config (`exec wlsunset -l <lat> -L <long>`) for smooth, automatic warm-screen transition during evening hours.

### 5. 🖥️ Multi-Monitor Management (`kanshi`)
Add `kanshi` service integration (`exec kanshi`) and a configuration file to automatically adjust resolution, scaling, and display arrangements when connecting external monitors.

### 6. 🖼️ Fallback Wallpaper Scripting
Update or enhance `lock.sh` and Sway wallpaper configurations with fallback logic so that if `~/Pictures/wallpapers/labyrinth.jpg` is absent, it seamlessly falls back to a solid color (`#060b09`) or a generated gradient without failing.

### 7. 🔊 Network & Bluetooth Tray Integration
Add `nm-applet` and `blueman-applet` auto-start entries (`exec nm-applet --indicator`, `exec blueman-applet`) for quick network and Bluetooth management in Waybar.

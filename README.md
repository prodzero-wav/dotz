# LABYRINTH: SwayFX Dotfiles

A custom, atmospheric Wayland desktop environment built around **SwayFX** (a feature-rich fork of Sway with blur, shadows, and window effects), **Foot** terminal emulator, **Waybar**, **Fuzzel**, **Mako**, and **Swaylock**.

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

## 🚀 Installation & Deployment

### ⚡ Quick Start (Automated Installer)

An installation script `install.sh` is provided. It is tailored for **Arch Linux and Arch-based distributions** (Manjaro, EndeavourOS, Garuda, etc.), with automatic AUR helper support (`yay` / `paru`) and general Linux compatibility.

```bash
# 1. Clone the repository
git clone https://github.com/prodzero-wav/dotz
cd dotz

# 2. Make the installer executable (if needed) and run
chmod +x install.sh
./install.sh
```

#### Installer Command-Line Options

| Flag / Option | Description |
| :--- | :--- |
| `-y, --noconfirm` | Skip interactive prompts and automatically proceed. |
| `--no-pkgs` | Skip package manager dependency installation. |
| `--symlink` | Create symbolic links in `~/.config/` instead of copying files. |
| `--backup-dir DIR` | Specify a custom path for backing up existing configurations. |
| `--dry-run` | Simulate the installation without modifying files on disk. |
| `-h, --help` | Display help and usage information. |

**Examples:**

```bash
# Non-interactive installation with symlinks
./install.sh -y --symlink

# Dry-run mode to preview changes
./install.sh --dry-run

# Deploy configs only without installing system packages
./install.sh --no-pkgs
```

---

### 🛠️ Manual Installation

If you prefer to deploy files manually or are running a non-Arch distribution:

1. **Install required packages** (see [Software & Dependencies](#-software--dependencies)).

2. **Deploy dotfiles to `~/.config/`**:
   ```bash
   cp -r dot_config/* ~/.config/

   # Rename executable_* scripts if present and set executable permissions:
   cd ~/.config/sway/scripts
   for f in executable_*; do [ -f "$f" ] && mv "$f" "${f#executable_}"; done
   chmod +x ~/.config/sway/scripts/*
   chmod +x ~/.config/waybar/scripts/*
   ```

3. **Deploy Wallpapers**:
   ```bash
   mkdir -p ~/Pictures/wallpapers
   cp Pictures/wallpapers/* ~/Pictures/wallpapers/
   ```

---

## 🛠️ Software & Dependencies

### Official Packages (Arch Linux / Pacman)
* **Window Manager**: `swayfx` (Sway fork with extra effects)
* **Terminal**: `foot`
* **Application Launcher**: `fuzzel`
* **Status Bar & Notifications**: `waybar`, `mako`
* **Lock & Idle Manager**: `swaylock`, `swayidle`
* **Audio & System Control**: `playerctl`, `pavucontrol`, `fastfetch`, `power-profiles-daemon`
* **Screenshots & Utilities**: `grim`, `slurp`, `wl-clipboard`, `imagemagick`, `python`
* **File Manager & Web Browser**: `thunar`, `firefox`
* **Fonts & Schemas**: `ttf-unifont`, `ttf-nerd-fonts-symbols`, `gsettings-desktop-schemas`, `glib2`

### AUR Packages
* **On-Screen Display**: `swayosd-git` (or `swayosd`)
* **Cursor Theme**: `hackneyed-cursor-theme` (optional)

---

## 📁 Repository Structure

```text
.
├── install.sh               # Automated installer script (Arch-optimized & universal fallback)
├── dot_config/
│   ├── foot/
│   │   └── foot.ini         # Foot terminal configuration (transparency, colors, fonts)
│   ├── mako/
│   │   └── config           # Mako notification daemon configuration
│   ├── sway/
│   │   ├── config           # SwayFX window manager configuration & keybindings
│   │   └── scripts/         # Sway automation scripts (lock, saver, borderglow, powermenu)
│   ├── swaylock/
│   │   └── config           # Swaylock screen lock configuration
│   └── waybar/
│       ├── config.jsonc     # Waybar layout & module configuration
│       └── style.css        # Waybar CSS stylesheet
├── Pictures/
│   └── wallpapers/
│       └── labyrinth.jpg    # Default background wallpaper
└── README.md                # Documentation
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

## 🎨 Special Visual Features

* **Dynamic Border Glow**: `borderglow.py` running in background pulses the active window border between Bone and Teal.
* **Maze Screensaver**: Animated Python maze saver (`mazesaver.py`) launched full-screen via `$mod + z` or automatically on idle.
* **Waybar Integration**: Dynamic uptime ("lost time"), hardware stats, volume controls, and power profile manager integrated into Waybar.

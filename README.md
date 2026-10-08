# LABYRINTH: SwayFX Dotfiles

A custom, atmospheric Wayland desktop environment built around **SwayFX** (a feature-rich fork of Sway with blur, shadows, and window effects), **Foot** terminal emulator, **Waybar**, **Fuzzel**, **Mako**, and **swaylock-plugin**.

The theme features a muted, dark earthy palette ("pulled from the painting") with deep forest greens, dark teal accents, bone white text, and warm rust accents.

---

## 🎨 Screenshots

<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/d23e545a-431b-448b-a054-5de2826c91fc" />
<img width="1024" height="576" alt="image" src="https://github.com/user-attachments/assets/2e90eb81-7f1b-4fb3-9c5c-1331d5b56789" />


---

## 🚀 Installation & Deployment

### ⚡ Quick Start (Automated Installer)

An installation script `install.sh` is provided. It is tailored for **Arch Linux and Arch-based distributions** (Manjaro, EndeavourOS, Garuda, etc.), with automatic AUR helper support (`yay` / `paru`) and general Linux compatibility.

```bash
# 0. Update your system first (avoids stale-database 404s):
sudo pacman -Syu

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
| `--bashrc` | Also install the repo `.bashrc` (aliases, `y` yazi wrapper, starship/zoxide). Your existing one is backed up first. |
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

### 🏠 With chezmoi

The repo uses chezmoi naming (`dot_config`, `executable_*`, `.tmpl`), so you can deploy the configs with chezmoi:

```
chezmoi init --apply prodzero-wav/dotz
```

chezmoi only deploys the dotfiles. It does not install packages, the UnifontEX font, the cursor theme or the Firefox theme. Run `./install.sh` (or `extras/post-install.sh`) for those.

### 🖥️ Per-machine settings

Settings that depend on the hardware (monitor mode, refresh rate) are **not** tracked.

### 🛠️ Manual Installation

If you prefer to deploy files manually or are running a non-Arch distribution:

1. **Install required packages** (see [Software & Dependencies](#-software--dependencies)).

2. **Deploy dotfiles to `~/.config/`**:
   ```bash
   cp -r dot_config/* ~/.config/

   # Rename executable_* scripts if present and set executable permissions:
   for d in ~/.config/sway/scripts ~/.config/waybar/scripts; do
     for f in "$d"/executable_*; do [ -f "$f" ] && mv "$f" "$d/$(basename "$f" | sed 's/^executable_//')"; done
     chmod +x "$d"/*
   done

   # Fill in the fastfetch template (chezmoi does this automatically):
   cd ~/.config/fastfetch
   sed "s|{{ .chezmoi.homeDir }}|$HOME|g" config.jsonc.tmpl > config.jsonc && rm config.jsonc.tmpl
   ```

3. **Deploy Wallpapers**:
   ```bash
   mkdir -p ~/Pictures/wallpapers
   cp Pictures/wallpapers/* ~/Pictures/wallpapers/
   ```

---

## 🛠️ Software & Dependencies

### Official Packages (Arch Linux / Pacman)

- **Window manager helpers**: `swaybg`, `swayidle`
- **Terminal / launcher / bar / notifications**: `foot`, `fuzzel`, `waybar`, `mako`
- **System tools**: `playerctl`, `pavucontrol`, `fastfetch`, `power-profiles-daemon`, `grim`, `slurp`, `wl-clipboard`, `imagemagick`, `python`, `curl`
- **Apps**: `yazi` (+ `ffmpeg`, `fd`, `ripgrep`, `fzf`, `poppler` for previews), `mpv`, `thunar`, `firefox`
- **Theming**: `adw-gtk-theme`, `papirus-icon-theme`, `qt5-wayland`, `qt6-wayland`, `dconf`, `gsettings-desktop-schemas`, `glib2`
- **Fonts**: `ttf-nerd-fonts-symbols`, `ttf-nerd-fonts-symbols-mono` (icon glyphs)

### AUR Packages

- `swayfx` (needs `scenefx0.5`; falls back to `swayfx-git`)
- `swaylock-plugin` (the lockscreen needs it: `lock.sh` runs `lockbg.sh` as the background so the time updates live; plain `swaylock` and `swaylock-effects` will not work)
- `swayosd-git` (volume/brightness popups)
- `xcursor-hackneyed-light` (cursor theme, optional)
- `subtui-git` (Navidrome TUI player; run it once and log in, credentials are stored locally and never tracked)

### Installed by `extras/post-install.sh`

- **UnifontEX** (`UnifontExMono`): not packaged for Arch, downloaded from https://github.com/stgiga/UnifontEX
- GTK/Qt theme settings, the Hackneyed cursor settings, the shell prompt and the Firefox theme


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
| `$mod + n` | Open File Manager (`yazi` in foot) |
| `$mod + Shift + f` | Open GUI File Manager (`thunar`) |
| `$mod + m` | Open/Focus Music Player (`subtui`,) |
| `$mod + p` | Open Audio Control (`pavucontrol`) |
| `$mod + Shift + i` | Open System Information (`fastfetch`) |
| `$mod + z` | Start Screen Saver (`saver.sh start`) |
| `$mod + /` | Keybindings Helper (`keys.sh`) |
| ``$mod + ` `` | Toggle Dropdown Terminal Scratchpad |
| `$mod + q` | Close Focused Window |
| `$mod + Shift + c` | Reload Sway Configuration |
| `$mod + Escape` | Lock Screen (`lock.sh`) |
| `Super` (tap) | Open Application Launcher (`fuzzel`) |
| `Ctrl + Alt + Delete` | Power Menu (`powermenu.sh`) |
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

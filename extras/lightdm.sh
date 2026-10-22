#!/usr/bin/env bash
# LABYRINTH LightDM greeter (Arch). Needs sudo. Run after `chezmoi apply`; re-run after switching themes.
# Source of truth: ~/.config/labyrinth/lightdm/{gtk.css,lightdm-gtk-greeter.conf} (chezmoi-managed, themed by theme-apply.py)
# Usage: extras/lightdm.sh [wallpaper.jpg]
set -euo pipefail
SRC="$HOME/.config/labyrinth/lightdm"
WALL="${1:-$HOME/Pictures/wallpapers/labyrinth.jpg}"
FONT="$HOME/.local/share/fonts/UnifontExMono.ttf"
LDM_HOME="$(getent passwd lightdm | cut -d: -f6)"; LDM_HOME="${LDM_HOME:-/var/lib/lightdm}"

[[ -f $SRC/gtk.css && -f $SRC/lightdm-gtk-greeter.conf ]] || { echo "Missing $SRC. Run 'chezmoi apply' first."; exit 1; }
[[ -f $WALL ]] || { echo "Wallpaper not found: $WALL"; exit 1; }

pacman -Qq lightdm-gtk-greeter &>/dev/null || sudo pacman -S --needed --noconfirm lightdm-gtk-greeter

# font: the greeter runs as user 'lightdm' and can't see ~/.local/share/fonts
if [[ ! -f $FONT ]]; then
  mkdir -p "${FONT%/*}"
  curl -fL -o "$FONT" "https://github.com/stgiga/UnifontEX/raw/main/UnifontExMono.ttf"
fi
sudo install -Dm644 "$FONT" /usr/local/share/fonts/UnifontExMono.ttf
sudo fc-cache -f

sudo install -Dm644 "$WALL" /usr/share/backgrounds/labyrinth.jpg
sudo install -Dm644 "$SRC/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
sudo install -Dm644 "$SRC/gtk.css" /etc/lightdm/labyrinth/gtk-3.0/gtk.css   # preview copy
sudo install -Dm644 "$SRC/gtk.css" "$LDM_HOME/.config/gtk-3.0/gtk.css"
sudo chown -R lightdm:lightdm "$LDM_HOME/.config" 2>/dev/null || true
sudo install -dm755 /etc/lightdm/lightdm.conf.d
printf '[Seat:*]\ngreeter-session=lightdm-gtk-greeter\n' | sudo tee /etc/lightdm/lightdm.conf.d/50-labyrinth.conf >/dev/null

echo "Done. Preview: XDG_CONFIG_HOME=/etc/lightdm/labyrinth lightdm-gtk-greeter --test-mode"
echo "Apply: log out (don't restart lightdm while logged in)."

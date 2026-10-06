#!/usr/bin/env bash
# Everything that isn't a plain config file. Safe to re-run.
set -u
say() { echo "[post-install] $*"; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. UnifontEX (not in the Arch repos)
if ! fc-list 2>/dev/null | grep -qi 'unifontex'; then
  say "downloading UnifontEX..."
  mkdir -p "$HOME/.local/share/fonts"
  if curl -fL -o "$HOME/.local/share/fonts/UnifontExMono.ttf" "https://github.com/stgiga/UnifontEX/raw/main/UnifontExMono.ttf"; then
    fc-cache -f
  else
    say "WARNING: could not download UnifontEX. Get it from https://github.com/stgiga/UnifontEX and put the .ttf in ~/.local/share/fonts"
  fi
fi

# 2. GTK / cursor / dark mode (GTK reads these via gsettings as well as settings.ini)
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'UnifontExMono 12' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'Hackneyed' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
mkdir -p "$HOME/.icons/default"
printf '[Icon Theme]\nInherits=Hackneyed\n' > "$HOME/.icons/default/index.theme"

# 3. Qt follows GTK (bash login shells)
touch "$HOME/.bash_profile"
[ -s "$HOME/.bash_profile" ] && { [ -f "$HOME/.bash_profile.labyrinth.bak" ] || cp "$HOME/.bash_profile" "$HOME/.bash_profile.labyrinth.bak"; }
[ -s "$HOME/.bashrc" ] && ! grep -q LABYRINTH-PROMPT "$HOME/.bashrc" && { [ -f "$HOME/.bashrc.labyrinth.bak" ] || cp "$HOME/.bashrc" "$HOME/.bashrc.labyrinth.bak"; }
sed -i '/LABYRINTH-BEGIN/,/LABYRINTH-END/d' "$HOME/.bash_profile"
cat >> "$HOME/.bash_profile" << 'EOF'
# LABYRINTH-BEGIN
export QT_QPA_PLATFORMTHEME=gtk3
export QT_QPA_PLATFORM="wayland;xcb"
# LABYRINTH-END
EOF

# 4. bash prompt
if [ -f "$HOME/.bashrc" ] && ! grep -q 'LABYRINTH-PROMPT' "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" << 'EOF'

# LABYRINTH-PROMPT
[ -f "$HOME/.config/labyrinth/prompt.bash" ] && source "$HOME/.config/labyrinth/prompt.bash"
EOF
fi

# 5. per-machine sway settings live here (not tracked by git)
mkdir -p "$HOME/.config/sway/local.d"
if [ ! -e "$HOME/.config/sway/local.d/00-local.conf" ]; then
  cat > "$HOME/.config/sway/local.d/00-local.conf" << 'EOF'
# Per-machine settings. Example (find your output name with: swaymsg -t get_outputs):
# output DP-2 mode 2560x1440@169.999Hz
EOF
fi

# 6. power profile switcher
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable --now power-profiles-daemon 2>/dev/null || say "could not enable power-profiles-daemon (run: sudo systemctl enable --now power-profiles-daemon)"
fi

# 7. Firefox theme (needs a Firefox profile to exist: open Firefox once first)
bash "$HERE/firefox-theme.sh" || say "Firefox theme skipped (open Firefox once, close it, then run extras/firefox-theme.sh)"

say "done"

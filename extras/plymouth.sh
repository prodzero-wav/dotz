#!/usr/bin/env bash
# LABYRINTH Plymouth theme installer (Arch + mkinitcpio + GRUB). Needs sudo. Safe to re-run.
# Run from the repo: extras/plymouth.sh   (theme files live in extras/plymouth/labyrinth)
set -euo pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/plymouth/labyrinth"
T=/usr/share/plymouth/themes/labyrinth
[[ -f $D/labyrinth.script ]] || { echo "Missing $D"; exit 1; }

# 1. package + theme
sudo pacman -S --needed --noconfirm plymouth python-pillow
# the PNGs are generated, not committed
GEN="$(mktemp -d)"; trap 'rm -rf "$GEN"' EXIT
python3 "$D/gen-assets.py" "$GEN" >/dev/null
sudo install -dm755 "$T"
sudo install -m644 "$GEN"/*.png "$D/labyrinth.plymouth" "$D/labyrinth.script" "$T/"

# 2. mkinitcpio: plymouth hook goes after udev (or systemd), before encrypt/filesystems
CONF=/etc/mkinitcpio.conf
for f in /etc/mkinitcpio.conf.d/*.conf; do
  [[ -f $f ]] && grep -Eq '^HOOKS=' "$f" && CONF="$f"
done
if grep -Eq '^HOOKS=.*\bplymouth\b' "$CONF"; then
  echo "plymouth hook already in $CONF"
else
  sudo cp "$CONF" "$CONF.bak-labyrinth"
  if   grep -Eq '^HOOKS=.*\bsystemd\b' "$CONF"; then sudo sed -i -E '/^HOOKS=/ s/\bsystemd\b/systemd plymouth/' "$CONF"
  elif grep -Eq '^HOOKS=.*\budev\b'    "$CONF"; then sudo sed -i -E '/^HOOKS=/ s/\budev\b/udev plymouth/' "$CONF"
  else echo "No udev/systemd hook in $CONF. Add 'plymouth' to HOOKS manually, then re-run."; exit 1; fi
  echo "added plymouth hook to $CONF (backup: $CONF.bak-labyrinth)"
fi

# 3. kernel params: quiet splash
if [[ -f /etc/default/grub ]]; then
  for p in quiet splash; do
    grep -Eq "^GRUB_CMDLINE_LINUX_DEFAULT=.*\b$p\b" /etc/default/grub && continue
    [[ -f /etc/default/grub.bak-labyrinth ]] || sudo cp /etc/default/grub /etc/default/grub.bak-labyrinth
    sudo sed -i -E "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"\$/ $p\"/" /etc/default/grub
  done
  sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "No /etc/default/grub (systemd-boot?). Add 'quiet splash' to your kernel options manually."
fi

# 4. set theme + rebuild initramfs
sudo plymouth-set-default-theme -R labyrinth

echo "Done. Reboot to see it. Preview from a TTY (not inside sway):"
echo "  sudo plymouthd --mode=boot; sudo plymouth --show-splash; sleep 8; sudo plymouth quit"

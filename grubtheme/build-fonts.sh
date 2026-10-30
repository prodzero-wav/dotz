#!/usr/bin/env bash
# Generates the GRUB bitmap fonts the theme needs from UnifontExMono.
# Run once before installing the theme (needs grub-mkfont, from the `grub` package).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TTF="${1:-$HOME/.local/share/fonts/UnifontExMono.ttf}"
[[ -f "$TTF" ]] || { echo "Font not found: $TTF (run extras/post-install.sh first, or pass a path)" >&2; exit 1; }
MK=grub-mkfont; command -v "$MK" >/dev/null || MK=grub2-mkfont
command -v "$MK" >/dev/null || { echo "grub-mkfont not found (install grub)" >&2; exit 1; }
# sizes referenced by theme.txt: 48 (title), 32 (menu/messages/terminal); 16 for small text
for s in 16 32 48; do
  "$MK" -s "$s" -o "$HERE/labyrinth/uni$s.pf2" "$TTF"
done
echo "Fonts written to $HERE/labyrinth/. Install the theme with:"
echo "  sudo cp -r $HERE/labyrinth /boot/grub/themes/ && set GRUB_THEME=/boot/grub/themes/labyrinth/theme.txt in /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg"

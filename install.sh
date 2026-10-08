#!/usr/bin/env bash
#
# LABYRINTH Dotfiles Installer
# Arch-like distro optimized installer with general Linux compatibility.
#

set -euo pipefail

# --- Color Formatting ---
if [[ -t 1 ]]; then
  BOLD="\033[1m"
  RESET="\033[0m"
  RED="\033[1;31m"
  GREEN="\033[1;32m"
  YELLOW="\033[1;33m"
  BLUE="\033[1;34m"
  CYAN="\033[1;36m"
else
  BOLD=""
  RESET=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  CYAN=""
fi

# --- Default Options ---
NOCONFIRM=false
SKIP_PKGS=false
USE_SYMLINK=false
INSTALL_BASHRC=false
DRY_RUN=false
CUSTOM_BACKUP_DIR=""
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Packages ---
ARCH_PACMAN_PKGS=(
  foot
  fuzzel
  waybar
  mako
  swaybg
  swayidle
  playerctl
  pavucontrol
  fastfetch
  grim
  slurp
  wl-clipboard
  thunar
  firefox
  python
  imagemagick
  ttf-nerd-fonts-symbols
  ttf-nerd-fonts-symbols-mono
  gsettings-desktop-schemas
  glib2
  power-profiles-daemon
  adw-gtk-theme
  papirus-icon-theme
  qt5-wayland
  qt6-wayland
  dconf
  curl
  autotiling
  starship
  zoxide
  lsd
  yazi
  mpv
  ffmpeg
  fd
  ripgrep
  fzf
  poppler
)

ARCH_AUR_PKGS=(
  scenefx0.5
  swayfx
  swaylock-plugin
  swayosd-git
  xcursor-hackneyed-light
  subtui-git
)

# --- Helper Functions ---
info() {
  echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${RESET} $1"
}

error() {
  echo -e "${RED}[ERROR]${RESET} $1" >&2
}

banner() {
  echo -e "${CYAN}${BOLD}"
  echo '  LABYRINTH : Dotfiles Installer'
  echo '  =============================='
  echo -e "${RESET}"
}

show_help() {
  banner
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -y, --noconfirm      Automatic yes to prompts; skip confirmation"
  echo "      --no-pkgs        Skip package manager dependency installation"
  echo "      --symlink        Symlink dotfiles instead of copying them"
  echo "      --bashrc         Also install the repo .bashrc (existing one is backed up)"
  echo "      --backup-dir DIR Specify custom backup directory path"
  echo "      --dry-run        Simulate actions without making filesystem changes"
  echo "  -h, --help           Display this help message and exit"
  echo ""
  exit 0
}

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--noconfirm)
      NOCONFIRM=true
      shift
      ;;
    --no-pkgs)
      SKIP_PKGS=true
      shift
      ;;
    --symlink)
      USE_SYMLINK=true
      shift
      ;;
    --bashrc)
      INSTALL_BASHRC=true
      shift
      ;;
    --backup-dir)
      if [[ $# -lt 2 ]]; then error "--backup-dir needs a directory"; exit 1; fi
      CUSTOM_BACKUP_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      show_help
      ;;
    *)
      error "Unknown option: $1"
      echo "Use ./install.sh --help to view available options."
      exit 1
      ;;
  esac
done

banner

# --- Detect OS & Package Manager ---
is_arch=false
AUR_HELPER=""

if [[ -f /etc/os-release ]]; then
  source /etc/os-release
fi

if [[ "${ID:-}" == "arch" ]] || [[ "${ID_LIKE:-}" == *"arch"* ]] || command -v pacman &>/dev/null; then
  is_arch=true
fi

if command -v yay &>/dev/null; then
  AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
  AUR_HELPER="paru"
fi

info "Detected environment:"
if [[ "$is_arch" == true ]]; then
  echo "  - OS Type: Arch Linux / Arch-based (${NAME:-Linux})"
  if [[ -n "$AUR_HELPER" ]]; then
    echo "  - AUR Helper: $AUR_HELPER"
  else
    echo "  - AUR Helper: None found (pacman will be used for official packages)"
  fi
else
  echo "  - OS Type: ${NAME:-Non-Arch Linux distribution}"
fi
echo ""

# --- Confirm Installation ---
if [[ "$NOCONFIRM" == false ]] && [[ "$DRY_RUN" == false ]]; then
  read -p "Do you want to proceed with the installation? [Y/n] " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    warn "Installation aborted by user."
    exit 0
  fi
fi

# --- Package Installation ---
if [[ "$SKIP_PKGS" == false ]]; then
  if [[ "$is_arch" == true ]]; then
    info "Installing dependencies on Arch Linux..."

    if [[ "$DRY_RUN" == true ]]; then
      info "[DRY-RUN] Would install official packages: ${ARCH_PACMAN_PKGS[*]}"
      if [[ -n "$AUR_HELPER" ]]; then
        info "[DRY-RUN] Would install AUR packages with $AUR_HELPER: ${ARCH_AUR_PKGS[*]}"
      fi
    else
      SUDO_CMD=""
      if command -v sudo &>/dev/null; then
        SUDO_CMD="sudo"
      fi

      info "Installing official packages via pacman..."
      for pkg in "${ARCH_PACMAN_PKGS[@]}"; do
        $SUDO_CMD pacman -S --needed --noconfirm "$pkg" || warn "Could not install: $pkg"
      done

      if [[ -n "$AUR_HELPER" ]]; then
        info "Installing AUR packages via $AUR_HELPER..."
        for pkg in "${ARCH_AUR_PKGS[@]}"; do
          $AUR_HELPER -S --needed --noconfirm "$pkg" || warn "Could not install AUR package: $pkg"
        done
        if ! command -v sway &>/dev/null; then
          warn "swayfx did not install, trying swayfx-git..."
          $AUR_HELPER -S --needed --noconfirm swayfx-git || warn "Could not install swayfx-git either. Install swayfx manually."
        fi
      else
        warn "No AUR helper (yay/paru) detected. Please install swayfx, swaylock-plugin and swayosd from the AUR manually."
      fi
    fi
  else
    warn "Non-Arch distribution detected."
    warn "Automatic package installation is optimized for Arch Linux."
    info "Recommended software to install manually on your distro:"
    echo "  - Window Manager: swayfx (or sway)"
    echo "  - Terminal: foot"
    echo "  - Launcher: fuzzel"
    echo "  - Bar & Notifications: waybar, mako"
    echo "  - Lock & Idle: swaylock-plugin, swayidle"
    echo "  - Utilities: swayosd, playerctl, pavucontrol, fastfetch, grim, slurp, wl-clipboard, thunar, firefox, imagemagick, unifont font"
    echo ""
  fi
else
  info "Skipping package installation as requested (--no-pkgs)."
fi

# --- Backup Configuration ---
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${CUSTOM_BACKUP_DIR:-$HOME/.config/labyrinth_backup_$TIMESTAMP}"
CONFIG_TARGET_DIR="$HOME/.config"
CONFIGS_TO_DEPLOY=(fastfetch foot fuzzel mako sway swaylock waybar gtk-3.0 gtk-4.0 swayosd labyrinth yazi subtui btop cava)
NEEDS_BACKUP=false

for cfg in "${CONFIGS_TO_DEPLOY[@]}"; do
  if [[ -d "$CONFIG_TARGET_DIR/$cfg" ]]; then
    NEEDS_BACKUP=true
    break
  fi
done

if [[ "$NEEDS_BACKUP" == true ]]; then
  info "Existing configuration found. Creating backup..."
  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY-RUN] Would back up existing configs to $BACKUP_DIR"
  else
    mkdir -p "$BACKUP_DIR"
    for cfg in "${CONFIGS_TO_DEPLOY[@]}"; do
      if [[ -d "$CONFIG_TARGET_DIR/$cfg" ]]; then
        cp -r "$CONFIG_TARGET_DIR/$cfg" "$BACKUP_DIR/"
        info "  - Backed up $CONFIG_TARGET_DIR/$cfg -> $BACKUP_DIR/$cfg"
      fi
    done
    success "Backup saved to: $BACKUP_DIR"
  fi
fi

# --- Deploy Dotfiles ---
info "Deploying dotfiles to $CONFIG_TARGET_DIR..."

SOURCE_DOT_CONFIG="$REPO_DIR/dot_config"

if [[ ! -d "$SOURCE_DOT_CONFIG" ]]; then
  error "Source folder '$SOURCE_DOT_CONFIG' not found in repository!"
  exit 1
fi

deploy_directory() {
  local src_dir="$1"
  local dest_dir="$2"

  [[ "$DRY_RUN" == true ]] || mkdir -p "$dest_dir"

  # Process all items in source directory
  find "$src_dir" -mindepth 1 -maxdepth 1 | while read -r item; do
    local rel_name
    rel_name="$(basename "$item")"

    # Strip executable_ prefix if present
    local clean_name
    clean_name="${rel_name#executable_}"
    clean_name="${clean_name#private_}"
    clean_name="${clean_name%.tmpl}"
    local target_item="$dest_dir/$clean_name"

    if [[ -d "$item" ]]; then
      deploy_directory "$item" "$target_item"
    else
      if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Deploy $item -> $target_item"
      else
        rm -f "$target_item"
        if [[ "$rel_name" == *.tmpl ]]; then
          sed "s|{{ .chezmoi.homeDir }}|$HOME|g" "$item" > "$target_item"
        elif [[ "$USE_SYMLINK" == true ]]; then
          ln -s "$item" "$target_item"
        else
          cp "$item" "$target_item"
        fi

        # Make scripts executable
        if [[ "$clean_name" == *.sh ]] || [[ "$clean_name" == *.py ]] || [[ "$rel_name" == executable_* ]]; then
          chmod +x "$target_item" 2>/dev/null || true
        fi
      fi
    fi
  done
}

deploy_directory "$SOURCE_DOT_CONFIG" "$CONFIG_TARGET_DIR"
success "Dotfiles deployed successfully."

# --- Deploy .bashrc (opt-in) ---
if [[ "$INSTALL_BASHRC" == true ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY-RUN] Would back up ~/.bashrc and install $REPO_DIR/dot_bashrc"
  else
    if [[ -f "$HOME/.bashrc" ]]; then
      cp "$HOME/.bashrc" "$HOME/.bashrc.labyrinth_$TIMESTAMP.bak"
      info "Backed up ~/.bashrc -> ~/.bashrc.labyrinth_$TIMESTAMP.bak"
    fi
    rm -f "$HOME/.bashrc"
    if [[ "$USE_SYMLINK" == true ]]; then
      ln -s "$REPO_DIR/dot_bashrc" "$HOME/.bashrc"
    else
      cp "$REPO_DIR/dot_bashrc" "$HOME/.bashrc"
    fi
    success ".bashrc installed (needs starship, zoxide, lsd)."
  fi
fi

# --- Deploy Wallpapers ---
WALLPAPER_SRC="$REPO_DIR/Pictures/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/wallpapers"

if [[ -d "$WALLPAPER_SRC" ]]; then
  info "Deploying wallpapers to $WALLPAPER_DEST..."
  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY-RUN] Would copy $WALLPAPER_SRC to $WALLPAPER_DEST"
    info "[DRY-RUN] Would apply wallpaper via swaymsg if Sway session is running"
  else
    mkdir -p "$WALLPAPER_DEST"
    cp -r "$WALLPAPER_SRC"/* "$WALLPAPER_DEST/"
    success "Wallpapers deployed."

    # Automatically set/apply wallpaper if running active Sway session
    if command -v swaymsg &>/dev/null && swaymsg -t get_version &>/dev/null; then
      info "Applying wallpaper to active Sway session..."
      if swaymsg "output * bg $WALLPAPER_DEST/labyrinth.jpg fill" &>/dev/null; then
        success "Wallpaper applied successfully."
      else
        warn "Could not apply wallpaper automatically via swaymsg."
      fi
    else
      info "No active Sway session detected. Wallpaper will be applied automatically when Sway starts."
    fi
  fi
fi

# --- Final Check & Permissions ---
if [[ "$DRY_RUN" == false ]]; then
  info "Setting executable permissions on scripts..."
  find "$CONFIG_TARGET_DIR/sway/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
  find "$CONFIG_TARGET_DIR/waybar/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
fi

# --- Post-install extras (UnifontEX font, GTK, cursor, shell prompt, Firefox theme) ---
if [[ "$DRY_RUN" == false ]]; then
  bash "$REPO_DIR/extras/post-install.sh" || warn "Post-install step had problems (see above)."
fi

# --- Post-Installation Summary ---
echo ""
banner
success "LABYRINTH installation complete!"
echo ""
echo -e "${BOLD}Installed components:${RESET}"
echo "  - Configs deployed to: ~/.config/{fastfetch,foot,fuzzel,mako,sway,swaylock,waybar,gtk-3.0,gtk-4.0,swayosd,labyrinth,yazi,subtui}"
echo "  - Wallpapers copied to: ~/Pictures/wallpapers/"
if [[ "$NEEDS_BACKUP" == true ]] && [[ "$DRY_RUN" == false ]]; then
  echo "  - Backup saved at: $BACKUP_DIR"
fi
echo ""
echo -e "${BOLD}Next Steps:${RESET}"
echo "  1. If you are not in a Wayland session, log out and select 'Sway' or launch 'sway' from TTY."
echo "  2. Hotkey Reference:"
echo "     - Mod (Super) + Enter : Open Foot terminal"
echo "     - Mod (Super) + d     : Open Fuzzel launcher"
echo "     - Mod (Super) + n     : Open yazi (file manager)"
echo "     - Mod (Super) + m     : Open SubTUI (Navidrome player; log in on first run)"
echo "     - Mod (Super) + w     : Open Firefox"
echo "     - Mod (Super) + /     : View keybindings helper"
echo "     - Mod (Super) + Esc   : Lock screen"
echo ""

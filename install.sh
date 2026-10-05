#!/usr/bin/env bash
#
# 🌀 LABYRINTH v2 Dotfiles Installer
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
DRY_RUN=false
CUSTOM_BACKUP_DIR=""
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Packages ---
ARCH_PACMAN_PKGS=(
  swayfx
  foot
  fuzzel
  waybar
  mako
  swaylock
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
  ttf-unifont
  ttf-nerd-fonts-symbols
  gsettings-desktop-schemas
  glib2
  power-profiles-daemon
)

ARCH_AUR_PKGS=(
  swayosd-git
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
  echo '  🌀 LABYRINTH v2 : Dotfiles Installer'
  echo '  ==================================='
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
    --backup-dir)
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
      $SUDO_CMD pacman -S --needed --noconfirm "${ARCH_PACMAN_PKGS[@]}" || warn "Some official packages failed to install."

      if [[ -n "$AUR_HELPER" ]]; then
        info "Installing AUR packages via $AUR_HELPER..."
        $AUR_HELPER -S --needed --noconfirm "${ARCH_AUR_PKGS[@]}" || warn "Some AUR packages failed to install."
      else
        warn "No AUR helper (yay/paru) detected. Please install 'swayosd' from the AUR manually if needed."
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
    echo "  - Lock & Idle: swaylock / swaylock-effects, swayidle"
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
CONFIGS_TO_DEPLOY=(foot mako sway swaylock waybar)
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

  mkdir -p "$dest_dir"

  # Process all items in source directory
  find "$src_dir" -mindepth 1 -maxdepth 1 | while read -r item; do
    local rel_name="$(basename "$item")"

    # Strip executable_ prefix if present
    local clean_name="${rel_name#executable_}"
    local target_item="$dest_dir/$clean_name"

    if [[ -d "$item" ]]; then
      deploy_directory "$item" "$target_item"
    else
      if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Deploy $item -> $target_item"
      else
        rm -f "$target_item"
        if [[ "$USE_SYMLINK" == true ]]; then
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

# --- Deploy Wallpapers ---
WALLPAPER_SRC="$REPO_DIR/Pictures/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/wallpapers"

if [[ -d "$WALLPAPER_SRC" ]]; then
  info "Deploying wallpapers to $WALLPAPER_DEST..."
  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY-RUN] Would copy $WALLPAPER_SRC to $WALLPAPER_DEST"
  else
    mkdir -p "$WALLPAPER_DEST"
    cp -r "$WALLPAPER_SRC"/* "$WALLPAPER_DEST/"
    success "Wallpapers deployed."
  fi
fi

# --- Final Check & Permissions ---
if [[ "$DRY_RUN" == false ]]; then
  info "Setting executable permissions on scripts..."
  find "$CONFIG_TARGET_DIR/sway/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
  find "$CONFIG_TARGET_DIR/waybar/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
fi

# --- Post-Installation Summary ---
echo ""
banner
success "LABYRINTH v2 installation complete!"
echo ""
echo -e "${BOLD}Installed components:${RESET}"
echo "  - Configs deployed to: ~/.config/{sway,foot,mako,swaylock,waybar}"
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
echo "     - Mod (Super) + w     : Open Firefox"
echo "     - Mod (Super) + /     : View keybindings helper"
echo "     - Mod (Super) + Esc   : Lock screen"
echo ""

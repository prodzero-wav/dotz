# Changelog

## v1.1.0
- Wi-Fi menu: per-branch success check, password no longer visible in `ps`.
- Missing video/image wallpaper falls back to the theme's solid colour.
- GRUB fonts and Plymouth PNGs are generated instead of committed (repo is ~25MB lighter going forward).
- `install.sh` is chezmoi-first and installs packages in one batch.
- Sway config split into `config` plus `conf.d/`.
- CI: shellcheck and ruff. README: troubleshooting and script table.

#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d%H%M%S)"

backup_if_exists() {
  local target="$1"
  if [ -e "$target" ]; then
    cp -a "$target" "${target}.bak.${TS}"
    echo "Backup: ${target}.bak.${TS}"
  fi
}

echo "== Instalando configurações do hypr-waybar-theme =="

# Dependências (Fedora)
# sudo dnf install -y waybar rofi dunst playerctl jq curl lm_sensors mpv audacious wl-clipboard
# Opcionais: wttrbar, blueman, brightnessctl, power-profiles-daemon/tuned-ppd conforme hardware

mkdir -p "$HOME/.config" "$HOME/bin" "$HOME/.local/share/applications"

# Waybar
backup_if_exists "$HOME/.config/waybar"
mkdir -p "$HOME/.config/waybar"
cp -rf "$REPO_DIR/.config/waybar/." "$HOME/.config/waybar/"

# Hyprland
mkdir -p "$HOME/.config/hypr/scripts"
backup_if_exists "$HOME/.config/hypr/hyprland.lua"
cp -f "$REPO_DIR/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
cp -f "$REPO_DIR/.config/hypr/scripts/music-notify.sh" "$HOME/.config/hypr/scripts/music-notify.sh"

# Rofi
backup_if_exists "$HOME/.config/rofi"
mkdir -p "$HOME/.config/rofi"
cp -rf "$REPO_DIR/.config/rofi/." "$HOME/.config/rofi/"

# Dunst
backup_if_exists "$HOME/.config/dunst"
mkdir -p "$HOME/.config/dunst"
cp -rf "$REPO_DIR/.config/dunst/." "$HOME/.config/dunst/"

# Bin e desktop
backup_if_exists "$HOME/bin/hypr-wallpaper-menu"
cp -f "$REPO_DIR/bin/hypr-wallpaper-menu" "$HOME/bin/hypr-wallpaper-menu"
cp -f "$REPO_DIR/.local/share/applications/hypr-wallpaper.desktop" "$HOME/.local/share/applications/hypr-wallpaper.desktop"

# Permissões
chmod +x "$HOME/.config/waybar/"*.sh "$HOME/.config/hypr/scripts/music-notify.sh" "$HOME/bin/hypr-wallpaper-menu"

echo "== Concluído =="
echo "- Recarregue o Hyprland: hyprctl reload"
echo "- Reinicie a Waybar: pkill waybar; waybar & disown"
echo "- Inicie notificações: dunst & e ~/.config/hypr/scripts/music-notify.sh & (ou reinicie sessão)"
echo "- Selecione wallpaper pelo drun: 'Ajustar Wallpaper' (salvo em ~/.config/hypr/current-wallpaper)"

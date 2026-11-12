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

# Dependências (Fedora) - instale antes se necessário:
# sudo dnf install -y waybar rofi dunst jq curl lm_sensors mpv audacious playerctl \
#   wl-clipboard swaybg wofi grim slurp brightnessctl git nautilus papirus-icon-theme kitty chromium
# Opcionais: wttrbar, blueman, power-profiles-daemon ou tuned-ppd, qt6ct/kvantum (Qt)

mkdir -p "$HOME/.config" "$HOME/bin" "$HOME/.local/share/applications"

# Waybar
backup_if_exists "$HOME/.config/waybar"
mkdir -p "$HOME/.config/waybar"
cp -rf "$REPO_DIR/.config/waybar/." "$HOME/.config/waybar/"

# Hyprland
mkdir -p "$HOME/.config/hypr/scripts" "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots"
backup_if_exists "$HOME/.config/hypr/hyprland.lua"
cp -f "$REPO_DIR/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
cp -f "$REPO_DIR/.config/hypr/scripts/music-notify.sh" "$HOME/.config/hypr/scripts/music-notify.sh"
if [ -f "$REPO_DIR/.config/hypr/scripts/screenshot-region.sh" ]; then
  cp -f "$REPO_DIR/.config/hypr/scripts/screenshot-region.sh" "$HOME/.config/hypr/scripts/screenshot-region.sh"
fi
# Wallpapers + wallpaper padrão
if [ -d "$REPO_DIR/wallpapers" ]; then
  cp -f "$REPO_DIR/wallpapers/"* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi
if [ ! -f "$HOME/.config/hypr/current-wallpaper" ]; then
  echo "$HOME/Pictures/Wallpapers/gargantua-black-3840x2160-9621.jpg" > "$HOME/.config/hypr/current-wallpaper"
fi

# Rofi
backup_if_exists "$HOME/.config/rofi"
mkdir -p "$HOME/.config/rofi"
cp -rf "$REPO_DIR/.config/rofi/." "$HOME/.config/rofi/"

# Dunst
backup_if_exists "$HOME/.config/dunst"
mkdir -p "$HOME/.config/dunst"
cp -rf "$REPO_DIR/.config/dunst/." "$HOME/.config/dunst/"

# GTK (Nautilus/GTK)
backup_if_exists "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-3.0"
cp -rf "$REPO_DIR/.config/gtk-3.0/." "$HOME/.config/gtk-3.0/"
backup_if_exists "$HOME/.config/gtk-4.0"
mkdir -p "$HOME/.config/gtk-4.0"
cp -rf "$REPO_DIR/.config/gtk-4.0/." "$HOME/.config/gtk-4.0/"

# Kitty
backup_if_exists "$HOME/.config/kitty"
mkdir -p "$HOME/.config/kitty"
if [ -d "$REPO_DIR/.config/kitty" ]; then
  cp -rf "$REPO_DIR/.config/kitty/." "$HOME/.config/kitty/"
fi

# Bin e desktop
backup_if_exists "$HOME/bin/hypr-wallpaper-menu"
cp -f "$REPO_DIR/bin/hypr-wallpaper-menu" "$HOME/bin/hypr-wallpaper-menu"
if [ -f "$REPO_DIR/bin/hypr-resolution-menu" ]; then
  backup_if_exists "$HOME/bin/hypr-resolution-menu"
  cp -f "$REPO_DIR/bin/hypr-resolution-menu" "$HOME/bin/hypr-resolution-menu"
fi
cp -f "$REPO_DIR/.local/share/applications/hypr-wallpaper.desktop" "$HOME/.local/share/applications/hypr-wallpaper.desktop"
if [ -f "$REPO_DIR/.local/share/applications/hypr-resolution.desktop" ]; then
  cp -f "$REPO_DIR/.local/share/applications/hypr-resolution.desktop" "$HOME/.local/share/applications/hypr-resolution.desktop"
fi

# Permissões
chmod +x "$HOME/.config/waybar/"*.sh "$HOME/.config/hypr/scripts/"*.sh "$HOME/bin/hypr-wallpaper-menu" "$HOME/bin/hypr-resolution-menu" 2>/dev/null || true

echo "== Concluído =="
echo "- Recarregue o Hyprland: hyprctl reload"
echo "- Reinicie a Waybar: pkill waybar; waybar & disown"
echo "- Inicie notificações: dunst & e ~/.config/hypr/scripts/music-notify.sh & (ou reinicie sessão)"
echo "- Selecione wallpaper pelo drun: 'Ajustar Wallpaper' (salvo em ~/.config/hypr/current-wallpaper)"

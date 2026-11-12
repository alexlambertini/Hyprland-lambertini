#!/bin/bash
# Menu de energia (Waybar/rofi)

chosen=$(printf '%s\n' \
  "  Bloquear" \
  "󰒲  Suspender" \
  "󰍃  Sair" \
  "󰜉  Reiniciar" \
  "⏻  Desligar" | rofi -dmenu -i -p "Energia" -theme-str 'window {width: 260px;} listview {lines: 5;}')

case "$chosen" in
  *"Bloquear"*)
    if command -v hyprlock >/dev/null 2>&1; then hyprlock
    elif command -v loginctl >/dev/null 2>&1; then loginctl lock-session
    fi
    ;;
  *"Suspender"*) systemctl suspend ;;
  *"Sair"*) hyprctl dispatch exit >/dev/null 2>&1 || loginctl terminate-user "$USER" ;;
  *"Reiniciar"*) systemctl reboot ;;
  *"Desligar"*) systemctl poweroff ;;
esac

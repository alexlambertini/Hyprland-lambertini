#!/bin/bash
# Alterna o layout do teclado (BR <-> US-Intl) e atualiza o widget da Waybar.
# Os layouts são definidos em ~/.config/hypr/hyprland.lua (kb_layout = "br,us").
hyprctl switchxkblayout all next >/dev/null 2>&1
pkill -RTMIN+15 waybar 2>/dev/null || true

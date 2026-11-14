#!/bin/bash
# Ação do widget de layout do teclado (Waybar).
# Clique esquerdo: se o widget está oculto, mostra; se visível, alterna o layout.
# Clique direito: ocultar/mostrar (ver widget-toggle.sh no config.jsonc).
STATE="$HOME/.config/waybar/.kblayout-enabled"
if [ ! -f "$STATE" ]; then
  : > "$STATE"
  pkill -RTMIN+15 waybar 2>/dev/null || true
else
  exec "$HOME/.config/waybar/kblayout-switch.sh"
fi

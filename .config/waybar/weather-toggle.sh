#!/bin/bash
# Alterna exibição do widget de clima (Waybar)
STATE="$HOME/.config/waybar/.weather-enabled"
if [ -f "$STATE" ]; then
  rm -f "$STATE"
else
  : > "$STATE"
fi
# Atualiza módulos custom/weather que escutam o sinal 11
pkill -RTMIN+11 waybar 2>/dev/null || true

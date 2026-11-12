#!/bin/bash
# Alterna visibilidade de um widget custom da Waybar
# Uso: widget-toggle.sh <nome> <sinal-rtmin>
NAME="$1"
SIG="$2"
STATE="$HOME/.config/waybar/.${NAME}-enabled"
if [ -f "$STATE" ]; then
  rm -f "$STATE"
else
  : > "$STATE"
fi
if [ -n "$SIG" ]; then
  pkill -RTMIN+"$SIG" waybar 2>/dev/null || true
fi

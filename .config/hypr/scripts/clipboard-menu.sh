#!/bin/bash
# Menu de histórico da área de transferência (cliphist + rofi)
set -euo pipefail

if ! command -v cliphist >/dev/null 2>&1; then
  notify-send "Clipboard" "cliphist não instalado" 2>/dev/null || true
  exit 0
fi

sel=$(cliphist list | rofi -dmenu -i -p "Clipboard" -theme-str 'window {width: 60%;} listview {lines: 12;}') || exit 0
[ -z "$sel" ] && exit 0

printf '%s' "$sel" | cliphist decode | wl-copy

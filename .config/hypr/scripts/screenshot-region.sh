#!/bin/bash
# Captura de região (grim+slurp): salva em ~/Pictures/Screenshots e copia para área de transferência
set -euo pipefail
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

GEOM="$(slurp 2>/dev/null || true)"
[ -z "$GEOM" ] && exit 0

grim -g "$GEOM" "$FILE"
wl-copy < "$FILE"

if command -v notify-send >/dev/null 2>&1; then
  notify-send -a "screenshot" -i "$FILE" "Captura de tela" "Salva em: $FILE (copiada para a área de transferência)"
fi

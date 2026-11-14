#!/bin/bash
STATE="$HOME/.config/waybar/.kblayout-enabled"
if [ ! -f "$STATE" ]; then
  echo '{"text":"󰌌","tooltip":"Layout de teclado oculto (clique para mostrar)","class":"disabled"}'
  exit 0
fi

LAYOUT=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[] | select(.main==true) | .active_keymap' 2>/dev/null | head -1)
[ -z "$LAYOUT" ] && LAYOUT=$(hyprctl devices -j 2>/dev/null | jq -r '.keyboards[0].active_keymap // empty' 2>/dev/null)

if [ -z "$LAYOUT" ]; then
  echo '{"text":"󰌌 ?","tooltip":"Layout indisponível","class":"error"}'
  exit 0
fi

SHORT="$LAYOUT"
echo "$LAYOUT" | grep -qi "portuguese" && SHORT="BR"
echo "$LAYOUT" | grep -qi "english" && SHORT="US"

# Escapa para JSON
SHORT_ESC=$(printf '%s' "$SHORT" | sed 's/\\/\\\\/g; s/"/\\"/g')
LAYOUT_ESC=$(printf '%s' "$LAYOUT" | sed 's/\\/\\\\/g; s/"/\\"/g')
echo "{\"text\":\"󰌌 ${SHORT_ESC}\",\"tooltip\":\"Teclado: ${LAYOUT_ESC}\\nClique esquerdo: alternar (BR/US-Intl)\\nClique direito: ocultar/mostrar\",\"class\":\"enabled\"}"

#!/bin/bash
# Toggle OpenCode como painel lateral lado a lado (divide a tela)
set -euo pipefail

CLASS="opencode-assist"
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

dispatch() {
  local cmd="$1"
  if [ -S "$SOCK" ]; then
    printf '%s' "$cmd" | nc -U "$SOCK" >/dev/null 2>&1 || true
  else
    hyprctl dispatch "$cmd" >/dev/null 2>&1 || true
  fi
}

ADDR=$(hyprctl clients -j 2>/dev/null | jq -r --arg c "$CLASS" '.[] | select(.class==$c) | .address' | head -1)

if [ -z "$ADDR" ]; then
  # Abre lado a lado à direita (dwindle: pré-seleciona divisão)
  dispatch "layoutmsg preselect r"
  kitty --class "$CLASS" -e opencode >/dev/null 2>&1 &
  exit 0
fi

# Se já existe: fecha para devolver espaço às janelas
dispatch "closewindow address:$ADDR"

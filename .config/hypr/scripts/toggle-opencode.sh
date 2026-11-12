#!/bin/bash
# Toggle OpenCode como painel lateral (overlay, estilo Central de Ações/Copilot)
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

# Se não existe, inicia no special workspace
if ! hyprctl clients -j 2>/dev/null | grep -q "\"class\": \"$CLASS\""; then
  kitty --class "$CLASS" -e opencode >/dev/null 2>&1 &
  sleep 0.4
fi

dispatch "togglespecialworkspace opencode"

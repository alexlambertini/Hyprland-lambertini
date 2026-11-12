#!/bin/bash
# Toggle OpenCode como assistente lateral (Hyprland special workspace)
set -euo pipefail

CLASS="opencode-assist"
SPECIAL="special:opencode"
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

dispatch() {
  local cmd="$1"
  if [ -S "$SOCK" ]; then
    printf '%s' "$cmd" | nc -U "$SOCK" >/dev/null 2>&1 || true
  else
    hyprctl dispatch "$cmd" >/dev/null 2>&1 || true
  fi
}

# Verifica se já existe janela do assistente
if ! hyprctl clients -j 2>/dev/null | grep -q "\"class\": \"$CLASS\""; then
  kitty --class "$CLASS" -e opencode >/dev/null 2>&1 &
  # pequena espera para a janela registrar antes do toggle
  sleep 0.4
fi

dispatch "togglespecialworkspace opencode"

#!/bin/bash
# Abre/fecha painel lateral com Web UI do OpenCode em modo app (Chromium)
# Divide a tela; se workspace vazia, abre em 100%
set -euo pipefail

CLASS="opencode-web"
PORT="${OPENCODE_WEB_PORT:-4096}"
URL="http://127.0.0.1:${PORT}/"
OPENCODE_BIN="$HOME/.opencode/bin/opencode"
CHROMIUM_BIN="${CHROMIUM_BIN:-$(command -v chromium-browser || command -v chromium || echo chromium-browser)}"
SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

dispatch() {
  local cmd="$1"
  if [ -S "$SOCK" ]; then
    printf '%s' "$cmd" | nc -U "$SOCK" >/dev/null 2>&1 || true
  else
    hyprctl dispatch "$cmd" >/dev/null 2>&1 || true
  fi
}

# Fecha se painel já estiver aberto
ADDR=$(hyprctl clients -j 2>/dev/null | jq -r --arg c "$CLASS" '
  .[] | select(.class==$c or .initialClass==$c or (.title|test("OpenCode"))) | .address' | head -1)

if [ -n "$ADDR" ]; then
  dispatch "closewindow address:$ADDR"
  exit 0
fi

# Garante servidor OpenCode web
if ! curl -fsS --max-time 1 "$URL" >/dev/null 2>&1; then
  if [ -x "$OPENCODE_BIN" ]; then
    nohup "$OPENCODE_BIN" serve --hostname 127.0.0.1 --port "$PORT" >/tmp/opencode-serve.log 2>&1 &
  else
    nohup opencode serve --hostname 127.0.0.1 --port "$PORT" >/tmp/opencode-serve.log 2>&1 &
  fi
  for i in 1 2 3 4 5 6 7 8 9 10; do
    curl -fsS --max-time 1 "$URL" >/dev/null 2>&1 && break
    sleep 0.4
  done
fi

# Se houver janelas, divide à direita; se vazio, ocupa 100% naturalmente
OTHER=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.windows // 0' 2>/dev/null || echo 0)
if [ "${OTHER:-0}" -gt 0 ]; then
  dispatch "layoutmsg preselect r"
fi

# Abre Web UI como app (janela dedicada, sem UI do navegador)
"$CHROMIUM_BIN" --app="$URL" --class="$CLASS" --name="$CLASS" >/dev/null 2>&1 &

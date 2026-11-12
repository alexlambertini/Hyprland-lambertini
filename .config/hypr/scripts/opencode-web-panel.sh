#!/bin/bash
# Abre/fecha painel lateral com Web UI do OpenCode em modo app (Chromium)
# Divide a tela; se workspace vazia, abre em 100%
set -euo pipefail

CLASS="opencode-web"
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

resolve_url() {
  # 1) serviço em execução do OpenCode (sem senha adicional)
  local svc
  svc=$("$OPENCODE_BIN" service status 2>/dev/null | head -1 | tr -d '\r' || true)
  if [ -n "$svc" ] && curl -fsS --max-time 1 "$svc" >/dev/null 2>&1; then
    echo "$svc"
    return 0
  fi

  # 2) porta padrão local já ativa
  if curl -fsS --max-time 1 "http://127.0.0.1:4096/" >/dev/null 2>&1; then
    echo "http://127.0.0.1:4096/"
    return 0
  fi

  # 3) inicia servidor local
  if [ -x "$OPENCODE_BIN" ]; then
    nohup "$OPENCODE_BIN" serve --hostname 127.0.0.1 --port 4096 >/tmp/opencode-serve.log 2>&1 &
  else
    nohup opencode serve --hostname 127.0.0.1 --port 4096 >/tmp/opencode-serve.log 2>&1 &
  fi
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -fsS --max-time 1 "http://127.0.0.1:4096/" >/dev/null 2>&1; then
      echo "http://127.0.0.1:4096/"
      return 0
    fi
    sleep 0.4
  done
  echo "http://127.0.0.1:4096/"
}

URL="$(resolve_url)"

# Se houver janelas, divide à direita; se vazio, ocupa 100% naturalmente
OTHER=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.windows // 0' 2>/dev/null || echo 0)
if [ "${OTHER:-0}" -gt 0 ]; then
  dispatch "layoutmsg preselect r"
fi

# Abre Web UI como app (janela dedicada, sem UI do navegador)
"$CHROMIUM_BIN" --app="$URL" --class="$CLASS" --name="$CLASS" >/dev/null 2>&1 &

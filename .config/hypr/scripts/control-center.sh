#!/bin/bash
# Central de Controle (Rofi) — menu único no tema do sistema com submenus:
#   Rede (cabeada + Tailscale), Áudio, Mídia, Perfil de energia,
#   Captura de tela, Área de transferência, Widgets (Conky) e Sessão.
#
# Abrir com: SUPER + N
set -uo pipefail

THEME='window {width: 420px;} listview {lines: 10;}'
SCRIPTS="$HOME/.config/hypr/scripts"

pick()   { rofi -dmenu -i -no-custom -p "$1" -theme-str "$THEME"; }
ask()    { rofi -dmenu -i -p "$1" -theme-str "$THEME"; }
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a "central" "$@" || true; }
have()   { command -v "$1" >/dev/null 2>&1; }
# Executa com privilégio via pkexec (lxpolkit pergunta a senha no GUI), se existir.
priv()   { local p; p="$(command -v "$1" 2>/dev/null || echo "$1")"; shift
           if have pkexec; then pkexec "$p" "$@"; else "$p" "$@"; fi; }

# ------------------------------- Rede -------------------------------
net_active() { nmcli -t -f NAME connection show --active 2>/dev/null | head -1; }
net_ip()     { ip -4 -o addr show scope global 2>/dev/null | awk '{print $2": "$4}' | paste -sd' ' -; }
wired_name() { nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2=="802-3-ethernet"{print $1; exit}'; }
tail_up()    { tailscale status --json 2>/dev/null | grep -q '"BackendState": *"Running"'; }

net_conns() {
  local sel name
  sel="$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '{print $1"  ("$2")"}' | pick "Conexões salvas")"
  [ -z "$sel" ] && return 0
  name="${sel%  (*}"
  if nmcli connection up "$name" >/dev/null 2>&1; then
    notify "Rede" "Ativada: $name"
  else
    notify "Rede" "Falha ao ativar: $name"
  fi
}

net_menu() {
  local cur ip ts sel w
  cur="$(net_active)"; ip="$(net_ip)"; w="$(wired_name)"
  tail_up && ts="ligado" || ts="desligado"
  sel="$(printf '%s\n' \
    "󰈀  Conexão: ${cur:-desconectada}" \
    "󰩠  IP: ${ip:-—}" \
    "󰒓  Conexões salvas..." \
    "󰤨  Conectar cabeada" \
    "󰤮  Desconectar cabeada" \
    "󰒓  Tailscale: $ts" \
    "󰒓  Tailscale — ligar" \
    "󰒓  Tailscale — desligar" | pick "Rede")"
  case "$sel" in
    *"Conexões salvas"*) net_conns ;;
    *"Conectar cabeada"*)   [ -n "$w" ] && nmcli connection up "$w" >/dev/null 2>&1 && notify "Rede" "Conectado: $w" ;;
    *"Desconectar cabeada"*) [ -n "$w" ] && nmcli connection down "$w" >/dev/null 2>&1 && notify "Rede" "Desconectado: $w" ;;
    *"Tailscale — ligar"*)    priv tailscale up  >/dev/null 2>&1 && notify "Tailscale" "Ligado" ;;
    *"Tailscale — desligar"*) priv tailscale down >/dev/null 2>&1 && notify "Tailscale" "Desligado" ;;
  esac
}

# ------------------------------- Áudio ------------------------------
audio_switch() {
  local kind="$1" sel name desc
  sel="$(pactl -f json list "${kind}s" 2>/dev/null | python3 -c '
import sys, json
try: data = json.load(sys.stdin)
except Exception: data = []
for d in data:
    print("%s|%s" % (d.get("name",""), d.get("description") or d.get("name","")))
' | pick "Dispositivos de áudio")"
  [ -z "$sel" ] && return 0
  name="${sel%%|*}"; desc="${sel#*|}"
  if [ "$kind" = "sink" ]; then pactl set-default-sink "$name"; else pactl set-default-source "$name"; fi
  notify "Áudio" "Padrão: $desc"
}

audio_menu() {
  local sel
  sel="$(printf '%s\n' \
    "󰕾  Volume +5%" \
    "󰕾  Volume -5%" \
    "󰝟  Mudo (alternar)" \
    "󰓃  Trocar saída..." \
    "󰍬  Trocar entrada..." \
    "󰒓  Abrir mixer (pavucontrol)" | pick "Áudio")"
  case "$sel" in
    *"Volume +5%"*) wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    *"Volume -5%"*) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    *Mudo*)         wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    *"Trocar saída"*)   audio_switch sink ;;
    *"Trocar entrada"*) audio_switch source ;;
    *"Abrir mixer"*)    (pavucontrol >/dev/null 2>&1 &) ;;
  esac
}

# ------------------------------- Mídia ------------------------------
media_menu() {
  local sel
  sel="$(printf '%s\n' \
    "󰐊  Play/Pausar" \
    "󰒭  Próxima" \
    "󰒮  Anterior" \
    "󰝚  Tocando agora" | pick "Mídia")"
  case "$sel" in
    *Play*)  playerctl play-pause ;;
    *Próxima*) playerctl next ;;
    *Anterior*) playerctl previous ;;
    *"Tocando agora"*) notify "Mídia" "$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null || echo 'nada tocando')" ;;
  esac
}

# --------------------------- Perfil de energia ----------------------
power_menu() {
  local sel
  sel="$(printf '%s\n' \
    "󰾆  Econômico (powersave)" \
    "󰒓  Equilibrado (balanced)" \
    "󰓅  Desempenho (throughput-performance)" | pick "Perfil de energia")"
  case "$sel" in
    *powersave*)    priv tuned-adm profile powersave              >/dev/null 2>&1 && notify "Energia" "Perfil: powersave" ;;
    *balanced*)     priv tuned-adm profile balanced               >/dev/null 2>&1 && notify "Energia" "Perfil: balanced" ;;
    *throughput*)   priv tuned-adm profile throughput-performance >/dev/null 2>&1 && notify "Energia" "Perfil: throughput-performance" ;;
  esac
}

# --------------------------- Captura de tela ------------------------
shot_menu() {
  local sel
  sel="$(printf '%s\n' \
    "󰄾  Capturar região" \
    "󰏫  Anotar captura" \
    "󰈙  Extrair texto (OCR)" | pick "Captura de tela")"
  case "$sel" in
    *"Capturar região"*) "$SCRIPTS/screenshot-region.sh" ;;
    *Anotar*)            "$SCRIPTS/screenshot-region.sh" annotate ;;
    *OCR*)               "$SCRIPTS/screenshot-region.sh" ocr ;;
  esac
}

# ------------------------------- Principal --------------------------
main_menu() {
  local net ts
  net="$(net_active)"; tail_up && ts="on" || ts="off"
  printf '%s\n' \
    "󰖩  Rede — ${net:-desconectada}  (Tailscale: $ts)" \
    "󰕾  Áudio" \
    "󰝚  Mídia" \
    "󰒓  Perfil de energia" \
    "󰄾  Captura de tela" \
    "󰆏  Área de transferência" \
    "󰖯  Widgets (Conky)" \
    "󰐥  Energia / Sessão"
}

sel="$(main_menu | pick "Central de Controle")"
case "$sel" in
  *Rede*)                  net_menu ;;
  *Áudio*)                 audio_menu ;;
  *Mídia*)                 media_menu ;;
  *"Perfil de energia"*)   power_menu ;;
  *Captura*)               shot_menu ;;
  *"Área de transferência"*) "$SCRIPTS/clipboard-menu.sh" ;;
  *Widgets*)               "$HOME/.local/bin/conky-toggle" ;;
  *"Energia / Sessão"*)    "$HOME/.config/waybar/power-menu.sh" ;;
esac

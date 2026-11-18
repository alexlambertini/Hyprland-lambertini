#!/bin/bash
# Central de Controle (Rofi) — menu único no tema do sistema com submenus:
#   Rede (cabeada + Tailscale), Wi-Fi, Bluetooth, Áudio, Mídia, Perfil de energia,
#   Captura de tela, Área de transferência, Widgets (Conky) e Sessão.
# Wi-Fi/Bluetooth só aparecem com adaptador; sem hardware avisam e voltam.
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

# ------------------------------- Wi-Fi ------------------------------
wifi_dev()    { nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}'; }
wifi_status() { local d; d="$(wifi_dev)"
                [ -z "$d" ] && { echo "sem adaptador"; return; }
                [ "$(nmcli -t radio wifi 2>/dev/null)" = "enabled" ] && echo "ligado" || echo "desligado"; }

wifi_scan() {
  local sel ssid sec pw line
  sel="$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list --rescan yes 2>/dev/null \
        | while IFS= read -r line; do
            sec="${line##*:}"; rest="${line%:*}"
            sig="${rest##*:}"; ssid="${rest%:*}"
            ssid="${ssid//\\:/:}"
            { [ -z "$ssid" ] || [ "$ssid" = "--" ]; } && continue
            printf '%s\t%s\t%s\n' "$ssid" "$sig" "$sec"
          done | sort -u -t$'\t' -k1,1 \
        | awk -F'\t' '{printf "%s  (%s%%, %s)\n",$1,$2,($3==""?"aberta":$3)}' | pick "Redes Wi-Fi")"
  [ -z "$sel" ] && return 0
  ssid="${sel%%  (*}"
  sec="${sel##*  (}"; sec="${sec##*, }"; sec="${sec%)}"
  if [ "$sec" = "aberta" ]; then
    nmcli device wifi connect "$ssid" >/dev/null 2>&1 && notify "Wi-Fi" "Conectado: $ssid" || notify "Wi-Fi" "Falha: $ssid"
  else
    pw="$(ask "Senha de $ssid")"; [ -z "$pw" ] && return 0
    nmcli device wifi connect "$ssid" password "$pw" >/dev/null 2>&1 && notify "Wi-Fi" "Conectado: $ssid" || notify "Wi-Fi" "Falha: $ssid"
  fi
}

wifi_menu() {
  local d sel ssid
  d="$(wifi_dev)"
  if [ -z "$d" ]; then notify "Wi-Fi" "Nenhum adaptador Wi-Fi detectado"; return 0; fi
  sel="$(printf '%s\n' \
    "󰖩  Wi-Fi: $(wifi_status)" \
    "󰒓  Ligar Wi-Fi" \
    "󰒓  Desligar Wi-Fi" \
    "󰖩  Redes disponíveis..." \
    "󰒓  Conectar a rede oculta..." | pick "Wi-Fi")"
  case "$sel" in
    *"Ligar Wi-Fi"*)      nmcli radio wifi on  >/dev/null 2>&1 && notify "Wi-Fi" "Ligado" ;;
    *"Desligar Wi-Fi"*)   nmcli radio wifi off >/dev/null 2>&1 && notify "Wi-Fi" "Desligado" ;;
    *"Redes disponíveis"*) wifi_scan ;;
    *"rede oculta"*)      ssid="$(ask "SSID da rede")"
                          if [ -n "$ssid" ]; then
                            nmcli device wifi connect "$ssid" >/dev/null 2>&1 && notify "Wi-Fi" "Conectando: $ssid" || notify "Wi-Fi" "Falha: $ssid"
                          fi ;;
  esac
}

# ----------------------------- Bluetooth ----------------------------
bt_ok()     { have bluetoothctl && systemctl is-active --quiet bluetooth 2>/dev/null; }
bt_status() { bt_ok || { echo "indisponível"; return; }
              timeout 3 bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && echo "ligado" || echo "desligado"; }

bt_pairs()  { timeout 5 bluetoothctl devices Paired 2>/dev/null || timeout 5 bluetoothctl paired-devices 2>/dev/null; }
bt_list()   { timeout 5 bluetoothctl devices 2>/dev/null | sed -n 's/^Device \([0-9A-Fa-f:]\{17\}\) \(.*\)/\2  (\1)/p'; }

bt_connect_menu() {
  local sel name mac
  sel="$(bt_pairs | sed -n 's/^Device \([0-9A-Fa-f:]\{17\}\) \(.*\)/\2  (\1)/p' | pick "Dispositivos Bluetooth")"
  [ -z "$sel" ] && return 0
  name="${sel%  (*}"; mac="${sel##*(}"; mac="${mac%)}"
  timeout 15 bluetoothctl connect "$mac" >/dev/null 2>&1 && notify "Bluetooth" "Conectado: $name" || notify "Bluetooth" "Falha: $name"
}

bt_scan_menu() {
  local sel name mac
  notify "Bluetooth" "Procurando dispositivos (~10s)..."
  timeout 12 bluetoothctl --timeout 10 scan on >/dev/null 2>&1
  sel="$(bt_list | pick "Parear dispositivo")"
  [ -z "$sel" ] && return 0
  name="${sel%  (*}"; mac="${sel##*(}"; mac="${mac%)}"
  timeout 15 bluetoothctl pair  "$mac" >/dev/null 2>&1
  timeout 10 bluetoothctl trust "$mac" >/dev/null 2>&1
  timeout 15 bluetoothctl connect "$mac" >/dev/null 2>&1 && notify "Bluetooth" "Pareado e conectado: $name" || notify "Bluetooth" "Falha: $name"
}

bt_menu() {
  local sel extra
  if ! bt_ok; then notify "Bluetooth" "Nenhum adaptador/serviço Bluetooth disponível"; return 0; fi
  have blueman-manager && extra="󰂯  Abrir gerenciador (blueman)" || extra=""
  sel="$(printf '%s\n' \
    "󰂯  Bluetooth: $(bt_status)" \
    "󰒓  Ligar" \
    "󰒓  Desligar" \
    "󰂰  Dispositivos pareados..." \
    "󰂰  Escanear e parear..." \
    ${extra:+"$extra"} | pick "Bluetooth")"
  case "$sel" in
    *"Ligar"*)    timeout 5 bluetoothctl power on  >/dev/null 2>&1 && notify "Bluetooth" "Ligado" ;;
    *"Desligar"*) timeout 5 bluetoothctl power off >/dev/null 2>&1 && notify "Bluetooth" "Desligado" ;;
    *"pareados"*) bt_connect_menu ;;
    *"Escanear"*) bt_scan_menu ;;
    *blueman*)    (blueman-manager >/dev/null 2>&1 &) ;;
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
    "󰈀  Rede — ${net:-desconectada}  (Tailscale: $ts)" \
    "󰖩  Wi-Fi — $(wifi_status)" \
    "󰂯  Bluetooth — $(bt_status)" \
    "󰕾  Áudio" \
    "󰝚  Mídia" \
    "󰒓  Perfil de energia" \
    "󰄾  Captura de tela" \
    "󰆏  Área de transferência" \
    "󰖯  Widgets (Conky)" \
    "󰐥  Energia / Sessão"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  sel="$(main_menu | pick "Central de Controle")"
  case "$sel" in
    *Rede*)                    net_menu ;;
    *Wi-Fi*)                   wifi_menu ;;
    *Bluetooth*)               bt_menu ;;
    *Áudio*)                   audio_menu ;;
    *Mídia*)                   media_menu ;;
    *"Perfil de energia"*)     power_menu ;;
    *Captura*)                 shot_menu ;;
    *"Área de transferência"*) "$SCRIPTS/clipboard-menu.sh" ;;
    *Widgets*)                 "$HOME/.local/bin/conky-toggle" ;;
    *"Energia / Sessão"*)      "$HOME/.config/waybar/power-menu.sh" ;;
  esac
fi

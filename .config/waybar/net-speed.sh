#!/bin/bash
STATE="$HOME/.config/waybar/.netspeed-enabled"
CACHE="$HOME/.config/waybar/.netspeed-cache"

if [ ! -f "$STATE" ]; then
  echo '{"text":"󰈀","tooltip":"Tráfego de rede oculto (clique para mostrar)","class":"disabled"}'
  exit 0
fi

IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)
[ -z "$IFACE" ] && IFACE=$(nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | awk -F: '$3=="connected" && $2!="loopback" {print $1; exit}')

if [ -z "$IFACE" ] || [ ! -d "/sys/class/net/$IFACE" ]; then
  echo '{"text":"󰈀 --","tooltip":"Interface de rede não encontrada","class":"error"}'
  exit 0
fi

RX=$(cat "/sys/class/net/$IFACE/statistics/rx_bytes" 2>/dev/null)
TX=$(cat "/sys/class/net/$IFACE/statistics/tx_bytes" 2>/dev/null)
NOW=$(date +%s)

DRX=0; DTX=0
if [ -f "$CACHE" ]; then
  read -r ORX OTX OT < "$CACHE"
  DT=$((NOW - OT))
  [ "$DT" -le 0 ] && DT=1
  DRX=$(( (RX - ORX) / DT ))
  DTX=$(( (TX - OTX) / DT ))
  [ "$DRX" -lt 0 ] && DRX=0
  [ "$DTX" -lt 0 ] && DTX=0
fi
echo "$RX $TX $NOW" > "$CACHE"

fmt() {
  local B=$1
  if [ "$B" -ge 1048576 ]; then
    awk -v b="$B" 'BEGIN{printf "%.1fM", b/1048576}'
  elif [ "$B" -ge 1024 ]; then
    awk -v b="$B" 'BEGIN{printf "%.0fK", b/1024}'
  else
    printf "%dB" "$B"
  fi
}

echo "{\"text\":\"↓$(fmt $DRX) ↑$(fmt $DTX)\",\"tooltip\":\"Rede ($IFACE)\\n↓ $(fmt $DRX)/s  ↑ $(fmt $DTX)/s\\n(clique para ocultar/mostrar)\",\"class\":\"enabled\"}"

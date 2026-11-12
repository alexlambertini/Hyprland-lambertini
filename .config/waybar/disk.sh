#!/bin/bash
STATE="$HOME/.config/waybar/.disk-enabled"
if [ ! -f "$STATE" ]; then
  echo '{"text":"󰋊","tooltip":"Disco oculto (clique para mostrar)","class":"disabled"}'
  exit 0
fi

read -r USED AVAIL PCT <<<$(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $3, $4, $5}')
if [ -z "$PCT" ]; then
  echo '{"text":"󰋊 ?","tooltip":"Disco indisponível","class":"error"}'
  exit 0
fi

CLASS="ok"
[ "$PCT" -ge 80 ] && CLASS="warning"
[ "$PCT" -ge 90 ] && CLASS="critical"

echo "{\"text\":\"󰋊 ${PCT}%\",\"tooltip\":\"Disco /: ${USED} usado, ${AVAIL} livre (${PCT}%)\\n(clique para ocultar/mostrar)\",\"class\":\"${CLASS}\"}"

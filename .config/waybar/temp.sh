#!/bin/bash
STATE="$HOME/.config/waybar/.temp-enabled"
if [ ! -f "$STATE" ]; then
  echo '{"text":"","tooltip":"Temperatura oculta (clique para mostrar)","class":"disabled"}'
  exit 0
fi

OUT=$(sensors 2>/dev/null)
if [ -z "$OUT" ]; then
  echo '{"text":" ?","tooltip":"Sensores indisponíveis","class":"error"}'
  exit 0
fi

# Tenta temperatura do pacote CPU, senão edge GPU, senão acpitz
TEMP=$(echo "$OUT" | awk '/Package id 0:/ {gsub(/\+|°C.*/,"",$4); print $4; exit}')
LABEL="CPU"
if [ -z "$TEMP" ]; then
  TEMP=$(echo "$OUT" | awk '/edge:/ {gsub(/\+|°C.*/,"",$2); print $2; exit}')
  LABEL="GPU"
fi
if [ -z "$TEMP" ]; then
  TEMP=$(echo "$OUT" | awk '/temp1:/ {gsub(/\+|°C.*/,"",$2); print $2; exit}')
  LABEL="Sistema"
fi

if [ -z "$TEMP" ]; then
  echo '{"text":" --","tooltip":"Sem leitura de temperatura","class":"error"}'
  exit 0
fi

# Inteiro para exibição
TINT=$(awk -v t="$TEMP" 'BEGIN{printf "%.0f", t}')
CLASS="ok"
[ "$TINT" -ge 70 ] 2>/dev/null && CLASS="warning"
[ "$TINT" -ge 85 ] 2>/dev/null && CLASS="critical"

echo "{\"text\":\" ${TINT}°C\",\"tooltip\":\"Temperatura (${LABEL}): ${TINT}°C\\n(clique para ocultar/mostrar)\",\"class\":\"${CLASS}\"}"

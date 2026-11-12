#!/bin/bash
# Widget de clima para Waybar (temperatura, detecção automática por IP via wttr.in)
STATE="$HOME/.config/waybar/.weather-enabled"

# Desabilitado: mostra indicador discreto para poder reativar com clique
if [ ! -f "$STATE" ]; then
  echo '{"text":"󰖐","tooltip":"Clima oculto (clique para mostrar)","class":"disabled"}'
  exit 0
fi

# Busca clima (timeout curto para não travar a barra)
DATA=$(curl -fsS --max-time 8 'https://wttr.in/?format=j1' 2>/dev/null)
if [ -z "$DATA" ]; then
  echo '{"text":"󰖐 --","tooltip":"Não foi possível obter o clima (clique para tentar atualizar/alternar)","class":"error"}'
  exit 0
fi

TEMP=$(printf '%s' "$DATA" | jq -r '.current_condition[0].temp_C // empty' 2>/dev/null)
DESC=$(printf '%s' "$DATA" | jq -r '.current_condition[0].weatherDesc[0].value // empty' 2>/dev/null)
FEELS=$(printf '%s' "$DATA" | jq -r '.current_condition[0].FeelsLikeC // empty' 2>/dev/null)
HUM=$(printf '%s' "$DATA" | jq -r '.current_condition[0].humidity // empty' 2>/dev/null)
AREA=$(printf '%s' "$DATA" | jq -r '.nearest_area[0].areaName[0].value // empty' 2>/dev/null)
REGION=$(printf '%s' "$DATA" | jq -r '.nearest_area[0].region[0].value // empty' 2>/dev/null)

if [ -z "$TEMP" ]; then
  echo '{"text":"󰖐 --","tooltip":"Clima indisponível","class":"error"}'
  exit 0
fi

TEXT="󰖐 ${TEMP}°C"
LOC="$AREA"
[ -n "$REGION" ] && [ -n "$LOC" ] && LOC="$LOC, $REGION"
[ -z "$LOC" ] && LOC="Localização automática"

TOOLTIP="${LOC}\\n${DESC}\\nSensação: ${FEELS}°C | Umidade: ${HUM}%\\n(clique para habilitar/desabilitar)"

# Escapa para JSON
TEXT_ESC=$(printf '%s' "$TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g')
TOOLTIP_ESC=$(printf '%s' "$TOOLTIP" | sed 's/\\/\\\\/g; s/"/\\"/g')

printf '{"text":"%s","tooltip":"%s","class":"enabled"}\n' "$TEXT_ESC" "$TOOLTIP_ESC"

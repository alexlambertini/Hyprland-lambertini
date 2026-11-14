#!/bin/bash
DATA=$(curl -fsS --max-time 8 'https://wttr.in/?format=j1' 2>/dev/null)
if [ -z "$DATA" ]; then echo "Clima indisponível"; exit 0; fi
TEMP=$(printf '%s' "$DATA" | jq -r '.current_condition[0].temp_C // empty' 2>/dev/null)
DESC=$(printf '%s' "$DATA" | jq -r '.current_condition[0].lang_pt[0].value // .current_condition[0].weatherDesc[0].value // empty' 2>/dev/null)
FEELS=$(printf '%s' "$DATA" | jq -r '.current_condition[0].FeelsLikeC // empty' 2>/dev/null)
HUM=$(printf '%s' "$DATA" | jq -r '.current_condition[0].humidity // empty' 2>/dev/null)
AREA=$(printf '%s' "$DATA" | jq -r '.nearest_area[0].areaName[0].value // empty' 2>/dev/null)
if [ -z "$TEMP" ]; then echo "Clima indisponível"; exit 0; fi
echo "${TEMP}°C · ${DESC}"
echo "Sensação ${FEELS}°C · Umidade ${HUM}%"
[ -n "$AREA" ] && echo "$AREA"

#!/bin/bash
STATE="$HOME/.config/waybar/.mic-enabled"
if [ ! -f "$STATE" ]; then
  echo '{"text":"","tooltip":"Microfone oculto (clique dir. para mostrar)","class":"disabled"}'
  exit 0
fi

get_source() {
  wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null && return 0
  wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null && return 0
  # fallback: primeiro Source listado
  local id
  id=$(wpctl status 2>/dev/null | awk '/Sources:/{f=1;next} f && /^[[:space:]]*│[[:space:]]*$/{exit} f && /[0-9]+\./{gsub(/[^0-9]/,"",$1); if($1!=""){print $1; exit}}')
  [ -n "$id" ] && wpctl get-volume "$id" 2>/dev/null && return 0
  return 1
}

VOL=$(get_source)
if [ -z "$VOL" ]; then
  echo '{"text":"","tooltip":"Microfone indisponível/sem fonte padrão (clique dir. para ocultar)","class":"error"}'
  exit 0
fi

MUTED=0
echo "$VOL" | grep -q MUTED && MUTED=1
PCT=$(echo "$VOL" | awk '{printf "%d", $2*100}')

if [ "$MUTED" -eq 1 ]; then
  echo "{\"text\":\"\",\"tooltip\":\"Microfone: mudo (clique esq. mutar/ativar, dir. ocultar)\",\"class\":\"muted\"}"
else
  echo "{\"text\":\" ${PCT}%\",\"tooltip\":\"Microfone: ${PCT}% (clique esq. mutar/ativar, dir. ocultar)\",\"class\":\"active\"}"
fi

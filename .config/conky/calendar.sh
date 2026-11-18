#!/bin/bash
# Calendario de 2 meses (atual + proximo) para o Conky.
# Destaca o dia de hoje e os feriados, colore o cabecalho dos dias da
# semana e gera um arquivo de estado (calendar-state.lua) lido pelo
# tooltip (calendar.lua).
#
# Cores (tema Waybar):
#   hoje        -> laranja  #df6124 (negrito)
#   feriado     -> sky      #89dceb
#   sab/dom     -> vermelho #f53c3c (cabecalho)
#   seg a sex   -> amarelo  #f9e2af (cabecalho)
#
# Feriados: nacionais fixos + Sexta-feira Santa (movel).
# (Carnaval e Corpus Christi sao ponto facultativo - nao incluidos.)

TODAY_TAG='${color #df6124}'
HOLIDAY_TAG='${color #89dceb}'
WEEKEND_TAG='${color #f53c3c}'      # cabecalho: sabado e domingo
WEEKDAY_TAG='${color #f9e2af}'      # cabecalho: segunda a sexta
RESET='${color}'
TODAY_FONT='${font JetBrains Mono Nerd Font:size=9:bold}'
BASE_FONT='${font JetBrains Mono Nerd Font:size=9}'
GAP="      "                                  # 6 espacos entre os dois meses
STATE="$HOME/.config/conky/calendar-state.lua"

TODAY_D=$(date +%-d)
TODAY_M=$(date +%-m)
TODAY_Y=$(date +%Y)
NEXT_M=$(( TODAY_M % 12 + 1 ))
NEXT_Y=$TODAY_Y
[ "$NEXT_M" -eq 1 ] && NEXT_Y=$(( TODAY_Y + 1 ))

# Data da Pascoa (Meeus/Jones/Butcher, calendario gregoriano).
easter() {
  local y=$1 a b c d e f g h i k l m month day
  a=$((y % 19)); b=$((y / 100)); c=$((y % 100))
  d=$((b / 4)); e=$((b % 4))
  f=$(((b + 8) / 25)); g=$(((b - f + 1) / 3))
  h=$(((19*a + b - d - g + 15) % 30))
  i=$((c / 4)); k=$((c % 4))
  l=$(((32 + 2*e + 2*i - h - k) % 7))
  m=$(((a + 11*h + 22*l) / 451))
  month=$(((h + l - 7*m + 114) / 31))
  day=$(((h + l - 7*m + 114) % 31 + 1))
  printf '%04d-%02d-%02d\n' "$y" "$month" "$day"
}

# Feriados do mes $2 do ano $1: imprime "DD|Nome" (um por linha).
holidays_named() {
  local y=$1 m=$2 es mm dd
  case "$m" in
    1)  echo "1|Confraternização Universal" ;;
    4)  echo "21|Tiradentes" ;;
    5)  echo "1|Dia do Trabalhador" ;;
    9)  echo "7|Independência" ;;
    10) echo "12|Nossa Senhora Aparecida" ;;
    11) echo "2|Finados"; echo "15|Proclamação da República"; echo "20|Consciência Negra" ;;
    12) echo "25|Natal" ;;
  esac
  # Sexta-feira Santa = Pascoa - 2 dias
  es=$(easter "$y")
  read -r mm dd < <(date -d "$es -2 days" +'%m %d')
  mm=$((10#$mm)); dd=$((10#$dd))
  [ "$mm" -eq "$m" ] && echo "$dd|Sexta-feira Santa"
}

# Numero do dia num campo de 2 chars ("0" se vazio).
field_day() { local f="${1// /}"; [ -n "$f" ] && printf '%d' "$((10#$f))" || printf '0'; }

# Destaca, numa linha de 20 chars (7 campos de 2), hoje e feriados.
# $1 = linha, $2 = dia de hoje (vazio se nao for o mes atual), $3.. = feriados.
render_row() {
  local line="$1" today="$2"; shift 2
  local hols=" $* " out="" k s f num
  for k in 0 1 2 3 4 5 6; do
    s=$((k*3)); f="${line:s:2}"
    [ "$k" -gt 0 ] && out+=" "
    num="${f// /}"
    if [ -n "$num" ] && [ -n "$today" ] && [ "$num" = "$today" ]; then
      out+="${TODAY_TAG}${TODAY_FONT}${f}${BASE_FONT}${RESET}"
    elif [ -n "$num" ] && [[ "$hols" == *" $num "* ]]; then
      out+="${HOLIDAY_TAG}${f}${RESET}"
    else
      out+="$f"
    fi
  done
  printf '%s' "$out"
}

# Colore o cabecalho dos dias da semana (7 campos de 2 chars):
# domingo (campo 0) e sabado (campo 6) em vermelho; seg-sex em amarelo.
render_header() {
  local line="$1" out="" k s f
  for k in 0 1 2 3 4 5 6; do
    s=$((k*3)); f="${line:s:2}"
    [ "$k" -gt 0 ] && out+=" "
    if [ "$k" -eq 0 ] || [ "$k" -eq 6 ]; then
      out+="${WEEKEND_TAG}${f}${RESET}"
    else
      out+="${WEEKDAY_TAG}${f}${RESET}"
    fi
  done
  printf '%s' "$out"
}

# --- dados dos feriados ---
mapfile -t HOL_A < <(holidays_named "$TODAY_Y" "$TODAY_M")
mapfile -t HOL_B < <(holidays_named "$NEXT_Y" "$NEXT_M")
HOL_A_DAYS=$(printf '%s\n' "${HOL_A[@]}" | cut -d'|' -f1 | tr '\n' ' ')
HOL_B_DAYS=$(printf '%s\n' "${HOL_B[@]}" | cut -d'|' -f1 | tr '\n' ' ')

# --- monta o calendario e as grades ---
mapfile -t rows < <(cal -n 2)
GL=(); GR=()
idx=0
for line in "${rows[@]}"; do
  if [ "$idx" -ge 2 ]; then
    lrow=""; rrow=""
    for k in 0 1 2 3 4 5 6; do
      [ "$k" -gt 0 ] && { lrow+=","; rrow+=","; }
      lrow+="$(field_day "${line:$((k*3)):2}")"
      rrow+="$(field_day "${line:$((22+k*3)):2}")"
    done
    GL+=("$lrow"); GR+=("$rrow")
  fi
  idx=$((idx+1))
done
# garante 6 linhas (meses com 6 semanas)
while [ "${#GL[@]}" -lt 6 ]; do GL+=("0,0,0,0,0,0,0"); done
while [ "${#GR[@]}" -lt 6 ]; do GR+=("0,0,0,0,0,0,0"); done

# --- desenha ---
idx=0
for line in "${rows[@]}"; do
  left="${line:0:20}"
  right="${line:22}"
  if [ "$idx" -eq 1 ]; then
    lout=$(render_header "$left")
    rout=$(render_header "$right")
    printf '%s%s%s\n' "$lout" "$GAP" "$rout"
  elif [ "$idx" -lt 2 ]; then
    printf '%s%s%s\n' "$left" "$GAP" "$right"
  else
    lout=$(render_row "$left" "$TODAY_D" $HOL_A_DAYS)
    rout=$(render_row "$right" "" $HOL_B_DAYS)
    printf '%s%s%s\n' "$lout" "$GAP" "$rout"
  fi
  idx=$((idx+1))
done

# --- estado para o tooltip (calendar.lua) ---
{
  printf 'return {\n'
  printf '  month = { L = %d, R = %d },\n' "$TODAY_M" "$NEXT_M"
  printf '  year  = { L = %d, R = %d },\n' "$TODAY_Y" "$NEXT_Y"
  printf '  grid = {\n    L = {\n'
  for r in "${GL[@]}"; do printf '      {%s},\n' "$r"; done
  printf '    },\n    R = {\n'
  for r in "${GR[@]}"; do printf '      {%s},\n' "$r"; done
  printf '    },\n  },\n  holidays = {\n'
  for ln in "${HOL_A[@]}"; do
    [ -z "$ln" ] && continue
    printf '    ["%d-%d"] = "%s",\n' "$TODAY_M" "$((10#${ln%%|*}))" "${ln#*|}"
  done
  for ln in "${HOL_B[@]}"; do
    [ -z "$ln" ] && continue
    printf '    ["%d-%d"] = "%s",\n' "$NEXT_M" "$((10#${ln%%|*}))" "${ln#*|}"
  done
  printf '  },\n}\n'
} > "$STATE"

#!/bin/bash
# Notificação de faixa em reprodução (MPRIS/playerctl + notify-send/dunst)

command -v playerctl >/dev/null 2>&1 || exit 0
command -v notify-send >/dev/null 2>&1 || exit 0

LAST=""

playerctl --follow metadata --format '{{status}}|{{artist}}|{{title}}|{{album}}|{{mpris:artUrl}}' 2>/dev/null | while IFS='|' read -r STATUS ARTIST TITLE ALBUM ART; do
  [ -z "$TITLE" ] && continue
  [ "$STATUS" != "Playing" ] && continue
  KEY="$ARTIST|$TITLE|$ALBUM"
  [ "$KEY" = "$LAST" ] && continue
  LAST="$KEY"

  BODY="$ARTIST"
  [ -n "$ALBUM" ] && [ -n "$ARTIST" ] && BODY="$ARTIST — $ALBUM"
  [ -z "$ARTIST" ] && BODY="$ALBUM"

  notify-send -a "music-notify" -u normal -i "audio-x-generic" "♪ $TITLE" "$BODY"
done

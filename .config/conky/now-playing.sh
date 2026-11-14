#!/bin/bash
if ! command -v playerctl >/dev/null 2>&1; then echo "playerctl não encontrado"; exit 0; fi
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ] || [ "$status" = "Stopped" ]; then
  echo "Nada tocando"
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)
if [ -n "$artist" ] && [ -n "$title" ]; then
  echo "$artist — $title"
elif [ -n "$title" ]; then
  echo "$title"
else
  echo "$status"
fi
echo "[$status]"

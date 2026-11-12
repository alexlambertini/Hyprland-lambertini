#!/bin/bash
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null || wpctl set-mute @DEFAULT_SOURCE@ toggle 2>/dev/null || true
pkill -RTMIN+12 waybar 2>/dev/null || true

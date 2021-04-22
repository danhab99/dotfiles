#!/bin/bash
dunstctl set-paused true
amixer set Master 0%
MEDIA_STATUS=$(playerctl status)
playerctl pause
# adb shell input keyevent 26 &

i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n

dunstctl set-paused false
amixer set Master 100%

if [ $MEDIA_STATUS = "Playing" ]; then
  playerctl play
fi

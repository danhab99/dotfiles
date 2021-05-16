#!/bin/bash
dunstctl set-paused true
MEDIA_STATUS=$(playerctl status)
playerctl pause

i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n

dunstctl set-paused false

if [ $MEDIA_STATUS = "Playing" ]; then
  playerctl play
fi

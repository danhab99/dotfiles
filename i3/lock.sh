#!/bin/bash
notify-send "DUNST_COMMAND_PAUSE"
MEDIA_STATUS=$(playerctl status)
playerctl pause
# adb shell input keyevent 26 &

i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n

notify-send "DUNST_COMMAND_RESUME"

if [ $MEDIA_STATUS = "Playing" ]; then
  playerctl play
fi

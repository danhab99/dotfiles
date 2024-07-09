#!/bin/bash

MEDIA_STATUS=$(playerctl status)
playerctl pause


current_hour=$(date +"%H")

day_start=6
day_end=23

if [ "$current_hour" -ge "$day_start" ] && [ "$current_hour" -lt "$day_end" ]; then
  let OFF=$day_end-$day_start
  betterlockscreen --lock blur --off $OFF
else
  i3lock -c 000000
fi

if [ "$MEDIA_STATUS" == "Playing" ]; then
  playerctl play
fi

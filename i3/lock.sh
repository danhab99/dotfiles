#!/bin/bash
set +x
dunstctl set-paused true
#playerctl pause

i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n

dunstctl set-paused false

#playerctl play

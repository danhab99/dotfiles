#!/bin/bash
# set +x
# dunstctl set-paused true
# MEDIA_STATUS=$(playerctl status)
# playerctl pause

#i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n
betterlockscreen -l

# dunstctl set-paused false

# if [ "$MEDIA_STATUS" == "Playing" ]; then
#   playerctl play
# fi

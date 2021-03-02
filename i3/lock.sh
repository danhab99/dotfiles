#!/bin/bash
notify-send "DUNST_COMMAND_PAUSE"
amixer -D pulse sset Master 0%

i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n

notify-send "DUNST_COMMAND_RESUME"
amixer -D pulse sset Master 100%

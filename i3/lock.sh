#!/bin/bash
notify-send "DUNST_COMMAND_PAUSE"
i3lock -t -i "$(grep -P -o '(?<=file=).*' ~/.config/nitrogen/bg-saved.cfg)" -n
notify-send "DUNST_COMMAND_RESUME"

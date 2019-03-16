#!/bin/bash

WP=$($HOME/.config/variety/scripts/get_wallpaper | grep -Po "(?<=file:\/\/).*(?=\')")
NWP=$(mogrify -verbose -format png $WP 2>&1 >/dev/null | grep -Po "(?<==>).+\.png")
i3lock -i $NWP

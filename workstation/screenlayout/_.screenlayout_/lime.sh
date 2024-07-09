#!/bin/sh
xrandr --output eDP1 --primary --mode 1920x1080 --pos 1080x1080 --rotate normal --output DP1 --off --output DP2 --off --output DP3 --mode 1920x1080 --pos 0x0 --rotate left --output DP4 --off --output HDMI1 --mode 1920x1080 --pos 1080x0 --rotate normal --output VIRTUAL1 --off
sleep 1
nitrogen --restore
betterlockscreen --update "$(cat bg-saved.cfg | grep -Po "file.*" | grep -Po "/.*")"

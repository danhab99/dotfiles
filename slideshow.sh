#!/bin/bash

here=$HOME/Pictures/wallpaper

mkdir -p $here/.cache

while true; do
	for f in $here/*.png; do
		source $here/changewallpaper.sh "$f"
		notify-send "Changed wallpaper to $f"
		sleep 10m
	done
done

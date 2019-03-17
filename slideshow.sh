#!/bin/bash

mkdir -p $HOME/Pictures/wallpaper/.cache

while true; do
	ls *.png | shuf > .cache/list
	for f in $(cat list); do
		cp -f "$f" .cache/current_wallpaper.png
		feh --bg-scale .cache/current_wallpaper.png
		convert .cache/current_wallpaper.png -blur 0x8 -resize 1920x1080! .cache/blurred_wallpaper.png
		sleep 10m
	done
done

#!/bin/bash

mkdir -p $HOME/Pictures/wallpaper/.cache

if [ ! -f $HOME/Pictures/wallpaper/.cache/.LOCK ]; then
	touch $HOME/Pictures/wallpaper/.cache/.LOCK
else
	echo "Lock file exists"
	exit 1
fi

cp -f "$1" .cache/current_wallpaper.png
convert .cache/current_wallpaper.png -blur 0x8 -resize 1920x1080! .cache/blurred_wallpaper.png
feh --bg-scale .cache/current_wallpaper.png

rm $HOME/Pictures/wallpaper/.cache/.LOCK

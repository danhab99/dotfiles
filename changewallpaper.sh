#!/bin/bash

mkdir -p $HOME/Pictures/wallpaper/.cache

if [ ! -f $HOME/Pictures/wallpaper/.cache/.LOCK ]; then
	touch $HOME/Pictures/wallpaper/.cache/.LOCK
else
	echo "Lock file exists"
	echo ""
	echo "Please run sudo rm $HOME/Pictures/wallpaper/.cache/.LOCK to fix"
	exit 1
fi

if [[ $1 =~ http.* ]]; then
	echo "Downloading..."
	curl -o- $1 > .cache/current_wallpaper.png
else
	echo "Copying..."
	cp -f "$1" .cache/current_wallpaper.png
fi

convert .cache/current_wallpaper.png -blur 0x8 -resize 1920x1080! .cache/blurred_wallpaper.png
feh --bg-scale .cache/current_wallpaper.png

rm $HOME/Pictures/wallpaper/.cache/.LOCK

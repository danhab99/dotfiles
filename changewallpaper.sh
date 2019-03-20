#!/bin/bash

cache=$HOME/.cache/wallpaper
lock=$cache/.LOCK

mkdir -p $cache

if [ ! -f $lock ]; then
	touch $lock
else
	echo "Lock file exists"
	echo ""
	echo "Please run sudo rm $lock to fix"
	exit 1
fi

if [[ $1 =~ http.* ]]; then
	echo "Downloading..."
	curl -o- $1 > $cache/current_wallpaper.png
else
	echo "Copying..."
	cp -f "$1" $cache/current_wallpaper.png
fi

convert $cache/current_wallpaper.png -blur 0x8 -resize 1920x1080! $cache/blurred_wallpaper.png
feh --bg-scale $cache/current_wallpaper.png

rm $lock

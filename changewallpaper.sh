#!/bin/bash

cache=$HOME/Pictures/wallpaper/.cache/
lock=$cache/.LOCK

rm -rf $cache
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

echo "Setting wallpaper"
feh --bg-scale $cache/current_wallpaper.png

echo "Creating lockscreen"
convert $cache/current_wallpaper.png -blur 0x16 -resize 1920x1080! $cache/blurred_wallpaper.png
convert $cache/blurred_wallpaper.png -gravity North -pointsize 100 -font helvetica -fill white -annotate +0+100 'Locked' $cache/blurred_wallpaper.png
convert $cache/blurred_wallpaper.png -gravity North -pointsize 25 -font helvetica -fill white -annotate +0+200 'Start typing to unlock' $cache/blurred_wallpaper.png

rm $lock

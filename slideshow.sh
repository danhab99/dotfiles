#!/bin/bash

here=$HOME/Pictures/wallpaper
cache=$here/.cache
lock=$cache/.SH_LOCK
mkdir -p $cache

if [ ! -f $lock ]; then
	touch $lock
	echo "Starting slideshow"
	echo $BASHPID > $lock
else
	PID=$(cat $lock)
	if [ -e /proc/${PID} -a /proc/${PID}/exe ]; then
		echo "Slideshow is already running"
		exit 1
	else
		echo $BASHPID > $lock
	fi
fi


while true; do
	for f in $here/*.png; do
		source $here/changewallpaper.sh "$f"
		notify-send "Changed wallpaper to $f"
		sleep 10m
	done
done

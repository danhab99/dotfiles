#!/usr/bin/env bash
ID=$(xinput | grep "ELAN0650:01 04F3:304B Touchpad" | grep -Po "(?<=id=)\d+")

function lp {
	i=$(xinput list-props $ID | grep "$1" | head -1 | grep -Po "(?<=\()\d+")
	xinput set-prop $ID $i 1
}

lp "libinput Tapping Enabled"
lp "libinput Natural Scrolling Enabled"
lp "libinput Tapping Drag Enabled"

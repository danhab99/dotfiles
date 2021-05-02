#!/usr/bin/env bash

function getIDByName {
  ID=$(xinput | grep $1 | grep -Po "(?<=id=)\d+")
}

getIDByName "Hoksi Technology DURGOD Taurus K320 Keyboard"
xinput enable $ID

getIDByName "ELAN0650:01 04F3:304B Touchpad"

function setProps {
	i=$(xinput list-props $ID | grep "$1" | head -1 | grep -Po "(?<=\()\d+")
	xinput set-prop $ID $i 1
}

setProps "libinput Tapping Enabled"
setProps "libinput Natural Scrolling Enabled"
setProps "libinput Tapping Drag Enabled"



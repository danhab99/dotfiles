#!/usr/bin/env bash

ID=""

function getIDByName {
  ID=$(xinput | grep "$1" | grep -Po "(?<=id=)\d+")
}

getIDByName "Hoksi Technology DURGOD Taurus K320 Keyboard"
xinput enable $ID

getIDByName "ELAN0650:01 04F3:304B Touchpad"

function setProps {
	i=$(xinput list-props $ID | grep -i "$1" | head -1 | grep -Po "(?<=\()\d+")
	xinput set-prop $ID $i 1
}

setProps "tapping enabled"
setProps "natural scrolling enabled"
setProps "tapping drag enabled"



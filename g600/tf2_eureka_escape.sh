#!/bin/bash

xdotool key 3

function sleep_rand() {
  RAND=$(shuf -i $1-$2 -n 1)
  RAND=$(echo "$RAND / 1000.0" | bc -l)
  echo "Sleep $RAND"
  sleep $RAND
}

sleep_rand 1000 1200
xdotool key r

sleep_rand 500 600
xdotool key $1

sleep_rand 2900 3000
xdotool key e
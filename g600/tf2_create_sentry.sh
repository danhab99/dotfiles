#!/bin/bash

# function sleep_rand() {
#   RAND=$(shuf -i $1-$2 -n 1)
#   RAND=$(echo "$RAND / 1000.0" | bc -l)
#   echo "Sleep $RAND"
#   sleep $RAND
# }

BOTT=80
TOP=90

source /home/dan/.config/g600/tf2_keypress.sh

sleep_key $BOTT $TOP 5

sleep_key $BOTT $TOP 1

sleep_key $BOTT $TOP 4

sleep_key $BOTT $TOP 1

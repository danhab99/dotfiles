#!/bin/bash

TMP_FILE=/tmp/vgrep
touch $TMP_FILE

grep -Rn "$@" > "$TMP_FILE"
vim "$TMP_FILE"

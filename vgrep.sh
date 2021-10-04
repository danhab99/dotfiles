#!/bin/bash

TMP_FILE=/tmp/vgrep
touch $TMP_FILE

grep -Rn --exclude-dir=node_modules --exclude-dir=.git "$1" . > "$TMP_FILE"
vim "$TMP_FILE"

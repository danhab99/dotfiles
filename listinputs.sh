#!/usr/bin/env bash
# Usage: listinputs.sh [target-dir]
# Prints flake input lines for every subflake, with path: URLs relative to target-dir.
# Defaults to the current directory when no argument is given.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(realpath "${1:-.}")"
SUBFLAKES_DIR="$SCRIPT_DIR/subflakes"
URL_PREFIX="path:$(realpath --relative-to="$TARGET_DIR" "$SUBFLAKES_DIR")"

for dir in "$SUBFLAKES_DIR"/*/; do
  name=$(basename "$dir")
  echo "    $name.url = \"$URL_PREFIX/$name\";"
done

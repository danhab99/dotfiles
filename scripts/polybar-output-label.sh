#!/usr/bin/env bash
# Per-monitor Polybar label: physical slot + visible workspace numbers on this output.
set -euo pipefail

MONITOR="${MONITOR:-?}"

case "$MONITOR" in
  DVI-I-2-2 | DP-2-2) slot="LEFT" ;;
  DVI-I-1-1 | DP-2-1) slot="CNTR" ;;
  DVI-I-* | DP-2-3*) slot="RGHT" ;;
  eDP-1) slot="LAPT" ;;
  *) slot="$MONITOR" ;;
esac

ws=""
if command -v i3-msg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  ws=$(i3-msg -t get_workspaces 2>/dev/null \
    | jq -r --arg o "$MONITOR" '[.[] | select(.output == $o and .visible) | .num] | join(",")' \
    || true)
fi

if [ -n "$ws" ]; then
  printf '%s · ws %s' "$slot" "$ws"
else
  printf '%s' "$slot"
fi

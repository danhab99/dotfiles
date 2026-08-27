#!/usr/bin/env bash
# Launch one Polybar per *active* output (has a mode).
# Never kill existing bars until replacements are up — a hung xrandr after
# pkill is what made the status bar disappear mid-session.
set -uo pipefail

CONFIG="${POLYBAR_CONFIG:-$HOME/.config/polybar/config.ini}"
BAR_NAME="${POLYBAR_BAR:-main}"

if command -v feh >/dev/null 2>&1; then
  wp=""
  if [[ -f "${HOME}/.config/nitrogen/bg-saved.cfg" ]]; then
    wp=$(awk -F= '/^file=/ { print $2; exit }' "${HOME}/.config/nitrogen/bg-saved.cfg")
  fi
  if [[ -n "${wp}" && -f "${wp}" ]]; then
    timeout -k 1 4 feh --bg-scale --no-xinerama "${wp}" >/dev/null 2>&1 || true
  fi
fi

monitors=()
if command -v xrandr >/dev/null 2>&1; then
  mapfile -t monitors < <(
    timeout -k 1 3 xrandr --query 2>/dev/null | awk '/ connected/ && /[0-9]+x[0-9]+/ { print $1 }' || true
  )
fi

# If RandR is hung/wedged, still put a bar on the dock outputs.
if [[ ${#monitors[@]} -eq 0 ]]; then
  for d in /sys/class/drm/card1-DP-*/enabled; do
    [ -r "$d" ] || continue
    [ "$(cat "$d" 2>/dev/null)" = "enabled" ] || continue
  done
  monitors=(DP-2-1 DP-2-2 DP-2-3)
  echo "polybar-launch: xrandr unavailable; using fallback ${monitors[*]}" >&2
fi

new_pids=()
for m in "${monitors[@]}"; do
  MONITOR="$m" polybar --config="$CONFIG" "$BAR_NAME" &
  new_pids+=("$!")
  echo "polybar-launch: started on $m (pid $!)" >&2
done

sleep 0.4
# Drop only stale polybar processes, keep the ones we just started.
# Binary comm is `.polybar-wrappe` on Nix — match by argv.
if pgrep -f '/bin/polybar ' >/dev/null 2>&1; then
  for p in $(pgrep -f '/bin/polybar '); do
    keep=0
    for n in "${new_pids[@]}"; do
      [ "$p" = "$n" ] && keep=1 && break
    done
    [ "$keep" = 1 ] || kill "$p" 2>/dev/null || true
  done
fi

wait

#!/usr/bin/env bash
# Keep one Polybar per active RandR output. Monitors often appear after the
# session starts (DisplayLink dock, KVM, layout scripts) — a one-shot launch
# leaves bars on the wrong screen or missing entirely.
set -uo pipefail

CONFIG="${POLYBAR_CONFIG:-$HOME/.config/polybar/config.ini}"
BAR_NAME="${POLYBAR_BAR:-main}"
POLL_SEC="${POLYBAR_POLL_SEC:-2}"

declare -A bar_pids=()

refresh_wallpaper() {
  if ! command -v feh >/dev/null 2>&1; then
    return 0
  fi
  local wp=""
  if [[ -f "${HOME}/.config/nitrogen/bg-saved.cfg" ]]; then
    wp=$(awk -F= '/^file=/ { print $2; exit }' "${HOME}/.config/nitrogen/bg-saved.cfg")
  fi
  if [[ -n "${wp}" && -f "${wp}" ]]; then
    timeout -k 1 4 feh --bg-scale --no-xinerama "${wp}" >/dev/null 2>&1 || true
  fi
}

# Active outputs with a mode line (connected and lit).
# Use --current, never --query/--listactivemonitors: on tradezero's KVM/MST
# dock those re-probe EDIDs over i915 AUX (~0.8–2s) and stutter the display
# every POLL_SEC. --current is ~30ms and still returns live CRTC names.
active_monitors() {
  if ! command -v xrandr >/dev/null 2>&1; then
    return 1
  fi
  timeout -k 1 3 xrandr --current 2>/dev/null \
    | awk '/ connected/ && /[0-9]+x[0-9]+/ { print $1 }'
}

# When RandR is wedged, guess from DRM sysfs + known dock naming schemes.
drm_fallback_monitors() {
  local candidates=()
  local link name status enabled
  for link in /sys/class/drm/card*-*; do
    [ -e "$link" ] || continue
    name=$(basename "$link")
    case "$name" in
      card*-DP-*|card*-HDMI-*|card*-DVI-*|card*-eDP-*)
        status=$(cat "${link}/status" 2>/dev/null || echo "")
        enabled=$(cat "${link}/enabled" 2>/dev/null || echo "")
        [ "$status" = "connected" ] || continue
        [ "$enabled" = "enabled" ] || continue
        candidates+=("${name#card*-}")
        ;;
    esac
  done
  if [ "${#candidates[@]}" -gt 0 ]; then
    printf '%s\n' "${candidates[@]}"
    return 0
  fi
  # Last resort: historical dock layouts (MST + DisplayLink xrandr names).
  printf '%s\n' DVI-I-2-2 DVI-I-1-1 DP-2-2 DP-2-1 DP-2-3 eDP-1
}

want_monitors() {
  local -a found=()
  mapfile -t found < <(active_monitors || true)
  if [ "${#found[@]}" -gt 0 ]; then
    printf '%s\n' "${found[@]}"
    return 0
  fi
  drm_fallback_monitors
}

bar_alive() {
  local pid=$1
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

start_bar() {
  local monitor=$1
  MONITOR="$monitor" polybar --config="$CONFIG" "$BAR_NAME" &
  bar_pids["$monitor"]=$!
  echo "polybar-launch: started on ${monitor} (pid ${bar_pids[$monitor]})" >&2
}

stop_bar() {
  local monitor=$1
  local pid=${bar_pids[$monitor]:-}
  [ -z "$pid" ] && return 0
  kill "$pid" 2>/dev/null || true
  unset 'bar_pids[$monitor]'
}

reconcile_bars() {
  local -a want=()
  local monitor running

  mapfile -t want < <(want_monitors)

  for monitor in "${!bar_pids[@]}"; do
    if ! bar_alive "${bar_pids[$monitor]}"; then
      unset 'bar_pids[$monitor]'
    fi
  done

  for monitor in "${!bar_pids[@]}"; do
    local keep=0
    for running in "${want[@]}"; do
      [ "$monitor" = "$running" ] && keep=1 && break
    done
    [ "$keep" = 1 ] || stop_bar "$monitor"
  done

  for monitor in "${want[@]}"; do
    if [ -z "${bar_pids[$monitor]:-}" ] || ! bar_alive "${bar_pids[$monitor]}"; then
      start_bar "$monitor"
    fi
  done
}

# Take over from a previous generation / manual launch.
while read -r pid; do
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
done < <(pgrep -f '/bin/polybar ' 2>/dev/null || true)
sleep 0.2

refresh_wallpaper

while true; do
  reconcile_bars
  sleep "$POLL_SEC"
done

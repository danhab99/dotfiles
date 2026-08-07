#!/usr/bin/env bash
# Launch one Polybar per *active* output (has a mode).
# Skips connected-but-off panels (e.g. eDP-1 with no geometry).
# Pseudo-transparency needs a full-coverage root pixmap — see docs/kvm-display-seizure.md.
set -euo pipefail

CONFIG="${POLYBAR_CONFIG:-$HOME/.config/polybar/config.ini}"
BAR_NAME="${POLYBAR_BAR:-main}"

pkill -x polybar 2>/dev/null || true
# Brief wait so IPC sockets release
sleep 0.3

# Pseudo-transparency samples _XROOTPMAP_ID. Nitrogen's saved image is often
# 1px short of the virtual desktop (5759x1079 vs 5760x1080), which makes
# Polybar paint black instead of wallpaper. Re-span before bars start.
if command -v feh >/dev/null 2>&1; then
  wp=""
  if [[ -f "${HOME}/.config/nitrogen/bg-saved.cfg" ]]; then
    wp=$(awk -F= '/^file=/ { print $2; exit }' "${HOME}/.config/nitrogen/bg-saved.cfg")
  fi
  if [[ -n "${wp}" && -f "${wp}" ]]; then
    feh --bg-scale --no-xinerama "${wp}" >/dev/null 2>&1 || true
  fi
fi

mapfile -t monitors < <(
  xrandr --query | awk '/ connected/ && /[0-9]+x[0-9]+/ { print $1 }'
)

if [[ ${#monitors[@]} -eq 0 ]]; then
  echo "polybar-launch: no active monitors" >&2
  exit 1
fi

for m in "${monitors[@]}"; do
  MONITOR="$m" polybar --config="$CONFIG" "$BAR_NAME" &
  echo "polybar-launch: started on $m (pid $!)"
done

wait

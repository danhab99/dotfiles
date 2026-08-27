#!/usr/bin/env bash
# Before SDDM/X: if dock monitors are connected, force laptop panel off via DRM
# sysfs (no RandR — that retriggers MST EDID reads).
set -euo pipefail

EDP_STATUS="${EDP_STATUS:-/sys/class/drm/card1-eDP-1/status}"
DOCK_CONNECTED_NEED="${DOCK_CONNECTED_NEED:-2}"

dock_connected=0
for f in /sys/class/drm/card1-DP-*/status; do
  [ -e "$f" ] || continue
  [ "$(cat "$f" 2>/dev/null)" = "connected" ] && dock_connected=$((dock_connected + 1))
done

if [ "${dock_connected}" -ge "${DOCK_CONNECTED_NEED}" ] && [ -w "${EDP_STATUS}" ]; then
  printf 'off\n' > "${EDP_STATUS}"
  echo "force-edp-off-when-docked: dock_dp=${dock_connected} wrote off to ${EDP_STATUS}"
else
  echo "force-edp-off-when-docked: skip dock_dp=${dock_connected}"
fi

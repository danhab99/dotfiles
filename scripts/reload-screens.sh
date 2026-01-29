#!/usr/bin/env bash
set -euo pipefail

# Abort on Wayland (xrandr won't help there)
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
    echo "Wayland session detected. xrandr cannot force a rescan."
    echo "Log in with X11 or use your compositor's display tools."
    exit 1
fi

echo "X11 session detected."

# Get connected outputs
mapfile -t OUTPUTS < <(xrandr --query | awk '/ connected/ {print $1}')

if [[ ${#OUTPUTS[@]} -eq 0 ]]; then
    echo "No connected outputs found."
    exit 1
fi

echo "Connected outputs:"
printf '  - %s\n' "${OUTPUTS[@]}"

echo
echo "Step 1: Cycling outputs via xrandr..."
for out in "${OUTPUTS[@]}"; do
    echo "  Cycling $out"
    xrandr --output "$out" --off
done

sleep 1

for out in "${OUTPUTS[@]}"; do
    xrandr --output "$out" --auto
done

echo
echo "Step 2: Triggering DRM hotplug event..."
if command -v udevadm >/dev/null 2>&1; then
    sudo udevadm trigger --subsystem-match=drm
else
    echo "udevadm not available, skipping DRM trigger."
fi

echo
echo "Rescan complete."
echo "If resolution is still wrong, the issue is likely EDID or driver-related."

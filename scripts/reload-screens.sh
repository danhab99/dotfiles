#!/usr/bin/env bash
set -euo pipefail

# Detect if running from TTY and find X session user
if [[ -z "${DISPLAY:-}" ]]; then
    # Find the X session user and display
    X_USER=$(who | awk '/\(:0\)/ {print $1; exit}')
    if [[ -z "$X_USER" ]]; then
        echo "Error: Could not find user running X session"
        exit 1
    fi
    
    # Re-execute the entire script as the X user with proper environment
    echo "Running as X user: $X_USER"
    exec sudo -u "$X_USER" DISPLAY=:0 XAUTHORITY="/home/$X_USER/.Xauthority" bash "$0" "$@"
fi

# Abort on Wayland (xrandr won't help there)
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
    echo "Wayland session detected. xrandr cannot force a rescan."
    echo "Log in with X11 or use your compositor's display tools."
    exit 1
fi

echo "X11 session detected (DISPLAY=$DISPLAY)."

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

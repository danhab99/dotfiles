#!/usr/bin/env bash
# Compatibility wrapper — canonical launcher lives in subflakes/polybar/launch.sh
exec bash /etc/nixos/subflakes/polybar/launch.sh "$@"

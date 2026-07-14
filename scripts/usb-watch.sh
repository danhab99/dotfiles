#!/usr/bin/env bash
# Live tail of USB disconnect events. Ctrl-C to stop.
set -euo pipefail
echo "Watching kernel log for USB disconnects (Ctrl-C to stop)..."
echo "In another terminal run: usb-status"
exec journalctl -k -f --no-pager | rg --line-buffered 'USB disconnect|05e3:0610|0bda:5411'

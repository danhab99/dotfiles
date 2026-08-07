#!/usr/bin/env bash
# Polybar helper: print CAPS if Caps Lock is on.
set -euo pipefail
xset q 2>/dev/null | awk '/Caps Lock:/ { if ($4 == "on") print "CAPS" }'

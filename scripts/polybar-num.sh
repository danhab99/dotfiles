#!/usr/bin/env bash
# Polybar helper: print NUM if Num Lock is on.
set -euo pipefail
xset q 2>/dev/null | awk '/Num Lock:/ { if ($8 == "on") print "NUM" }'

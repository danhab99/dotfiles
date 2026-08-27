#!/usr/bin/env bash
# Fail loudly if the running X server is missing tradezero livelock fixes.
set -euo pipefail

xid_marker='GetXIDRange O(1) free-extent rb-tree (RFC 2013 port)'
vblank_marker='ms_queue_vblank: EBUSY and flush empty; aborting'
SYSTEM_X="$(readlink -f /run/current-system/sw/bin/X 2>/dev/null || true)"

xpid="$(pgrep -f '/bin/X(org)?( |$)' | head -1 || true)"
if [ -z "${xpid}" ]; then
  echo "ensure-patched-x: no X server (at greeter?)"
  exit 0
fi

xbin="$(tr '\0' ' ' < "/proc/${xpid}/cmdline" | awk '{print $1}')"
store="${xbin%/bin/Xorg}"
store="${store%/bin/X}"
drv="${store}/lib/xorg/modules/drivers/modesetting_drv.so"

if ! rg -Fq "${xid_marker}" <(strings "${xbin}" 2>/dev/null); then
  echo "ensure-patched-x: FATAL: UNPATCHED Xorg pid=${xpid} missing GetXIDRange — just switch && sudo reboot (system X: ${SYSTEM_X})" >&2
  exit 1
fi

if [ ! -r "${drv}" ] || ! rg -Fq "${vblank_marker}" <(strings "${drv}" 2>/dev/null); then
  echo "ensure-patched-x: FATAL: UNPATCHED modesetting pid=${xpid} missing vblank abort — just switch && sudo reboot (system X: ${SYSTEM_X})" >&2
  exit 1
fi

echo "ensure-patched-x: OK pid=${xpid} GetXIDRange+vblank-abort (${xbin})"

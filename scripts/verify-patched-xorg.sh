#!/usr/bin/env bash
# Verify the Nix-built xorg-server contains both tradezero livelock fixes.
set -euo pipefail

xid_marker='GetXIDRange O(1) free-extent rb-tree (RFC 2013 port)'
vblank_marker='ms_queue_vblank: EBUSY and flush empty; aborting'

xorg="$(readlink -f /run/current-system/sw/bin/X 2>/dev/null || true)"
if [ -z "${xorg}" ]; then
  echo "verify-patched-xorg: no /run/current-system/sw/bin/X" >&2
  exit 1
fi

store="${xorg%/bin/Xorg}"
store="${store%/bin/X}"
drv="${store}/lib/xorg/modules/drivers/modesetting_drv.so"

if ! rg -Fq "${xid_marker}" <(strings "${xorg}"); then
  echo "verify-patched-xorg: FATAL missing XID marker in ${xorg}" >&2
  exit 1
fi

if [ ! -r "${drv}" ] || ! rg -Fq "${vblank_marker}" <(strings "${drv}"); then
  echo "verify-patched-xorg: FATAL missing vblank marker in ${drv}" >&2
  exit 1
fi

echo "verify-patched-xorg: OK ${xorg} + ${drv}"

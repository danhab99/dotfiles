#!/usr/bin/env bash
# Post-reboot: prove tradezero Xorg livelock fixes are installed AND live.
# Exit 0 only if system + running session both carry GetXIDRange + vblank-abort.
set -euo pipefail

xid_marker='GetXIDRange O(1) free-extent rb-tree (RFC 2013 port)'
vblank_marker='ms_queue_vblank: EBUSY and flush empty; aborting'
fail=0

say() { printf '%s\n' "$*"; }
ok() { say "PASS: $*"; }
bad() { say "FAIL: $*"; fail=1; }

say "=== confirm Xorg livelock fixes $(date -Iseconds) ==="
say "host=$(hostname) session=${XDG_SESSION_TYPE:-?} display=${DISPLAY:-?}"

SYSTEM_X="$(readlink -f /run/current-system/sw/bin/X 2>/dev/null || true)"
if [ -z "${SYSTEM_X}" ]; then
  bad "no /run/current-system/sw/bin/X"
else
  ok "system X = ${SYSTEM_X}"
fi

SYSTEM_STORE="${SYSTEM_X%/bin/Xorg}"
SYSTEM_STORE="${SYSTEM_STORE%/bin/X}"
SYSTEM_DRV="${SYSTEM_STORE}/lib/xorg/modules/drivers/modesetting_drv.so"

if [ -n "${SYSTEM_X}" ] && rg -Fq "${xid_marker}" <(strings "${SYSTEM_X}"); then
  ok "system X has GetXIDRange rb-tree marker"
else
  bad "system X missing GetXIDRange marker — just switch did not land patches"
fi

if [ -r "${SYSTEM_DRV}" ] && rg -Fq "${vblank_marker}" <(strings "${SYSTEM_DRV}"); then
  ok "system modesetting has vblank-abort marker"
else
  bad "system modesetting missing vblank-abort marker"
fi

xpid="$(pgrep -f '/bin/X(org)?( |$)' | head -1 || true)"
if [ -z "${xpid}" ]; then
  bad "no running X server (not logged into graphical session?)"
else
  ok "running X pid=${xpid}"
  RUN_X="$(tr '\0' ' ' < "/proc/${xpid}/cmdline" | awk '{print $1}')"
  RUN_X_REAL="$(readlink -f "${RUN_X}" 2>/dev/null || true)"
  say "running cmdline X = ${RUN_X}"
  say "running resolved  = ${RUN_X_REAL:-unresolved}"

  if [ -n "${RUN_X_REAL}" ] && [ "${RUN_X_REAL}" = "${SYSTEM_X}" ]; then
    ok "running X == current-system X (session is live on patched build)"
  else
    bad "running X is NOT current-system — reboot/display-manager restart still needed (or wrong binary)"
  fi

  RUN_STORE="${RUN_X_REAL%/bin/Xorg}"
  RUN_STORE="${RUN_STORE%/bin/X}"
  RUN_DRV="${RUN_STORE}/lib/xorg/modules/drivers/modesetting_drv.so"

  if [ -n "${RUN_X_REAL}" ] && rg -Fq "${xid_marker}" <(strings "${RUN_X_REAL}" 2>/dev/null); then
    ok "running X has GetXIDRange marker"
  else
    bad "running X missing GetXIDRange marker"
  fi

  if [ -r "${RUN_DRV}" ] && rg -Fq "${vblank_marker}" <(strings "${RUN_DRV}" 2>/dev/null); then
    ok "running modesetting has vblank-abort marker"
  else
    bad "running modesetting missing vblank-abort (session still old .so)"
  fi

  u1=$(awk '{print $14+$15}' "/proc/${xpid}/stat")
  sleep 2
  u2=$(awk '{print $14+$15}' "/proc/${xpid}/stat")
  clk=$(getconf CLK_TCK 2>/dev/null || echo 100)
  pct=$(( (u2 - u1) * 100 / (clk * 2) ))
  say "X CPU (2s instant): ${pct}%"
  if [ "${pct}" -ge 90 ]; then
    bad "X already pegged >=90% — livelock may still be active; check gdb"
  else
    ok "X not pegged right now (${pct}%)"
  fi
fi

say "--- user units ---"
systemctl --user is-active ensure-patched-x.service 2>/dev/null || true
systemctl --user is-active display-seizure-watchdog.service kvm-seizure-capture.service 2>/dev/null || true

if [ "${fail}" -ne 0 ]; then
  say "=== RESULT: NOT LIVE — do not trust session yet ==="
  exit 1
fi

say "=== RESULT: INSTALLED AND LIVE ==="
exit 0

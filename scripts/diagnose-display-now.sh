#!/usr/bin/env bash
# One-shot display/KVM diagnostic — run after a wedge or from an agent session.
set -uo pipefail

echo "=== display diagnostic $(date -Iseconds) ==="

if [ -x /etc/nixos/scripts/confirm-xorg-livelock-fixes-live.sh ]; then
  /etc/nixos/scripts/confirm-xorg-livelock-fixes-live.sh || true
  echo
fi

XPID=$(pgrep -f '/bin/X(org)?( |$)' | head -1 || true)
echo "Xorg: $(readlink -f /run/current-system/sw/bin/X 2>/dev/null || echo unknown)"
echo "X pid=${XPID:-none}"
if [ -n "${XPID}" ]; then
  tr '\0' ' ' < "/proc/${XPID}/cmdline" | awk '{print $1}'
  u1=$(awk '{print $14+$15}' "/proc/${XPID}/stat")
  sleep 2
  u2=$(awk '{print $14+$15}' "/proc/${XPID}/stat")
  clk=$(getconf CLK_TCK 2>/dev/null || echo 100)
  echo "X CPU (2s instant): $(( (u2 - u1) * 100 / (clk * 2) ))%"
  ps -p "${XPID}" -o etime,pcpu,stat 2>/dev/null
  if command -v nix >/dev/null 2>&1; then
    echo "--- X hot stack (gdb) ---"
    sudo nix shell nixpkgs#gdb -c gdb -batch -ex "thread 1" -ex "bt 6" -p "${XPID}" 2>/dev/null \
      | rg '^#' || echo "(no stack — install/run with sudo gdb)"
  fi
fi

A=$(awk '/ i915$/ { s=0; for (i=2;i<NF;i++) s+=$i; print s; exit }' /proc/interrupts 2>/dev/null || echo 0)
sleep 2
B=$(awk '/ i915$/ { s=0; for (i=2;i<NF;i++) s+=$i; print s; exit }' /proc/interrupts 2>/dev/null || echo 0)
echo "i915 IRQ/s: $(( (B - A) / 2 ))"

echo "eDP: $(cat /sys/class/drm/card1-eDP-1/status 2>/dev/null)/$(cat /sys/class/drm/card1-eDP-1/enabled 2>/dev/null)"
for f in /sys/class/drm/card1-DP-*/status; do
  [ "$(cat "$f" 2>/dev/null)" = connected ] && echo "$(basename "$(dirname "$f")"): connected"
done

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
systemctl is-active display-seizure-system-watchdog.service force-edp-off-when-docked.service 2>/dev/null || true
systemctl --user is-active display-seizure-watchdog.service kvm-seizure-capture.service polybar.service 2>/dev/null || true

echo "--- capture tail ---"
tail -8 "${HOME}/.local/share/kvm-seizure-capture/samples.jsonl" 2>/dev/null || echo "(no capture log)"

echo "--- events tail ---"
tail -5 "${HOME}/.local/share/kvm-seizure-capture/events.log" 2>/dev/null || echo "(no events)"

echo "--- Xorg modesetting/vblank lines ---"
rg 'ms_queue_vblank|flip queue|EDID for output|GetXIDRange|flush empty|iteration cap' /var/log/Xorg.0.log 2>/dev/null | tail -8 || echo "(none)"

echo "--- dmesg i915/drm (last 15) ---"
dmesg -T 2>/dev/null | rg -i 'i915|drm|dp-|mst|edid' | tail -15 || true

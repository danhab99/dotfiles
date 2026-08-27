#!/usr/bin/env bash
# Sample tradezero display-seizure signals without talking to X/RandR.
# Never call xrandr (that retriggers i915 MST EDID reads).
set -uo pipefail

OUT_DIR="${KVM_SEIZURE_CAPTURE_DIR:-$HOME/.local/share/kvm-seizure-capture}"
mkdir -p "${OUT_DIR}"
SAMPLES="${OUT_DIR}/samples.jsonl"
EVENTS="${OUT_DIR}/events.log"
INTERVAL="${KVM_SEIZURE_CAPTURE_INTERVAL:-10}"

find_x_pid() {
  pgrep -f '/bin/X(org)?( |$)' 2>/dev/null | head -1 || true
}

x_jiffies() {
  local pid="$1"
  [ -r "/proc/${pid}/stat" ] || { echo 0; return; }
  awk '{print $14+$15}' "/proc/${pid}/stat"
}

i915_irqs() {
  awk '/ i915$/ { s=0; for (i=2;i<NF;i++) s+=$i; print s; exit }' /proc/interrupts
}

drm_line() {
  local c name status enabled
  for c in /sys/class/drm/card*-*/status; do
    [ -e "$c" ] || continue
    name="$(basename "$(dirname "$c")")"
    status="$(cat "$c" 2>/dev/null || echo '?')"
    enabled="$(cat "$(dirname "$c")/enabled" 2>/dev/null || echo '?')"
    printf '%s=%s/%s ' "$name" "$status" "$enabled"
  done
}

xorg_counts() {
  python3 - <<'PY' 2>/dev/null || echo 'edid=0 tmds=0 modeline=0 lines=0'
from pathlib import Path
p = Path("/var/log/Xorg.0.log")
if not p.exists():
    print("edid=0 tmds=0 modeline=0 lines=0")
    raise SystemExit
t = p.read_text(errors="replace")
print(
    "edid=%d tmds=%d modeline=%d lines=%d"
    % (t.count("EDID for output"), t.count("HDMI max TMDS"), t.count("Modeline"), t.count("\n"))
)
PY
}

echo "kvm-seizure-capture: writing ${SAMPLES} every ${INTERVAL}s" >&2
last_x=0
last_irq=0
peg_noted=0

while true; do
  now="$(date -Iseconds)"
  xpid="$(find_x_pid)"
  xj=0
  xjps=0
  irq=0
  irqps=0
  if [ -n "${xpid}" ]; then
    xj="$(x_jiffies "${xpid}")"
    if [ "${last_x}" -gt 0 ]; then
      xjps=$(( (xj - last_x) / INTERVAL ))
      [ "${xjps}" -lt 0 ] && xjps=0
    fi
    last_x="${xj}"
  else
    last_x=0
  fi
  irq="$(i915_irqs)"
  irq="${irq:-0}"
  if [ "${last_irq}" -gt 0 ]; then
    irqps=$(( (irq - last_irq) / INTERVAL ))
    [ "${irqps}" -lt 0 ] && irqps=0
  fi
  last_irq="${irq}"

  counts="$(xorg_counts)"
  drm="$(drm_line)"
  line="${now} xpid=${xpid:-none} x_jiffies_s=${xjps} i915_irq_s=${irqps} ${counts} drm=${drm}"
  echo "${line}" >> "${SAMPLES}"

  if [ "${xjps}" -ge 80 ]; then
    if [ "${peg_noted}" -eq 0 ]; then
      {
        echo "=== PEG ${now} ==="
        echo "${line}"
        ps -p "${xpid}" -o pid,etime,pcpu,cputime,stat,nlwp,cmd 2>/dev/null || true
        rg 'i915' /proc/interrupts
      } >> "${EVENTS}"
      peg_noted=1
    fi
  else
    peg_noted=0
  fi

  sleep "${INTERVAL}"
done

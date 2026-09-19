#!/usr/bin/env bash
# Root-level display seizure watchdog (tradezero).
# Does NOT talk to X — only /proc + sysfs. When X is pegged (especially with
# eDP left on beside dock outputs), soft user-session recovery cannot run
# xrandr. Restart display-manager so the machine becomes usable again.
#
# See docs/kvm-display-seizure.md.
set -uo pipefail

PEG_PCT="${PEG_PCT:-90}"
PEG_STREAK="${PEG_STREAK:-3}"          # consecutive samples (~2s each) before action
COOLDOWN_SEC="${COOLDOWN_SEC:-90}"     # min seconds between DM restarts
EDP_SYSFS="${EDP_SYSFS:-/sys/class/drm/card1-eDP-1/enabled}"
STATE_DIR=/run/display-seizure-system-watchdog
mkdir -p "${STATE_DIR}"

find_x_pid() {
  pgrep -f '/bin/X(org)?( |$)' 2>/dev/null | head -1 || true
}

x_cpu_pct() {
  local xpid="$1" sample="${2:-2}" u1 u2 clk
  [ -r "/proc/${xpid}/stat" ] || { echo 0; return; }
  u1="$(awk '{print $14+$15}' "/proc/${xpid}/stat")"
  sleep "${sample}"
  [ -r "/proc/${xpid}/stat" ] || { echo 0; return; }
  u2="$(awk '{print $14+$15}' "/proc/${xpid}/stat")"
  clk="$(getconf CLK_TCK 2>/dev/null || echo 100)"
  echo "$(( (u2 - u1) * 100 / (clk * sample) ))"
}

dock_dp_count() {
  local n=0 d
  for d in /sys/class/drm/card1-DP-*/enabled; do
    [ -r "$d" ] || continue
    [ "$(cat "$d" 2>/dev/null)" = "enabled" ] && n=$((n + 1))
  done
  echo "${n}"
}

edp_on() {
  [ -r "${EDP_SYSFS}" ] && [ "$(cat "${EDP_SYSFS}" 2>/dev/null)" = "enabled" ]
}

last_restart=0
streak=0

while true; do
  xpid="$(find_x_pid)"
  if [ -z "${xpid}" ]; then
    streak=0
    sleep 2
    continue
  fi

  pct="$(x_cpu_pct "${xpid}" 2)"
  dock="$(dock_dp_count)"
  edp=0
  edp_on && edp=1

  # Pegged X is always bad. Pegged + eDP beside dock is the known hard wedge
  # (xrandr hangs; user-session soft recover cannot clear it).
  if [ "${pct}" -ge "${PEG_PCT}" ]; then
    streak=$((streak + 1))
    printf 'display-seizure-system-watchdog: X pid=%s cpu~%s%% streak=%s eDP=%s dock_dp=%s\n' \
      "${xpid}" "${pct}" "${streak}" "${edp}" "${dock}" >&2
  else
    streak=0
  fi

  should_restart=0
  if [ "${streak}" -ge "${PEG_STREAK}" ]; then
    if [ "${edp}" -eq 1 ] && [ "${dock}" -ge 2 ]; then
      should_restart=1
      reason="X pegged with eDP on while docked"
    elif [ "${streak}" -ge $((PEG_STREAK + 3)) ]; then
      # Longer streak without the eDP signature — still unusable
      should_restart=1
      reason="X pegged sustained"
    fi
  fi

  if [ "${should_restart}" -eq 1 ]; then
    now="$(date +%s)"
    if [ $((now - last_restart)) -ge "${COOLDOWN_SEC}" ]; then
      printf 'display-seizure-system-watchdog: RESTART display-manager (%s)\n' "${reason}" >&2
      systemctl restart display-manager.service || true
      last_restart="${now}"
      streak=0
      sleep 15
    else
      printf 'display-seizure-system-watchdog: cooldown (%ss left)\n' \
        "$((COOLDOWN_SEC - (now - last_restart)))" >&2
      streak=0
    fi
  fi

  sleep 1
done

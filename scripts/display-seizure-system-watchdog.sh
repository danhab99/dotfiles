#!/usr/bin/env bash
# Root-level display seizure watchdog (tradezero).
# NEVER restart display-manager / terminate sessions.
# When X is pegged with eDP on beside dock outputs, force laptop panel off via
# DRM sysfs only (RandR hangs). Do not touch eDP when X is healthy.
set -uo pipefail

PEG_PCT="${PEG_PCT:-90}"
PEG_STREAK="${PEG_STREAK:-3}"
COOLDOWN_SEC="${COOLDOWN_SEC:-45}"
EDP_STATUS="${EDP_STATUS:-/sys/class/drm/card1-eDP-1/status}"
EDP_ENABLED="${EDP_ENABLED:-/sys/class/drm/card1-eDP-1/enabled}"

find_x_pid() {
  pgrep -f '/bin/X(org)?( |$)' 2>/dev/null | head -1 || true
}

proc_cpu_jiffies() {
  local stat rest
  stat="$(cat "$1" 2>/dev/null)" || { echo 0; return; }
  rest="${stat##*)}"
  # shellcheck disable=SC2086
  set -- ${rest}
  echo $(( ${12:-0} + ${13:-0} ))
}

x_cpu_pct() {
  local xpid="$1" sample="${2:-2}" u1 u2 clk
  [ -r "/proc/${xpid}/stat" ] || { echo 0; return; }
  u1="$(proc_cpu_jiffies "/proc/${xpid}/stat")"
  sleep "${sample}"
  [ -r "/proc/${xpid}/stat" ] || { echo 0; return; }
  u2="$(proc_cpu_jiffies "/proc/${xpid}/stat")"
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
  [ -r "${EDP_ENABLED}" ] && [ "$(cat "${EDP_ENABLED}" 2>/dev/null)" = "enabled" ]
}

force_edp_off_sysfs() {
  [ -w "${EDP_STATUS}" ] || return 0
  printf 'off\n' > "${EDP_STATUS}" 2>/dev/null || true
}

last_action=0
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

  if [ "${pct}" -ge "${PEG_PCT}" ]; then
    streak=$((streak + 1))
    printf 'display-seizure-system-watchdog: X pid=%s cpu~%s%% streak=%s eDP=%s dock_dp=%s\n' \
      "${xpid}" "${pct}" "${streak}" "${edp}" "${dock}" >&2
  else
    streak=0
    sleep 1
    continue
  fi

  if [ "${streak}" -ge "${PEG_STREAK}" ] && [ "${dock}" -ge 2 ]; then
    now="$(date +%s)"
    if [ $((now - last_action)) -ge "${COOLDOWN_SEC}" ]; then
      printf 'display-seizure-system-watchdog: pegged at dock — sysfs eDP off (no logout)\n' >&2
      force_edp_off_sysfs
      last_action="${now}"
      streak=0
    fi
  fi

  sleep 1
done

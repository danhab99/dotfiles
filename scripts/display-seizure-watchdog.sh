#!/usr/bin/env bash
# Keep tradezero usable after KVM/USB hub blips.
# - Always: no compositors, kill real xfsettingsd, eDP off when docked
# - On X peg: STOP heavy clients → xrandr → CONT → reattach
# - If still pegged after several soft recovers: restart display-manager
# See docs/kvm-display-seizure.md.
set -uo pipefail

USER_NAME="${USER:-dan}"
EDP_SYSFS="${EDP_SYSFS:-/sys/class/drm/card1-eDP-1/enabled}"
ESCALATE_AFTER="${ESCALATE_AFTER:-3}"
ESCALATE_WINDOW="${ESCALATE_WINDOW:-120}"

resolve_display_env() {
  if [ -n "${DISPLAY:-}" ] && [ -n "${XAUTHORITY:-}" ] && [ -r "${XAUTHORITY}" ]; then
    return 0
  fi
  local pid
  pid="$(pgrep -u "${USER_NAME}" -x i3 2>/dev/null | head -1 || true)"
  if [ -z "${pid}" ]; then
    pid="$(pgrep -u "${USER_NAME}" -x xfce4-session 2>/dev/null | head -1 || true)"
  fi
  [ -n "${pid}" ] || return 1
  local envfile="/proc/${pid}/environ"
  [ -r "${envfile}" ] || return 1
  local line
  while IFS= read -r -d '' line; do
    case "${line}" in
      DISPLAY=*) DISPLAY="${line#DISPLAY=}" ;;
      XAUTHORITY=*) XAUTHORITY="${line#XAUTHORITY=}" ;;
    esac
  done < "${envfile}"
  export DISPLAY XAUTHORITY
  [ -n "${DISPLAY:-}" ] && [ -n "${XAUTHORITY:-}" ] && [ -r "${XAUTHORITY}" ]
}

kill_compositors() {
  pkill -u "${USER_NAME}" -x picom 2>/dev/null || true
  pkill -u "${USER_NAME}" -x xcompmgr 2>/dev/null || true
  pkill -u "${USER_NAME}" -x compton 2>/dev/null || true
}

kill_transparent_i3bar() {
  pkill -u "${USER_NAME}" -x i3bar 2>/dev/null || true
}

kill_xfsettingsd() {
  pkill -u "${USER_NAME}" -f '\.xfsettingsd-wrapped' 2>/dev/null || true
  local p cmd
  for p in $(pgrep -u "${USER_NAME}" -x xfsettingsd 2>/dev/null || true); do
    cmd="$(ps -p "${p}" -o args= 2>/dev/null || true)"
    case "${cmd}" in
      *sleep*infinity*) ;;
      *) kill "${p}" 2>/dev/null || true ;;
    esac
  done
}

edp_enabled() {
  [ -r "${EDP_SYSFS}" ] || return 1
  [ "$(cat "${EDP_SYSFS}" 2>/dev/null)" = "enabled" ]
}

dock_outputs_up() {
  local n=0 d
  for d in /sys/class/drm/card1-DP-*/enabled; do
    [ -r "$d" ] || continue
    [ "$(cat "$d" 2>/dev/null)" = "enabled" ] && n=$((n + 1))
  done
  [ "${n}" -ge 2 ]
}

cont_all_stopped() {
  local p
  for p in $(ps -o state=,pid= -u "${USER_NAME}" 2>/dev/null | awk '$1=="T"{print $2}'); do
    kill -CONT "${p}" 2>/dev/null || true
  done
}

stop_heavy_x_clients() {
  local p
  for p in $(pgrep -u "${USER_NAME}" -x VirtualBoxVM 2>/dev/null || true); do
    kill -STOP "${p}" 2>/dev/null || true
  done
  for p in $(pgrep -u "${USER_NAME}" -x slack 2>/dev/null || true); do
    kill -STOP "${p}" 2>/dev/null || true
  done
  for p in $(pgrep -u "${USER_NAME}" -x firefox 2>/dev/null || true); do
    kill -STOP "${p}" 2>/dev/null || true
  done
  for p in $(pgrep -u "${USER_NAME}" -x cursor 2>/dev/null || true); do
    kill -STOP "${p}" 2>/dev/null || true
  done
}

force_edp_off() {
  command -v xrandr >/dev/null 2>&1 || return 1
  timeout -k 1 3 xrandr --output eDP-1 --off >/dev/null 2>&1
}

assert_dock_layout() {
  command -v xrandr >/dev/null 2>&1 || return 0
  force_edp_off || true
  if [ -x "${HOME}/.screenlayout/auto.sh" ]; then
    timeout -k 1 8 "${HOME}/.screenlayout/auto.sh" >/dev/null 2>&1 || true
  else
    timeout -k 1 8 xrandr \
      --output eDP-1 --off \
      --output DP-2-2 --mode 1920x1080 --pos 0x0 --rotate normal \
      --output DP-2-1 --mode 1920x1080 --pos 1920x0 --rotate normal \
      --output DP-2-3 --mode 1920x1080 --pos 3840x0 --rotate normal --primary \
      >/dev/null 2>&1 || true
  fi
}

keep_edp_off_if_docked() {
  dock_outputs_up || return 0
  edp_enabled || return 0
  resolve_display_env || return 0
  printf 'display-seizure-watchdog: eDP on while docked — forcing off\n' >&2
  kill_xfsettingsd
  force_edp_off || true
  if edp_enabled; then
    assert_dock_layout
  fi
}

escalate_restart_dm() {
  printf 'display-seizure-watchdog: ESCALATE — restarting display-manager\n' >&2
  local systemctl_bin
  systemctl_bin="$(command -v systemctl || echo /run/current-system/sw/bin/systemctl)"
  if command -v sudo >/dev/null 2>&1; then
    sudo -n "${systemctl_bin}" start display-seizure-escalate.service >/dev/null 2>&1 && return 0
    sudo -n /run/current-system/sw/bin/systemctl start display-seizure-escalate.service >/dev/null 2>&1 && return 0
  fi
  # Own-session fallback (no root): drop GUI so SDDM comes back.
  local sid
  sid="$(loginctl 2>/dev/null | awk -v u="${USER_NAME}" '$3==u && $5=="user" && $4 ~ /^seat/ {print $1; exit}')"
  if [ -n "${sid}" ]; then
    printf 'display-seizure-watchdog: escalate via loginctl terminate-session %s\n' "${sid}" >&2
    loginctl terminate-session "${sid}" >/dev/null 2>&1 && return 0
  fi
  printf 'display-seizure-watchdog: escalate failed\n' >&2
  return 1
}

soft_recover() {
  printf 'display-seizure-soft-recover: running (reason=%s)\n' "${1:-unspecified}" >&2
  kill_compositors
  kill_transparent_i3bar
  kill_xfsettingsd
  stop_heavy_x_clients
  sleep 0.5
  if resolve_display_env; then
    force_edp_off || true
    assert_dock_layout
  fi
  cont_all_stopped
  if [ -x /etc/nixos/scripts/reattach-x-inputs.sh ]; then
    /etc/nixos/scripts/reattach-x-inputs.sh 2>/dev/null || true
  fi
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

find_x_pid() {
  pgrep -f '/bin/X(org)?( |$)' 2>/dev/null | head -1 || true
}

main_loop() {
  local peg_pct="${PEG_PCT:-85}" peg_streak_need="${PEG_STREAK:-2}" idle_sleep="${IDLE_SLEEP:-1}"
  local streak=0 xpid pct last_recover=0 now
  local recover_times=()

  while true; do
    kill_compositors
    kill_xfsettingsd
    keep_edp_off_if_docked

    xpid="$(find_x_pid)"
    if [ -z "${xpid}" ]; then
      streak=0
      sleep "${idle_sleep}"
      continue
    fi

    pct="$(x_cpu_pct "${xpid}" 2)"
    if [ "${pct}" -ge "${peg_pct}" ]; then
      streak=$((streak + 1))
      printf 'display-seizure-watchdog: X pid=%s cpu~%s%% streak=%s\n' "${xpid}" "${pct}" "${streak}" >&2
    else
      streak=0
    fi

    if [ "${streak}" -ge "${peg_streak_need}" ]; then
      now="$(date +%s)"
      if [ $((now - last_recover)) -ge 15 ]; then
        soft_recover "X pegged ~${pct}%"
        last_recover="${now}"
        recover_times+=("${now}")
        local filtered=() t
        for t in "${recover_times[@]}"; do
          [ $((now - t)) -le "${ESCALATE_WINDOW}" ] && filtered+=("${t}")
        done
        recover_times=("${filtered[@]}")

        sleep 2
        pct="$(x_cpu_pct "${xpid}" 2)"
        if [ "${pct}" -ge "${peg_pct}" ]; then
          printf 'display-seizure-watchdog: still pegged (~%s%%) fails=%s\n' "${pct}" "${#recover_times[@]}" >&2
          if [ "${#recover_times[@]}" -ge "${ESCALATE_AFTER}" ]; then
            escalate_restart_dm || true
            recover_times=()
            sleep 10
          fi
        else
          printf 'display-seizure-watchdog: soft recover cleared peg (now ~%s%%)\n' "${pct}" >&2
        fi
      fi
      streak=0
    fi
    sleep "${idle_sleep}"
  done
}

case "${1:-watch}" in
  once|recover) soft_recover "manual" ;;
  watch|*) main_loop ;;
esac

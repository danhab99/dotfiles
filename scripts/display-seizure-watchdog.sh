#!/usr/bin/env bash
# Keep tradezero usable after KVM/USB hub blips — CALL-SAFE.
# - Always: no compositors, kill real xfsettingsd, eDP off when docked
# - On X peg: layout reset + input reattach + ensure polybar (NO SIGSTOP Slack,
#   NO display-manager restart, NO session terminate)
# See docs/kvm-display-seizure.md.
set -uo pipefail

USER_NAME="${USER:-dan}"
EDP_SYSFS="${EDP_SYSFS:-/sys/class/drm/card1-eDP-1/enabled}"

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

dock_output_count() {
  local n=0 d
  for d in /sys/class/drm/card1-DP-*/enabled; do
    [ -r "$d" ] || continue
    [ "$(cat "$d" 2>/dev/null)" = "enabled" ] && n=$((n + 1))
  done
  echo "${n}"
}

dock_outputs_up() {
  [ "$(dock_output_count)" -ge 2 ]
}

undocked() {
  [ "$(dock_output_count)" -lt 2 ]
}

# Never SIGSTOP Slack / Electron call clients. Optional: pause VirtualBox only
# (VPN VM) — disabled by default; set STOP_VBOX_ON_PEG=1 to enable.
stop_optional_heavy() {
  [ "${STOP_VBOX_ON_PEG:-0}" = "1" ] || return 0
  local p
  for p in $(pgrep -u "${USER_NAME}" -x VirtualBoxVM 2>/dev/null || true); do
    kill -STOP "${p}" 2>/dev/null || true
  done
}

cont_vbox_if_stopped() {
  local p
  for p in $(pgrep -u "${USER_NAME}" -x VirtualBoxVM 2>/dev/null || true); do
    kill -CONT "${p}" 2>/dev/null || true
  done
}

force_edp_off_sysfs() {
  local status="${EDP_STATUS:-/sys/class/drm/card1-eDP-1/status}"
  [ -w "${status}" ] || return 1
  printf 'off\n' > "${status}" 2>/dev/null
}

force_edp_off() {
  force_edp_off_sysfs && return 0
  command -v xrandr >/dev/null 2>&1 || return 1
  timeout -k 1 3 xrandr --output eDP-1 --off >/dev/null 2>&1
}

enable_laptop_panel() {
  command -v xrandr >/dev/null 2>&1 || return 1
  if timeout -k 1 5 xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 >/dev/null 2>&1; then
    return 0
  fi
  timeout -k 1 5 xrandr --output eDP-1 --primary --auto >/dev/null 2>&1
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

assert_mobile_layout() {
  command -v xrandr >/dev/null 2>&1 || return 0
  if [ -x "${HOME}/.screenlayout/mobile.sh" ]; then
    timeout -k 1 8 "${HOME}/.screenlayout/mobile.sh" >/dev/null 2>&1 || true
  else
    enable_laptop_panel || true
  fi
}

polybar_running() {
  pgrep -u "${USER_NAME}" -f '/bin/polybar ' >/dev/null 2>&1
}

# DRM sysfs only — never xrandr --query. On this KVM/MST dock, RandR query
# re-reads EDIDs over i915 AUX (~0.8–2s) and freezes the display every loop.
active_monitor_count() {
  local n=0 d
  for d in /sys/class/drm/card*-*/enabled; do
    [ -r "$d" ] || continue
    case "$(basename "$(dirname "$d")")" in
      card*-eDP-*|card*-Writeback-*) continue ;;
    esac
    [ "$(cat "$d" 2>/dev/null)" = "enabled" ] && n=$((n + 1))
  done
  # Undocked laptop: eDP alone still needs a bar.
  if [ "${n}" -eq 0 ] && edp_enabled; then
    n=1
  fi
  echo "${n}"
}

polybar_bar_count() {
  pgrep -u "${USER_NAME}" -cf '/bin/polybar ' 2>/dev/null || echo 0
}

polybar_needs_reconcile() {
  local want have
  want="$(active_monitor_count)"
  have="$(polybar_bar_count)"
  [ "${want}" -gt 0 ] && [ "${want}" -ne "${have}" ]
}

ensure_polybar() {
  if polybar_needs_reconcile; then
    printf 'display-seizure-watchdog: polybar count %s != monitors %s — restarting\n' \
      "$(polybar_bar_count)" "$(active_monitor_count)" >&2
    systemctl --user restart polybar.service 2>/dev/null || true
    return 0
  fi
  polybar_running && return 0
  # Service "active" during feh/xrandr startup — do not SIGKILL (that is what
  # made the bar vanish in a restart loop). Nix wraps the binary as .polybar-wrappe
  # so `pgrep -x polybar` is always false here.
  if systemctl --user is-active --quiet polybar.service 2>/dev/null; then
    return 0
  fi
  systemctl --user start polybar.service 2>/dev/null || true
}

# Skip ALL RandR while X is pegged — xrandr hangs and is what kills polybar
# (launch used to pkill bars then block on xrandr).
x_is_pegged() {
  local xpid pct
  xpid="$(find_x_pid)"
  [ -n "${xpid}" ] || return 1
  pct="$(x_cpu_pct "${xpid}" 1)"
  [ "${pct}" -ge "${PEG_PCT_SKIP_RANDR:-80}" ]
}

keep_edp_off_if_docked() {
  dock_outputs_up || return 0
  edp_enabled || return 0
  x_is_pegged && return 0
  resolve_display_env || return 0
  printf 'display-seizure-watchdog: eDP on while docked — xrandr off only (X not pegged)\n' >&2
  kill_xfsettingsd
  force_edp_off || true
}

keep_edp_on_if_undocked() {
  undocked || return 0
  edp_enabled && return 0
  resolve_display_env || return 0
  printf 'display-seizure-watchdog: undocked and eDP off — enabling laptop panel\n' >&2
  assert_mobile_layout
}

# If docked monitors drifted to native 1440p, force 1080p (known X peg trigger).
# Read DRM sysfs — never xrandr --query. modesetting drmModeGetConnector() on
# every RandR query re-reads KVM EDIDs over i915 MST AUX (see drmmode_output_detect).
dock_mode_is_1440() {
  local f mode
  for f in /sys/class/drm/card1-DP-*/mode; do
    [ -r "$f" ] || continue
    mode="$(cat "$f" 2>/dev/null || true)"
    case "${mode}" in
      *1440*|*2560x*) return 0 ;;
    esac
  done
  return 1
}

keep_dock_1080p() {
  dock_outputs_up || return 0
  x_is_pegged && return 0
  dock_mode_is_1440 || return 0
  resolve_display_env || return 0
  printf 'display-seizure-watchdog: dock mode 1440/2560 via sysfs — forcing 1080p layout\n' >&2
  assert_dock_layout
  ensure_polybar
}

soft_recover() {
  printf 'display-seizure-soft-recover: running (reason=%s) [no RandR on peg, no logout, keep polybar]\n' \
    "${1:-unspecified}" >&2
  kill_compositors
  kill_transparent_i3bar
  kill_xfsettingsd
  if [ -x /etc/nixos/scripts/reattach-x-inputs.sh ]; then
    /etc/nixos/scripts/reattach-x-inputs.sh 2>/dev/null || true
  fi
  ensure_polybar
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

  while true; do
    kill_compositors
    kill_xfsettingsd
    if ! x_is_pegged; then
      keep_edp_off_if_docked
      keep_edp_on_if_undocked
      keep_dock_1080p
    fi
    ensure_polybar

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
        sleep 2
        pct="$(x_cpu_pct "${xpid}" 2)"
        if [ "${pct}" -ge "${peg_pct}" ]; then
          printf 'display-seizure-watchdog: still pegged (~%s%%) after call-safe recover — NOT escalating to logout\n' \
            "${pct}" >&2
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

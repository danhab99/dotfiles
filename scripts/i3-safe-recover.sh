#!/usr/bin/env bash
# Call-safe display + i3 recovery for tradezero KVM glitches.
# - Clears corrupt i3 restart-state (empty swallow from ghost Electron tiles)
# - Soft display recover (inputs, polybar, no logout)
# - Safe i3 restart if running, or cold-start i3 if WM died
# Bound to Mod4+Shift+r (i3) and Mod4+Shift+Escape (xbindkeys, no i3 needed).
set -uo pipefail

USER_NAME="${USER:-dan}"
UID_NUM="$(id -u "${USER_NAME}" 2>/dev/null || echo 1000)"
I3_RUN_DIR="${XDG_RUNTIME_DIR:-/run/user/${UID_NUM}}/i3"
LOG="${HOME}/.local/share/i3-safe-recover.log"

log() {
  printf '%s i3-safe-recover: %s\n' "$(date -Iseconds)" "$*" | tee -a "${LOG}" >&2
}

resolve_display_env() {
  if [ -n "${DISPLAY:-}" ] && [ -n "${XAUTHORITY:-}" ] && [ -r "${XAUTHORITY}" ]; then
    export DISPLAY XAUTHORITY
    return 0
  fi
  local pid envfile line
  for pid in \
    "$(pgrep -u "${USER_NAME}" -x i3 2>/dev/null | head -1 || true)" \
    "$(pgrep -u "${USER_NAME}" -f 'in1jphx1v4by3iigk97qsyhdys951vpg-xsession' 2>/dev/null | head -1 || true)" \
    "$(pgrep -u "${USER_NAME}" -x xfce4-session 2>/dev/null | head -1 || true)"; do
    [ -n "${pid}" ] || continue
    envfile="/proc/${pid}/environ"
    [ -r "${envfile}" ] || continue
    DISPLAY=""
    XAUTHORITY=""
    while IFS= read -r -d '' line; do
      case "${line}" in
        DISPLAY=*) DISPLAY="${line#DISPLAY=}" ;;
        XAUTHORITY=*) XAUTHORITY="${line#XAUTHORITY=}" ;;
      esac
    done < "${envfile}"
    if [ -n "${DISPLAY:-}" ] && [ -n "${XAUTHORITY:-}" ] && [ -r "${XAUTHORITY}" ]; then
      export DISPLAY XAUTHORITY
      return 0
    fi
  done
  return 1
}

clear_restart_state() {
  rm -f "${I3_RUN_DIR}"/restart-state.* 2>/dev/null || true
}

main() {
  mkdir -p "$(dirname "${LOG}")"
  log "start (uid=${UID_NUM})"

  if [ -x /etc/nixos/scripts/display-seizure-watchdog.sh ]; then
    /etc/nixos/scripts/display-seizure-watchdog.sh recover || true
  fi

  clear_restart_state

  if pgrep -u "${USER_NAME}" -x i3 >/dev/null 2>&1; then
    log "i3 running — restart after clearing restart-state"
    resolve_display_env || true
    if command -v i3-msg >/dev/null 2>&1; then
      i3-msg restart || log "i3-msg restart failed"
    else
      log "i3-msg missing"
    fi
    exit 0
  fi

  log "i3 not running — cold start"
  resolve_display_env || {
    log "cannot resolve DISPLAY/XAUTHORITY"
    exit 1
  }

  i3_bin="$(command -v i3 2>/dev/null || true)"
  [ -n "${i3_bin}" ] || {
    log "i3 binary not in PATH"
    exit 1
  }

  nohup "${i3_bin}" >>"${LOG}" 2>&1 &
  sleep 2

  if ! pgrep -u "${USER_NAME}" -x i3 >/dev/null 2>&1; then
    log "i3 failed to start — see ${LOG}"
    exit 1
  fi

  systemctl --user restart polybar.service 2>/dev/null || true
  systemctl --user reset-failed i3-focus-underline.service 2>/dev/null || true
  systemctl --user restart i3-focus-underline.service 2>/dev/null || true
  log "i3 cold start ok pid=$(pgrep -u "${USER_NAME}" -x i3 | head -1)"
}

main "$@"

#!/usr/bin/env bash
# Reattach floating XInput slaves to Virtual core pointer/keyboard.
# Idempotent. Safe in a tight loop. See docs/kvm-display-seizure.md.
set -uo pipefail

USER_NAME="${USER:-dan}"

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

preferred_master() {
  local name="$1" pointer="$2" keyboard="$3"
  case "${name}" in
    *[Mm]ouse*|*[Tt]rack[Pp]ad*|*[Tt]ouch[Pp]ad*|*[Tt]rack[Pp]oint*|*[Pp]ointer*)
      printf '%s %s\n' "${pointer}" "${keyboard}"
      ;;
    *)
      printf '%s %s\n' "${keyboard}" "${pointer}"
      ;;
  esac
}

reattach_floating() {
  command -v xinput >/dev/null 2>&1 || return 0
  local pointer keyboard
  pointer="$(xinput list --id-only 'Virtual core pointer' 2>/dev/null || echo 2)"
  keyboard="$(xinput list --id-only 'Virtual core keyboard' 2>/dev/null || echo 3)"
  local line id name masters first second
  while IFS= read -r line; do
    case "${line}" in *'floating slave'*) ;; *) continue ;; esac
    id="$(printf '%s\n' "${line}" | sed -n 's/.*id=\([0-9][0-9]*\).*/\1/p')"
    [ -n "${id}" ] || continue
    name="$(printf '%s\n' "${line}" | sed 's/^[[:space:]∼]*//;s/[[:space:]][[:space:]]*id=.*//')"
    masters="$(preferred_master "${name}" "${pointer}" "${keyboard}")"
    first="${masters%% *}"
    second="${masters##* }"
    if xinput reattach "${id}" "${first}" >/dev/null 2>&1; then
      printf 'reattach-x-inputs: id=%s -> master %s (%s)\n' "${id}" "${first}" "${name}" >&2
    elif xinput reattach "${id}" "${second}" >/dev/null 2>&1; then
      printf 'reattach-x-inputs: id=%s -> master %s fallback (%s)\n' "${id}" "${second}" "${name}" >&2
    else
      printf 'reattach-x-inputs: FAILED id=%s (%s)\n' "${id}" "${name}" >&2
    fi
  done < <(xinput list 2>/dev/null || true)
}

if ! resolve_display_env; then
  exit 0
fi
reattach_floating

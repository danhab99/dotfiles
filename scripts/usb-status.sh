#!/usr/bin/env bash
# Report USB power-prevention state and recent hub disconnects. Read-only.
set -uo pipefail

RED=$'\033[31m'
GRN=$'\033[32m'
YLW=$'\033[33m'
BLD=$'\033[1m'
RST=$'\033[0m'

pass=0
fail=0
warn=0

ok() { printf '  %s✓%s %s\n' "$GRN" "$RST" "$1"; pass=$((pass + 1)); }
bad() { printf '  %s✗%s %s\n' "$RED" "$RST" "$1"; fail=$((fail + 1)); }
note() { printf '  %s!%s %s\n' "$YLW" "$RST" "$1"; warn=$((warn + 1)); }

section() { printf '\n%s%s%s\n' "$BLD" "$1" "$RST"; }

has_cmdline() {
  tr ' ' '\n' </proc/cmdline | rg -q "^${1}$" 2>/dev/null || tr ' ' '\n' </proc/cmdline | rg -q "^${1}=" 2>/dev/null
}

section 'Kernel boot parameters'
if has_cmdline 'usbcore.autosuspend=-1'; then
  ok 'usbcore.autosuspend=-1'
else
  bad 'usbcore.autosuspend=-1 missing from /proc/cmdline (reboot after rebuild)'
fi

quirks="$(tr ' ' '\n' </proc/cmdline | rg '^usbcore.quirks=' | cut -d= -f2- || true)"
if [[ -n "$quirks" ]]; then
  ok "usbcore.quirks present"
  printf '    %s\n' "$quirks"
  for token in 05e3:0610:k 05e3:0626:k 0bda:5411:k; do
    if [[ "$quirks" == *"$token"* ]]; then
      ok "quirk $token"
    else
      bad "quirk $token missing"
    fi
  done
else
  bad 'usbcore.quirks missing from /proc/cmdline (reboot after rebuild)'
fi

section 'Loaded module defaults'
if [[ -r /sys/module/usbcore/parameters/autosuspend ]]; then
  val="$(cat /sys/module/usbcore/parameters/autosuspend)"
  if [[ "$val" == "-1" ]]; then
    ok "usbcore module autosuspend=$val"
  else
    bad "usbcore module autosuspend=$val (expected -1)"
  fi
else
  note 'cannot read /sys/module/usbcore/parameters/autosuspend'
fi

section 'xHCI host controllers (PCI power)'
xhci_found=0
for dir in /sys/bus/pci/drivers/xhci_hcd/0000:*; do
  [[ -d "$dir" ]] || continue
  xhci_found=1
  name="$(basename "$dir")"
  ctrl="$(cat "$dir/power/control" 2>/dev/null || echo '?')"
  as="$(cat "$dir/power/autosuspend" 2>/dev/null || echo '')"
  wake="$(cat "$dir/power/wakeup" 2>/dev/null || echo '?')"
  printf '  %s\n' "$name"
  [[ "$ctrl" == on ]] && ok 'power/control=on' || bad "power/control=$ctrl"
  if [[ -z "$as" ]]; then
    note 'power/autosuspend not exposed (control=on is what matters)'
  elif [[ "$as" == -1 || "$as" == 0 ]]; then
    ok "power/autosuspend=$as"
  else
    bad "power/autosuspend=$as"
  fi
  [[ "$wake" == disabled ]] && ok 'power/wakeup=disabled' || note "power/wakeup=$wake"
done
if [[ "$xhci_found" -eq 0 ]]; then
  note 'no xHCI PCI devices under /sys/bus/pci/drivers/xhci_hcd'
fi

section 'USB3 link power (ports)'
lpm_bad=0
lpm_total=0
while IFS= read -r -d '' permit; do
  lpm_total=$((lpm_total + 1))
  val="$(cat "$permit" 2>/dev/null || echo '?')"
  if [[ "$val" != "0" ]]; then
    lpm_bad=$((lpm_bad + 1))
    bad "${permit#*/sys/devices/}: $val (want 0)"
  fi
done < <(find /sys/devices -name usb3_lpm_permit -print0 2>/dev/null)

if [[ "$lpm_total" -eq 0 ]]; then
  note 'no usb3_lpm_permit nodes found'
elif [[ "$lpm_bad" -eq 0 ]]; then
  ok "all $lpm_total usb3_lpm_permit nodes are 0"
fi

section 'Dock / hub devices (runtime power)'
hub_found=0
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  hub_found=1
  dev="${line%% *}"
  rest="${line#* }"
  ctrl="${rest#*control=}"; ctrl="${ctrl%% *}"
  as="${rest#*autosuspend=}"; as="${as%% *}"
  vidpid="${rest%% *}"
  printf '  %s (%s)\n' "$dev" "$vidpid"
  [[ "$ctrl" == on ]] && ok 'control=on' || bad "control=$ctrl"
  if [[ "$as" == -1 || "$as" == 0 ]]; then
    ok "autosuspend=$as"
  else
    bad "autosuspend=$as"
  fi
done < <(
  for d in /sys/bus/usb/devices/*/; do
    [[ -f "$d/idVendor" && -f "$d/idProduct" ]] || continue
    v="$(cat "$d/idVendor")"
    p="$(cat "$d/idProduct")"
    case "$v:$p" in
      05e3:*|0bda:*|1a40:*) ;;
      *) continue ;;
    esac
    c="$(cat "$d/power/control" 2>/dev/null || echo '?')"
    a="$(cat "$d/power/autosuspend" 2>/dev/null || echo '?')"
    printf '%s %s:%s control=%s autosuspend=%s\n' "${d%/}" "$v" "$p" "$c" "$a"
  done
)
if [[ "$hub_found" -eq 0 ]]; then
  note 'no GenesysLogic / Realtek / VLI hubs currently connected'
fi

section 'Background enforcement'
for unit in disable-usb-suspend.service disable-usb-suspend-enforce.timer; do
  if systemctl is-enabled "$unit" &>/dev/null; then
    ok "$unit enabled"
  else
    bad "$unit not enabled"
  fi
done
if systemctl is-active disable-usb-suspend-enforce.timer &>/dev/null; then
  ok 'disable-usb-suspend-enforce.timer active'
else
  note 'disable-usb-suspend-enforce.timer not active'
fi

section 'Recent USB disconnects (kernel log, last 24h)'
disconnects="$(journalctl -k --since '24 hours ago' --no-pager 2>/dev/null | rg 'USB disconnect' || true)"
if [[ -z "$disconnects" ]]; then
  ok 'no USB disconnect lines in the last 24 hours'
else
  count="$(printf '%s\n' "$disconnects" | wc -l)"
  bad "$count USB disconnect event(s) in the last 24 hours:"
  printf '%s\n' "$disconnects" | tail -15 | sed 's/^/    /'
  printf '\n  %sWatch live:%s journalctl -k -f | rg "USB disconnect"\n' "$YLW" "$RST"
fi

section 'GenesysLogic hub port disconnects (last 7 days)'
# Hub root is usually usb 3-x.2 on this dock (05e3:0610).
hub_dc="$(journalctl -k --since '7 days ago' --no-pager 2>/dev/null | rg 'USB disconnect' | rg 'usb 3-[0-9]+\.2:' || true)"
if [[ -z "$hub_dc" ]]; then
  ok 'no dock hub port (usb 3-*.2) disconnects in 7 days'
else
  count="$(printf '%s\n' "$hub_dc" | wc -l)"
  bad "$count dock hub disconnect(s) in 7 days (last 10):"
  printf '%s\n' "$hub_dc" | tail -10 | sed 's/^/    /'
fi

section 'Summary'
printf '  %s%d passed%s  %s%d failed%s  %s%d notes%s\n' "$GRN" "$pass" "$RST" "$RED" "$fail" "$RST" "$YLW" "$warn" "$RST"
if [[ "$fail" -gt 0 ]]; then
  printf '\n  Fix: sudo nixos-rebuild switch --flake /etc/nixos/machine/tradezero && sudo reboot\n'
  printf '  Re-apply now (no reboot): sudo /etc/nixos/scripts/disable-usb-suspend.sh && usb-status\n'
  exit 1
fi
exit 0

#!/usr/bin/env bash
# Silent prevention: keep USB/PCI power paths awake. Never touches the display stack.
#
# IMPORTANT: Do not invoke this from a USB "change" udev RUN+= rule without a
# lock — writing power/* attrs emits more "change" events and can cascade into
# a hub/KVM reset storm (flashing displays, dead input, clock jumps).
#
# flock: WAIT up to 15s. Never `flock -n || exit 0` — that reported success
# while leaving xHCI on power/control=auto and USB3 LPM at u1_u2 (verified
# 2026-08-07: enforce unit "succeeded" in ~10ms with values still wrong).
set -uo pipefail

LOCK=/run/disable-usb-suspend.lock
exec 9>"$LOCK" 2>/dev/null || exit 0
if ! flock -w 15 9; then
  echo "disable-usb-suspend: flock timeout on $LOCK" >&2
  exit 1
fi

wrote=0
failed=0

write_sysfs() {
  local path="$1"
  local value="$2"
  # Skip write if already correct — avoids generating needless uevents.
  if [ -r "$path" ]; then
    local cur
    cur=$(cat "$path" 2>/dev/null || true)
    [ "$cur" = "$value" ] && return 0
  fi
  if [ ! -w "$path" ]; then
    failed=$((failed + 1))
    return 1
  fi
  if ! { echo "$value" >"$path"; } 2>/dev/null; then
    failed=$((failed + 1))
    return 1
  fi
  wrote=$((wrote + 1))
  return 0
}

for control in /sys/bus/usb/devices/*/power/control; do
  [ -f "$control" ] && write_sysfs "$control" on
done

for autosuspend in /sys/bus/usb/devices/*/power/autosuspend; do
  [ -f "$autosuspend" ] && write_sysfs "$autosuspend" -1
done

for delay in /sys/bus/usb/devices/*/power/autosuspend_delay_ms; do
  [ -f "$delay" ] && write_sysfs "$delay" 0
done

for wakeup in /sys/bus/usb/devices/*/power/wakeup; do
  [ -f "$wakeup" ] && write_sysfs "$wakeup" disabled
done

for persist in /sys/bus/usb/devices/*/power/persist; do
  [ -f "$persist" ] && write_sysfs "$persist" 1
done

for lpm in /sys/devices/*/usb*/power/usb3_hardware_lpm_u[12]; do
  [ -f "$lpm" ] && write_sysfs "$lpm" disabled
done

while IFS= read -r -d '' permit; do
  [ -w "$permit" ] && write_sysfs "$permit" 0
done < <(find /sys/devices -name usb3_lpm_permit -print0 2>/dev/null)

# Keep xHCI host controllers and their PCI parent ports fully powered.
for control in /sys/bus/pci/drivers/xhci_hcd/*/power/control; do
  [ -f "$control" ] && write_sysfs "$control" on
done

for autosuspend in /sys/bus/pci/drivers/xhci_hcd/*/power/autosuspend; do
  [ -f "$autosuspend" ] && write_sysfs "$autosuspend" -1
done

for wakeup in /sys/bus/pci/drivers/xhci_hcd/*/power/wakeup; do
  [ -f "$wakeup" ] && write_sysfs "$wakeup" disabled
done

# Walk every USB device's PCI ancestors — dock/TB ports flip to auto otherwise.
for d in /sys/bus/usb/devices/*; do
  [ -d "$d" ] || continue
  pci="$d"
  for _ in 1 2 3 4 5 6 7 8; do
    pci=$(readlink -f "$pci/.." 2>/dev/null || true)
    [ -n "$pci" ] || break
    case "$pci" in
      */pci/*|/sys/devices/pci*)
        [ -f "$pci/power/control" ] && write_sysfs "$pci/power/control" on
        [ -f "$pci/power/autosuspend" ] && write_sysfs "$pci/power/autosuspend" -1
        ;;
    esac
  done
done

# Input hub path (VIA + Moonlander + Magic Trackpad + Lenovo dock): force no USB2/3 LPM.
for d in /sys/bus/usb/devices/*; do
  [ -f "$d/idVendor" ] || continue
  v=$(cat "$d/idVendor" 2>/dev/null || true)
  case "$v" in
    2109|3297|05ac|17ef)
      for f in "$d"/power/usb2_hardware_lpm "$d"/power/usb3_hardware_lpm_u1 \
               "$d"/power/usb3_hardware_lpm_u2; do
        [ -f "$f" ] && write_sysfs "$f" "0"
        [ -f "$f" ] && write_sysfs "$f" "disabled"
      done
      for f in "$d"/port/*/disable_runtime_pm "$d"/../port/*/usb3_lpm_permit; do
        [ -f "$f" ] && write_sysfs "$f" "0"
      done
      ;;
  esac
done

# Verify the two things that have silently drifted before.
xhci_bad=0
for control in /sys/bus/pci/drivers/xhci_hcd/*/power/control; do
  [ -f "$control" ] || continue
  cur=$(cat "$control" 2>/dev/null || echo '?')
  if [ "$cur" != on ]; then
    echo "disable-usb-suspend: still $control=$cur after write" >&2
    xhci_bad=1
  fi
done

lpm_bad=0
while IFS= read -r -d '' permit; do
  cur=$(cat "$permit" 2>/dev/null || echo '?')
  if [ "$cur" != 0 ]; then
    echo "disable-usb-suspend: still $permit=$cur after write" >&2
    lpm_bad=1
  fi
done < <(find /sys/devices -name usb3_lpm_permit -print0 2>/dev/null)

if [ "$xhci_bad" -ne 0 ] || [ "$lpm_bad" -ne 0 ] || [ "$failed" -gt 0 ]; then
  echo "disable-usb-suspend: wrote=$wrote failed_writes=$failed xhci_bad=$xhci_bad lpm_bad=$lpm_bad" >&2
  exit 1
fi

exit 0

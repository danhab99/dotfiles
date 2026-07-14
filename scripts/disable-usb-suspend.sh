#!/usr/bin/env bash
# Silent prevention: keep USB/PCI power paths awake. Never touches the display stack.
set -uo pipefail

write_sysfs() {
  local path="$1"
  local value="$2"
  { echo "$value" >"$path"; } 2>/dev/null || true
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

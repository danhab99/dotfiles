#!/bin/sh
# Reset the xHCI USB controller to recover from stuck devices.
# This handles the recurring issue where a KVM switch power interruption
# causes a device to enter an infinite usb_set_interface timeout loop
# (-110 ETIMEDOUT).
#
# POSIX sh — safe to run from a bare TTY or rescue shell.
#
# Usage: sudo /etc/nixos/scripts/reset-usb.sh
#    or: sudo systemctl start reset-usb
set -eu

echo "=== xHCI USB Controller Reset ==="

# Auto-detect xHCI PCI devices
XHCI_DIR="/sys/bus/pci/drivers/xhci_hcd"
XHCI_DEVICES=""
for d in "$XHCI_DIR"/0000:*; do
  [ -d "$d" ] || continue
  XHCI_DEVICES="$XHCI_DEVICES ${d##*/}"
done

if [ -z "$XHCI_DEVICES" ]; then
  echo "ERROR: No xHCI controllers found."
  exit 1
fi

# Step 1: Unbind all USB devices to stop any timeout storms
for dev in /sys/bus/usb/devices/[0-9]*-[0-9]*; do
  [ -d "$dev" ] || continue
  devname="${dev##*/}"
  case "$devname" in usb*) continue ;; esac
  if [ -e "$dev/driver" ]; then
    echo "Unbinding $devname..."
    echo "$devname" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null || true
  fi
done

sleep 1

# Step 2: Reset each xHCI controller via PCI unbind/rebind
for pci_dev in $XHCI_DEVICES; do
  echo "Unbinding xHCI controller $pci_dev..."
  echo "$pci_dev" > "$XHCI_DIR/unbind"
done

sleep 2

for pci_dev in $XHCI_DEVICES; do
  echo "Rebinding xHCI controller $pci_dev..."
  echo "$pci_dev" > "$XHCI_DIR/bind"
done

sleep 3
echo "Done. All USB devices should re-enumerate."

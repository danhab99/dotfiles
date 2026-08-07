#!/usr/bin/env bash
# Emergency recovery for the tradezero KVM/USB display seizure.
# See docs/kvm-display-seizure.md. Safe to run from a TTY.
#
# Policy: work/calls machine — kill compositors, never leave picom running.
set -uo pipefail

echo "=== display-seizure-recover ==="

pkill -u "${USER:-dan}" -x picom 2>/dev/null || true
pkill -u "${USER:-dan}" -x xcompmgr 2>/dev/null || true
pkill -u "${USER:-dan}" -x compton 2>/dev/null || true
sleep 0.5
pkill -KILL -u "${USER:-dan}" -x picom 2>/dev/null || true
pkill -KILL -u "${USER:-dan}" -x xcompmgr 2>/dev/null || true

mkdir -p "${HOME}/.config/systemd/user"
for u in picom.service xcompmgr.service picom-minimal-live.service picom-x-watchdog.service; do
  ln -sfn /dev/null "${HOME}/.config/systemd/user/${u}"
done

# Ensure compositor kill-loop is running
cat > "${HOME}/.config/systemd/user/no-compositor-guard.service" <<'EOF'
[Unit]
Description=Keep X compositor-free (tradezero work / calls)
After=graphical-session-pre.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/bin/sh -c 'while true; do pkill -x picom 2>/dev/null; pkill -x xcompmgr 2>/dev/null; pkill -x compton 2>/dev/null; sleep 3; done'
Restart=always
RestartSec=1

[Install]
WantedBy=graphical-session.target
EOF

if [ -S "/run/user/$(id -u)/bus" ]; then
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now no-compositor-guard.service 2>/dev/null || true
fi

echo "picom processes: $(pgrep -c -u "${USER:-dan}" -x picom 2>/dev/null || echo 0)"

if [ -x /etc/nixos/scripts/disable-usb-suspend.sh ]; then
  if [ "$(id -u)" -eq 0 ]; then
    /etc/nixos/scripts/disable-usb-suspend.sh || true
  else
    sudo /etc/nixos/scripts/disable-usb-suspend.sh || true
  fi
fi

if [ -x /etc/nixos/scripts/usb-status.sh ]; then
  /etc/nixos/scripts/usb-status.sh || true
fi

XPID=$(pgrep -f 'bin/X ' | head -1 || true)
if [ -n "${XPID}" ]; then
  echo "X pid=${XPID}"
  top -b -n 2 -d 1 -p "${XPID}" 2>/dev/null | tail -4
else
  echo "No X server — if the greeter is stuck: sudo systemctl restart display-manager"
fi

echo "=== done ==="
echo "If GUI still unusable: sudo systemctl restart display-manager"
echo "Durable: nixos-rebuild switch (docs/kvm-display-seizure.md) — NO picom on this machine"

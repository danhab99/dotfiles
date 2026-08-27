#!/usr/bin/env bash
# Run in an interactive terminal (GPG signing required).
set -euo pipefail
cd /etc/nixos

export GPG_TTY="${GPG_TTY:-$(tty)}"

git commit -m "$(cat <<'EOF'
Patch Xorg modesetting for Intel MST/KVM dock on tradezero.

Overlay xorg-server with vblank/pageflip EBUSY retry limits and skip DRM
uevent connector reprobes; add pre-X eDP-off, metrics capture, and build
verification scripts. Extend kvm-switch watchdogs and polybar launch checks.
EOF
)"

git rebase origin/master

echo "Done. Review with: git log --oneline origin/master..HEAD"

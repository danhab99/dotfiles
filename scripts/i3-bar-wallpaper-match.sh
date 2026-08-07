#!/usr/bin/env bash
# Set i3bar background to the average color of the wallpaper's bottom strip.
# This is "fake transparency" — no compositor, no X lock risk.
# See docs/kvm-display-seizure.md.
set -euo pipefail

CONFIG="${HOME}/.config/i3/config"
NITROGEN_CFG="${HOME}/.config/nitrogen/bg-saved.cfg"
COLOR_FILE="${HOME}/.config/i3/bar-wallpaper-color"

need() { command -v "$1" >/dev/null 2>&1 || { echo "i3-bar-wallpaper-match: missing $1" >&2; exit 1; }; }
need magick

wp=""
if [[ -f "$NITROGEN_CFG" ]]; then
  wp=$(rg -o 'file=.*' "$NITROGEN_CFG" | head -1 | sed 's/^file=//')
fi
if [[ -z "$wp" || ! -f "$wp" ]]; then
  echo "i3-bar-wallpaper-match: no nitrogen wallpaper at $NITROGEN_CFG" >&2
  exit 0
fi

# Bottom 8% of the image → 1×1 average pixel → #RRGGBB
hex=$(magick "$wp" -gravity South -crop '100%x8%+0+0' +repage -resize 1x1 txt:- \
  | rg -o '#[0-9A-Fa-f]{6}' | head -1)
if [[ -z "$hex" ]]; then
  echo "i3-bar-wallpaper-match: failed to sample $wp" >&2
  exit 1
fi

mkdir -p "$(dirname "$COLOR_FILE")"
echo "$hex" >"$COLOR_FILE"

if [[ ! -f "$CONFIG" ]]; then
  echo "i3-bar-wallpaper-match: no i3 config yet; wrote $COLOR_FILE=$hex"
  exit 0
fi

# Materialize if HM left the config read-only / store-linked.
if [[ ! -w "$CONFIG" ]]; then
  tmp=$(mktemp)
  cat "$CONFIG" >"$tmp"
  rm -f "$CONFIG"
  cp "$tmp" "$CONFIG"
  chmod 644 "$CONFIG"
  rm -f "$tmp"
fi

# Opaque bar only — never i3bar -t (that needs a compositor).
sed -i 's/i3bar_command i3bar -t/i3bar_command i3bar/' "$CONFIG"
# Bar chrome: background + inactive workspace cells track wallpaper.
sed -i -E "s/^([[:space:]]*background )#[0-9A-Fa-f]{6}/\1${hex}/" "$CONFIG"
sed -i -E "s/^([[:space:]]*inactive_workspace )#[0-9A-Fa-f]{6} #[0-9A-Fa-f]{6}/\1${hex} ${hex}/" "$CONFIG"

echo "i3-bar-wallpaper-match: bar bg → $hex (from $wp)"

shopt -s nullglob
socks=(/run/user/"$(id -u)"/i3/ipc-socket.*)
shopt -u nullglob
if [[ -n "${I3SOCK:-}" ]]; then
  i3-msg -s "$I3SOCK" reload >/dev/null 2>&1 || true
elif [[ ${#socks[@]} -gt 0 ]]; then
  i3-msg -s "${socks[0]}" reload >/dev/null 2>&1 || true
fi

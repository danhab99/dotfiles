# KVM / USB-C hub display seizure (tradezero)

**Policy (2026-08-07):** work / calls machine. **No picom. No xcompmgr.**
Fleet-wide: all desktop hosts use **polybar** (not i3bar) and leave picom off by default.

## Aesthetics without a compositor

| Want | How (stable) |
| --- | --- |
| Rounded corners | **i3-rounded** `border_radius` via X Shape — no compositor |
| Status bar | **`polybar` subflake** + per-machine `polybar.ini` (sibling of `i3blocks.conf`). `pseudo-transparency` = urxvt-style root pixmap blend. |
| Focus cue | `i3-focus-underline` (override-redirect; no compositor) |

Real ARGB (`i3bar -t` / compositor Polybar) **requires** a compositor on X11.
That turns a KVM/USB hub blip into a frozen session here. We do not use it.

## Symptom (when policy was violated)

- Windows flash / “seizure”; input dead; X at ~100% CPU

## Root causes

1. Any X compositor after a hub blip (full picom, minimal picom, xcompmgr)
2. VIA USB hub disconnects on the dock path
3. USB enforce `flock -n || exit 0` false success
4. Ad-hoc `picom-*-live.service` units

## Intended config

```nix
i3 = {
  enable = true;
  i3blocksConfig = ./i3blocks.conf;
  # enablePicom / enableI3bar default false
  enableFocusUnderline = true;
  borderRadius = 12;
  focusBorderWidth = 0;
};
polybar = {
  enable = true;
  polybarConfig = ./polybar.ini;
};
kvm-switch.enable = true;  # tradezero
# + no-compositor-guard on tradezero
```

## Live recovery

```bash
/etc/nixos/scripts/display-seizure-recover.sh
# last resort:
sudo systemctl restart display-manager
```

## Do not

- Re-enable picom for “real” bar transparency
- Enable xcompmgr
- USB `change` udev `RUN+=` of disable-usb-suspend.sh

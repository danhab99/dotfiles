# KVM / USB-C hub display seizure (tradezero)

**Policy (2026-08-07):** work / calls machine. **No picom. No xcompmgr.**
Fleet-wide: all desktop hosts use **polybar** (not i3bar) and never run a
compositor. (2026-09-04: this used to be a per-machine toggle in the i3
subflake — `enablePicom`/`enableXcompmgr`/`enableI3bar` etc. — but no machine
ever turned any of them on, so the options and their dead code paths were
removed. Compositor-free is now just how the subflake behaves, fleet-wide,
not a setting.)

## Aesthetics without a compositor

| Want | How (stable) |
| --- | --- |
| Rounded corners | **i3-rounded** `border_radius` via X Shape — no compositor |
| Status bar | **`polybar` subflake** + per-machine `polybar.ini` (sibling of `i3blocks.conf`). `pseudo-transparency` = urxvt-style root pixmap blend. |
| Focus cue | `i3-focus-underline` (override-redirect; no compositor) |

Real ARGB (`i3bar -t` / compositor Polybar) **requires** a compositor on X11.
That turns a KVM/USB hub blip into a frozen session here. We do not use it.

## Symptoms

| Symptom | Cause |
| --- | --- |
| Tiles flash; X ~100% CPU | Compositor and/or **eDP left on** beside dock outputs |
| Dead KB/trackpad; X otherwise OK | All devices `[floating slave]` (only XTEST on masters) |

## Root causes

1. Any X compositor after a hub blip
2. VIA USB hub disconnects on the dock path
3. USB enforce false success / missing `flock` in PATH
4. Ad-hoc `picom-*-live.service` units
5. Floating XInput after hub blip
6. **eDP re-enabled** (xfsettingsd / DRM) while three dock monitors are up — soft `xrandr` hangs once X is pegged

## Automatic recovery (`kvm-switch`)

| Service | Action |
| --- | --- |
| **`x-input-guard`** | Reattach floating slaves every 0.5s |
| **`display-seizure-watchdog`** | Keep eDP off when docked; on X peg STOP heavies → layout → CONT → reattach; after 3 failed soft recovers escalate |
| **`display-seizure-escalate`** | `systemctl restart display-manager` (NOPASSWD for dan); watchdog also falls back to `loginctl terminate-session` |

Also: stub `~/.local/bin/xfsettingsd`, hide autostart, xfconf `Default/eDP-1/Active = false`.

**Commit these scripts** — they lived only as uncommitted files once and vanished, leaving guards broken.

## Intended config

```nix
i3 = {
  enable = true;
  # no compositor / borderRadius / focus-underline knobs to set — the
  # subflake always runs compositor-free with rounded corners and the
  # focus-underline service on.
};
polybar = {
  enable = true;
  polybarConfig = ./polybar.ini;
};
kvm-switch.enable = true;  # tradezero
# + tradezero's own no-compositor-guard (machine/tradezero/flake.nix)
```

## Live recovery

```bash
/etc/nixos/scripts/display-seizure-recover.sh
/etc/nixos/scripts/reattach-x-inputs.sh
/etc/nixos/scripts/display-seizure-watchdog.sh recover
# last resort:
sudo systemctl restart display-manager
# or (no root): loginctl terminate-session <gui-session>
```

## Do not

- Re-enable picom for “real” bar transparency
- Enable xcompmgr
- USB `change` udev `RUN+=` of disable-usb-suspend.sh
- Leave STOP’d processes after recovery (always CONT)

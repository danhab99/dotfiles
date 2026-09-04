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
| X ~100% CPU | Compositor and/or **eDP left on** beside dock outputs; **or XID exhaustion livelock** (`GetXIDRange` / XC-MISC after multi-day Electron uptime) |
| Dead KB/trackpad; X otherwise OK | All devices `[floating slave]` (only XTEST on masters) |

## Root causes

1. Any X compositor after a hub blip
2. VIA USB hub disconnects on the dock path
3. USB enforce false success / missing `flock` in PATH
4. Ad-hoc `picom-*-live.service` units
5. Floating XInput after hub blip
6. **eDP re-enabled** (xfsettingsd / DRM) while three dock monitors are up — soft `xrandr` hangs once X is pegged

## Acceptance (non‑negotiable)

1. Display must not seize (X must not peg ~100%)
2. Status bar always visible (polybar, `Restart=always`)
3. Laptop panel on when undocked
4. **Calls must survive** — never restart display-manager / terminate session / SIGSTOP Slack as “recovery”

## Automatic recovery (`kvm-switch`) — call-safe

| Service | Action |
| --- | --- |
| **`x-input-guard`** | Reattach floating slaves every 0.5s |
| **`display-seizure-watchdog`** (user) | Keep eDP **off** when docked; eDP **on** when undocked; force dock **1080p**; on peg: layout + reattach + ensure polybar. **No Slack STOP. No logout.** |
| **`display-seizure-system-watchdog`** (root) | `/proc`+sysfs only. On peg / eDP-while-docked: **`echo off` into eDP DRM `status`**. **Never** restarts display-manager. |

Also: stub `~/.local/bin/xfsettingsd`, hide autostart, xfconf `Default/eDP-1/Active = false`.

**Commit these scripts** — they lived only as uncommitted files once and vanished, leaving guards broken.

**History:** An earlier root escalate path restarted `display-manager` and logged Dan out mid‑day (bathroom → login screen). That path is removed; it is not an acceptable fix on a calls machine.

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

## Live recovery (call-safe)

**Hotkeys (tradezero, kvm-switch):**

| Chord | When |
| --- | --- |
| **Mod4+Shift+R** | i3 alive — safe restart (clears corrupt `restart-state` first) |
| **Mod4+Shift+Escape** | i3 dead — same script via xbindkeys (X-level grab) |

```bash
/etc/nixos/scripts/i3-safe-recover.sh   # preferred one-shot
/etc/nixos/scripts/display-seizure-recover.sh
/etc/nixos/scripts/reattach-x-inputs.sh
/etc/nixos/scripts/display-seizure-watchdog.sh recover
~/.screenlayout/auto.sh   # dock 1080p + eDP off
systemctl --user restart polybar.service
```

**Do not** use bare `i3 restart` / Mod4+Shift+R without the safe script after KVM
ghost tiles — saved layout can contain an empty Electron swallow and i3 will exit.

**Do not** restart display-manager or terminate the GUI session to “clear” a peg while on calls.

## Do not

- Re-enable picom for “real” bar transparency
- Enable xcompmgr
- USB `change` udev `RUN+=` of disable-usb-suspend.sh
- SIGSTOP Slack / Electron to clear an X peg
- Restart display-manager / terminate-session as automatic recovery
- Leave STOP’d processes after recovery (always CONT)

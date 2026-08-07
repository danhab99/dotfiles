# Upstream report draft: compositor + KVM/USB hub hard-locks X

**Status:** draft for filing — not filed yet.  
**Date of incident:** 2026-08-07 (and recurring for ~1 year)  
**Machine:** Lenovo ThinkPad (Alder Lake Iris Xe), NixOS, i3-rounded, 3× external
monitors via Thunderbolt dock + KVM.

## Short answer

Yes, report it. Prefer **two** issues (cross-linked):

1. **[yshui/picom](https://github.com/yshui/picom/issues)** — compositor
   participates in / fails to survive multi-DP damage storms after USB/KVM
   reconnects; historical XID-leak abort on this host with full picom.
2. **[xorg/xserver](https://gitlab.freedesktop.org/xorg/xserver/-/issues)**
   (modesetting / present) — **Xorg stayed at ~100% CPU and stopped serving
   clients even after picom was killed**, so the session lock is not only
   “picom crashed.”

Optional third if DP link flaps are cleanly reproducible without a compositor:
Linux **i915** (KVM EDID / link-state). Lower priority until (1)+(2) are filed
with strace/xtrace.

Related existing picom issues (not duplicates — different trigger):
- XID exhaustion: https://github.com/yshui/picom/issues/406 , #473, #885, #1373
- High CPU (mostly NVIDIA/DPMS): #575, #1288 — **not** our Intel/USB-hub case

---

## Title (picom)

`Intel multi-DP + KVM/USB hub reconnect: minimal xrender picom correlates with Xorg 100% CPU / dead input; X stays pegged after picom exit`

## Title (xorg)

`modesetting: Xorg pegs one core (~100% ioctl/writev) after dock/KVM USB hub reconnect storm; i3 IPC hangs; killing compositor does not recover`

---

## Environment

| Item | Value |
| --- | --- |
| OS | NixOS (unstable track), host `tradezero` |
| Kernel | `6.18.37` |
| CPU/GPU | Intel Alder Lake-UP3 GT2 Iris Xe (`00:02.0`) |
| Xorg | `1.21.1.23`, driver `modesetting` (+ `displaylink`/`evdi` loaded but outputs are `DP-2-*` MST) |
| WM | i3-rounded 4.21 |
| Compositor | picom 12.x (Nixpkgs); also reproduced historically with full picom and with `xcompmgr -n` |
| Displays | 3× 1920×1080 on `DP-2-1`, `DP-2-2`, `DP-2-3` (primary), eDP off |
| Dock | Lenovo ThinkPad Thunderbolt 3 Dock |
| Trigger path | VIA Labs hub `2109:0817` / `2109:2817` on `usb 2-2.2` / `usb 3-2.2` (Moonlander, Magic Trackpad, webcam) |
| Kernel knobs already applied | `usbcore.autosuspend=-1`, hub `usbcore.quirks=…:k`, `i915.enable_psr=0 enable_fbc=0 enable_dc=0`, `pcie_aspm=off` |

## Symptoms

1. After random KVM switch / USB-C hub power blip (kernel logs `USB disconnect` on `2-2.2` / `3-2.2`), GUI “seizes”: windows flash, input dead, often only TTY usable.
2. `top` shows **X at ~100% of one core** (use instantaneous `top`, not long-term `ps %CPU`).
3. `i3-msg` hangs / connection refused on the live socket while i3 process still exists (blocked on X).
4. **Minimal picom** (no shadows/fade, `backend=xrender`, `use-damage=false`) still correlated: one run consumed **~17m42s CPU over ~19h**, then X locked.
5. After `pkill picom`, **X remained ~100%** until display-manager restart — so recovery is not “just restart picom.”
6. Alternate compositor `xcompmgr -n` previously produced continuous `BadRegion` storms and froze input (2026-08-06).

## Picom config at failure (minimal)

```conf
backend = "xrender";
vsync = true;
shadow = false;
fading = false;
use-damage = false;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
unredir-if-possible = false;  # also tried true
```

## Evidence to attach when filing

Capture on next reproduction (from SSH/TTY):

```bash
# Instant X CPU
top -b -n 2 -d 1 -p "$(pgrep -f 'bin/X ' | head -1)"

# Syscall mix (needs root)
sudo timeout 2 strace -p "$(pgrep -f 'bin/X ' | head -1)" -c

# USB trigger correlation
journalctl -k --since '10 min ago' | rg 'USB disconnect|2-2\.2|3-2\.2|VIA'

# Compositor
journalctl --user -u picom -b --no-pager | tail -100
pgrep -a picom; xprop -root _NET_WM_CM_S0

# Optional: xtrace picom until lock (large)
# picom under xtrace per https://github.com/yshui/picom/issues/1373
```

From 2026-08-07 lock, strace on X while pegged was dominated by `ioctl`, `writev`, `recvmsg` (busy serving/composite path), not an IRQ storm (`i915` IRQ rate was calm).

## Expected vs actual

- **Expected:** USB hub re-enumerate may drop input briefly; compositor and X remain responsive; at worst picom restarts.
- **Actual:** X becomes unusable (100% CPU, no input, WM IPC dead); killing picom does not restore X.

## Workaround used locally

- Do not run any X compositor on this host for calls/work stability.
- USB autosuspend/LPM mitigation + neutralize autorandr DRM hotplug.
- Floating opaque Polybar instead of ARGB i3bar.

This is unacceptable long-term if ARGB / rounded compositing is required — hence upstream.

## Filing checklist

- [ ] Open picom issue with this body + config + versions
- [ ] Open xorg/xserver issue with X-stays-pegged-after-picom-kill emphasis + strace `-c`
- [ ] Cross-link the two issues
- [ ] On next reproduce: attach `Xorg.0.log`, `journalctl -k` USB section, `strace -c`, `picom --version`, `xrandr --query`
- [ ] Note NixOS store paths / package versions so upstream can map to picom git rev

## Maintainer-facing hypothesis (for discussion, not asserted)

Composite manager + multi-CRTC Present/damage during MST/KVM link or USB-driven input re-entry leaves the X server in a livelock serving clients; picom may amplify (damage, redirects) or leak XIDs over time (full picom), but **X not recovering after picom exit** points at server/driver as well.

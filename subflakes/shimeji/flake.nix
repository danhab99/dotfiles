{
  description = "shimeji";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nurpkgs.url = "github:claymorwan/nurpkgs";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "shimeji";

    options = { lib, ... }: with lib; {
      characters = mkOption {
        type = types.attrsOf types.path;
        default = { };
        description = ''
          Shimeji character sets to install, keyed by the name shown in
          ShimeLinux's chooser. Each value is a directory containing the
          character's PNG frames plus a conf/ subdirectory with
          actions.xml and behaviors.xml.
        '';
      };
    };

    output = { lib, pkgs, nurpkgs, cfg, ... }:
      let
        shimelinux-package = nurpkgs.legacyPackages.${pkgs.system}.shimelinux.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            # Upstream's generic (non-KDE/Wayland) workArea just returns the
            # raw screen bounds, ignoring panel/bar reservations — mascots
            # walk the literal screen edge and end up half-hidden behind
            # polybar. Makes it respect a reserved work area instead.
            ./workarea.patch
            # MouseInfo.getPointerInfo() intermittently returns null right as
            # a window's pointer/focus state changes (e.g. the instant a
            # mascot is clicked) — upstream's fallback snapped the mascot to
            # (0,0), the top-left corner, on those ticks.
            ./cursorpos.patch
            # The embedded Dragged action anchors the mascot offsetY (120px
            # default) *below* the cursor. A mascot resting at floor level —
            # where it spends nearly all its time — already has a cursor y
            # close to the screen's bottom edge, so grabbing it there routinely
            # pushed the computed anchor past environment.screen.bottom.
            # UserBehavior.next() reads that as "out of the screen bounds" and
            # aborts the drag on the very first tick into Fall → Thrown, which
            # is why grabbing the mascot never actually worked. See
            # dragclamp.patch.
            ./dragclamp.patch
          ];
          patchFlags = [ "-p1" ];
        });
      in
      {
        homeManager = {
          imports = [
            nurpkgs.homeModules.shimelinux
          ];

          programs.shimelinux = {
            enable = true;
            package = shimelinux-package;
          };

          # Was an i3 exec_always one-liner (pkill + relaunch). That gave no
          # restart-on-crash, no stdout/stderr capture, and needed the
          # pkill-first hack only because exec_always has no concept of "already
          # running" across an `i3-msg restart` (which `just switch` triggers).
          # It was also observed to silently no-op on some boots — nothing in
          # the journal, no mascot, no error — with no way to tell why. A user
          # service fixes all of that: Restart=on-failure, real logs via
          # `journalctl --user -u brushbuddy`, and it survives i3 restarts
          # without needing to be killed and relaunched at all.
          systemd.user.services.brushbuddy = {
            Unit = {
              Description = "ShimeLinux desktop mascot (brushbuddy)";
              After = [ "graphical-session-pre.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${shimelinux-package}/bin/shimelinux";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };

          xsession.windowManager.i3.config = {
            # Without this, i3 tiles the mascot's overlay window like any
            # other window (stretching it to fill the tile instead of leaving
            # it as a small window that walks around), which also blocks
            # input to everything else. ShimeLinux's own docs call for the
            # same fix on sway/Hyprland/niri; i3 needs it too.
            floating.criteria = [
              { class = "com-group_finity-mascot"; }
            ];

            # i3-rounded rounds every window's frame via an X Shape combine
            # (see the i3 subflake's border_radius) — no compositor needed,
            # but it stacks badly with ShimeLinux's own Shape mask (the
            # mascot is already a non-rectangular sprite, reshaped every
            # animation tick). On 2026-08-29 this produced "Surface ... is
            # not initialized, skipping drawing" in the i3 log roughly once a
            # second for the mascot's entire ~10.5h session — almost
            # certainly what wedged input badly enough to force a hard
            # power-off. "border none" skips i3's frame/decoration handling
            # for this window entirely, so i3-rounded has nothing to round.
            window.commands = [
              {
                command = "border none";
                criteria = { class = "com-group_finity-mascot"; };
              }
            ];
          };

          home.file = lib.mapAttrs'
            (name: path: {
              name = ".config/shimelinux/img/${name}";
              value = {
                source = path;
                recursive = true;
              };
            })
            cfg.characters;
        };
      };
  };
}

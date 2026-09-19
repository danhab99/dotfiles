{
  description = "i3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "i3";

    options =
      { lib }:
      with lib;
      {
        configFile = mkOption {
          type = types.nullOr types.path;
          description = "Machine specific i3 config file";
          default = null;
        };
        i3blocksConfig = mkOption {
          type = types.path;
          description = "Machine specific i3blocks config file";
        };
        screen = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        defaultLayoutScript = mkOption {
          type = types.str;
        };
        fontSize = mkOption {
          type = types.float;
        };

        modKey = mkOption {
          type = types.str;
          default = "Mod4";
          description = "The modifier key used by i3 (e.g. 'Mod4' or 'Mod1').";
        };
        altModKey = mkOption {
          type = types.str;
          default = "Mod1";
          description = "The modifier key used by i3 (e.g. 'Mod4' or 'Mod1').";
        };

        # Opt out of compositors by default (KVM/USB hard-locks on tradezero;
        # other hosts use polybar pseudo-transparency instead).
        # See docs/kvm-display-seizure.md.
        enablePicom = mkEnableOption "picom compositor";

        # ARGB-only picom (bar transparency + flameshot). No shadows/fading.
        enablePicomMinimal = mkEnableOption "minimal picom (ARGB only, no shadows)";

        # Avoid on tradezero: BadRegion storms froze X input (2026-08-06).
        enableXcompmgr = mkEnableOption "xcompmgr (bar transparency only)";

        # Bottom-edge focus cue (no picom shadow / no full border required).
        enableFocusUnderline = mkEnableOption "focused-window bottom underline";

        # Without a compositor, i3bar -t cannot do real ARGB transparency.
        # Instead paint the bar the average color of the wallpaper bottom strip
        # so it visually blends (fake transparency).
        enableBarWallpaperMatch = mkEnableOption "match i3bar bg to wallpaper (no compositor)";

        # Default off — polybar subflake owns the status bar on all hosts.
        enableI3bar = mkEnableOption "i3bar + i3blocks status bar";

        # Opaque bar/workspace chrome when not using ARGB compositor bar.
        barBackground = mkOption {
          type = types.str;
          default = "#2f343f";
          description = "i3bar background when not using ARGB transparency.";
        };

        # i3-rounded Shape clip radius. Does NOT need a compositor.
        borderRadius = mkOption {
          type = types.ints.unsigned;
          default = 12;
          description = "i3-rounded border_radius (X Shape; no compositor).";
        };

        focusBorderWidth = mkOption {
          type = types.ints.unsigned;
          default = 0;
          description = "i3 pixel border width; 0 disables borders.";
        };

        focusBorderColor = mkOption {
          type = types.str;
          default = "#c0caf5";
          description = "Border/indicator color for the focused window.";
        };
      };

    output =
      {
        pkgs,
        config,
        cfg,
        lib,
        ...
      }:
      let
        focusUnderline = pkgs.writers.writePython3Bin "i3-focus-underline" {
          libraries = [
            pkgs.python3Packages.i3ipc
            pkgs.python3Packages.python-xlib
          ];
          flakeIgnore = [ "E501" ];
        } (builtins.readFile ./i3-focus-underline.py);

        # Flameshot 14 + Qt 6.11 returns null grabs on this X11 multi-monitor
        # setup ("Unable to capture screen"). Pin 12.1 / Qt5 until that works.
        nixpkgs2411 = import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
          sha256 = "1s2gr5rcyqvpr58vxdcb095mdhblij9bfzaximrva2243aal3dgx";
        }) {
          inherit (pkgs) system;
          config.allowUnfree = true;
        };
        flameshot = nixpkgs2411.flameshot;

        # x_shape_window() applies its rounded-corner X Shape mask to every
        # floating window unconditionally — it checks fullscreen_mode and
        # smart_gaps, but never border style. A `for_window ... border none`
        # window (e.g. the shimeji subflake's mascot) still gets shaped, and
        # for a window that's *already* Shape-masked to a non-rectangular
        # sprite and reshaped every ~40ms animation tick, that produced
        # "Surface ... is not initialized, skipping drawing" in the i3 log
        # roughly once a second for as long as the mascot ran — observed
        # over a ~10.5h session on 2026-08-29, and plausibly what wedged
        # input badly enough to need a hard power-off. Skip shaping (same as
        # the existing fullscreen/smart_gaps bail-out) for BS_NONE windows,
        # matching how the rest of this file already treats border style
        # (con_border_style, used the same way a few lines up).
        i3-rounded = pkgs.i3-rounded.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./shape-skip-border-none.patch ];
        });
      in
      {
        packages = [
          # Qt5 pin (see nixpkgs2411 above) — not pkgs.flameshot (Qt6/broken grab).
          flameshot
        ] ++ (with pkgs; [
          betterlockscreen
          dmenu
          i3-rounded
          firefox
          i3blocks
          i3status
          nemo
          oneko
          imagemagick
          ripgrep
        ]) ++ lib.optionals (cfg.enablePicom || cfg.enablePicomMinimal) [
          pkgs.picom
        ] ++ lib.optionals cfg.enableXcompmgr [
          pkgs.xcompmgr
        ] ++ lib.optionals cfg.enableFocusUnderline [
          focusUnderline
        ] ++ (with pkgs; [
          playerctl
          sysstat
          brave
        ]);

        nixos = {
          services.xserver.windowManager.i3 = {
            enable = true;
            package = i3-rounded;
          };

          services.xserver = {
            enable = true;
            desktopManager = {
              xterm.enable = false;
              xfce = {
                enable = true;
                noDesktop = true;
                enableXfwm = false;
              };
            };
          };
          services.displayManager.defaultSession = "xfce+i3";

          security.pam.services.i3lock = {
            enable = true;
            allowNullPassword = false;
            startSession = false;
          };
        };

        homeManager = {
          xsession.windowManager.i3 = {
            enable = true;
            package = i3-rounded;

            config = (import ./_config.nix { inherit pkgs cfg lib; });

            # i3-rounded uses X Shape for corners — no compositor required
            # (unlike picom shaders). Always emit when radius > 0.
            extraConfig = ''
              ${lib.optionalString (cfg.borderRadius > 0) "border_radius ${toString cfg.borderRadius}"}
              ${if cfg.configFile == null then "" else (builtins.readFile cfg.configFile)}
            '';
          };

          # Explicit enable=false when no compositor flag is set — otherwise a
          # prior HM generation's picom.service can linger via mkMerge gaps.
          services.picom = lib.mkMerge [
            (lib.mkIf (!(cfg.enablePicom || cfg.enablePicomMinimal)) {
              enable = false;
            })
            (lib.mkIf cfg.enablePicom {
              enable = true;
              vSync = true;
              shadow = true;
              shadowOpacity = 0.9;

              shadowExclude = [
                "name = 'Notification'"
                "class_g = 'Conky'"
                "class_g ?= 'Notify-osd'"
                "class_g = 'Cairo-clock'"
                "_GTK_FRAME_EXTENTS@:c"
                "!focused && !floating"
                "_NET_WM_NAME@:s *= 'Android Emulator'"
              ];

              settings.blur = {
                shadow-radius = 12;
              };
            })
            (lib.mkIf cfg.enablePicomMinimal {
              enable = true;
              backend = "xrender";
              vSync = true;
              fade = false;
              shadow = false;
              settings = {
                # Damage tracking has XID-leaked on this KVM/multi-DP setup.
                use-damage = false;
                mark-wmwin-focused = true;
                mark-ovredir-focused = true;
                # Unredirect fullscreen when possible — less composite work
                # during KVM stress (still needed for ARGB bar/corners).
                unredir-if-possible = true;
              };
            })
          ];

          systemd.user.services = lib.mkMerge [
            (lib.mkIf cfg.enableXcompmgr {
              xcompmgr = {
                Unit = {
                  Description = "xcompmgr (i3bar transparency only, no shadows)";
                  After = [ "graphical-session-pre.target" ];
                  PartOf = [ "graphical-session.target" ];
                };
                Service = {
                  ExecStart = "${pkgs.xcompmgr}/bin/xcompmgr -n";
                  Restart = "on-failure";
                  RestartSec = 2;
                };
                Install = {
                  WantedBy = [ "graphical-session.target" ];
                };
              };
            })
            (lib.mkIf cfg.enableFocusUnderline {
              i3-focus-underline = {
                Unit = {
                  Description = "i3 focused-window bottom underline";
                  After = [ "graphical-session-pre.target" ];
                  PartOf = [ "graphical-session.target" ];
                };
                Service = {
                  ExecStart = "${focusUnderline}/bin/i3-focus-underline";
                  # Clean IPC disconnects used to exit 0 and leave no indicator.
                  Restart = "always";
                  RestartSec = 1;
                };
                Install = {
                  WantedBy = [ "graphical-session.target" ];
                };
              };
            })
            (lib.mkIf cfg.enableBarWallpaperMatch {
              i3-bar-wallpaper-match = {
                Unit = {
                  Description = "Match i3bar background to wallpaper (fake transparency)";
                  After = [ "graphical-session-pre.target" ];
                  PartOf = [ "graphical-session.target" ];
                };
                Service = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  # PATH so the script finds magick/rg/i3-msg from the profile.
                  Environment = "PATH=${lib.makeBinPath [ pkgs.imagemagick pkgs.ripgrep i3-rounded pkgs.coreutils pkgs.gnused pkgs.gnugrep ]}";
                  ExecStart = pkgs.writeShellScript "i3-bar-wallpaper-match" (
                    builtins.readFile ../../scripts/i3-bar-wallpaper-match.sh
                  );
                };
                Install = {
                  WantedBy = [ "graphical-session.target" ];
                };
              };
            })
          ];

          systemd.user.timers = lib.mkIf (!(cfg.enablePicom || cfg.enablePicomMinimal || cfg.enableXcompmgr)) {
            no-compositor-guard = {
              Unit = {
                Description = "Periodically kill stray X compositors";
              };
              Timer = {
                OnBootSec = "30s";
                OnUnitActiveSec = "60s";
                AccuracySec = "15s";
                Unit = "no-compositor-guard.service";
              };
              Install = {
                WantedBy = [ "timers.target" "graphical-session.target" ];
              };
            };
          };

          home.file = {
            ".config/i3blocks-contrib" = {
              source = builtins.fetchGit {
                shallow = true;
                url = "https://github.com/vivien/i3blocks-contrib.git";
                rev = "9d66d81da8d521941a349da26457f4965fd6fcbd";
              };
              recursive = true;
            };

            ".config/i3blocks.conf" = {
              source = cfg.i3blocksConfig;
            };
          };
        };
      };
  };
}

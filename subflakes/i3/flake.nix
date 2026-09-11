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
        extraKeybindings = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = "Machine-specific i3 keybindings, merged over (and overriding) the shared defaults.";
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
          nemo
          oneko
          imagemagick
          ripgrep
        ]) ++ [
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
            # (unlike picom shaders).
            extraConfig = ''
              border_radius 12
              ${if cfg.configFile == null then "" else (builtins.readFile cfg.configFile)}
            '';
          };

          systemd.user.services.i3-focus-underline = {
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
        };
      };
  };
}

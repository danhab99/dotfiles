import ../module.nix {
  name = "sway";

  options =
    { lib }:
    with lib;
    {
      waybarconfigFile = mkOption {
        type = types.path;
        description = "Machine specific waybar config file";
      };
      extraInput = mkOption {
        type = types.attrsOf types.attrs;
        default = { };
        description = "Additional input device configurations";
      };
      extraStartup = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description = "Additional startup commands for machine-specific needs";
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
      outputs = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            resolution = mkOption {
              type = types.str;
              description = "Output resolution (e.g., 1920x1080)";
            };
            position = mkOption {
              type = types.str;
              description = "Output position (e.g., 0,0)";
            };
            scale = mkOption {
              type = types.str;
              default = "1";
              description = "Output scale factor";
            };
          };
        });
        default = { };
        description = "Output (monitor) configurations";
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
    {
      packages = with pkgs; [
        brightnessctl
        grim
        slurp
        swaybg
        swaylock-effects
        swayidle
        wl-clipboard
        wtype
        ydotool
        playerctl
        nemo
        sysstat
        waybar
        wdisplays
        wofi
        kanshi
      ];

      nixos = {
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
          extraPackages = with pkgs; [
            # Additional packages for Sway session
            xwayland
          ];
          extraOptions = [
            # Force Sway to use DRM backend for NVIDIA
            "--unsupported-gpu"
          ];
        };

        security.pam.services.swaylock = {
          enable = true;
          allowNullPassword = false;
          startSession = false;
        };

        # Enable ydotool for automated input
        systemd.services.ydotoold = {
          enable = true;
          description = "ydotool daemon";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            Restart = "always";
            ExecStart = "${pkgs.ydotool}/bin/ydotoold";
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            KillMode = "process";
            TimeoutSec = 180;
          };
        };
      };

      homeManager = {
        wayland.windowManager.sway = {
          enable = true;
          package = pkgs.sway;
          systemd.enable = true;
          xwayland = true;

          config = (import ./config.nix { inherit pkgs cfg lib; });
        };

        programs.waybar = {
          enable = true;
          systemd.enable = true;
        };

        home.file = {
          ".config/waybar/config" = {
            source = cfg.waybarconfigFile;
          };
        };

        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 300;
              command = "${pkgs.swaylock-effects}/bin/swaylock -f";
            }
            {
              timeout = 600;
              command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
              resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
            }
          ];
        };
      };
    };
}

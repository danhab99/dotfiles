{
  description = "polybar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "polybar";

    options =
      { lib }:
      with lib;
      {
        polybarConfig = mkOption {
          type = types.path;
          description = "Machine-specific Polybar config (sibling of i3blocksConfig).";
        };

        barName = mkOption {
          type = types.str;
          default = "main";
          description = "Bar section name inside the config (without bar/).";
        };
      };

    output =
      {
        pkgs,
        cfg,
        lib,
        ...
      }:
      let
        polybarPkg = pkgs.polybar.override {
          i3Support = true;
          pulseSupport = true;
        };

        launch = pkgs.writeShellScript "polybar-launch" ''
          set -euo pipefail
          export PATH="${lib.makeBinPath [
            polybarPkg
            pkgs.xrandr
            pkgs.xset
            pkgs.feh
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.gawk
            pkgs.procps
          ]}:$PATH"
          export POLYBAR_CONFIG=${cfg.polybarConfig}
          export POLYBAR_BAR=${cfg.barName}
          ${builtins.readFile ./launch.sh}
        '';
      in
      {
        packages = [
          polybarPkg
          pkgs.xset
          pkgs.pavucontrol
          pkgs.feh
        ];

        nixos = { };

        homeManager = {
          systemd.user.services.polybar = {
            Unit = {
              Description = "Polybar status bars (one per active monitor)";
              After = [ "graphical-session-pre.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${launch}";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };

          home.file.".config/polybar/config.ini".source = cfg.polybarConfig;
        };
      };
  };
}

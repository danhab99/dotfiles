{
  description = "i3 window manager NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "i3";
      inherit inputs;

      options = { lib }:
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
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            betterlockscreen
            dmenu
            flameshot
            i3-rounded
            firefox
            i3blocks
            i3status
            nemo
            nitrogen
            oneko
            picom
            playerctl
            sysstat
            brave
          ];

          nixos = {
            services.xserver.windowManager.i3 = {
              enable = true;
              package = pkgs.i3-rounded;
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
              package = pkgs.i3-rounded;

              config = (import ./i3config.nix { inherit pkgs cfg lib; });

              extraConfig = ''
                border_radius 12
              '';
            };
          };
        };
    };
}

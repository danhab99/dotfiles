{
  description = "xorg NixOS module";

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
      name = "xorg";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "xorg module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            xclip
            xdotool
            xbacklight
            xev
            xf86-input-evdev
            # xpad
            xsel
            arandr
            xrandr
            xorg-server
            displaylink
          ];

          nixos = {
            services.xserver = {
              enable = true;
              displayManager.startx.enable = true; # Optional if using startx
              videoDrivers = cfg.videoDrivers;

              xautolock.enable = false;
              desktopManager.xterm.enable = false;

              # Disable DPMS and screen blanking at X server level
              serverFlagsSection = ''
                Option "BlankTime" "0"
                Option "StandbyTime" "0"
                Option "SuspendTime" "0"
                Option "OffTime" "0"
              '';

              desktopManager.xfce = {
                enable = true;
                noDesktop = true;
                enableXfwm = false;
              };

              # Keyboard settings
              xkb = {
                model = "thinkpad";
                layout = "us";
                variant = "";
              };
            };

            services.libinput = {
              enable = true;
              mouse.middleEmulation = false;
            };

            # Disable XFCE power manager to prevent it from managing DPMS
            services.xserver.desktopManager.xfce.enableScreensaver = false;
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

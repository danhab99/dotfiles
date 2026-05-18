{
  description = "gestures NixOS module";

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
      name = "gestures";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "gestures module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            libinput
            libinput-gestures
            wmctrl # needed for internal window commands
            xdotool # or ydotool, depending on your workflow
          ];

          nixos = {
            services.libinput.enable = true;
          };

          homeManager = {
            xsession.windowManager.i3.config.startup = [
              {
                command = "libinput-gestures --device \"${cfg.devicePath}\"";
                always = true;
              }
            ];

            home.file.".config/libinput-gestures.conf".source = pkgs.writeText "libinput-gestures.conf" ''
              gesture swipe up 3 i3-msg fullscreen enable
              gesture swipe down 3 i3-msg fullscreen disable
              gesture pinch clockwise xdotool key "Super_L+Shift+x"
              gesture pinch anticlockwise xdotool key "Super_L+Shift+x"
            '';
          };
        };
    };
}

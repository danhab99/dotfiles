{
  description = "audio NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "audio";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "audio module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            alsa-utils
            pamixer
            pavucontrol
            playerctl
            pulseaudioFull
          ];

          nixos = {
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              audio.enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };
          };
        };
    };
}

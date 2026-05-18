{
  description = "obs NixOS module";

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
      name = "obs";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "obs module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          nixos = {
            boot.kernelModules = [ "v4l2loopback" ];
            boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

            programs.obs-studio = {
              enable = true;
              plugins = with pkgs.obs-studio-plugins; [
                wlrobs
                # obs-pipewire-audio-capture
              ];
              enableVirtualCamera = true;
            };
          };
        };
    };
}

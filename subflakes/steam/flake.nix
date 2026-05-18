{
  description = "steam NixOS module";

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
      name = "steam";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "steam module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          nixos = {
            programs.steam = {
              enable = true;
              remotePlay.openFirewall = true;
              dedicatedServer.openFirewall = false;
              localNetworkGameTransfers.openFirewall = false;

              protontricks.enable = true;

              package = pkgs.steam.override {
                extraPkgs =
                  pkgs: with pkgs; [
                    # libvulkan
                    vulkan-loader
                    vulkan-validation-layers
                    mesa
                  ];
              };
            };

            hardware.steam-hardware.enable = true;
          };
        };
    };
}

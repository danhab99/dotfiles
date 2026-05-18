{
  description = "threedtools NixOS module";

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
      name = "threedtools";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "threedtools module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            freecad
            blender
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

{
  description = "appimage NixOS module";

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
      name = "appimage";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "appimage module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          nixos = {
            programs.appimage = {
              enable = true;
              binfmt = true;
            };
          };
        };
    };
}

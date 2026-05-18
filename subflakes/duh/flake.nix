{
  description = "duh NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    duh.url = "github:danhab99/duh/main";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "duh";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "duh module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, duh, ... }:
        {
          packages = with pkgs; [
            duh.packages.x86_64-linux.duh
          ];
        };
    };
}

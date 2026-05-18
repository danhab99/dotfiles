{
  description = "vbox NixOS module";

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
      name = "vbox";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "vbox module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            virtualisation.virtualbox.host.enable = true;

            users.extraGroups.vboxusers.members = [ "dan" ];
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

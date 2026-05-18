{
  description = "bitwarden NixOS module";

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
      name = "bitwarden";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "bitwarden module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            bitwarden-desktop
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            programs.rbw = {
              enable = true;
              settings = {
                email = "dan.habot@gmail.com";
                pinentry = pkgs.pinentry-curses;
                base_url = null;
                identity_url = null;
              };
            };
          };
        };
    };
}

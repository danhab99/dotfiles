{
  description = "secrets NixOS module";

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
      name = "secrets";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "secrets module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          nixos = {
            security.rtkit.enable = true;

            security.pam.services = {
              login.enableGnomeKeyring = true; # Enable for TTY login
              sddm.enableGnomeKeyring = true;
            };

            services.gnome.gnome-keyring.enable = true;
            programs.seahorse.enable = true;

            services.passSecretService.enable = true;
          };
        };
    };
}

{
  description = "gnupg NixOS module";

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
      name = "gnupg";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "gnupg module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          homeManager = {
            programs.gpg = {
              enable = true;
              mutableKeys = true;
            };

            services.gpg-agent = {
              enable = true;
              enableSshSupport = true;
              defaultCacheTtl = 10000000;
              maxCacheTtl = 10000000;

              pinentry.package = pkgs.pinentry-curses;
              enableZshIntegration = true;
            };
          };
        };
    };
}

{
  description = "ranger NixOS module";

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
      name = "ranger";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "ranger module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            ranger
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            home.file = {
              ".config/ranger" = {
                source = ./config;
                recursive = true;
              };
            };

            programs.zsh.initContent = builtins.readFile ./zsh.sh;
          };
        };
    };
}

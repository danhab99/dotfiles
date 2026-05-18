{
  description = "urxvt NixOS module";

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
      name = "urxvt";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "urxvt module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            programs.urxvt = {
              enable = true;

              scroll.bar.enable = false;
            };

            home.file = {
              ".urxvt/ext" = {
                source = builtins.fetchGit {
                  shallow = true;
                  url = "https://github.com/simmel/urxvt-resize-font.git";
                  rev = "b5935806f159594f516da9b4c88bf1f3e5225cfd";
                };
                recursive = true;
              };
            };
          };
        };
    };
}

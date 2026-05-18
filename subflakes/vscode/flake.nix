{
  description = "vscode NixOS module";

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
      name = "vscode";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "vscode module";
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
            programs.vscode = {
              enable = true;
              package = pkgs.vscode-fhs; # or pkgs.vscodium

              mutableExtensionsDir = true;

              profiles.default = {
                # enableMCPIntergration = true;
                # enableUpdateCheck = false;
                extensions = with pkgs.vscode-extensions; [
                  github.copilot
                  jnoortheen.nix-ide
                  ms-python.vscode-pylance
                  vscodevim.vim
                ];
              };
            };
          };
        };
    };
}

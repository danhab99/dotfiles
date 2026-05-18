{
  description = "libreoffice NixOS module";

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
      name = "libreoffice";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "libreoffice module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            libreoffice-qt
            hunspell
            hunspellDicts.uk_UA
            hunspellDicts.th_TH
          ];
        };
    };
}

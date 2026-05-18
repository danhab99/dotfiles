{
  description = "essential-packages NixOS module";

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
      name = "essential-packages";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "essential-packages module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        let
          customBusybox = pkgs.busybox.overrideAttrs (oldAttrs: rec {
            postInstall = ''
              ${oldAttrs.postInstall or ""}
              # Remove the reboot symlink if it exists
              rm -f $out/bin/reboot
              rm -f $out/bin/host*
              rm -f $out/bin/lspci
            '';
          });
        in
        {
          packages = with pkgs; [
            acpi
            cachix
            curl
            customBusybox
            entr
            ffmpeg
            file
            just
            gnutar
            gzip
            jq
            nmap
            wget
            upower
            unzip
            zip
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

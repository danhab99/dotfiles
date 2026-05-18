{
  description = "all-packages NixOS module";

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
      name = "all-packages";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "all-packages module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            glances
            just
            gparted
            killall
            nixfmt-tree
            nodejs
            openssl
            pciutils
            powershell
            python3
            s3cmd
            scdl
            sshfs
            usbutils
            yai
            yt-dlp
          ];
        };
    };
}

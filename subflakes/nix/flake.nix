{
  description = "nix NixOS module";

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
      name = "nix";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "nix module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            nix-index
          ];

          nixos = {
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "root" "dan" ];

              allowed-users = [ "dan" ];
              require-sigs = false;
              auto-optimise-store = true;
              warn-dirty = false;
            };

            nix.distributedBuilds = cfg.remoteBuild;
            nix.buildMachines = [
              {
                hostName = "desktop-nix";
                sshUser = "dan";
                # FIX: Bypass the systemd multiplexer and silence status messages
                systems = [ "x86_64-linux" "aarch64-linux" ];
                maxJobs = 20;
                supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
                mandatoryFeatures = [ ];
              }
            ];

            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.allowBroken = true;

            programs.nix-ld.enable = true;
            programs.nix-ld.libraries = with pkgs; [
              gtk3
              glibc
              freetype
            ];
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

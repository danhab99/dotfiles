{
  description = "nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "nix";

    options =
      { lib }:
        with lib;
        {
          remoteBuild = mkEnableOption "remote build";
        };

    output =
      { pkgs, cfg, ... }:
      {
        packages = with pkgs; [
          nix-index
        ];

        nixos = {
          nix = {
            settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [ "root" "dan" ];
              allowed-users = [ "dan" ];
              require-sigs = false;
              auto-optimise-store = true;
              warn-dirty = false;

              substituters = [
                "https://cache.nixos.org/"
                "https://nix-community.cachix.org"
              ];

              trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
            };

            distributedBuilds = cfg.remoteBuild;
            buildMachines = [
              {
                hostName = "desktop-nix";
                sshUser = "dan";
                systems = [ "x86_64-linux" "aarch64-linux" ];
                maxJobs = 20;
                supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
                mandatoryFeatures = [ ];
              }
            ];
          };

          nixpkgs.config = {
            allowUnfree = true;
            allowBroken = true;
          };

          programs.nix-ld.enable = true;
          programs.nix-ld.libraries = with pkgs; [
            gtk3
            glibc
            freetype
          ];
        };

        homeManager = { };
      };
  };
}

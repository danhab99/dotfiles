{
  description = "docker NixOS module";

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
      name = "docker";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "docker module";

          dataRoot = lib.mkOption {
            type = types.str;
            default = "/var/lib/docker";
          };
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            diffoci
            dive
            docker-buildx
            docker-compose
            docker-credential-helpers
            lazydocker
            minikube
            pass
          ];

          nixos = {
            hardware.nvidia-container-toolkit.enable = config.module.nvidia.enable;

            virtualisation.docker = {
              enable = true;
              enableOnBoot = true;

              daemon.settings = {
                data-root = cfg.dataRoot;
              };

              extraPackages = with pkgs; [
                docker-buildx
              ];

              rootless = {
                enable = true;
                setSocketVariable = true;
              };
            };
          };
        };
    };
}

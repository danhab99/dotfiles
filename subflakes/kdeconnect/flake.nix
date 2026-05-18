{
  description = "kdeconnect NixOS module";

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
      name = "kdeconnect";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "kdeconnect module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            networking.firewall = {
              allowedTCPPorts = builtins.genList (x: x + 1714) 51;
              allowedUDPPorts = builtins.genList (x: x + 1714) 51;
            };
          };

          homeManager = {
            services.kdeconnect = {
              enable = true;
              indicator = true;
            };
          };
        };
    };
}

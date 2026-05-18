{
  description = "soulseek NixOS module";

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
      name = "soulseek";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "soulseek module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            nicotine-plus
          ];

          nixos = {
            networking.firewall = {
              allowedTCPPorts = [ 2242 ];
              allowedUDPPorts = [ 2242 ];
            };
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

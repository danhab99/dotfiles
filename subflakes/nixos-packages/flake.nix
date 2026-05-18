{
  description = "nixos-packages NixOS module";

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
      name = "nixos-packages";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "nixos-packages module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            aider-chat-full
            audacity
            # d8p.brave
            dbeaver-bin
            gimp
            github-copilot-cli
            kubectl
            nettools
            obsidian
            postgresql
            powershell
            seahorse
            totp-cli
            tree
            unixODBCDrivers.msodbcsql17
            vlc
            webcamoid
          ];

          nixos = {
            programs.nixos-cli.enable = true;
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

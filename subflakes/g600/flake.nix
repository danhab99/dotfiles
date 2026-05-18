{
  description = "g600 NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    logitech-g600-rs.url = "github:danhab99/logitech-g600-rs/main";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "g600";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "g600 module";
          devicePath = lib.mkOption { };
          deviceName = lib.mkOption { };
        };

      output = { pkgs, config, cfg, lib, logitech-g600-rs, ... }:
        {
          packages = with pkgs; [
            libratbag
            logitech-g600-rs.packages.x86_64-linux.default
          ];

          nixos.services.ratbagd = {
            enable = true;
          };

          homeManager = {
            xsession.windowManager.i3.config.startup = [
              {
                command = "xinput disable $$(xinput list --id-only '${cfg.deviceName}')";
                always = true;
              }
              {
                command = "${logitech-g600-rs-pkg}/bin/logitech-g600-rs --device-path ${cfg.devicePath} --config-path ${./g600.toml} >> ~/.log/g600.log";
                always = true;
              }
            ];

            home.file.".config/g600" = {
              recursive = true;
              source = ./assets;
            };

          };
        };
    };
}

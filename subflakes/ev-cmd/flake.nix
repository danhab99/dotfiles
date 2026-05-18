{
  description = "ev-cmd NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    ev-cmd.url = "github:danhab99/ev-cmd/main";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ev-cmd, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;

      ev-cmd-pkg = ev-cmd.packages.x86_64-linux.default;
    in
    mkModuleSubflake {
      name = "ev-cmd";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "ev-cmd module";
          devicePath = lib.mkOption { };
          deviceName = lib.mkOption { };
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            ev-cmd-pkg
          ];

          homeManager = {
            xsession.windowManager.i3.config.startup = [
              {
                command = "xinput disable $$(xinput list --id-only '${cfg.deviceName}')";
                always = true;
              }
              {
                command = "${ev-cmd-pkg}/bin/ev-cmd --device-path ${cfg.devicePath} --config-path ${./ev-cmd.toml} >> ~/.log/ev-cmd.log";
                always = true;
              }
            ];
          };
        };
    };
}

{
  description = "tty NixOS module";

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
      name = "tty";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "tty module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            console = {
              enable = true;
              earlySetup = true;

              # packages = with pkgs; [
              #   terminus_font
              # ];

              colors = [
                "000000"
                "7f7f7f"
                "c3c3c3"
                "ffffff"
                "880015"
                "ed1c24"
                "b97a57"
                "ff7f27"
                "ffc90e"
                "fff200"
                "efe4b0"
                "b5e61d"
                "22b14c"
                "99d9ea"
                "7092be"
                "00a2e8"
                "3f48cc"
                "a349a4"
                "ffaec9"
                "c8bfe7"
              ];

              # font = "${pkgs.terminus_font}/share/consolefonts/ter-v36n.psf.gz";
              keyMap = "us";
            };
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}

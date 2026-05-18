{
  description = "redshift NixOS module";

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
      name = "redshift";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "redshift module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            services.geoclue2 = {
              enable = true;
              enableWifi = true;
              submitData = false;
            };
          };

          homeManager = {
            services.redshift = {
              enable = true;

              provider = "geoclue2";

              temperature = {
                # day = 5500;
                day = 4000;
                night = 3000;
              };

              settings = {
                redshift = {
                  adjustment-method = "randr";
                  brightness-day = "1";
                  brightness-night = "1";
                };
                randr = { };
              };
            };
          };
        };
    };
}

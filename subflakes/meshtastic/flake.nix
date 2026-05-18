{
  description = "meshtastic NixOS module";

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
      name = "meshtastic";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "meshtastic module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          nixos = {
            boot.kernelModules = [ "gpio-pca953x" "spidev" ];

            # This forces the pins high via sysfs at boot
            systemd.services.fix-radio-pins = {
              enable = cfg.fixRadio;

              description = "Force Radio Power Pins";
              script = ''
                if [ ! -d /sys/class/gpio/gpio16 ]; then
                  echo 16 > /sys/class/gpio/export
                fi
                echo out > /sys/class/gpio/gpio16/direction
                echo 1 > /sys/class/gpio/gpio16/value
    
                if [ ! -d /sys/class/gpio/gpio27 ]; then
                  echo 27 > /sys/class/gpio/export
                fi
                echo out > /sys/class/gpio/gpio27/direction
                echo 1 > /sys/class/gpio/gpio27/value
              '';
              wantedBy = [ "multi-user.target" ];
            };

            services.meshtasticd = {
              enable = true;
              user = "dan";
              settings = { };
            };
          };
        };
    };
}

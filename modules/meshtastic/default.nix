import ../_module.nix
{
  name = "meshtastic";

  options = { lib, ... }: with lib; {
    fixRadio = mkEnableOption { };
  };

  output = { pkgs, cfg, ... }: {
    packages = with pkgs; [
      contact
    ];

    homeManager = { };

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
}

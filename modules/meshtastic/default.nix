import ../_module.nix
{
  name = "meshtastic";

  options = { lib, ... }: with lib; {
    fixRadio = mkEnableOption "radio fix";
    piVersion = mkOption {
      type = types.int;
      default = 4;
      description = "Raspberry Pi version (4 or 5)";
    };
  };

  output = { pkgs, cfg, ... }: {
    packages = with pkgs; [
      contact
    ];

    homeManager = { };

    nixos = {
      # Enable SPI and Device Tree Overlays for LoRa module
      boot.loader.raspberryPi = {
        enable = true;
        version = cfg.piVersion;
        firmwareConfig = ''
          dtparam=spi=on
          dtoverlay=spi1-1cs
          dtoverlay=spi0-0cs
        '';
      };

      boot.kernelModules = [ "gpio-pca953x" "spidev" ];

      # System packages required by meshtasticd
      environment.systemPackages = with pkgs; [
        libgpiod
        yaml-cpp
        libusb1
        i2c-tools
        openssl
        ulfius
        orcania
      ];

      # Grant user access to SPI and GPIO pins
      users.users.dan.extraGroups = [ "dialout" "spi" "gpio" ];

      # Meshtasticd configuration file
      environment.etc."meshtasticd/config.yaml".text = ''
        Lora:
          Module: sx1262
          DIO2_AS_RF_SWITCH: true
          DIO3_TCXO_VOLTAGE: true
          IRQ: 26
          Busy: 24
          Reset: 25
          spidev: spidev1.0

        GPS:
          # Use /dev/ttyAMA0 if you are on a CM5 module, or /dev/ttyS0 for CM4
          SerialPath: /dev/ttyS0

        Webserver:
          Port: 443
          RootPath: /var/lib/meshtasticd/web
      '';

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

      # Meshtasticd systemd service
      systemd.services.meshtasticd = {
        description = "Meshtastic Daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "/usr/local/bin/meshtasticd"; # Path to your downloaded meshtasticd binary
          Restart = "always";
          User = "root";
        };
      };
    };
  };
}

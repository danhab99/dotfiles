import ../module.nix
{
  name = "audio";

  options = { lib }: with lib; {
    enableBluetooth = lib.mkEnableOption "enableBluetooth";
    # enableJACK = lib.mkEnableOption "enableJACK";
  };

  output = { pkgs, cfg, lib, ... }: {
    packages = with pkgs; [
      alsa-utils
      pamixer
      pavucontrol
      playerctl
      pulseaudioFull
    ];

    homeManager = { };

    nixos = {
      hardware.bluetooth.enable = cfg.enableBluetooth;
      hardware.bluetooth.powerOnBoot = cfg.enableBluetooth;
      services.blueman.enable = cfg.enableBluetooth;

      # nixpkgs.config.pulseaudio = true;

      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        extraConfig.pipewire = {
          "99-disable-bell" = {
            "context.properties" = { "module.x11.bell" = false; };
          };
        };

        wireplumber = {
          enable = true;
          extraConfig.bluetooth = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true; # wideband speech for headset mics
              "bluez5.enable-hw-volume" = true; # lets volume keys sync properly
            };
          };
        };
      };
    };
  };
}

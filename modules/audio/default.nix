import ../module.nix
{
  name = "audio";

  options = { lib }: with lib; {
    enableBluetooth = lib.mkEnableOption "enableBluetooth";
    enableJACK = lib.mkEnableOption "enableJACK";
  };

  output = { pkgs, cfg, lib, ... }: {
    packages = with pkgs; [
      alsa-utils
      pamixer
    ];

    homeManager = { };

    nixos = {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;    # pipewire-pulse (Pulse clients talk to PipeWire)
        jack.enable = true;     # optional: let pipewire provide JACK
        extraConfig.pipewire = {
          "99-disable-bell" = {
            "context.properties" = { "module.x11.bell" = false; };
          };
        };
      };

      hardware.pulseaudio.enable = false;
      nixpkgs.config.pulseaudio = false;

    };

  };
}

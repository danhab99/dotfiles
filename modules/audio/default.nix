import ../module.nix
{
  name = "audio";

  options = { lib }: with lib; {
    enableBluetooth = lib.mkEnableOption "enableBluetooth";
    enableJACK = lib.mkEnableOption "enableJACK";
  };

  output = { pkgs, cfg, lib, ... }: {
    packages = with pkgs; [

    ];

    homeManager = { };

    nixos = {
      services.pipewire.enable = lib.mkForce false;

      hardware.bluetooth.enable = cfg.enableBluetooth;
      hardware.bluetooth.powerOnBoot = true;
      services.blueman.enable = cfg.enableBluetooth;

      hardware.pulseaudio = {
        enable = true;
        package = pkgs.pulseaudioFull;
      };

      services.jack = {
        jackd.enable = cfg.enableJACK;
        # support ALSA only programs via ALSA JACK PCM plugin
        alsa.enable = false;
        # support ALSA only programs via loopback device (supports programs like Steam)
        loopback = {
          enable = true;
          # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
          #dmixConfig = ''
          #  period_size 2048
          #'';
        };
      };

      users.extraUsers.dan.extraGroups = [ "jackaudio" ];

      nixpkgs.config.pulseaudio = true;

      hardware.pulseaudio.extraConfig = "load-module module-combine-sink";
    };
  };
}

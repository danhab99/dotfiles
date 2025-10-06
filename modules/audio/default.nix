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
      hardware = {
        alsa.enable = true;
        alsa.enablePersistence = true;
        bluetooth.enable = cfg.enableBluetooth;
        bluetooth.powerOnBoot = cfg.enableBluetooth;
      };

      security.rtkit.enable = true;
      
      services = {
        services.blueman.enable = cfg.enableBluetooth;
        services.pipewire.enable = lib.mkForce false;
        services.pipewire.wireplumber.enable = lib.mkForce false;
        services.pulseaudio.enable = lib.mkForce true; # current option
        services.pulseaudio.package = pkgs.pulseaudioFull; # codecs, BT
        services.pulseaudio.support32Bit = true; # Steam/Wine
      };
    };
  };
}

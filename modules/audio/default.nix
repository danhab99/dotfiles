import ../module.nix {
  name = "audio";

  options =
    { lib }:
    with lib;
    {
      enableBluetooth = lib.mkEnableOption "enableBluetooth";
      # enableJACK = lib.mkEnableOption "enableJACK";
    };

  output =
    {
      pkgs,
      cfg,
      lib,
      ...
    }:
    {
      packages = with pkgs; [
        alsa-utils
        pamixer
        pavucontrol
        playerctl
        pulseaudioFull # for pactl/paplay CLI compatibility
      ];

      homeManager = { };

      nixos = {
        hardware = {
          bluetooth.enable = cfg.enableBluetooth;
          bluetooth.powerOnBoot = cfg.enableBluetooth;
        };

        security.rtkit.enable = true;

        services = {
          blueman.enable = cfg.enableBluetooth;

          # PipeWire replaces PulseAudio — required for Wayland audio
          pulseaudio.enable = lib.mkForce false;

          pipewire = {
            enable = lib.mkForce true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true; # PulseAudio compatibility layer
            wireplumber.enable = true;
          };
        };
      };
    };
}

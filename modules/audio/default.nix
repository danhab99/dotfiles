import ../_module.nix {
  name = "audio";

  options =
    { lib }:
      with lib;
      {
        enableBluetooth = lib.mkEnableOption "enableBluetooth";
        # enableJACK = lib.mkEnableOption "enableJACK";
      };

  output =
    { pkgs
    , cfg
    , lib
    , ...
    }:
    {
      packages = with pkgs; [
        alsa-utils
        pamixer
        pavucontrol
        playerctl
        pulseaudioFull
      ];

      homeManager = { };

      nixos = {
        security.rtkit.enable = true;

        services.pipewire = {
          enable = true;
          audio.enable = true;
        };
      };
    };
}

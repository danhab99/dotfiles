{
  description = "audio";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
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
          hardware.bluetooth.enable = cfg.enableBluetooth;
          services.blueman.enable = cfg.enableBluetooth;

          security.rtkit.enable = true;

          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            wireplumber = {
              enable = true;
              # WirePlumber often picks output-only profiles on laptop HDA
              # codecs, which hides the internal microphone entirely.
              extraConfig."51-alsa-duplex-profile" = {
                "monitor.alsa.rules" = [
                  {
                    matches = [
                      { "device.name" = "~alsa_card.pci-[0-9a-f_.]+$"; }
                    ];
                    actions = {
                      update-props = {
                        "device.profile" = "output:analog-stereo+input:analog-stereo";
                      };
                    };
                  }
                ];
              };
            };
          };
        };
      };
  };
}

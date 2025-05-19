import ../module.nix {
  name = "pipewire";

  output = { pkgs, ... }: {
    packages = with pkgs;
      [
        pavucontrol
        playerctl
        pulseaudioFull
      ];

    nixos = {
      hardware.pulseaudio.enable = true;
      hardware.pulseaudio.support32Bit = true;

      users.extraUsers.dan.extraGroups = [ "audio" ];

      nixpkgs.config.pulseaudio = true;
      hardware.pulseaudio.extraConfig = "load-module module-combine-sink";

      services.pipewire = {
        enable = false;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        extraConfig.pipewire = {
          "99-disable-bell" = {
            "context.properties" = { "module.x11.bell" = false; };
          };
        };
      };
    };

    homeManager = { };
  };
}

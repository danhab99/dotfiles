import ../module.nix {
  name = "pipewire";

  output = { pkgs, ... }: {
    packages = with pkgs;
      [
        # ...
      ];

    nixos = {
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
      };
    };

    homeManager = { };
  };
}

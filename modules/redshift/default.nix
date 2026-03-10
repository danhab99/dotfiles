import ../module.nix {
  name = "redshift";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        gammastep
      ];

      homeManager = {
        services.gammastep = {
          enable = true;

          provider = "geoclue2";

          temperature = {
            day = 4000;
            night = 3000;
          };

          settings = {
            general = {
              adjustment-method = "wayland";
              brightness-day = "1.0";
              brightness-night = "1.0";
            };
          };
        };
      };

      nixos = {
        services.geoclue2 = {
          enable = true;
          enableWifi = true;
          submitData = false;
        };
      };
    };
}

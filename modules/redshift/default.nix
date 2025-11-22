import ../module.nix
{
  name = "redshift";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      redshift
    ];

    homeManager = {
      services.redshift = {
        enable = true;

        provider = "geoclue2";

        brightness = {
          # Note the string values below.
          day = "1";
          night = "0.8";
        };
        temperature = {
          # day = 5500;
          day = 4000;
          night = 3000;
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


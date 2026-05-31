{
  description = "redshift";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "redshift";

    output =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          redshift
        ];

        homeManager = {
          services.redshift = {
            enable = true;

            provider = "geoclue2";

            temperature = {
              day = 4000;
              night = 3000;
            };

            settings = {
              redshift = {
                adjustment-method = "randr";
                brightness-day = "1";
                brightness-night = "1";
              };
              randr = { };
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
  };
}

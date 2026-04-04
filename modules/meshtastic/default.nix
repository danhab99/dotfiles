import ../_module.nix
{
  name = "meshtastic";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {

    };

    nixos = {
      services.meshtasticd = {
        enable = true;
        user = "dan";
        settings = {

        };
      };
    };
  };
}


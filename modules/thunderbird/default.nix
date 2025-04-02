import ../module.nix
{
  name = "thunderbird";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      thunderbird = {
        enable  =rue;
      };
    };

    nixos = {

    };
  };
}


import ../module.nix
{
  name = "ranger";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      home.file = {
        ".config/ranger" = {
          source = ./config;
          recursive = true;
        };
      };
    };

    nixos = {

    };
  };
}


import ../_module.nix
{
  name = "cursor";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      cursor-cli
      code-cursor
    ];

    homeManager = {

    };

    nixos = {

    };
  };
}


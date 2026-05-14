import ../_module.nix
{
  name = "duh";

  requires = {
    duh.url = "github:danhab99/duh/main";
  };

  output = { pkgs, duh, ... }: {
    packages = with pkgs; [
      duh.packages.x86_64-linux.duh
    ];

    homeManager = {

    };

    nixos = {

    };
  };
}


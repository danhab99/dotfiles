{
  description = "smartgit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "smartgit";

    options = { lib, ... }: with lib; {

    };

    output = { pkgs, ... }: {
      packages = with pkgs; [
        smartgit
      ];

      nixos = { 

      };

      homeManager = {

      };

      droid = {

      };
    };
  };
}

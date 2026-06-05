{
  description = "my-nix-flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "my-nix-flake";

    options = { lib, ... }: with lib; {

    };

    output = { pkgs, ... }: {
      packages = with pkgs; [

      ];

      nixos = { 

      };

      homeManager = {

      };

      droid = {

      };
    };

    devshells = { pkgs, ... }: {
      default = {

      };
    };

    template = ./files;
    templateWelcome = "Created a blank instance of this nix flake";
  };
}

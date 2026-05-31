{
  description = "my-packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    duh.url = "github:danhab99/duh/main";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "my-packages";

    output =
      { pkgs, duh, ... }:
      {
        packages = with pkgs; [
          duh.packages.x86_64-linux.duh
        ];

        homeManager = { };

        nixos = { };
      };
  };
}

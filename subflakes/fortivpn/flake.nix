{
  description = "fortivpn";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "fortivpn";

    output =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          openfortivpn
        ];

        homeManager = { };

        nixos = { };
      };
  };
}

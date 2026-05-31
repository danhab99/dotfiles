{
  description = "go";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "go";

    devshells =
      { self, pkgs, ... }:
      {
        "" = {
          packages = with pkgs; [
            go
            gopls
          ];

          env = {
            GO_PATH = "${self.outPath}/.go";
          };
        };
      };
  };
}

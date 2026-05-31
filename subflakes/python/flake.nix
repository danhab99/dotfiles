{
  description = "python";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "python";

    devshells =
      { pkgs, ... }:
      {
        "313" = {
          packages = with pkgs; [
            just
            python313
            python313Packages.requests
            python313Packages.pypandoc
            python313Packages.toml
          ];
        };
      };
  };
}

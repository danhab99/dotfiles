{
  description = "cursor";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "cursor";

    options = { lib, ... }: with lib; { };

    output = { pkgs, ... }: {
      packages = with pkgs; [
        cursor-cli
        code-cursor
      ];
    };
  };
}

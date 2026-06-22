{
  description = "claude";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "claude";

    options = { lib, ... }: with lib; { };

    output = { pkgs, ... }: {
      packages = with pkgs; [
        claude-code
      ];
    };
  };
}

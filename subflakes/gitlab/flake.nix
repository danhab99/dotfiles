{
  description = "gitlab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "gitlab";

    options = { lib, ... }: with lib; {

    };

    output = { pkgs, ... }: {
      packages = with pkgs; [
        glab
      ];
    };
  };
}

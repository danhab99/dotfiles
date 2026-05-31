{
  description = "droid-packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "droid-packages";

    output = { pkgs, ... }: {
      packages = with pkgs; [
        openssh
        gnugrep
      ];
    };
  };
}

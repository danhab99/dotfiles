{
  description = "mk";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "mk";
    description = "mk";
    template = ./_files;
  };
}
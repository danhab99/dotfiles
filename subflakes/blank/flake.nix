{
  description = "blank nix shell for adding packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "blank";
    description = "blank nix shell for adding packages";
    template = ./_files;
  };
}

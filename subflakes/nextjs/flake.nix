{
  description = "nextjs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "nextjs";
    description = "nextjs";
    template = ./_files;
  };
}

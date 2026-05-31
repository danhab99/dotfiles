{
  description = "changelog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "changelog";
    description = "changelog";
    template = ./_files;
  };
}

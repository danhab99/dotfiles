{
  description = "printing";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "printing";

    output = { ... }: {
      nixos = {
        services.printing.enable = true;
      };
    };
  };
}

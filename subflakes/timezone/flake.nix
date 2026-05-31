{
  description = "timezone";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "timezone";

    output =
      { ... }:
      {
        nixos = {
          time.timeZone = "America/New_York";
        };
      };
  };
}

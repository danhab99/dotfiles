{
  description = "threedtools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "threedtools";

    output =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          freecad
          blender
          bambu-studio
        ];

        homeManager = { };

        nixos = { };
      };
  };
}

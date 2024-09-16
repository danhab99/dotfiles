{
  description = "";

  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    workstation =
      pkgs.mkShell
        {
          buildInputs = with pkgs; [
            gnupg
          ];
        };
  };
}

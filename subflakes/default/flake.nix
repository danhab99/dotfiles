{
  description = "default";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cli.url = "github:nix-community/nixos-cli/main";
    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs:
    let
      base = import ../output.nix inputs {
        name = "default";

        devshells =
          { pkgs, ... }:
          {
            "" = {
              packages = with pkgs; [
                cachix
                containerd
                git
                just
                nixd
                nixpkgs-fmt
              ];
            };
          };
      };
    in
    base
    // {
      nixosModules.subflake =
        { ... }:
        {
          imports = [
            inputs."home-manager".nixosModules.home-manager
            inputs."nixos-cli".nixosModules.nixos-cli
          ];

          config = {
            nixpkgs.overlays = [
              inputs.nur.overlays.default
            ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          };
        };
    };
}

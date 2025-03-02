{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR";
    nixos-cli.url = "github:water-sucks/nixos";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, nixos-cli, nur, stylix, ... }@inputs:
    let
      inherit (self) outputs;

      mkNix = system: hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = system;
          modules = [
            stylix.nixosModules.stylix
            nixos-cli.nixosModules.nixos-cli
            { networking.hostName = hostname; }

            ./machine/${hostname}/hardware-configuration.nix
            ./machine/${hostname}/configuration.nix
            ./machine/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.dan = ./machine/${hostname}/home.nix;
              };
            }
          ];
        };
    in {
      nixosConfigurations = {
        workstation = mkNix "x86_64-linux" "workstation";
      };
    };
}

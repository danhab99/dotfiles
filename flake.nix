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
      mkNix = hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            stylix.nixosModules.stylix
            nixos-cli.nixosModules.nixos-cli
            ./machine/configuration.nix
            ./machine/${hostname}/configuration.nix
            ./machine/${hostname}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dan = {
                imports = [ ./machine/home.nix ./machine/${hostname}/home.nix ];
              };
            }
          ];
        };
    in { nixosConfigurations = { workstation = mkNix "workstation"; }; };
}

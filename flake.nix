{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cli = {
      url = "github:water-sucks/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cli, nur, ... }@inputs:
    let
      inherit (self) outputs;
      mkNix = hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
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

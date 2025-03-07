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

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cli, nur, stylix, ... }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake
      systems = [ "x86_64-linux" "aarch64-linux" ];
      # Helper function to generate a set of attributes for each system
      forAllSystems = nixpkgs.lib.genAttrs systems;
      # Helper function to create default pkgs instance for each system
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
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
    in {
      nixosConfigurations = {
        workstation = mkNix "workstation";
      };
      
      # Standalone home-manager configuration
      homeConfigurations = {
        "dan" = forAllSystems (system:
          home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsFor system;
            extraSpecialArgs = {
              inherit inputs outputs;
            };
            modules = [
              ./machine/home.nix
              ./machine/workstation/home.nix  # You might want to make this more generic
              # stylix.homeManagerModules.stylix
            ];
          });
      };
    };
}

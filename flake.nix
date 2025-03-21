{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs2.url = "github:nixos/nixpkgs/e6cea36f83499eb4e9cd184c8a8e823296b50ad5";

    nixos-cli = {
      url = "github:water-sucks/nixos";
      inputs.nixpkgs.follows = "nixpkgs2";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, nixos-cli, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkNix = hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            nixos-cli.nixosModules.nixos-cli
            (import ./machine/machine.nix { inherit hostName; })
            ./machine/${hostName}/configuration.nix
            ./machine/${hostName}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        workstation = mkNix "workstation";
        laptop = mkNix "laptop";
      };

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShell {
          buildInputs = with (pkgsFor system); [
            git
            nixpkgs-fmt
            nil
            gnumake
          ];

          shellHook = ''
            zsh
          '';
        };
      });
    };
}

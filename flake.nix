{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs_for_xpad.url = "github:nixos/nixpkgs/910796cabe436259a29a72e8d3f5e180fc6dfacc";
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-24.05";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , home-manager
    , flake-utils
    , nixpkgs_for_xpad
    , nix-on-droid
    , ...
    }:
    let
      inherit (self) outputs;

      mkNix = hostName:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            nixpkgs_for_xpad = import nixpkgs_for_xpad { system = "x86_64-linux"; };
          } // inputs;
          modules = [
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
      nixosConfigurations =
        let
          dir = builtins.readDir ./machine;
          names = builtins.attrNames dir;
          machines = builtins.filter (f: dir.${f} == "directory") names;
          pairs = builtins.map (machineName: { name = machineName; value = mkNix machineName; }) machines;
        in
        builtins.listToAttrs pairs;

      templates = import ./templates;

      nixOnDroidConfigurations.default =
        let
          system = "aarch64-linux";
        in
        nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs = inputs // {
            nixpkgs_for_xpad = import nixpkgs_for_xpad { inherit system; };
          };

          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          modules = [
            ./nix-on-droid.nix
            ./modules/droid.nix
          ];
        };

    } // (
      flake-utils.lib.eachSystem flake-utils.lib.allSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixpkgs-fmt
            nixd
            gnumake
            containerd
            oci-cli
          ];

          shellHook = ''
            zsh
          '';
        };

      })
    );
}
